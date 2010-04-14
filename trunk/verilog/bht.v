//Problem: For those outputs that will give to ROB, they can not be given directly because their value is for next cycle. To solve this problem, those rob_xx need to be buffered in the ifid pipeline register and give to rob during the id stage.
//BHT should not output to any module rather than if(id?).

module bht(//Inputs
						clock,
						reset,
						
						if_NPC0,
						if_NPC1,//not implemented yet
									
						if_valid_cond0,
						if_valid_cond1,

						recover_cond,
						recover_bhr,//stored by ROB to use in recover_cond.
						
						rob_retire_num,//new & not implemented
						
						rob_retire_cond0,
						rob_retire_NPC0,
						rob_retire_BHR0,
						rob_actual_taken0,
						
						rob_retire_cond1,
						rob_retire_NPC1,
						rob_retire_BHR1,
						rob_actual_taken1,
						
						//Outputs
						if_branch_taken0,
						if_branch_taken1,
						id_bhr0,//these inputs are given to id rather than rob. These value would eventually be given to ROB by id.
						id_bhr1
						);
//parameters
`ifndef	NUM_BHT_PATTERN_ENTRIES
`define	NUM_BHT_PATTERN_ENTRIES	64
`endif

`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
`endif
//2bit saturated counter parameters
`ifndef ST_NOT_TAKEN
`define ST_NOT_TAKEN 2'd0
`endif

`ifndef	WK_NOT_TAKEN
`define WK_NOT_TAKEN 2'd1
`endif

`ifndef	WK_TAKEN
`define WK_TAKEN 2'd2
`endif

`ifndef	ST_TAKEN
`define ST_TAKEN 2'd3
`endif

input																	clock;
input																	reset;

input	[63:0]													if_NPC0;
input	[63:0]													if_NPC1;

input																	if_valid_cond0;
input																	if_valid_cond1;

input																	recover_cond;// when this is high, there is an exception.
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	recover_bhr;
input	[1:0]														rob_retire_num;// new & not implemented

input																	rob_retire_cond0;
input	[63:0]													rob_retire_NPC0;
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_retire_BHR0;
input																	rob_actual_taken0;

input																	rob_retire_cond1;
input	[63:0]													rob_retire_NPC1;
input	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_retire_BHR1;
input																	rob_actual_taken1;

output																if_branch_taken0;
output																if_branch_taken1;
output	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr0;
output	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr1;

reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	BHR;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	next_BHR;
reg	[1:0]																pattern				[`NUM_BHT_PATTERN_ENTRIES-1:0];
reg	[1:0]																next_pattern	[`NUM_BHT_PATTERN_ENTRIES-1:0];

reg																			taken0;
reg																			taken1;

reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr0;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr1;

reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	inter_BHR;
//used only when both are predictions and taken0 is 0.

wire																		if_branch_taken0;
wire																		if_branch_taken1;

integer i;

//output	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	BHR;

assign if_branch_taken0 = taken0;
assign if_branch_taken1 = taken1;

always @* begin
//default
	next_BHR = BHR;
	inter_BHR = BHR;
	taken0 = 1'b0;
	taken1 = 1'b0;
	id_bhr0 = BHR;
	id_bhr1 = BHR;
	for (i=0; i<`NUM_BHT_PATTERN_ENTRIES; i=i+1) begin
		next_pattern[i] = pattern[i];
	end

//if not during recovery, which means normal.
	if(~recover_cond) begin
	//if only if_valid_cond0
		if (rob_retire_num[1] & ~rob_retire_num[0]) begin//rob_retire_num == 2
			if (if_valid_cond0 && ~if_valid_cond1) begin
				taken0 = next_pattern[if_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^BHR][1];
				next_BHR = {BHR[4:0], taken0};
				id_bhr0 = BHR;
				id_bhr1 = next_BHR;
			end
		//if only if_valid_cond1
			else if (~if_valid_cond0 && if_valid_cond1) begin
				taken1 = next_pattern[if_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^BHR][1];
				next_BHR = {BHR[4:0], taken1};
				id_bhr0 = BHR;
				id_bhr1 = BHR;
			end
		//if both if_valid_cond0 and if_valid_cond1
			else if (if_valid_cond0 && if_valid_cond1) begin
				taken0 = next_pattern[if_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^BHR][1];
				if (taken0) begin
					next_BHR = {BHR[4:0], 1'b1};
					id_bhr0 = BHR;
					id_bhr1 = next_BHR;
				end
				else begin
					inter_BHR = {BHR[4:0], 1'b0};
					taken1 = next_pattern[if_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^inter_BHR][1];
					next_BHR = {inter_BHR[4:0], taken1};
					id_bhr0 = BHR;
					id_bhr1 = inter_BHR;
				end
			end
		end
		else if (~rob_retire_num[1] & rob_retire_num[0]) begin//rob_retire_num == 1
			if (if_valid_cond0) begin
				taken0 = next_pattern[if_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^BHR][1];
				next_BHR = {BHR[4:0], taken0};
				id_bhr0 = BHR;
				id_bhr1 = next_BHR;
			end
		end
	end

// During recovery, recover bht only. Ignore anything else.
	else
		next_BHR = recover_bhr;
		
// change pattern when recover or retire.
	if(~recover_cond) begin//if recover, then ignore retire
		// rob_0
		if(rob_retire_cond0) begin
			if (rob_actual_taken0) begin //the correct outcome is a taken
				if(~pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0][0] | 
					 ~pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0][1])
					 
					next_pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0] = pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0] + 2'b1;
			end
			else begin //the correct outcome is a not-taken
				if(pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0][0] | 
					 pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0][1])
					 
					next_pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0] = pattern[rob_retire_NPC0[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR0] - 2'b1;
			end
		end
	// rob_1
		if(rob_retire_cond1) begin
			if (rob_actual_taken1) begin //the correct outcome is a taken
				if(~pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1][0] | 
					 ~pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1][1])
					 
					next_pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1] = pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1] + 2'b1;
			end
			else begin //the correct outcome is a not-taken
				if(pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1][0] | 
					 pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1][1])
					 
					next_pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1] = pattern[rob_retire_NPC1[`LOG_NUM_BHT_PATTERN_ENTRIES+1:2]^rob_retire_BHR1] - 2'b1;
			end
		end
	end
end
//end always


always @(posedge clock) begin
	if (reset) begin
		BHR <= `SD `LOG_NUM_BHT_PATTERN_ENTRIES'b0;
		for (i=0; i<`NUM_BHT_PATTERN_ENTRIES; i=i+1) begin
			pattern[i] <= `SD	`WK_NOT_TAKEN;
		end 
	end
	else begin
		BHR <= `SD next_BHR;
		for (i=0; i<`NUM_BHT_PATTERN_ENTRIES; i=i+1) begin
			pattern[i] <= `SD next_pattern[i];
		end
	end
end

genvar IDX;
generate
	for(IDX=0; IDX<`NUM_BHT_PATTERN_ENTRIES; IDX=IDX+1)
	begin : foo
		wire	[1:0]	PATTERN = pattern[IDX];
		wire	[1:0]	NEXT_PATTERN = next_pattern[IDX];
	end
endgenerate

endmodule
