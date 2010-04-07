/////////////////////////////////////////////////////////////////////////
//   EECS470 Project Team Panda                                        //
//                                                                     //
//  ROB Testcases									                   									 //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module testbench;

`ifndef NUM_BTB_ENTRIES
`define	NUM_BTB_ENTRIES	1024
`endif

`ifndef	LOG_NUM_BTB_ENTRIES
`define	LOG_NUM_BTB_ENTRIES	10
`endif
  // Registers and wires used in the testbench
reg									clock;
reg									reset;

reg	[63:0]					if_pc;//current PC

reg									rob_retire_is_jump0;//the retired instruction.
reg	[63:0]					rob_retire_pc0;
reg	[63:0]					rob_cre_npc0;

reg									rob_retire_is_jump1;//the retired instruction.
reg	[63:0]					rob_retire_pc1;
reg	[63:0]					rob_cre_npc1;

wire	[63:0]				if_pred_addr0;//the predictied npc
wire	[63:0]				if_pred_addr1;

reg	[63:0]					cre_if_pred_addr0;//the predictied npc
reg	[63:0]					cre_if_pred_addr1;
reg									eval_pred_addr0;
reg									eval_pred_addr1;


  // Instantiate the Pipeline
btb btb_0(//inputs
					clock,
					reset,
					
					if_pc,
					
					rob_retire_is_jump0,
					rob_retire_pc0,
					rob_cre_npc0,

					rob_retire_is_jump1,
					rob_retire_pc1,
					rob_cre_npc1,
					
					//outputs
					if_pred_addr0,
					if_pred_addr1
					);
	
// Compare the results with the correct ones
always @(posedge clock)
begin
	#3;
	if (eval_pred_addr0 && (if_pred_addr0 != cre_if_pred_addr0)) begin
		$display("*** incorrect if_pred_addr0: %d, predicted: %d ***", if_pred_addr0, cre_if_pred_addr0);
		$display("*** incorrect at time: %d ***", $time);
		$finish;
	end
	else if (eval_pred_addr1 && (if_pred_addr1 != cre_if_pred_addr1)) begin
		$display("*** incorrect if_pred_addr1: %d, predicted; %d ***", if_pred_addr1, cre_if_pred_addr1);
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
  $monitor("Time:%4.0f\nif_pred_addr0: %d\tif_pred_addr1: %d\n", $time, if_pred_addr0, if_pred_addr1);
	clock = 0;
	reset = 1;
	
	if_pc = 0;
	
	rob_retire_is_jump0 = 0;
	rob_retire_pc0 = 0;
	rob_cre_npc0 = 0;
	
	rob_retire_is_jump1 = 0;
	rob_retire_pc1 = 0;
	rob_cre_npc1 = 0;
	
	eval_pred_addr0 = 0;
	cre_if_pred_addr0 = 0;
	
	eval_pred_addr1 = 0;
	cre_if_pred_addr1 = 0;
@(negedge clock);
	reset = 0;
@(negedge clock);
	rob_retire_is_jump0 = 1;
	rob_retire_pc0 = 0;
	rob_cre_npc0 = 40;
	
	eval_pred_addr0 = 1;
	cre_if_pred_addr0 = 40;
@(negedge clock);
	rob_retire_is_jump0 = 1;
	rob_retire_pc0 = 64'h1000;
	rob_cre_npc0 = 60;

	eval_pred_addr0 = 1;
	cre_if_pred_addr0 = 60;
@(negedge clock);
	rob_retire_is_jump0 = 1;
	rob_retire_pc0 = 0;
	rob_cre_npc0 = 100;
	
	rob_retire_is_jump1 = 1;
	rob_retire_pc1 = 4;
	rob_cre_npc1 = 104;
	
	eval_pred_addr0 = 1;
	cre_if_pred_addr0 = 100;
	eval_pred_addr1 = 1;
	cre_if_pred_addr1 = 104;
@(negedge clock);
$finish;
end

endmodule


