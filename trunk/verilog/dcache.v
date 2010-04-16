// Number of cachelines. must update both on a change
`define Dcache_IDX_BITS       5      // log2(Dcache_LINES)
`define Dcache_LINES (1<<`Dcache_IDX_BITS)
`define QUEUE_SIZE 10;
module dcache(// inputs
              clock,
              reset,
              
              Dmem2proc_response,
              Dmem2proc_data,
              Dmem2proc_tag,
							rob_halt,
              proc2Dcache_addr,
              proc2Dcache_st_data,
              proc2Dcache_st_addr,
              cachemem_data,
              cachemem_valid,
							dcache_wr_dirty,
							rob_wr_mem,
							lsq_rd_mem,
							lsq_pr,
							lsq_ar,
              // outputs
              proc2Dmem_command,
              proc2Dmem_addr,
              proc2Dmem_data,
							lsq_load_avail,
              Dcache_data_out,
              Dcache_valid_out,   
							cdb_load_en,
							cdb_pr,
							cdb_ar,
							dcache_wr_data,
              dcache_rd_idx,
              dcache_rd_tag,
              dcache_wr_idx1,
              dcache_wr_tag1,
							dcache_wr_idx0,
							dcache_wr_tag0,
              dcache_wr_en1,
							dcache_wr_en0
             );

  input         clock;
  input         reset;
  input   [3:0] Dmem2proc_response;//number called
  input  [63:0] Dmem2proc_data;
  input   [3:0] Dmem2proc_tag;//get number
  input  				rob_halt;

  input  [63:0] proc2Dcache_addr;//addr on ld/st
  input  [63:0] proc2Dcache_st_data;
  input  [63:0] proc2Dcache_st_addr;
  input  [63:0] cachemem_data;//data from cache
  input         cachemem_valid;//if the data is valid
  input					rob_wr_mem;//lsq signal of store
  input					lsq_rd_mem;//lsq signal of read
	input					dcache_wr_dirty;//read the dirty bit of the 
	input   [6:0] lsq_pr;
	input   [4:0] lsq_ar;
  output  [1:0] proc2Dmem_command;//store? load? none?
  output [63:0] proc2Dmem_addr;//addr to dmem
  output [63:0] proc2Dmem_data;
  output				lsq_load_avail;
  output [63:0] Dcache_data_out;     // value is memory[proc2Dcache_addr]
  output        Dcache_valid_out;    // when this is high
  output 				cdb_load_en;
	output	[6:0] cdb_pr;
	output  [4:0] cdb_ar;
  output  [6:0] dcache_rd_idx;
  output [21:0] dcache_rd_tag;
  output  [6:0] dcache_wr_idx1;
  output [21:0] dcache_wr_tag1;
	output  [6:0] dcache_wr_idx0;
  output [21:0] dcache_wr_tag0;
  output        dcache_wr_en1;
	output        dcache_wr_en0;
	output [63:0] dcache_wr_data;

	integer i, j;

  wire  [6:0] dcache_rd_idx;
  wire [21:0] dcache_rd_tag;

  
  
  //Command Queue
  
  reg  [63:0] waiting_addr			[63:0];
  reg  [1:0]  waiting_cmd				[63:0];
  reg  [63:0] waiting_data			[63:0];
	reg  [6:0]  waiting_pr 				[63:0];
	reg  [4:0]  waiting_ar 				[63:0];
	reg  [63:0] next_waiting_addr	[63:0];
	reg  [1:0]  next_waiting_cmd	[63:0];
	reg  [63:0] next_waiting_data	[63:0];
	reg  [6:0]  next_waiting_pr	 	[63:0];
	reg  [4:0]  next_waiting_ar 	[63:0];
	// Head and tail
	
  reg  [5:0] head;
  reg  [5:0] tail;
	
  reg [5:0] next_head;
  reg [5:0] next_tail;
	
	reg  [6:0] dcache_wr_idx0;
  reg [21:0] dcache_wr_tag0;
	reg  [6:0] dcache_wr_idx1;
  reg [21:0] dcache_wr_tag1;
  
  //Response Queue
  reg   [6:0] index				[15:0];
  reg  [21:0] tag					[15:0];
	reg   [6:0] pr					[15:0];
	reg   [4:0] ar					[15:0];
  reg	 [15:0] occupied;
  reg   [6:0] next_index 	[15:0];
	reg	 [21:0] next_tag	 	[15:0];
	reg   [6:0] next_pr     [15:0];
	reg   [4:0] next_ar     [15:0];
	reg  [15:0] next_occupied;
	
	reg   [6:0] cdb_pr;
	reg   [4:0] cdb_ar;

 
  reg [1:0] 	proc2Dmem_command;
  reg [63:0]	proc2Dmem_data;
  reg [63:0]	proc2Dmem_addr;
	reg cdb_load_en;
	reg dcache_wr_en1;
	//reg dcache_wr_en0;
	
  wire [5:0] tail_plus_one = (tail == 6'd63) ? 0 : tail + 1;
  wire [5:0] head_plus_one = (head == 6'd63) ? 0 : head + 1;


	//Internal combinational logic
  wire [63:0] Dcache_data_out = cachemem_data;
  wire Dcache_hit = (lsq_rd_mem | rob_wr_mem) & cachemem_valid; 
	wire Dcache_miss = (lsq_rd_mem | rob_wr_mem) & !cachemem_valid;
	wire Dcache_miss_solved = (Dmem2proc_tag != 0); 
	//Output combinational logic
  assign lsq_load_avail = (~rob_wr_mem);
  assign Dcache_valid_out = cachemem_valid;
  assign dcache_wr_en0 = Dcache_miss_solved;
  assign {dcache_rd_tag, dcache_rd_idx} = waiting_addr[head][31:3];  
  assign dcache_wr_data = proc2Dcache_st_data;
  
  
	always @*
	begin
	  for(i = 0; i< 64; i=i+1)
		begin
			next_waiting_addr[i] 	= waiting_addr[i];
			next_waiting_cmd[i] 	= waiting_cmd[i];
			next_waiting_data[i]  = waiting_data[i];
			next_waiting_pr [i] 	= waiting_pr [i];
			next_waiting_ar [i] 	= waiting_ar [i];
		end
		for (i = 0; i < 16; i = i + 1)
		begin
			next_occupied[i] 	= occupied[i];
			next_index[i] 		= index[i];
			next_tag[i] 			= tag[i];
		end
		next_head = head;
		next_tail = tail;
		cdb_load_en = 0;
		dcache_wr_en1 = 0;
		if(Dcache_hit)
		$display("Dcache hit");
		begin//if it is a hit, then initiate data updating
			proc2Dmem_command = `BUS_NONE;
			if(lsq_rd_mem & lsq_load_avail)//if it is a load, then data will be directed to cdb
			begin
				cdb_load_en = ~rob_wr_mem;
	      cdb_pr		  = lsq_pr;
				cdb_ar			= lsq_ar;
			end
			else if (rob_wr_mem)//if it is a store, then set the dirty bits and store data
			begin
			  dcache_wr_en1  = 1;
			  {dcache_wr_tag1, dcache_wr_idx1} = proc2Dcache_st_addr[31:3];			
			end
		end//if dcache hit
		if(Dcache_miss_solved)
		$display("Cache miss solved");
    begin//if the miss is solved, then initiate data updating in the second communication channel
			//dcache_wr_en0  = 1;
			dcache_wr_idx0 = index[Dmem2proc_tag];
			dcache_wr_tag0 = tag[Dmem2proc_tag];
			//cdb_pr				 = pr [Dmem2proc_tag];
			//cdb_ar				 = ar [Dmem2proc_tag];
			next_occupied[Dmem2proc_tag]  = 0;
			
			//Data is just the data from Dmem;
		end
			
		if(Dcache_miss)
		begin//If there is a cache miss, update tail
			next_tail = tail_plus_one;
			next_waiting_addr[tail] = rob_wr_mem? proc2Dcache_st_addr : proc2Dcache_addr;
			next_waiting_cmd[tail] =  rob_wr_mem? 2 : lsq_rd_mem ? 1 : 0;//`BUS_STORE = 2, `BUS_LOAD = 1
			next_waiting_data[tail] = proc2Dcache_st_data;
			next_waiting_pr [tail] = lsq_pr;
			next_waiting_ar [tail] = lsq_ar;
			proc2Dmem_command = waiting_cmd[head];
			proc2Dmem_addr    = waiting_addr[head];
			proc2Dmem_data    = waiting_data[head];
		end
		if(Dmem2proc_response != 0&&!occupied[Dmem2proc_response])
		begin//If there is a response, put the reading information into the waiting bench
			next_index[Dmem2proc_response] = dcache_rd_idx;
			next_tag  [Dmem2proc_response] = dcache_rd_tag;
			next_pr   [Dmem2proc_response] = waiting_pr [head];
			next_ar   [Dmem2proc_response] = waiting_ar [head];
			next_occupied[Dmem2proc_response] = 1;
			next_head = head_plus_one;
		end


 end
 
 
 
 
  always @(posedge clock)
  begin
    if(reset)
    begin
     
      for(j = 0; j<16; j = j + 1)
      begin
      	index[j] 			<= `SD -1;
      	tag[j] 				<= `SD -1;
				occupied [j] 	<= `SD 0;
				pr[j]					<= `SD 0;
				ar[j]					<= `SD 0;
      end
			head <= `SD 0;
			tail <= `SD 0;
			for (j = 0; j < 64; j = j + 1)
			begin
				waiting_addr[j] 	<= `SD -1;
				waiting_cmd[j] 		<= `SD -1;
				waiting_data[j] 	<= `SD 0;
				waiting_pr[j]  		<= `SD 0;
				waiting_ar[j]	 		<= `SD 0;
    end
		
	end
    else
    begin
    	 for(j = 0; j<16; j = j + 1)
      begin
      	index[j] 			<= `SD next_index[j];
      	tag[j] 				<= `SD next_tag[j];
				pr[j] 				<= `SD next_pr[j];
				ar[j]					<= `SD next_ar[j];
				occupied [j]  <= `SD next_occupied[j];
      end
			head 						<= `SD next_head;
			tail 						<= `SD next_tail;
			for (j = 0; j < 64; j = j + 1)
			begin
				waiting_addr[j] <= `SD next_waiting_addr[j];
				waiting_cmd[j] 	<= `SD next_waiting_cmd[j];
				waiting_data[j] <= `SD next_waiting_data[j];
				waiting_pr[j]  	<= `SD next_waiting_pr[j];
				waiting_ar[j]  	<= `SD next_waiting_ar[j];
      end
			
    end
  end

endmodule

