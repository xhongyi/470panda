/////////////////////////////////////////////////////////////////////////
//   EECS470 Project Team Panda                                        //
//                                                                     //
//  ROB Testcases									                   									 //
/////////////////////////////////////////////////////////////////////////

module testbench;
`ifndef	LOG_NUM_BHT_PATTERN_ENTRIES
`define	LOG_NUM_BHT_PATTERN_ENTRIES 6
`endif
  // Registers and wires used in the testbench
reg																			clock;
reg																			reset;

reg	[63:0]															if_pc;
reg	[63:0]															if_pc_plus_four;

reg																			if_valid_cond0;
reg																			if_valid_cond1;

reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_exception_BHR;
reg																			rob_exception;

reg																			rob_retire_cond0;
reg	[63:0]															rob_retire_pc0;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_retire_BHR0;
reg																			rob_actual_taken0;

reg																			rob_retire_cond1;
reg	[63:0]															rob_retire_pc1;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	rob_retire_BHR1;
reg																			rob_actual_taken1;

wire																			if_branch_taken0;
wire																			if_branch_taken1;
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	if_BHR_out0;
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	if_BHR_out1;

reg																				cre_if_branch_taken0;//the predictied npc
reg																				cre_if_branch_taken1;
reg		[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	cre_if_BHR_out0;
reg		[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	cre_if_BHR_out1;

reg		[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	real_BHR;

wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	BHR;
reg		[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	cre_BHR;

bht	bht0	(//Inputs
						clock,
						reset,
						
						if_pc,
						if_pc_plus_four,//not implemented yet
									
						if_valid_cond0,
						if_valid_cond1,

						rob_exception_BHR,//stored by ROB to use in recovery.
						rob_exception,
						
						rob_retire_cond0,
						rob_retire_pc0,
						rob_retire_BHR0,
						rob_actual_taken0,
						
						rob_retire_cond1,
						rob_retire_pc1,
						rob_retire_BHR1,
						rob_actual_taken1,
						
						//Outputs
						if_branch_taken0,
						if_branch_taken1,
						if_BHR_out0,//these inputs are given to if rather than rob. These value would eventually be given to ROB by id.
						if_BHR_out1,
						BHR
						);
	
// Compare the results with the correct ones
always @(posedge clock)
begin
	#7;
	if ((if_branch_taken0 != cre_if_branch_taken0) || (if_BHR_out0 != cre_if_BHR_out0)) begin
		$display("*** incorrect ***\n if_branch_taken0: %d\t cre_if_branch_taken0: %d\n if_BHR_out0: %d\t cre_if_BHR_out0: %d\n", if_branch_taken0, cre_if_branch_taken0, if_BHR_out0, cre_if_BHR_out0);
		$display("*** incorrect at time: %d ***", $time);
		$finish;
	end
	else if ((if_branch_taken1 != cre_if_branch_taken1) || (if_BHR_out1 != cre_if_BHR_out1)) begin
		$display("*** incorrect ***\n if_branch_taken1: %d\t cre_if_branch_taken1: %d\n if_BHR_out1: %d\t cre_if_BHR_out1: %d\n", if_branch_taken1, cre_if_branch_taken1, if_BHR_out1, cre_if_BHR_out1);
		$display("*** incorrect at time: %d ***", $time);
		$finish;
	end
	else if (BHR != cre_BHR) begin
		$display("*** incorrect ***\n BHR: %d\t creBHR: %d\n", BHR, cre_BHR);
		$display("*** incorrect at time: %d ***", $time);
		$finish;
	end
end
// Generate System Clock
always
begin
  #5;
  clock = ~clock;
end

initial begin

  //$vcdpluson;
  $monitor("Time:%4.0f \n if_branch_taken0: %d\t if_BHR_out0: %d\n if_branch_taken1: %d\t if_BHR_out1: %d\n BHR: %d\n", $time, if_branch_taken0, if_BHR_out0, if_branch_taken1, if_BHR_out1, BHR);
  
	clock = 0;
	reset = 1;

	if_pc = 0;
	if_pc_plus_four = 0;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 0;
	rob_exception = 0;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 0;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 0;
	cre_if_BHR_out1 = 0;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	reset = 0;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 0;

	if_valid_cond0 = 1;
	if_valid_cond1 = 0;

	rob_exception_BHR = 0;
	rob_exception = 0;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 0;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 0;
	cre_if_BHR_out1 = 0;
	
	cre_BHR = 6'b000000;
	real_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 0;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 0;
	rob_exception = 0;

	rob_retire_cond0 = 1;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 6'b000000;
	rob_actual_taken0 = 1;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 0;
	cre_if_BHR_out1 = 0;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 1;
	if_valid_cond1 = 0;

	rob_exception_BHR = 0;
	rob_exception = 0;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 0;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 1;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 6'b000000;
	cre_if_BHR_out1 = 6'b000001;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 6'b000000;
	rob_exception = 1;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 0;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 6'b000000;
	cre_if_BHR_out1 = 6'b000000;
	
	cre_BHR = 6'b000001;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 6'b000000;
	rob_exception = 0;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 0;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 6'b000000;
	cre_if_BHR_out1 = 6'b000000;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 6'b000000;
	rob_exception = 0;

	rob_retire_cond0 = 1;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 6'b000000;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 6'b000000;
	cre_if_BHR_out1 = 6'b000000;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 6'b000000;
	rob_exception = 0;

	rob_retire_cond0 = 1;
	rob_retire_pc0 = 4;
	rob_retire_BHR0 = 6'b000000;
	rob_actual_taken0 = 1;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 6'b000000;
	cre_if_BHR_out1 = 6'b000000;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 1;
	if_valid_cond1 = 1;

	rob_exception_BHR = 6'b000000;
	rob_exception = 0;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 6'b000000;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 1;
	cre_if_BHR_out0 = 6'b000000;
	cre_if_BHR_out1 = 6'b000000;
	
	cre_BHR = 6'b000000;
@(negedge clock);
	if_pc = 0;
	if_pc_plus_four = 4;

	if_valid_cond0 = 0;
	if_valid_cond1 = 0;

	rob_exception_BHR = 6'b000000;
	rob_exception = 0;

	rob_retire_cond0 = 0;
	rob_retire_pc0 = 0;
	rob_retire_BHR0 = 6'b000000;
	rob_actual_taken0 = 0;

	rob_retire_cond1 = 0;
	rob_retire_pc1 = 0;
	rob_retire_BHR1 = 0;
	rob_actual_taken1 = 0;

	cre_if_branch_taken0 = 0;//the predictied npc
	cre_if_branch_taken1 = 0;
	cre_if_BHR_out0 = 6'b000001;
	cre_if_BHR_out1 = 6'b000001;
	
	cre_BHR = 6'b000001;
@(negedge clock);
$finish;
end

endmodule


