`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
`endif
`define ROB_WIDTH 64
`define ROB_BITS	6
//`define CDB_WIDTH 6
//////////////////////////////////////////////////////////
// EECS470 Project Team Panda							//
// Re-order Buffer										//
// Min Clock Cycle: 3.2ns								//
//////////////////////////////////////////////////////////


//Additional Inputs: id_ar_idxs, exceptions, actual_taken, actual_branch_addrs
//Additional Outputs: mt_retire_ars, fl_retire_num to map table, exception, if_cre_pcs, fl_exception_pr_idxs
module rob(//inputs
			reset,
			clock,
			//dispatch
			fl_pr0,
			fl_pr1,
			mt_p0told,
			mt_p1told,
			id_dest_idx0,
			id_dest_idx1,
			id_dispatch_num,
			id_valid_inst0,
			id_valid_inst1,
			id_halt0,
			id_halt1,
			id_bhr0,
			id_bhr1,
			//complete
			cdb_pr_ready,
			cdb_pr_tag_0,
			cdb_pr_tag_1,
			cdb_pr_tag_2,
			cdb_pr_tag_3,
			cdb_pr_tag_4,
			cdb_pr_tag_5,
			cdb_exception,
			//retire
			cdb_PC0,
			cdb_actual_addr0,
			cdb_actual_taken0,
			cdb_cond_branch0,
			cdb_uncond_branch0,

			cdb_PC1,
			cdb_actual_addr1,
			cdb_actual_taken1,
			cdb_cond_branch1,
			cdb_uncond_branch1,
			//outputs
			//dispatch
			id_cap,
			//retire
			fl_retire_tag_a,
			fl_retire_tag_b,
			mt_retire_ar_a,
			mt_retire_ar_b,
			fl_retire_num,
			fl_exception_ar,
			fl_exception_pr,
			bht_exception_bhr,
			btb_bht_PC0,
			btb_actual_addr0,
			bht_actual_taken0,
			bht_cond_branch0,
			btb_uncond_branch0,
			
			btb_bht_PC1,
			btb_actual_addr1,
			bht_actual_taken1,
			bht_cond_branch1,
			btb_uncond_branch1,
			bht_bhr_out0,
			bht_bhr_out1,
			btb_retire_jump0,
			btb_retire_jump1,
			retire_exception,
			retire_halt //new it is true when halt inst is retired

);
input reset;
input clock;

input [6:0] fl_pr0;
input [6:0] fl_pr1;
input [6:0] mt_p0told;
input [6:0] mt_p1told;
input [4:0] id_dest_idx0;
input [4:0] id_dest_idx1;
input  id_valid_inst0;
input  id_valid_inst1;
input [1:0] id_dispatch_num;
input [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] id_bhr0;
input [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] id_bhr1;
input [`CDB_WIDTH-1:0] cdb_pr_ready; //Note: the bandwidth is CDB_WIDTH;
input [6:0] cdb_pr_tag_0;
input [6:0] cdb_pr_tag_1;
input [6:0] cdb_pr_tag_2;
input [6:0] cdb_pr_tag_3; 
input [6:0] cdb_pr_tag_4;
input [6:0] cdb_pr_tag_5; //Note: the bandwidth is CDB_WIDTH;

input [63:0]cdb_PC0;
input [63:0]cdb_actual_addr0;
input 			cdb_actual_taken0;
input				cdb_cond_branch0;
input				cdb_uncond_branch0;

input [63:0] cdb_PC1;
input [63:0] cdb_actual_addr1;
input				 cdb_actual_taken1;
input				 cdb_cond_branch1;
input				 cdb_uncond_branch1;

input [`CDB_WIDTH-1:0]  cdb_exception;

input id_halt0;
input	id_halt1;

output [1:0] id_cap;

output [6:0] fl_retire_tag_a;
output [6:0] fl_retire_tag_b;
output [4:0] mt_retire_ar_a;
output [4:0] mt_retire_ar_b;
output [4:0] fl_exception_ar;
output [6:0] fl_exception_pr;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_exception_bhr;
output [63:0] btb_bht_PC0;
output [63:0] btb_actual_addr0;
output  bht_actual_taken0;
output  bht_cond_branch0;
output  btb_uncond_branch0;

output [63:0] btb_bht_PC1;
output [63:0] btb_actual_addr1;
output  bht_actual_taken1;
output  bht_cond_branch1;
output  btb_uncond_branch1;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr_out0;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr_out1;
output retire_exception;
output btb_retire_jump0;
output btb_retire_jump1;
output [1:0] fl_retire_num;
output retire_halt; 


reg [1:0] fl_retire_num;
reg [6:0] fl_retire_tag_a;
reg [6:0] fl_retire_tag_b;
reg [4:0] mt_retire_ar_a;
reg [4:0] mt_retire_ar_b;
reg [1:0] id_cap; 
reg retire_exception;
reg [4:0] fl_exception_ar;
reg [6:0] fl_exception_pr;
reg [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr_out0;
reg [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr_out1;
reg [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_exception_bhr;
 //wires
wire [`ROB_BITS-1:0] head_plus_one;
wire [`ROB_BITS-1:0] tail_plus_one;
wire [`ROB_BITS-1:0] tail_plus_two;
wire [63:0] previous_pc;

 //Internal State
reg [`ROB_WIDTH-1:0] ready;
reg [`ROB_WIDTH-1:0] exception;
reg [4:0] ar	 [`ROB_WIDTH-1:0];
reg [6:0] tag  [`ROB_WIDTH-1:0];  //64 tags, 7 bits each.
reg [6:0] told [`ROB_WIDTH-1:0];  //64 old tags, 7 bits each.
reg [`ROB_BITS-1:0] head ; //head position, anywhere between 0 and `ROB_WIDTH-1.
reg [`ROB_BITS-1:0] tail ; //tail position, anywhere between 0 and `ROB_WIDTH-1.
reg [`ROB_WIDTH-1:0] halt;
reg [`ROB_WIDTH-1:0] valid;
reg [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bhr [`ROB_WIDTH-1:0];
//reg inputs

reg retire_halt;

//Update State
reg [`ROB_WIDTH-1:0] next_ready;
reg [`ROB_WIDTH-1:0] next_exception;
reg [4:0] next_ar   [`ROB_WIDTH-1:0];
reg [6:0] next_tag  [`ROB_WIDTH-1:0];
reg [6:0] next_told [`ROB_WIDTH-1:0];
reg [`ROB_BITS-1:0] next_head;
reg [`ROB_BITS-1:0] next_tail;
reg [`ROB_WIDTH-1:0] next_halt;
reg [`ROB_WIDTH-1:0] next_valid;
reg [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] next_bhr [`ROB_WIDTH-1:0];

integer index, jindex, kindex;

assign full = ((tail == head) && (valid[head] != 1'd0));
assign almost_full = ((tail==`ROB_WIDTH-1 && head==0)|(head==tail+`ROB_BITS'b1));

assign  head_plus_one = (head==`ROB_WIDTH-1) ? `ROB_BITS'b0 : head + `ROB_BITS'b1;
assign  tail_plus_one = (tail == `ROB_WIDTH-1)? `ROB_BITS'b0 : tail + `ROB_BITS'b1;
assign 	btb_bht_PC0 = cdb_PC0;
assign  btb_actual_addr0 = cdb_actual_addr0;
assign	bht_actual_taken0 = cdb_actual_taken0;
assign  bht_cond_branch0 = cdb_cond_branch0;
assign  btb_uncond_branch0 = cdb_uncond_branch0;
assign 	btb_bht_PC1 = cdb_PC1;
assign  btb_actual_addr1 = cdb_actual_addr1;
assign	bht_actual_taken1 = cdb_actual_taken1;
assign  bht_cond_branch1 = cdb_cond_branch1;
assign  btb_uncond_branch1 = cdb_uncond_branch1;



always @*
begin
//Load Internal State
for (kindex = 0; kindex < `ROB_WIDTH; kindex = kindex + 1)
begin
	next_tag[kindex] = tag[kindex];
	next_told[kindex] = told[kindex];
	next_ready[kindex] = ready[kindex];
	next_halt[kindex] = halt [kindex];
	next_valid[kindex] = valid[kindex];
	next_bhr[kindex] = bhr[kindex];
end


    
	//Start of dispatch	
	//checklist:
	//check rs_avail:
	//update tag with fl , told with mt at tail
  
  id_cap = full? 2'd0 : almost_full? 2'd1 :2'd2;
	case (id_dispatch_num) 
		2'b00:
		begin
		
			//id_cap = 2'b0;
 			next_tail = tail;
		end
		2'b01:
		begin
			
			next_tag[tail] = fl_pr0;
			next_told[tail] = mt_p0told;
			next_ar[tail] = id_dest_idx0;
			next_ready[tail] = ~id_valid_inst0; 
			next_halt[tail] = id_halt0;
			next_valid[tail] = 1'd1;
			next_bhr[tail] = id_bhr0;
			//id_cap = 2'b1;
			next_tail = tail_plus_one;
		end
		2'b10,2'b11:
		begin
			next_bhr[tail] = id_bhr0;
			next_tag[tail] = fl_pr0;
			next_told[tail] = mt_p0told;
			next_ar[tail] = id_dest_idx0;
			next_halt[tail] = id_halt0;
			next_bhr[tail_plus_one] = id_bhr1;
			next_tag[tail_plus_one] = fl_pr1;
			next_told[tail_plus_one] = mt_p1told;
			next_ar[tail_plus_one] = id_dest_idx1;
			next_halt[tail_plus_one] = id_halt1;
			next_ready[tail] = ~id_valid_inst0;
			next_ready[tail_plus_one] = ~id_valid_inst1;
			next_valid[tail] = 1'd1;
			next_valid[tail_plus_one] = 1'd1;
		  //id_cap = 2'b10;
			next_tail = tail_plus_two;
		end
	endcase
	
	//end of dispatch

	//complete
	//checklist:
	//check each bit of cdb_pr_ready
	//if any bit of cdb_pr_ready == 1, search the hold file for ready bit.
	if(cdb_pr_ready[0] ==1 )
	begin			
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_0 == tag[index]) next_ready[index] = 1'b1;
		end
	end
	
	if(cdb_pr_ready[1] ==1 )
	begin
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin 				//Note: the two tags COULD be the same
			if(cdb_pr_tag_1 == tag[index]) next_ready[index] = 1'b1;
		end
	end
	
	if(cdb_pr_ready[2] ==1 )
	begin	
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_2 == tag[index]) next_ready[index] = 1'b1;
		end				
	end
	
	if(cdb_pr_ready[3] ==1 )
	begin	
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_3 == tag[index]) next_ready[index] = 1'b1;
		end				
	end

	if(cdb_pr_ready[4] ==1 )
	begin				
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_4 == tag[index]) next_ready[index] = 1'b1;
		end				
	end
	
	if(cdb_pr_ready[5] ==1 )
	begin
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_5 == tag[index]) next_ready[index] = 1'b1;
		end	
	end	
	if(cdb_exception[0] ==1 )
	begin			
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_0 == tag[index]) next_exception[index] = 1'b1;
		end
	end
	
	if(cdb_exception[1] ==1 )
	begin
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin 				//Note: the two tags COULD be the same
			if(cdb_pr_tag_1 == tag[index]) next_exception[index] = 1'b1;
		end
	end
	
	if(cdb_exception[2] ==1 )
	begin	
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_2 == tag[index]) next_exception[index] = 1'b1;
		end				
	end
	
	if(cdb_exception[3] ==1 )
	begin	
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_3 == tag[index]) next_exception[index] = 1'b1;
		end				
	end

	if(cdb_exception[4] ==1 )
	begin				
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_4 == tag[index]) next_exception[index] = 1'b1;
		end				
	end
	
	if(cdb_exception[5] ==1 )
	begin
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_5 == tag[index]) next_exception[index] = 1'b1;
		end	
	end	
	//end of complete

	//retire
	//Note: default case here is we retire two command, this may be incorrect.
	//checklist:
	//check  if tail and tail_plus_one are ready
	//if ready, put the tag to retire
	//if retire is tail, output
	if (exception[head])
	begin
		retire_exception = 1;
		next_tail = head;
		fl_exception_ar = ar[head];
		fl_exception_pr = tag[head];
		bht_exception_bhr = bhr[head];
	end
	else if (exception[head_plus_one])
	begin
		retire_exception = 1;
		next_tail = head_plus_one;
		fl_exception_ar = ar[head_plus_one];
		fl_exception_pr = tag[head_plus_one];
		bht_exception_bhr = bhr[head_plus_one];
	end 
  if (ready[head] == 1 && ready[head_plus_one] ==1)
	begin
		next_head =  head + 2;
		next_ready[head] = 0;
		next_ready[head_plus_one] = 0;
		fl_retire_tag_a = tag[head];
		fl_retire_tag_b = tag[head_plus_one];
		bht_bhr_out0 = bhr[head];
		bht_bhr_out1 = bhr[head_plus_one];
		mt_retire_ar_a = ar[head];
		mt_retire_ar_b = ar[head_plus_one];
		fl_retire_num = 2'b10;
		retire_halt = halt[head] | halt[head_plus_one];
		next_valid[head] = 1'd0;
		next_valid[head_plus_one] = 1'd0;
		
	end
	else if (ready[head] == 1)
	begin
		next_head = head + 1;
		next_ready[head] = 0;
		fl_retire_tag_a	= tag[head];
		fl_retire_tag_b = 7'h7f;
		mt_retire_ar_a = ar[head];
		mt_retire_ar_b = 5'h1f;
		bht_bhr_out0 = bhr[head];
		bht_bhr_out1 = 6'h3f;
		fl_retire_num = 2'b01;
		retire_halt = halt[head];
		next_valid[head] = 1'd0;
	end
	else
	begin
		//do nothing
		next_head = head;
		fl_retire_num = 2'b00;
		fl_retire_tag_a = 7'h7f;
		fl_retire_tag_b = 7'h7f;
		mt_retire_ar_a = 5'h1f;
		mt_retire_ar_b = 5'h1f;
		retire_halt = 0;
	end
	

end // end of combinational logic

always @(posedge clock)
begin //of sequential logic
	if(reset)
	begin
		 head <= `SD 0;
		 tail <= `SD 0;
		for (index = 0; index < `ROB_WIDTH; index = index + 1)
		begin
		  ar [index] <= `SD 5'h0;
		  exception[index] <= `SD 1'h0;
			halt [index] <= `SD 1'h0;
			tag[index] <= `SD 7'h7f;
			told[index] <= `SD 7'h7f;
			ready[index] <= `SD 1'h0;
			valid[index] <= `SD 1'h0;
			bhr[index] <=`SD `LOG_NUM_BHT_PATTERN_ENTRIES'h0;
		end
		//initialization
	end
	else
	begin
			for (kindex = 0; kindex < `ROB_WIDTH; kindex = kindex + 1)
			begin
				ar [kindex] <= `SD next_ar [kindex];
				exception[kindex] <= `SD next_exception[kindex];
				halt [kindex] <= `SD next_halt[kindex];
				tag[kindex] <= `SD next_tag[kindex];
				told[kindex] <= `SD next_told[kindex];
				bhr[index] <= `SD next_bhr[index];
				if (next_halt[kindex])
					ready[kindex] <= `SD 1;
				else
					ready[kindex] <= `SD next_ready[kindex];
				valid[kindex] <= `SD next_valid[kindex];
			end
			
			head <= `SD next_head;
			tail <= `SD next_tail;
	end
end//of sequential logic

genvar IDX;
generate
	for(IDX=0; IDX<`ROB_WIDTH; IDX=IDX+1)
	begin : foo
	  wire [4:0] AR = ar[IDX];
	  wire EXCEPTION = exception[IDX];
		wire [6:0] TAG = tag[IDX];  //64 tags, 7 bits each.
		wire [6:0] TOLD = told[IDX];
		wire [6:0] NEXT_TAG = next_tag[IDX];  //64 tags, 7 bits each.
		wire [6:0] NEXT_TOLD = next_told[IDX];
	end
wire special0 = (cdb_pr_tag_0 == tag[0]);
wire special1 = (cdb_pr_tag_1 == tag[1]);
endgenerate


endmodule
	
	
