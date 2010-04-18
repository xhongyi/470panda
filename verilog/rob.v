//`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
//`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
//`endif
//`define ROB_WIDTH 64
//`define ROB_BITS	6
//`define CDB_WIDTH 6
//////////////////////////////////////////////////////////
// EECS470 Project Team Panda							//
// Re-order Buffer										//
// Min Clock Cycle: 3.2ns								//
//////////////////////////////////////////////////////////


//Additional Inputs: id_ar_idxs, exceptions, actual_taken, actual_branch_addrs
//Additional Outputs: mt_retire_ars, lsq_mt_fl_bht_recover_retire_num to map table, exception, if_cre_pcs, fl_exception_pr_idxs

module rob(//inputs
						reset,
						clock,
						//dispatch
						id_dispatch_num,

						fl_pr0,
						fl_pr1,
						mt_p0told,
						mt_p1told,
						id_NPC0,//new
						id_NPC1,//new
						id_IR0,
						id_IR1,
						id_dest_idx0,//new
						id_dest_idx1,//new
						id_valid_inst0,
						id_valid_inst1,
						id_cond_branch0,//new
						id_cond_branch1,//new
						id_uncond_branch0,//new
						id_uncond_branch1,//new
						id_halt0,
						id_halt1,
						id_bhr0,//new
						id_bhr1,//new
						id_wr_mem0,//new!!
						id_wr_mem1,//new!!
						//complete
						cdb_pr_ready,
						cdb_pr_tag_0,
						cdb_pr_tag_1,
						cdb_pr_tag_2,
						cdb_pr_tag_3,
						cdb_pr_tag_4,
						cdb_pr_tag_5,
						cdb_exception0,
						cdb_exception1,
						cdb_exception2,
						cdb_exception3,
						cdb_exception4,
						cdb_exception5,

						cdb_actual_addr0,//new
						cdb_actual_taken0,//new
						cdb_actual_addr1,//new
						cdb_actual_taken1,//new
						//outputs
						//dispatch
						id_cap,
						//retire
						mt_retire_ar_a,//new
						mt_retire_ar_b,//new
						mt_retire_taga,
						mt_retire_tagb,
						fl_retire_tolda,
						fl_retire_toldb,
						
						lsq_mt_fl_bht_recover_retire_num,//modified!!
						
						bht_recover_cond_branch0,//new
						bht_recover_retire_bhr0,//new
						bht_recover_NPC0,//new
						bht_actual_taken0,//new
						recover_uncond_branch0,//new
						recover_actual_addr0,//new

						bht_recover_cond_branch1,//new
						bht_recover_retire_bhr1,//new
						bht_recover_NPC1,//new
						bht_actual_taken1,//new
						recover_uncond_branch1,//new
						recover_actual_addr1,//new
						
						lsq_retire_wr_mem0,//new!!
						lsq_retire_wr_mem1,//new!!

						rob_retire_IR0,
						rob_retire_IR1,
						

						recover_exception,//new
						retire_halt //new it is true when halt inst is retired
					);

`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
`endif
`define ROB_WIDTH 64
`define ROB_BITS	6

input														reset;
input														clock;

input	[6:0]											fl_pr0;
input	[6:0]											fl_pr1;
input	[6:0]											mt_p0told;
input	[6:0]											mt_p1told;
input	[63:0]										id_NPC0;
input	[63:0]										id_NPC1;
input	[31:0]										id_IR0;
input	[31:0]										id_IR1;
input	[4:0]											id_dest_idx0;//new
input	[4:0]											id_dest_idx1;//new
input	[1:0]											id_dispatch_num;
input														id_valid_inst0;
input														id_valid_inst1;
input														id_cond_branch0;
input														id_cond_branch1;
input														id_uncond_branch0;
input														id_uncond_branch1;
input														id_halt0;
input														id_halt1;
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr0;
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr1;

input														id_wr_mem0;//new!!
input														id_wr_mem1;//new!!


input	[5:0]											cdb_pr_ready;	//Note:	the	bandwidth	is	CDB_WIDTH;
input	[6:0]											cdb_pr_tag_0;
input	[6:0]											cdb_pr_tag_1;
input	[6:0]											cdb_pr_tag_2;
input	[6:0]											cdb_pr_tag_3;	
input	[6:0]											cdb_pr_tag_4;
input	[6:0]											cdb_pr_tag_5; //Note: the bandwidth is CDB_WIDTH;
input														cdb_exception0;
input														cdb_exception1;
input														cdb_exception2;
input														cdb_exception3;
input														cdb_exception4;
input														cdb_exception5;

input	[63:0]										cdb_actual_addr0;//new
input														cdb_actual_taken0;//new

input	[63:0]										cdb_actual_addr1;//new
input														cdb_actual_taken1;//new

output	[1:0]										id_cap;

output	[4:0]										mt_retire_ar_a;
output	[4:0]										mt_retire_ar_b;
output	[6:0]										mt_retire_taga;
output	[6:0]										mt_retire_tagb;
output	[6:0]										fl_retire_tolda;
output	[6:0]										fl_retire_toldb;
output	[1:0]										lsq_mt_fl_bht_recover_retire_num;

output													bht_recover_cond_branch0;
output	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_recover_retire_bhr0;
output	[63:0]									bht_recover_NPC0;
output													bht_actual_taken0;
output													recover_uncond_branch0;
output	[63:0]									recover_actual_addr0;

output													bht_recover_cond_branch1;
output	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_recover_retire_bhr1;
output	[63:0]									bht_recover_NPC1;
output													bht_actual_taken1;
output	[63:0]									recover_actual_addr1;
output													recover_uncond_branch1;

output													lsq_retire_wr_mem0;//new!!
output													lsq_retire_wr_mem1;//new!!

output	[31:0]									rob_retire_IR0;
output	[31:0]									rob_retire_IR1;

output													recover_exception;//new
output													retire_halt;


wire	[1:0]										id_cap;

wire	[4:0]										mt_retire_ar_a;
wire	[4:0]										mt_retire_ar_b;
wire	[6:0]										mt_retire_taga;
wire	[6:0]										mt_retire_tagb;
wire	[6:0]										fl_retire_tolda;
wire	[6:0]										fl_retire_toldb;

wire													bht_recover_cond_branch0;
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_recover_retire_bhr0;
wire	[63:0]									bht_recover_NPC0;
wire													bht_actual_taken0;
wire													recover_uncond_branch0;
wire	[63:0]									recover_actual_addr0;

wire													bht_recover_cond_branch1;
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_recover_retire_bhr1;
wire	[63:0]									bht_recover_NPC1;
wire													bht_actual_taken1;
wire	[63:0]									recover_actual_addr1;
wire													recover_uncond_branch1;

wire													lsq_retire_wr_mem0;
wire													lsq_retire_wr_mem1;

wire													recover_exception;
// parameter-use-wire
wire	[`ROB_BITS-1:0]	head_plus_one;
wire	[`ROB_BITS-1:0]	tail_plus_one;
wire	[`ROB_BITS-1:0]	tail_plus_two;
wire	[`ROB_BITS-1:0]	head_plus_two;

	//Internal	State
reg	[`ROB_BITS-1:0]		head; //head position, anywhere between 0 and `ROB_WIDTH-1.
reg	[`ROB_BITS-1:0]		tail; //tail position, anywhere between 0 and `ROB_WIDTH-1.

reg	[`ROB_WIDTH-1:0]	ready;
reg	[`ROB_WIDTH-1:0]	exception;
reg	[`ROB_WIDTH-1:0]	cond_branch;
reg	[`ROB_WIDTH-1:0]	uncond_branch;
reg	[`ROB_WIDTH-1:0]	wr_mem;
reg	[`ROB_WIDTH-1:0]	actual_taken;
reg	[63:0]						NPC					[`ROB_WIDTH-1:0];  //64 tags, 64 bits each.
reg	[63:0]						actual_addr	[`ROB_WIDTH-1:0];  //64 tags, 64 bits each.
reg	[4:0]							ar					[`ROB_WIDTH-1:0];
reg	[6:0]							tag					[`ROB_WIDTH-1:0];  //64 tags, 7 bits each.
reg	[6:0]							told				[`ROB_WIDTH-1:0];  //64 old tags, 7 bits each.
reg	[`ROB_WIDTH-1:0]	halt;
reg	[`ROB_WIDTH-1:0]	valid;
reg	[31:0]						ir					[`ROB_WIDTH-1:0];
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bhr	[`ROB_WIDTH-1:0];
//reg inputs

reg	retire_halt;
reg	[1:0]	lsq_mt_fl_bht_recover_retire_num;

//Update State
reg	[`ROB_BITS-1:0]		next_head; //head position, anywhere between 0 and `ROB_WIDTH-1.
reg	[`ROB_BITS-1:0]		next_tail; //tail position, anywhere between 0 and `ROB_WIDTH-1.

reg	[`ROB_WIDTH-1:0]	next_ready;
reg	[`ROB_WIDTH-1:0]	next_exception;
reg	[`ROB_WIDTH-1:0]	next_cond_branch;
reg	[`ROB_WIDTH-1:0]	next_uncond_branch;
reg	[`ROB_WIDTH-1:0]	next_wr_mem;
reg	[`ROB_WIDTH-1:0]	next_actual_taken;
reg	[63:0]						next_NPC					[`ROB_WIDTH-1:0];  //64 tags, 64 bits each.
reg	[63:0]						next_actual_addr	[`ROB_WIDTH-1:0];  //64 tags, 64 bits each.
reg	[4:0]							next_ar						[`ROB_WIDTH-1:0];
reg	[6:0]							next_tag					[`ROB_WIDTH-1:0];  //64 tags, 7 bits each.
reg	[6:0]							next_told					[`ROB_WIDTH-1:0];  //64 old tags, 7 bits each.
reg	[`ROB_WIDTH-1:0]	next_halt;
reg	[`ROB_WIDTH-1:0]	next_valid;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	next_bhr	[`ROB_WIDTH-1:0];

integer	i;

assign	full = ((tail == head) && (valid[head] != 1'd0));
assign	almost_full = ((tail==`ROB_WIDTH-1 && head==0)|(head==tail+`ROB_BITS'b1));

assign	head_plus_one = (head ==`ROB_WIDTH-1) ? `ROB_BITS'b0 : head + `ROB_BITS'd1;
assign	tail_plus_one = (tail == `ROB_WIDTH-1)? `ROB_BITS'b0 : tail + `ROB_BITS'd1;
assign	head_plus_two = (head == `ROB_WIDTH-2)? `ROB_BITS'b0 :
																															(head == `ROB_WIDTH-1)? `ROB_BITS'b1 : head + `ROB_BITS'd2;
assign	tail_plus_two = (tail == `ROB_WIDTH-2)? `ROB_BITS'b0 :
																															(tail == `ROB_WIDTH-1)? `ROB_BITS'b1 : tail + `ROB_BITS'd2;
																															
assign  id_cap = full? 2'd0 : almost_full? 2'd1 :2'd2;

assign	mt_retire_ar_a = ar[head];
assign	mt_retire_ar_b = ar[head_plus_one];
assign	mt_retire_taga = tag[head];
assign	mt_retire_tagb = tag[head_plus_one];
assign	fl_retire_tolda = told[head];
assign	fl_retire_toldb = told[head_plus_one];

assign	bht_recover_cond_branch0 = cond_branch[head];
assign	bht_recover_retire_bhr0 = bhr[head];
assign	bht_recover_NPC0 = NPC[head];
assign	bht_actual_taken0 = actual_taken[head];
assign	recover_uncond_branch0 = uncond_branch[head];
assign	recover_actual_addr0 = actual_addr[head];
assign	lsq_retire_wr_mem0 = wr_mem[head];//new!!

assign	bht_recover_cond_branch1 = cond_branch[head_plus_one];
assign	bht_recover_retire_bhr1 = bhr[head_plus_one];
assign	bht_recover_NPC1 = NPC[head_plus_one];
assign	bht_actual_taken1 = actual_taken[head_plus_one];
assign	recover_actual_addr1 = actual_addr[head_plus_one];
assign	recover_uncond_branch1 = uncond_branch[head_plus_one];
assign	lsq_retire_wr_mem1 = wr_mem[head_plus_one];//new!!

assign	recover_exception = (lsq_mt_fl_bht_recover_retire_num[0] & exception[head]) | (lsq_mt_fl_bht_recover_retire_num[1] & exception[head_plus_one]);

assign rob_retire_IR0 = ir[head];
assign rob_retire_IR1 = ir[head+1];

always @*
begin
//Default:
	lsq_mt_fl_bht_recover_retire_num 	= 2'd0;
	retire_halt										= 1'd0;
	next_head = head;
	next_tail = tail;
	for (i = 0; i < `ROB_WIDTH; i = i + 1)
	begin
		next_ready[i]					= ready[i];
		next_exception[i]			= exception[i];
		next_cond_branch[i]		= cond_branch[i];
		next_uncond_branch[i]	= uncond_branch[i];
		next_actual_taken[i]	= actual_taken[i];
		next_wr_mem[i]				=	wr_mem[i];//new!!
		next_NPC[i]						= NPC[i];  //64 tags, 64 bits each.
		next_actual_addr[i]		= actual_addr[i]; //64 tags, 64 bits each.
		next_ar[i]						= ar[i];
		next_tag[i]						= tag[i];  //64 tags, 7 bits each.
		next_told[i]					= told[i]; //64 old tags, 7 bits each.
		next_halt[i]					= halt[i];
		next_valid[i]					= valid[i];
		next_bhr[i]						= bhr[i];
	end
	
	//Start of dispatch	
	//checklist:
	//check rs_avail:
	//update tag with fl , told with mt at tail
 

	case (id_dispatch_num) 
		2'b00:
		begin
 			next_tail = tail;
		end
		2'b01:
		begin
			next_tag[tail]						= fl_pr0;
			next_told[tail]						= mt_p0told;
			next_ar[tail]							= id_dest_idx0;
			next_ready[tail]					= ~id_valid_inst0; 
			next_halt[tail]						= id_halt0;
			next_valid[tail]					= 1'd1;
			next_bhr[tail]						= id_bhr0;
			next_NPC[tail]						= id_NPC0;
			next_cond_branch[tail]		= id_cond_branch0;
			next_uncond_branch[tail]	= id_uncond_branch0;
			next_wr_mem[tail]					= id_wr_mem0;//new!!
			//id_cap = 2'b1;
			next_tail = tail_plus_one;
		end
		2'b10,2'b11:
		begin
			next_NPC[tail] 						= id_NPC0;
			next_bhr[tail]						= id_bhr0;
			next_tag[tail]						= fl_pr0;
			next_told[tail]						= mt_p0told;
			next_ar[tail]							= id_dest_idx0;
			next_halt[tail]						= id_halt0;
			next_ready[tail]					= ~id_valid_inst0;
			next_valid[tail]					= 1'd1;
			next_cond_branch[tail]		= id_cond_branch0;
			next_uncond_branch[tail]	= id_uncond_branch0;
			next_wr_mem[tail]					= id_wr_mem0;//new!!
			next_NPC[tail_plus_one]					= id_NPC1;
			next_bhr[tail_plus_one]					= id_bhr1;
			next_tag[tail_plus_one]					= fl_pr1;
			next_told[tail_plus_one]				= mt_p1told;
			next_ar[tail_plus_one]					= id_dest_idx1;
			next_halt[tail_plus_one]				= id_halt1;
			next_ready[tail_plus_one]				= ~id_valid_inst1;
			next_valid[tail_plus_one] 			= 1'd1;
			next_cond_branch[tail_plus_one]	= id_cond_branch1;
			next_uncond_branch[tail_plus_one]	= id_uncond_branch1;
			next_wr_mem[tail_plus_one]			= id_wr_mem1;//new!!
		  //id_cap = 2'b10;
			next_tail = tail_plus_two;
		end
	endcase
	
	//end of dispatch

	//complete
	//checklist:
	//check each bit of cdb_pr_ready
	//if any bit of cdb_pr_ready == 1, search the hold file for ready bit.
	if(cdb_pr_ready[0] ==1)
	begin			
		for (i = 0; i < `ROB_WIDTH; i = i + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_0 == tag[i] & valid[i]) begin
				next_ready[i]					= 1'b1;
				next_exception[i]			= cdb_exception0;
				next_actual_addr[i]		= cdb_actual_addr0;
				next_actual_taken[i]	= cdb_actual_taken0;
			end
		end
	end
	
	if(cdb_pr_ready[1] ==1)
	begin
		for (i = 0; i < `ROB_WIDTH; i = i + 1)
		begin 				//Note: the two tags COULD be the same
			if(cdb_pr_tag_1 == tag[i] & valid[i]) begin
				next_ready[i]					= 1'b1;
				next_exception[i]			= cdb_exception1;
				next_actual_addr[i]		= cdb_actual_addr1;
				next_actual_taken[i]	= cdb_actual_taken1;
			end
		end
	end
	
	if(cdb_pr_ready[2] ==1)
	begin	
		for (i = 0; i < `ROB_WIDTH; i = i + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_2 == tag[i] & valid[i]) begin
				next_ready[i]					= 1'b1;
				next_exception[i]			= cdb_exception2;
				next_actual_addr[i]		= 1'b0;
				next_actual_taken[i]	= 1'b0;
			end
		end				
	end
	
	if(cdb_pr_ready[3] ==1)
	begin	
		for (i = 0; i < `ROB_WIDTH; i = i + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_3 == tag[i] & valid[i]) begin
				next_ready[i]					= 1'b1;
				next_exception[i]			= cdb_exception3;
				next_actual_addr[i]		= 1'b0;
				next_actual_taken[i]	= 1'b0;
			end
		end				
	end

	if(cdb_pr_ready[4] ==1)
	begin				
		for (i = 0; i < `ROB_WIDTH; i = i + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_4 == tag[i] & valid[i]) begin
				next_ready[i]					= 1'b1;
				next_exception[i]			= cdb_exception4;
				next_actual_addr[i]		= 1'b0;
				next_actual_taken[i]	= 1'b0;
			end
		end				
	end
	
	if(cdb_pr_ready[5] ==1)
	begin
		for (i = 0; i < `ROB_WIDTH; i = i + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_5 == tag[i] & valid[i]) begin
				next_ready[i]					= 1'b1;
				next_exception[i]			= cdb_exception5;
				next_actual_addr[i]		= 1'b0;
				next_actual_taken[i]	= 1'b0;
			end
		end	
	end
	//end of complete

	//retire
	//Note: default case here is we retire two command, this may be incorrect.
	//checklist:
	//check  if tail and tail_plus_one are ready
	//if ready, put the tag to retire
	//if retire is tail, output
  if (ready[head] & ready[head_plus_one] & ~exception[head] & ~(wr_mem[head] & wr_mem[head_plus_one])) begin//two
		next_head											= head_plus_two;
		next_ready[head]							= 1'b0;
		next_ready[head_plus_one]			= 1'b0;
		lsq_mt_fl_bht_recover_retire_num	= 2'd2;
		retire_halt										= halt[head] | halt[head_plus_one];
		next_valid[head]							= 1'd0;
		next_valid[head_plus_one]			= 1'd0;
		next_tag[head]								= 7'd127;
		next_tag[head]								= 7'd127;
	end
	else if (ready[head] & (~ready[head_plus_one] | exception[head] | (wr_mem[head] & wr_mem[head_plus_one]))) begin//one
		next_head											= head_plus_one;
		next_ready[head]							= 1'b0;
		lsq_mt_fl_bht_recover_retire_num 	= 2'd1;
		retire_halt										= halt[head];
		next_valid[head]							= 1'd0;
		next_tag[head]								= 7'd127;
	end
end // end of combinational logic

always @(posedge clock)
begin //of sequential logic
	if(reset) begin
		for (i = 0; i < `ROB_WIDTH; i = i + 1) begin
			ready[i]					<= `SD 1'd0;
			exception[i]			<= `SD 1'd0;
			cond_branch[i]		<= `SD 1'd0;
			uncond_branch[i]	<= `SD 1'd0;
			actual_taken[i]		<= `SD 1'd0;
			NPC[i]						<= `SD 63'd0;  //64 tags, 64 bits each.
			actual_addr[i]		<= `SD 63'd0; //64 tags, 64 bits each.
			ar[i]							<= `SD 5'd0;
			tag[i]						<= `SD 7'd127;  //64 tags, 7 bits each.
			told[i]						<= `SD 7'd127; //64 old tags, 7 bits each.
			halt[i]						<= `SD 1'd0;
			valid[i]					<= `SD 1'd0;
			bhr[i]						<= `SD 6'd0;
			wr_mem[i]					<= `SD 1'd0;//new!!
			ir[i]								<= `SD 32'b0;
		end
		head <= `SD 1'd0;
		tail <= `SD 1'd0;
		//initialization
	end
	else begin
		for (i = 0; i < `ROB_WIDTH; i = i + 1) begin
			exception[i]			<= `SD next_exception[i];
			cond_branch[i]		<= `SD next_cond_branch[i];
			uncond_branch[i]	<= `SD next_uncond_branch[i];
			actual_taken[i]		<= `SD next_actual_taken[i];
			NPC[i]						<= `SD next_NPC[i];  //64 tags, 64 bits each.
			actual_addr[i]		<= `SD next_actual_addr[i]; //64 tags, 64 bits each.
			ar[i]							<= `SD next_ar[i];
			tag[i]						<= `SD next_tag[i];  //64 tags, 7 bits each.
			told[i]						<= `SD next_told[i]; //64 old tags, 7 bits each.
			halt[i]						<= `SD next_halt[i];
			valid[i]					<= `SD next_valid[i];
			bhr[i]						<= `SD next_bhr[i];
			wr_mem[i]					<= `SD next_wr_mem[i];
			if (next_halt[i])
				ready[i] <= `SD 1;
			else
				ready[i] <= `SD next_ready[i];
		end
		head <= `SD next_head;
		tail <= `SD next_tail;
		if (id_dispatch_num[0] | id_dispatch_num[1])
			ir[tail]			<= `SD id_IR0;
		if (id_dispatch_num[1])
			ir[tail+1]		<= `SD id_IR1;
	end
end//of sequential logic

genvar IDX;
generate
	for(IDX=0; IDX<`ROB_WIDTH; IDX=IDX+1)
	begin : robfoo
wire										READY = ready[IDX];
wire										EXCEPTION = exception[IDX];
wire										COND_BRANCH = cond_branch[IDX];
wire										UNCOND_BRANCH = uncond_branch[IDX];
wire										ACTUAL_TAKEN = actual_taken[IDX];
wire	[63:0]						FOO_NPC = NPC[IDX];  //64 tags, 64 bits each.
wire	[63:0]						ACTUAL_ADDR = actual_addr[IDX];  //64 tags, 64 bits each.
wire	[4:0]							AR = ar[IDX];
wire	[6:0]							TAG = tag[IDX];  //64 tags, 7 bits each.
wire	[6:0]							TOLD = told[IDX];  //64 old tags, 7 bits each.
wire										HALT = halt[IDX];
wire										VALID = valid[IDX];
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	BHR = bhr[IDX];
	end
wire special0 = (cdb_pr_tag_0 == tag[0]);
wire special1 = (cdb_pr_tag_1 == tag[1]);
endgenerate

endmodule
	
	
