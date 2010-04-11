// Number of cachelines. must update both on a change
`define Dcache_IDX_BITS       5      // log2(Dcache_LINES)
`define Dcache_LINES (1<<`Dcache_IDX_BITS)
`define QUEUE_SIZE 10;
module Dcache(// inputs
              clock,
              reset,
              
              Dmem2proc_response,
              Dmem2proc_data,
              Dmem2proc_tag,

              proc2Dcache_addr,
              cachemem_data,
              cachemem_valid,
							dcache_wr_dirty,
							lsq_wr_mem,
							lsq_rd_mem,
              // outputs
              proc2Dmem_command,
              proc2Dmem_addr,

              Dcache_data_out,
              Dcache_valid_out,   
							cdb_load_en,
              dcache_rd_idx,
              dcache_rd_tag,
              dcache_wr_idx,
              dcache_wr_tag,
              data_write_enable
             );

  input         clock;
  input         reset;
  input   [3:0] Dmem2proc_response;//number called
  input  [63:0] Dmem2proc_data;
  input   [3:0] Dmem2proc_tag;//get number

  input  [63:0] proc2Dcache_addr;//addr on ld/st
  input  [63:0] cachemem_data;//data from cache
  input         cachemem_valid;//if the data is valid
  input					lsq_wr_mem;//lsq signal of store
  input					lsq_rd_mem;//lsq signal of read
	input					dcache_wr_dirty;//read the dirty bit of the 
  output  [1:0] proc2Dmem_command;//store? load? none?
  output [63:0] proc2Dmem_addr;//addr to dmem

  output [63:0] Dcache_data_out;     // value is memory[proc2Dcache_addr]
  output        Dcache_valid_out;    // when this is high
  output 				cdb_load_en;
  output  [6:0] dcache_rd_idx;
  output [21:0] dcache_rd_tag;
  output  [6:0] dcache_wr_idx;
  output [21:0] dcache_wr_tag;
  output        data_write_enable;

	integer i, j;

  wire  [6:0] dcache_rd_idx;
  wire [21:0] dcache_rd_tag;

  assign {dcache_rd_tag, dcache_rd_idx} = proc2Dcache_addr[31:3];
  
  reg  [21:0] waiting_tag[63:0];
	reg  [5:0]  waiting_idx[63:0];
	reg  [21:0] next_waiting_tag[63:0];
	reg  [5:0]  next_waiting_idx;
	
  reg  [5:0] head;
  reg  [5:0] tail;
	
  reg [5:0] next_head;
  reg [5:0] next_tail;
	
	reg  [6:0] dcache_wr_idx;
  reg [21:0] dcache_wr_tag;
  reg   [6:0] index[15:0];
  reg  [21:0] tag[15:0];
  reg	 [15:0] occupied;
  reg   [6:0] next_index [15:0];
	reg	 [21:0] next_tag	 [15:0];
	reg  [15:0] next_occupied;
 
  reg miss_outstanding;
  
	reg cdb_load_en;
	reg data_write_enable;
	
  wire tail_plus_one = (tail == 63) ? 0 : tail + 1;
  wire head_plus_one = (head == 63) ? 0 : head + 1;

  //wire send_request = miss_outstanding;

  wire [63:0] Dcache_data_out = cachemem_data;
  wire Dcache_miss_solved = (Dmem2proc_tag != 0);
  wire Dcache_hit = (lsq_rd_mem | lsq_wr_mem) & cachemem_valid; 
	wire Dcache_miss = (lsq_rd_mem | lsq_wr_mem) & !cachemem_valid; 
  wire unanswered_miss = miss_outstanding & (Dmem2proc_response==0);
  assign proc2Dmem_addr = proc2Dcache_addr;//Add evict address
  assign proc2Dmem_command = lsq_wr_mem | dcache_wr_dirty ? `BUS_STORE:
    lsq_rd_mem | (miss_outstanding) ? `BUS_LOAD : `BUS_NONE;//Add evict command
 
	always @*
	begin
	  for(i = 0; i< 64; i=i+1)
		begin
			next_waiting_tag[i] = waiting_tag[i];
			next_waiting_idx[i] = waiting_idx[i];
		end
		next_head = head;
		next_tail =  tail;
		if(Dcache_hit | Dcache_miss_solved)
		begin//if it is a hit, then initiate data updating
			if(lsq_rd_mem)//if it is a load, then data will be directed to cdb
				cdb_load_en = 1;
			else if (lsq_wr_mem)//if it is a store, then set the dirty bits and store data
			  data_write_enable = 1;
		end//if dcache hit
				
		if(Dcache_miss)
		begin//If there is a cache miss, update tail
			next_tail = tail_plus_one;
			next_waiting_idx[tail] = dcache_rd_idx;
			next_waiting_tag[tail] = dcache_rd_tag;
		end
		if(Dmem2proc_response != 0&&!occupied[Dmem2proc_response])
		begin//If there is a response, put the reading information into the waiting bench
			next_index[Dmem2proc_response] = next_waiting_idx[head];
			next_tag[Dmem2proc_response]   = next_waiting_tag[head];
			next_occupied[Dmem2proc_response] = 1;
			next_head = head_plus_one;
		end
		if(Dmem2proc_tag != 0)//Dcache_miss_solved
		begin//if the tag is returned, do the cache reading and eviction process
			occupied[Dmem2proc_tag] = 0;
			dcache_wr_idx = index[Dmem2proc_tag];
			dcache_wr_tag = tag[Dmem2proc_tag];
			data_write_enable = ~dcache_wr_dirty;
		end

 end
 
 
 
 
  always @(posedge clock)
  begin
    if(reset)
    begin
     
      for(j = 0; j<16; j = j + 1)
      begin
      	index[j] <=`SD -1;
      	tag[j] <= `SD -1;
				occupied [j] <= `SD 0;
      end
			head <= `SD 0;
			tail <= `SD 0;
			for (j = 0; j < 64; j = j + 1)
			begin
				waiting_tag[j] <= `SD -1;
				waiting_idx[j] <= `SD -1;
    end
		miss_outstanding <=`SD 0;
	end
    else
    begin
    	 for(j = 0; j<16; j = j + 1)
      begin
      	index[j] <=`SD next_index[j];
      	tag[j] <= `SD next_tag[j];
				occupied [j] <= `SD next_occupied;
      end
			head <= `SD next_head;
			tail <= `SD next_tail;
			for (j = 0; j < 64; j = j + 1)
			begin
				waiting_tag[j] <= `SD next_waiting_tag[j];
				waiting_idx[j] <= `SD next_waiting_idx[j];
      end
			miss_outstanding <= `SD unanswered_miss;
    end
  end

endmodule

