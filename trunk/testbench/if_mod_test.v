/*
 * Module name: if_test.v
 * Description: Test whether the fetch stage module is correct
 */


`timescale 1ns/100ps

module if_test;

	reg			clock;
	reg			reset;

  reg         ex_mem_take_branch0; // taken-branch signal
  reg			ex_mem_take_branch1;
  reg  [63:0] ex_mem_target_pc0;   // target pc: use if take_branch is TRUE
  reg  [63:0] ex_mem_target_pc1;
  reg  [63:0] Imem2proc_data;     // Data coming back from instruction-memory
  reg  [1:0]  Imem_valid;
  reg  [1:0]  busy;		//Whether RS and ROB are busy

  wire [63:0] proc2Imem_addr;     // Address sent to Instruction memory
  wire [63:0] if_NPC_out;         // PC of instruction after fetched (PC+4).
  wire [31:0] if_IR_out0;          // fetched instruction
  wire [31:0] if_IR_out1;
  wire        if_valid_inst_out0;
  wire		  if_valid_inst_out1;

	// Correct outputs
  reg [63:0] proc2Imem_addr_pred;     // Address sent to Instruction memory
  reg [63:0] if_NPC_out_pred;         // PC of instruction after fetched (PC+4).
  reg [31:0] if_IR_out0_pred;          // fetched instruction
  reg [31:0] if_IR_out1_pred;
  reg        if_valid_inst_out0_pred;
  reg		 if_valid_inst_out1_pred;
	// For test case
	reg					correct;

	if_mod if_0(// Inputs
                clock,
                reset,
                ex_mem_take_branch0,
				ex_mem_take_branch1,
                ex_mem_target_pc0,
				ex_mem_target_pc1,
                Imem2proc_data,
                Imem_valid,
				busy,
                    
                // Outputs
                if_NPC_out,        // PC+4 of fetched instruction		//PC+8 of fetched instruction
                if_IR_out0,         // fetched instruction out
				if_IR_out1,		//  second fetched instruction out
                proc2Imem_addr,
                if_valid_inst_out0,
				if_valid_inst_out1  // when low, instruction is garbage
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
		$monitor("Time: %4.0f\n\nInput\n reset: %b\n ex_mem_take_branch0: %b\n ex_mem_take_branch1: %b\n ex_mem_target_pc0: %b\n ex_mem_target_pc1: %b\n Imem2proc_data: %b\n Imem_valid: %b\n busy: %b\n if_NPC_out: %b\n  if_IR_out0: %b\n if_IR_out1: %b\n proc2Imem_addr: %b\n if_valid_inst_out0: %b\n if_valid_inst_out1: %b\n\n", $time, reset, ex_mem_take_branch0, ex_mem_take_branch1, ex_mem_target_pc0, ex_mem_target_pc1, Imem2proc_data, Imem_valid, busy, if_NPC_out, if_IR_out0, if_IR_out1, proc2Imem_addr, if_valid_inst_out0, if_valid_inst_out1);

		#(`VERILOG_CLOCK_PERIOD/4.0);

		

		correct = 1;
		/*
		if ( && rob_p0told != cr_rob_p0told)
			$display("*** rob_p0told is %b and it should be %b", rob_p0told, cr_rob_p0told);
		else if (rob_ar_b_valid && rob_p1told != cr_rob_p1told)
			$display("*** rob_p1told is %b and it should be %b", rob_p1told, cr_rob_p1told);
		else if (rob_ar_a1_valid && rs_pr_a1 != cr_rs_pr_a1)
			$display("*** rs_pr_a1 is %b and it should be %b", rs_pr_a1, cr_rs_pr_a1);
		else if (rob_ar_a2_valid && rs_pr_a2 != cr_rs_pr_a2)
			$display("*** rs_pr_a2 is %b and it should be %b", rs_pr_a2, cr_rs_pr_a2);
		else if (rob_ar_b1_valid && rs_pr_b1 != cr_rs_pr_b1)
			$display("*** rs_pr_b1 is %b and it should be %b", rs_pr_b1, cr_rs_pr_b1);
		else if (rob_ar_b2_valid && rs_pr_b2 != cr_rs_pr_b2)
			$display("*** rs_pr_b2 is %b and it should be %b", rs_pr_b2, cr_rs_pr_b2);
		else if (rob_ar_a1_valid && rs_pr_a1_ready != cr_rs_pr_a1_ready)
			$display("*** rs_pr_a1_ready is %b and it should be %b", rs_pr_a1_ready, cr_rs_pr_a1_ready);
		else if (rob_ar_a2_valid && rs_pr_a2_ready != cr_rs_pr_a2_ready)
			$display("*** rs_pr_a2_ready is %b and it should be %b", rs_pr_a2_ready, cr_rs_pr_a2_ready);
		else if (rob_ar_b1_valid && rs_pr_b1_ready != cr_rs_pr_b1_ready)
			$display("*** rs_pr_b1_ready is %b and it should be %b", rs_pr_b1_ready, cr_rs_pr_b1_ready);
		else if (rob_ar_b2_valid && rs_pr_b2_ready != cr_rs_pr_b2_ready)
			$display("*** rs_pr_b2_ready is %b and it should be %b", rs_pr_b2_ready, cr_rs_pr_b2_ready);
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

		// The reg values
		reset = 1;

		clock = 0;
		ex_mem_take_branch0 = 0;
		ex_mem_take_branch1 = 0;
		ex_mem_target_pc0 = 0;
		ex_mem_target_pc1 = 4;
		Imem2proc_data = 0;
		Imem_valid = 1;
		busy = 2;
		@(negedge clock)
		reset = 0;
		@(negedge clock)
		ex_mem_take_branch0 = 0;
		ex_mem_take_branch1 = 0;
		ex_mem_target_pc0 = 4;
		ex_mem_target_pc1 = 8;
		Imem2proc_data = 64'h0123456789abcdef;
		Imem_valid = 1;
		busy = 0;
		@(negedge clock)
		busy = 1;
		@ (negedge clock)
		busy = 2;
		@(negedge clock)
		$finish;
	end

endmodule
