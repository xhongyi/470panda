`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
`endif

module recover(//inputs
							clock,
							reset,
							
							rob_retire_num,
							rob_exception,
							
							rob_cond_branch0,
							rob_bhr0,
							rob_NPC0,
							rob_uncond_branch0,
							rob_actual_addr0,
							
							rob_cond_branch1,
							rob_bhr1,
							rob_NPC1,
							rob_uncond_branch1,
							rob_actual_addr1,
							//outputs
							//if
							if_reset,
							if_recover,
							if_recover_addr,
							//bht
							bht_reset,
							bht_recover,
							bht_bhr,
							//btb
							btb_reset,
							btb_recover,
							btb_NPC,
							btb_actual_addr,
							//fl
							fl_reset,
							fl_recover,
							//mt
							mt_reset,
							mt_recover,
							//universal reset: id,rob,rs,alu_sim,alu_mul,cdb
							other_reset
							);
							
input																			clock;
input																			reset;
							
input	[1:0]																rob_retire_num;
input																			rob_exception;
							
input																			rob_cond_branch0;
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_bhr0;
input	[63:0]															rob_NPC0;
input																			rob_uncond_branch0;
input	[63:0]															rob_actual_addr0;
							
input																			rob_cond_branch1;
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_bhr1;
input	[63:0]															rob_NPC1;
input																			rob_uncond_branch1;
input	[63:0]															rob_actual_addr1;


output																			if_reset;
output																			if_recover;
output	[63:0]															if_recover_addr;
output																			bht_reset;
output																			bht_recover;
output	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_bhr;
output																			btb_reset;
output																			btb_recover;
output	[63:0]															btb_NPC;
output	[63:0]															btb_actual_addr;
output																			fl_reset;
output																			fl_recover;
output																			mt_reset;
output																			mt_recover;
output																			other_reset;

wire																		if_reset;
wire																		bht_reset;
wire																		btb_reset;
wire																		fl_reset;
wire																		mt_reset;
wire																		other_reset;

reg																			if_recover;
reg	[63:0]															if_recover_addr;
reg																			bht_recover;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_bhr;
reg																			btb_recover;
reg	[63:0]															btb_NPC;
reg	[63:0]															btb_actual_addr;
reg																			fl_recover;
reg																			mt_recover;
reg																			else_reset;

reg																			next_if_recover;
reg	[63:0]															next_if_recover_addr;
reg																			next_bht_recover;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	next_bht_bhr;
reg																			next_btb_recover;
reg	[63:0]															next_btb_NPC;
reg	[63:0]															next_btb_actual_addr;
reg																			next_fl_recover;
reg																			next_mt_recover;
reg																			next_else_reset;

reg																			exception;
reg																			next_exception;

assign	if_reset = (reset)? 1'd1 : 1'd0;
assign	bht_reset = (reset)? 1'd1 : 1'd0;
assign	btb_reset = (reset)? 1'd1 : 1'd0;
assign	fl_reset = (reset)? 1'd1 : 1'd0;
assign	mt_reset = (reset)? 1'd1 : 1'd0;
assign	other_reset = (reset)? 1'd1 : else_reset;

always @* begin
	next_if_recover = 1'd0;
	next_fl_recover = 1'd0;
	next_mt_recover = 1'd0;
	next_bht_recover = 1'd0;
	next_btb_recover = 1'd0;

	next_if_recover_addr = 63'd0;
	next_bht_bhr = 6'd0;
	next_btb_NPC = 63'd0;
	next_btb_actual_addr = 63'd0;
	next_else_reset = 1'd0;
	
	next_exception = 1'd0;
	
	if (~exception & rob_exception) begin//when there is no previous exception and now we encounter an exception.
		next_if_recover = 1'd1;
		next_fl_recover = 1'd1;
		next_mt_recover = 1'd1;
		next_else_reset = 1'd1;
		next_exception = 1'd1;
		if (rob_retire_num[0]) begin//the exception happened at rob0
			next_if_recover_addr = rob_actual_addr0;
			next_bht_bhr = rob_bhr0;
			next_btb_NPC = rob_NPC0;
			next_btb_actual_addr = rob_actual_addr0;
			if (rob_cond_branch0)
				next_bht_recover = 1'd1;
			else if (rob_uncond_branch0)
				next_btb_recover = 1'd1;
		end
		else if (rob_retire_num[0]) begin
			next_if_recover_addr = rob_actual_addr1;
			next_bht_bhr = rob_bhr1;
			next_btb_NPC = rob_NPC1;
			next_btb_actual_addr = rob_actual_addr1;
			if (rob_cond_branch1)
				next_bht_recover = 1'd1;
			else if (rob_uncond_branch1)
				next_btb_recover = 1'd1;
		end
	end// if there is a previous exception, then next cycle must be restored, so we ignore current exceptions.
end//end always

always @(posedge clock) begin
	if (reset) begin
		if_recover		<= `SD 1'd0;
		fl_recover		<= `SD 1'd0;
		mt_recover		<= `SD 1'd0;
		bht_recover		<= `SD 1'd0;
		btb_recover		<= `SD 1'd0;

		if_recover_addr		<= `SD 63'd0;
		bht_bhr						<= `SD 6'd0;
		btb_NPC						<= `SD 63'd0;
		btb_actual_addr		<= `SD 63'd0;
		else_reset				<= `SD 1'd0;
		exception					<= `SD 1'd0;
	end
	else begin
		if_recover		<= `SD next_if_recover;
		fl_recover		<= `SD next_fl_recover;
		mt_recover		<= `SD next_mt_recover;
		bht_recover		<= `SD next_bht_recover;
		btb_recover		<= `SD next_btb_recover;

		if_recover_addr		<= `SD next_if_recover_addr;
		bht_bhr						<= `SD next_bht_bhr;
		btb_NPC						<= `SD next_btb_NPC;
		btb_actual_addr		<= `SD next_btb_actual_addr;
		else_reset				<= `SD next_else_reset;
		
		exception					<= `SD next_exception;
	end
end//end always

endmodule
