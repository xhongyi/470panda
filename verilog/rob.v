//`timescale 1ns/100ps
//////////////////////////////////////////////////////////
// EECS470 Project Team Panda							//
// Instruction Decoder									//
// This module is fully combinational					//
//////////////////////////////////////////////////////////
module decoder( //inputs
				instr,
				//outputs
				opcode,
				dest,
				opa,
				opb,
				dest_valid,
				opa_valid,
				opb_valid,
				immr
);

input [31:0] instr;
output [5:0] opcode;
output [4:0] dest;
output [4:0] opa;
output [4:0] opb;
output		 dest_valid;
output 		 opa_valid;
output		 opb_valid;
output [20:0] immr;

reg [4:0] dest;
reg [5:0] opcode;
reg [4:0] opa;
reg [4:0] opb;
reg [20:0] immr;
reg	       dest_valid;
reg 	   opa_valid;
reg 	   opb_valid;

//assign opcode = instr [31:26];
always @*
begin
	opcode = instr [31:26];
	case (instr[31:29])  
	3'h2:
	begin
		dest = instr[4:0];
		dest_valid = 1'b1;
		opa = instr[25:21];
		opa_valid = 1;
		opb = instr[20:16];
		opb_valid = instr[12];
		immr = {13'b0,instr[20:13]};
	end
	3'h3:
	begin
		dest = instr[25:21];
		dest_valid = 1'b1;
		opa = 5'b11111;
		opa_valid = 1'h0;
		opb = instr[20:16];
		opb_valid = 1;
		immr = 21'h1ffff;
	end
	3'h1, 3'h4, 3'h5:
	begin
		dest = (instr[31:26] ==`STQ_INST)? 5'h1f : instr[25:21];
		dest_valid = (instr[31:26] ==`STQ_INST)?1'b0 : 1'b1;
		opa = (instr[31:26] ==`STQ_INST)?instr[25:21]:5'b11111;
		opa_valid = (instr[31:26] ==`STQ_INST)?1'b1:1'b0;
		opb = instr[20:16];
		opb_valid = 1'h1;
		immr = 21'h1fff;//{5'b0,instr[15:0]};
	end
	3'h6, 3'h7:
	begin
		dest = instr[25:21];
		dest_valid = 1'b1;
		opa = 5'b11111;
		opa_valid = 1'b0;
		opb = 5'b11111;
		opb_valid = 1'b0;
		immr = instr[20:0];
	end
	default:
	begin
		dest = 5'b11111;
		opa = 5'b11111;
		opb = 5'b11111;
		immr = 21'h1ffff;
		dest_valid = 1'b0;
		opa_valid = 1'b0;
		opb_valid = 1'b0;
	end
	endcase
end




endmodule


//////////////////////////////////////////////////////////
// EECS470 Project Team Panda							//
// Re-order Buffer										//
//////////////////////////////////////////////////////////



module rob(//inputs
			reset,
			clock,
			//fetch
			inst0,
			inst1,
			pc0,
			pc1,
			//dispatch
			fl_pr0,
			fl_pr1,
			rs_avail,
			mt_p0told,
			mt_p1told,
			//complete
			cdb_pr_ready,
			cdb_pr_tag_0,
			cdb_pr_tag_1,
			cdb_pr_tag_2,
			cdb_pr_tag_3,
			//outputs
			//fetch
			tail_pc,
			//dispatch
			rs_mt_ar_a,
			rs_mt_ar_b,
			mt_ar_a1,
			mt_ar_b1,
			mt_ar_a2,
			mt_ar_b2,
			rs_mt_ar_a_valid,
			rs_mt_ar_b_valid,
			mt_ar_a1_valid,
			mt_ar_a2_valid,
			mt_ar_b1_valid,
			mt_ar_b2_valid,
			rs_immediate0,
			rs_immediate1,
			rs_opcode0,
			rs_opcode1,
			//rs_inst0,
			//rs_inst1,
			rs_mt_fl_dispatch_num,
			//retire
			fl_retire_tag_a,
			fl_retire_tag_b,
			fl_retire_num



);
input reset;
input clock;

input [31:0] inst0;
input [63:0] pc0;
input [31:0] inst1;
input [63:0] pc1;

input [6:0] fl_pr0;
input [6:0] fl_pr1;
input [1:0] rs_avail;
input [6:0] mt_p0told;
input [6:0] mt_p1told;

input [3:0] cdb_pr_ready; //Note: the bandwidth is CDB_WIDTH;
input [6:0] cdb_pr_tag_0;
input [6:0] cdb_pr_tag_1;
input [6:0] cdb_pr_tag_2;
input [6:0] cdb_pr_tag_3;  //Note: the bandwidth is CDB_WIDTH;


output [63:0] tail_pc;

output [4:0] rs_mt_ar_a;
output [4:0] rs_mt_ar_b;
output [4:0] mt_ar_a1;
output [4:0] mt_ar_b1;
output [4:0] mt_ar_a2;
output [4:0] mt_ar_b2;
output		 rs_mt_ar_a_valid;
output	     rs_mt_ar_b_valid;
output 		 mt_ar_a1_valid;
output		 mt_ar_b1_valid;
output 		 mt_ar_a2_valid;
output		 mt_ar_b2_valid;
output [20:0] rs_immediate0;
output [20:0] rs_immediate1;
output [5:0]  rs_opcode0;
output [5:0]  rs_opcode1;
output [1:0] rs_mt_fl_dispatch_num;

output [6:0] fl_retire_tag_a;
output [6:0] fl_retire_tag_b;
output [1:0] fl_retire_num;
 

reg [1:0] rs_mt_fl_dispatch_num;
reg [1:0] fl_retire_num;
reg [6:0] fl_retire_tag_a;
reg [6:0] fl_retire_tag_b;
 

 //wires
wire [5:0] head_plus_one;
wire [5:0] tail_plus_one;
wire [5:0] tail_plus_two;
wire [64:0] previous_pc;
 //Internal State
reg [31:0] inst [63:0]; //64 instructions, 32 bits each.
reg [63:0] pc   [63:0]; //64 instructions, 64 bits each.
reg [63:0] ready;
reg [6:0] tag  [63:0];  //64 tags, 7 bits each.
reg [6:0] told [63:0];  //64 old tags, 7 bits each.
reg [5:0] head ; //head position, anywhere between 0 and 63.
reg [5:0] tail ; //tail position, anywhere between 0 and 63.
reg [5:0] fetch_tail;//fetch tail position, different from dispatch tail
reg [63:0] tail_pc;


reg [5:0]  rs_opcode0;
reg [5:0]  rs_opcode1;
reg [4:0]  rs_mt_ar_a;
reg [4:0]  rs_mt_ar_b;
reg [4:0]  mt_ar_a1;
reg [4:0]  mt_ar_b1;
reg [4:0]  mt_ar_a2;
reg [4:0]  mt_ar_b2;
reg		   rs_mt_ar_a_valid;
reg        rs_mt_ar_b_valid;
reg 	   mt_ar_a1_valid;
reg		   mt_ar_b1_valid;
reg		   mt_ar_a2_valid;
reg		   mt_ar_b2_valid;
reg [20:0] rs_immediate0;
reg [20:0] rs_immediate1;




wire [5:0]  next_rs_opcode0;
wire [5:0]  next_rs_opcode1;
wire [4:0]  next_rs_mt_ar_a;
wire [4:0]  next_rs_mt_ar_b;
wire [4:0]  next_mt_ar_a1;
wire [4:0]  next_mt_ar_b1;
wire [4:0]  next_mt_ar_a2;
wire [4:0]  next_mt_ar_b2;
wire		   next_rs_mt_ar_a_valid;
wire 		   next_rs_mt_ar_b_valid;
wire 	   	   next_mt_ar_a1_valid;
wire		   next_mt_ar_b1_valid;
wire		   next_mt_ar_a2_valid;
wire		   next_mt_ar_b2_valid;
wire [20:0] next_rs_immediate0;
wire [20:0] next_rs_immediate1;
reg  [1:0]  next_rs_mt_fl_dispatch_num;


//Update State
reg [31:0] next_inst [63:0];
reg [63:0] next_pc [63:0];
reg [63:0] next_ready;
reg [6:0] next_tag  [63:0];
reg [6:0] next_told [63:0];
reg [5:0] next_head;
reg [5:0] next_tail;
reg [5:0] next_fetch_tail;
reg [63:0] next_tail_pc;
decoder decoder_1 (
					
					.instr(inst0),
					.opcode(next_rs_opcode0),
					.dest(next_rs_mt_ar_a),
					.opa(next_mt_ar_a1),
					.opb(next_mt_ar_a2),
					.dest_valid(next_rs_mt_ar_a_valid),
					.opa_valid(next_mt_ar_a1_valid),
					.opb_valid(next_mt_ar_a2_valid),
					.immr(next_rs_immediate0)
				);

				
decoder decoder_2 (
					
					.instr(inst1),
					.opcode(next_rs_opcode1),
					.dest(next_rs_mt_ar_b),
					.opa(next_mt_ar_b1),
					.opb(next_mt_ar_b2),
					.dest_valid(next_rs_mt_ar_b_valid),
					.opa_valid(next_mt_ar_b1_valid),
					.opb_valid(next_mt_ar_b2_valid),
					.immr(next_rs_immediate1)
				);
					




integer index, jindex, kindex;

assign full = ((fetch_tail==6'd63 && head==6'd0)|(head==fetch_tail+6'd1));
assign almost_full = ((fetch_tail==6'd62&&head==6'd0)&&(fetch_tail==6'd63&&head==6'd1)&&(head==fetch_tail+6'd2));
assign previous_pc = pc0 - 64'h4;

assign  head_plus_one = (head==6'd63) ? 6'b0 : head + 6'b1;
assign  tail_plus_one = (tail == 6'd63)? 6'd0 : tail + 6'd1;
assign  tail_plus_two = (tail == 6'd62) ? 6'd0 :  (tail == 6'd63) ? 6'd1 : tail + 6'd2; 

always @*
begin
//Load Internal State
for (kindex = 0; kindex < 64; kindex = kindex + 1)
begin
	next_inst[kindex] = inst[kindex];
	next_pc[kindex] = pc[kindex];
	next_tag[kindex] = tag[kindex];
	next_told[kindex] = told[kindex];
	next_ready[kindex] = ready[kindex];
end
//	if (reset)
//else
    //fetch
	//checklist:
	//Tell if full or almost full
	//fill in inst and pc into internal state, if applicable
	//update fetch_tail
	if(full)
	begin//do not fetch instruction
		next_fetch_tail = fetch_tail;
		next_tail_pc = previous_pc;
	end
	else if (almost_full)
	begin
		next_tail_pc = pc0;
	    if(fetch_tail == 6'd63)
			begin
				next_inst[0] = inst0;
				next_pc[0] = pc0;
                next_fetch_tail = 0;
				
			end
		else
		begin
			next_inst[fetch_tail+6'd1] = inst0;
	    	next_pc  [fetch_tail+6'd1] = pc0;
			next_fetch_tail = fetch_tail + 6'd1;
		end
	
	end//of almost full

	else
	begin
		next_tail_pc = pc1;
		if(fetch_tail == 6'd62)
		begin
			next_inst[63] = inst0;
			next_pc  [63] = pc0;
			next_inst[0] = inst1;
			next_pc  [0] = pc1;
			next_fetch_tail = 6'd0;
		end
		else if (fetch_tail == 6'd63)
		begin
			next_inst[0] = inst0;
			next_pc  [0] = pc0;
			next_inst[1] = inst1;
			next_pc  [1] = pc1;
			next_fetch_tail = 6'd1;
		end
	 	else 
		begin
			next_inst[fetch_tail+1] = inst0;
			next_pc  [fetch_tail+1] = pc0;
			next_inst[fetch_tail+2] = inst1;
			next_pc  [fetch_tail+2] = pc1;
			next_fetch_tail = fetch_tail + 6'd2;
		
		end
	
    end //of else (far from full)
	//end of fetch
	//Start of dispatch	
	//checklist:
	//check rs_avail:
	//decoder module linking instructions to 
	case (rs_avail) 
		2'b00,2'b11:
		begin
		$display("did not dispatch");	
			next_rs_mt_fl_dispatch_num = 2'b0;
 			next_tail = tail;
		end
		2'b01:
		begin
			$display("dispatched one");
			next_tag[tail] = fl_pr0;
			next_told[tail] = mt_p0told;
			next_rs_mt_fl_dispatch_num = 2'b1;
			next_tail = (tail == 6'd63)? 6'd0 : tail + 6'b1;
		end
		2'b10:
		begin
			$display("dispatched two");
			next_tag[tail] = fl_pr0;
			if (tail == 63) next_tag[0] = fl_pr1;
			else next_tag[tail+1] = fl_pr1;
			next_told [tail] = mt_p0told;
			if (tail == 63) next_told [0] = mt_p1told;
			else next_told[tail + 1] = mt_p1told;
		    next_rs_mt_fl_dispatch_num = 2'b10;
			next_tail = (tail == 6'd62) ? 6'd0 : (tail == 6'd63) ? 6'd1 : tail + 6'd2;
		end
	endcase
	$display("head is: %h tail is %h fetch tail is: %h tag[head]: %h tag[tail]: %h ready[head]: ",head, tail, fetch_tail, tag[head], tag[tail], ready[head]);
	$display("next_head is: %h next_tail is: %h next_tag[head] is: %h, next_tag[tail] is: %h",next_head, next_tail, next_tag[head], next_tag[tail]);
	//end of dispatch
	//complete
	//checklist:
	//check each bit of cdb_pr_ready
	//if any bit of cdb_pr_ready == 1, search the hold file for ready bit.
	if(cdb_pr_ready[0] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_0 == tag[index]) next_ready[index] = 1;
		end				
	end	
	if(cdb_pr_ready[1] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_1 == tag[index]) next_ready[index] = 1;
		end				
	end	
	if(cdb_pr_ready[2] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_2 == tag[index]) next_ready[index] = 1;
		end				
	end	
	if(cdb_pr_ready[3] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_3 == tag[index]) next_ready[index] = 1;
		end				
	end	
	//end of complete
	//retire
	//Note: default case here is we retire two command, this may be incorrect.
	//checklist:
	//check  if tail and tail_plus_one are ready
	//if ready, put the tag to retire
    if (ready[head] == 1 && ready[head_plus_one] ==1)
	begin
		next_head =  head + 2;
		next_ready[head] = 0;
		next_ready[head_plus_one] = 0;
		fl_retire_tag_a = tag[head];
		fl_retire_tag_b = tag[head_plus_one];
		fl_retire_num = 2'b10;
	end
	else if (ready[head] == 1)
	begin
		next_head = head + 1;
		next_ready[head] = 0;
		fl_retire_tag_a	= tag[head];
		fl_retire_tag_b = 7'h7f;
		fl_retire_num = 2'b01;
	end
	else
	begin
		//do nothing
		next_head = head;
		fl_retire_num = 2'b00;
		fl_retire_tag_a = 7'h7f;
		fl_retire_tag_b = 7'h7f;
	end
	

end // end of combinational logic

always @(posedge clock)
begin //of sequential logic
	if(reset)
	begin
		 head <= `SD 64'h0;
		 tail <= `SD 64'h0;
		 fetch_tail <= `SD 64'h0;
		 tail_pc <= `SD 64'b0;
		 rs_mt_ar_a <= `SD 5'b0;
		 rs_mt_ar_b <= `SD 5'b0;
		 mt_ar_a1 <= `SD 5'b0;
		 mt_ar_b1 <= `SD 5'b0;
		 mt_ar_a2 <= `SD 5'b0;
		 mt_ar_b2 <= `SD 5'b0;
		 rs_mt_ar_a_valid <= `SD 1'b0;
		 rs_mt_ar_b_valid <= `SD 1'b0;
		 mt_ar_a1_valid <= `SD 1'b0;
		 mt_ar_b1_valid <= `SD 1'b0;
		 mt_ar_a2_valid <= `SD 1'b0;
		 mt_ar_b2_valid <= `SD 1'b0;
		 rs_opcode0 <= `SD 6'b0;
		 rs_opcode1 <= `SD 6'b0;
		 rs_immediate0 <= `SD 21'b0;
		 rs_immediate1 <= `SD 21'b0;
		 rs_mt_fl_dispatch_num <= `SD 2'b0;
		 
		for (index = 0; index < 64; index = index + 1)
		begin
			inst[index] <= `SD 32'h0;
			pc[index] <= `SD 64'h0;
			tag[index] <= `SD 7'h0;
			told[index] <= `SD 7'h0;
			ready[index] <= `SD 1'h0;
		end
		//initialization
	end
	else
	begin
			for (kindex = 0; kindex < 64; kindex = kindex + 1)
			begin
				inst[kindex] <= `SD next_inst[kindex];
				pc[kindex] <= `SD next_pc[kindex];
				tag[kindex] <= `SD next_tag[kindex];
				told[kindex] <= `SD next_told[kindex];
				ready[kindex] <= `SD next_ready[kindex];
			end
			tail_pc <= `SD next_tail_pc;
			fetch_tail <= `SD next_fetch_tail;
			head <= `SD next_head;
			tail <= `SD next_tail;
			rs_mt_ar_a <= `SD next_rs_mt_ar_a;
		 	rs_mt_ar_b <= `SD next_rs_mt_ar_b;
		 	mt_ar_a1 <= `SD next_mt_ar_a1;
		 	mt_ar_b1 <= `SD next_mt_ar_b1;
		 	mt_ar_a2 <= `SD next_mt_ar_a2;
		 	mt_ar_b2 <= `SD next_mt_ar_b2;
			 rs_mt_ar_a_valid <= `SD next_rs_mt_ar_a_valid;
			 rs_mt_ar_b_valid <= `SD next_rs_mt_ar_b_valid;
			 mt_ar_a1_valid <= `SD next_mt_ar_a1_valid;
			 mt_ar_b1_valid <= `SD next_mt_ar_b1_valid;
			 mt_ar_a2_valid <= `SD next_mt_ar_a2_valid;
			 mt_ar_b2_valid <= `SD next_mt_ar_b2_valid;
			 rs_immediate0 <= `SD next_rs_immediate0;
			 rs_immediate1 <= `SD next_rs_immediate1;
			 rs_opcode0 <= `SD next_rs_opcode0;
			 rs_opcode1 <= `SD next_rs_opcode1;
			 rs_mt_fl_dispatch_num <= `SD next_rs_mt_fl_dispatch_num;
		
	end
end//of sequential logic

endmodule
	
	