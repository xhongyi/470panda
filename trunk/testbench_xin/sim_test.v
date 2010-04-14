/*
 * Module name: mt_test.v
 * Description: Test whether the map table module is correct
 */


`timescale 1ns/100ps

module sim_test;

	reg			clock;
	reg			reset;

  reg  [63:0] rs_sim_NPC0;           // incoming instruction PC+4
  reg  [63:0] rs_sim_NPC1;           // incoming instruction PC+4
  reg  [31:0] rs_sim_IR0;            // incoming instruction
  reg  [31:0] rs_sim_IR1;            // incoming instruction
  reg  [63:0] rs_sim_pra0;          // register A value from reg file   
  reg  [63:0] rs_sim_pra1;          // register A value from reg file

  reg  [63:0] rs_sim_prb0;          // register B value from reg file
  reg  [63:0] rs_sim_prb1;          // register B value from reg file

  reg   [1:0] rs_sim_opa_select0;    // opA mux select from decoder
  reg   [1:0] rs_sim_opa_select1;    // opA mux select from decoder

  reg   [1:0] rs_sim_opb_select0;    // opB mux select from decoder
  reg   [1:0] rs_sim_opb_select1;    // opB mux select from decoder

  reg   [4:0] rs_sim_alu_func0;      // ALU function select from decoder
  reg   [4:0] rs_sim_alu_func1;      // ALU function select from decoder

  reg         rs_sim_cond_branch0;   // is this a cond br? from decoder
  reg         rs_sim_cond_branch1;   // is this a cond br? from decoder
  
  reg         rs_sim_uncond_branch0; // is this an uncond br? from decoder
  reg         rs_sim_uncond_branch1; // is this an uncond br? from decoder


  wire [63:0] sim_alu_result_out0;   // ALU result
  wire [63:0] sim_alu_result_out1;   // ALU result

  wire        ex_take_branch_out0;  // is this a taken branch?
  wire        ex_take_branch_out1;  // is this a taken branch?
  wire [1:0]		rs_alu_ready;

	// Correct outputs
	reg	[6:0]	cr_rob_p0told;
	reg	[6:0]	cr_rob_p1told;
	reg	[6:0]	cr_rs_pr_a1;
	reg	[6:0]	cr_rs_pr_a2;
	reg	[6:0]	cr_rs_pr_b1;
	reg	[6:0]	cr_rs_pr_b2;

	reg				cr_rs_pr_a1_ready;
	reg				cr_rs_pr_a2_ready;
	reg				cr_rs_pr_b1_ready;
	reg				cr_rs_pr_b2_ready;

	// For test case
	reg					correct;
sim sim0(// Inputs
                clock,
                reset,
                rs_sim_NPC0,
				rs_sim_NPC1,
                rs_sim_IR0,
				rs_sim_IR1,
                rs_sim_pra0,
				rs_sim_pra1,
                rs_sim_prb0,
				rs_sim_prb1,
                rs_sim_opa_select0,
				rs_sim_opa_select1,
                rs_sim_opb_select0,
				rs_sim_opb_select1,
                rs_sim_alu_func0,
				rs_sim_alu_func1,
                rs_sim_cond_branch0,
				rs_sim_cond_branch1,
                rs_sim_uncond_branch0,
				rs_sim_uncond_branch1,
                
                // Outputs
                sim_alu_result_out0,
				sim_alu_result_out1,
                sim_take_branch_out0,
				sim_take_branch_out1
               );
	
	// Generate System Clock
	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clock = ~clock;
	end

	// Compare the results with the correct ones
	always @(posedge clock)
	begin
		$monitor("Time: %4.0f\n\nInput\n reset: %b\n rs_sim_NPC0: %b\n rs_sim_NPC1: %b\n rs_sim_IR0: %b\n rs_sim_IR1: %b\n rs_sim_pra0: %b\n rs_sim_pra1: %b\n rs_sim_prb0: %b\n rs_sim_prb1: %b\n rs_sim_opa_select0: %b\n rs_sim_opa_select1: %b\n  rs_sim_opb_select0: %b\n rs_sim_opb_select1: %b\n rs_sim_alu_func0: %b\n rs_sim_alu_func1: %b\n rs_sim_cond_branch0: %b\n rs_sim_cond_branch1: %b\n  rs_sim_uncond_branch0: %b\n rs_sim_uncond_branch1: %b\n sim_alu_result_out0: %b\n sim_alu_result_out1: %b\n sim_take_branch_out0 : %b\n sim_take_branch_out1: %b", $time, reset, rs_sim_NPC0, rs_sim_NPC1, rs_sim_IR0, rs_sim_IR1, rs_sim_pra0, rs_sim_pra1, rs_sim_prb0, rs_sim_prb1, rs_sim_opa_select0, rs_sim_opa_select1, rs_sim_opb_select0, rs_sim_opb_select1, rs_sim_alu_func0, rs_sim_alu_func1, rs_sim_cond_branch0, rs_sim_cond_branch1, rs_sim_uncond_branch0, rs_sim_uncond_branch1, sim_alu_result_out0, sim_alu_result_out1, sim_take_branch_out0, sim_take_branch_out1 );

		#(`VERILOG_CLOCK_PERIOD/4.0);

		
/*
		correct = 0;
		if (rob_ar_a_valid && rob_p0told != cr_rob_p0told)
			$display("*** rob_p0told is %b and it should be %b", rob_p0told, cr_rob_p0told);
		else if (rob_ar_b_valid && rob_p1told != cr_rob_p1told)
			$display("*** rob_p1told is %b and it should be %b", rob_p1told, cr_rob_p1told);
		else if (rob_ar_a1_valid && rs_pr_a1 != cr_rs_pr_a1)
			$display("*** rs_pr_a1 is %b and it should be %b", rs_pr_a1, cr_rs_pr_a1);
		else if (rob_ar_a2_valid && rs_pr_a2 != cr_rs_pr_a2)
			$display("*** rs_pr_a2 is %b and it should be %b", rs_pr_a2, cr_rs_pr_a2);
		
		else

			correct = 1;

		if (~correct)
		begin
			$display("*** Incorrect at time %4.0f\n", $time);
			$finish;
		end
*/
	end


	initial
	begin
		clock = 0;

		// Initializing

		// The input values
		reset = 1;
		rs_sim_NPC0 = 0;
		rs_sim_NPC1 = 4;
		rs_sim_IR0 = `NOOP_INST;
		rs_sim_IR1 =`NOOP_INST;
		rs_sim_pra0 = 0;
		rs_sim_pra1 = 0;
		rs_sim_prb0 = 0;
		rs_sim_prb1 = 0;
		rs_sim_opa_select0 = 0;
		rs_sim_opa_select1 = 0;
		rs_sim_opb_select0 = 0;
		rs_sim_opb_select1 = 0;
		rs_sim_alu_func0 = 0;
		rs_sim_alu_func1 = 0;
		rs_sim_cond_branch0 = 0;
		rs_sim_cond_branch1 = 0;
		rs_sim_uncond_branch0 = 0;
		rs_sim_uncond_branch1 = 0;
		@(negedge clock)
		reset = 0;
		rs_sim_NPC0 = 0;
		rs_sim_NPC1 = 4;
		rs_sim_IR0 = `NOOP_INST;
		rs_sim_IR1 =`NOOP_INST;
		rs_sim_pra0 = 3;
		rs_sim_pra1 = 4;
		rs_sim_prb0 = 5;
		rs_sim_prb1 = 6;
		rs_sim_opa_select0 = 0;
		rs_sim_opa_select1 = 0;
		rs_sim_opb_select0 = 0;
		rs_sim_opb_select1 = 0;
		rs_sim_alu_func0 = 0;
		rs_sim_alu_func1 = 0;
		rs_sim_cond_branch0 = 0;
		rs_sim_cond_branch1 = 0;
		rs_sim_uncond_branch0 = 0;
		rs_sim_uncond_branch1 = 0;
		

		@(negedge clock)
		$finish;
	end

endmodule
