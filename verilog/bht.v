module bht(//Inputs
						clock,
						reset,
						
						if_pc,
						if_valid_inst0,
						if_valid_inst1,
						if_IR0,
						if_IR1,
						
						rob_mis_pred,
						rob_mis_pred_pc,
						rob_BHR,//stored by ROB to use in recovery.
						rob_correct_taken,
						
						//Outputs
						if_branch_taken0,
						if_branch_taken1
						)
//parameters
`ifndef	NUM_BHT_PATTERN_ENTRIES
`define	NUM_BHT_PATTERN_ENTRIES	64
`endif

`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
`endif
//2bit saturated counter parameters
`define ST_NOT_TAKEN 2'd0
`define WK_NOT_TAKEN 2'd1
`endif
`define WK_TAKEN 2'd2
`define ST_TAKEN 2'd3
`endif

input																	clock;
input																	reset;

input	[63:0]													if_pc;
input	[63:0]													if_valid_inst0;
input	[63:0]													if_valid_inst1;
input	[63:0]													if_IR0;
input	[63:0]													if_IR1;

input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_BHR;
input																			rob_correct_taken;

input																	rob_retire_br0;
input	[63:0]													rob_retire_br_pc0;
input																	rob_cre_taken0;
input																	rob_retire_br1;
input	[63:0]													rob_retire_br_pc1;
input																	rob_cre_taken1;

output																if_branch_taken0;
output																if_branch_taken1;

reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	BHR;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	next_BHR;
reg	[1:0]															pattern				[`NUM_BHT_PATTERN_ENTRIES-1:0];
reg	[1:0]															next_pattern	[`NUM_BHT_PATTERN_ENTRIES-1:0];

reg																		taken0;
reg																		taken1;
integer i;

wire																	if_branch_taken0;
wire																	if_branch_taken1;

wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	inter_BHR;
wire	[63:0]															if_pc_plus_four;

assign if_pc_plus_four = if_pc + 3'd4;

assign inter_BHR = {BHR[4:0], 1'b0};//used only when both are predictions and taken0 is 0.

assign if_branch_taken0 = taken0;
assign if_branch_taken1 = taken1;
assign is_branch0 = (if_valid_inst0 & ((if_IR0[31:29] == 3'd6) | (if_IR0[31:29] == 3'd7)) & (if_IR0 != `BR_INST) & (if_IR0 != `BSR_INST))? 1'd1 : 1'd0;//Is conditional branch
assign is_branch1 = (if_valid_inst1 & ((if_IR1[31:29] == 3'd6) | (if_IR1[31:29] == 3'd7)) & (if_IR1 != `BR_INST) & (if_IR1 != `BSR_INST))? 1'd1 : 1'd0;

always @* begin
//default
	next_BHR = BHR;
	inter_BHR = BHR;
	for (i=0; i<`NUM_BHT_PATTERN_ENTRIES; i=i+1) begin
		next_pattern[i] = pattern[i];
	end

//if only is_branch0	
	if (is_branch0 && ~is_branch1) begin
		taken0 = pattern[if_pc[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1];
		next_BHR = {BHR[4:0], taken0};

	end
//if only is_branch1
	if (~is_branch0 && is_branch1) begin
		taken1 = pattern[if_pc_plus_four[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1];
		next_BHR = {BHR[4:0], taken1};
	end
//if both is_branch0 and is_branch1
	if (is_branch0 && is_branch1) begin
		taken0 = pattern[if_pc[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1];
		if (taken0) begin
			next_BHR = {BHR[4:0], 1'b1};
		end
		else begin
			inter_BHR = {inter_BHR[4:0], 1'b0}
			taken1 = pattern[if_pc_plus_four[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1];
			next_BHR = {inter_BHR[4:0], taken1};
		end
	end

// change pattern when retire.
// rob_0
	if(rob_retire_br0) begin
		if (rob_cre_taken0) begin //more taken
			if(~pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][0] | 
				 ~pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1])
				 
				next_pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] = pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] + 2'b1;
		end
		else begin
			if(pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][0] | 
				 pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1])
				 
				next_pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] = pattern[rob_retire_br_pc0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] - 2'b1;
		end
	end
// rob_1
	if(rob_retire_br1) begin
		if (rob_cre_taken1) begin //more taken
			if(~pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][0] | 
				 ~pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1])
				 
				next_pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] = pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] + 2'b1;
		end
		else begin
			if(pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][0] | 
				 pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR][1])
				 
				next_pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] = pattern[rob_retire_br_pc1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:1]^BHR] - 2'b1;
		end
	end

end
//end always


always @(posedge clock) begin
	if (reset) begin
		BHR <= LOG_NUM_BHT_PATTERN_ENTRIES'b0;
		for (i=0; i<`NUM_BHT_PATTERN_ENTRIES; i=i+1) begin
			pattern[i] <=	WK_NOT_TAKEN;
		end 
	end
	else begin
		BHR <= next_bht;
		for (i=0; i<`NUM_BHT_PATTERN_ENTRIES; i=i+1) begin
			pattern <= next_pattern;
		end
	end
end
