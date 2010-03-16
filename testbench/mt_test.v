/*
 * Module name: mt_test.v
 * Description: Test whether the map table module is correct
 */


`timescale 1ns/100ps

module mt_test;

	reg			clock;
	reg			reset;

	reg	[1:0]	id_dispatch_num;
	reg	[6:0]	fl_pr0;
	reg	[6:0]	fl_pr1;

	reg				id_valid_inst0;
	reg				id_valid_inst1;
	reg				id_opa_select0;
	reg				id_opa_select1;
	reg				id_opb_select0;
	reg				id_opb_select1;

	reg	[4:0]	id_dest_idx0;
	reg	[4:0]	id_dest_idx1;
	reg	[4:0]	id_ra_idx0;
	reg	[4:0]	id_ra_idx1;
	reg	[4:0]	id_rb_idx0;
	reg	[4:0]	id_rb_idx1;

	reg	[3:0]	cdb_broadcast;
	reg	[6:0]	cdb_pr_tags[3:0];
	reg	[4:0]	cdb_ar_tags[3:0];

	// Outputs
	wire	[6:0]	rob_p0told;
	wire	[6:0]	rob_p1told;
	wire	[6:0]	rs_pr_a1;
	wire	[6:0]	rs_pr_a2;
	wire	[6:0]	rs_pr_b1;
	wire	[6:0]	rs_pr_b2;

	wire				rs_pr_a1_ready;
	wire				rs_pr_a2_ready;
	wire				rs_pr_b1_ready;
	wire				rs_pr_b2_ready;

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

	mt mt_0 (// Inputs
					 .clock(clock),
					 .reset(reset),
					 .id_dispatch_num(id_dispatch_num),
					 .fl_pr0(fl_pr0),
					 .fl_pr1(fl_pr1),
					 .id_valid_inst0(id_valid_inst0),
					 .id_valid_inst1(id_valid_inst1),
					 .id_opa_select0(id_opa_select0),
					 .id_opb_select0(id_opb_select0),
					 .id_opa_select1(id_opa_select1),
					 .id_opb_select1(id_opb_select1),

					 .id_dest_idx0(id_dest_idx0),
					 .id_dest_idx1(id_dest_idx1),
					 .id_ra_idx0(id_ra_idx0),
					 .id_rb_idx0(id_rb_idx0),
					 .id_ra_idx1(id_ra_idx1),
					 .id_rb_idx1(id_rb_idx1),

					 .cdb_broadcast(cdb_broadcast),
					 .cdb_pr_tag0(cdb_pr_tags[0]),
					 .cdb_pr_tag1(cdb_pr_tags[1]),
					 .cdb_pr_tag2(cdb_pr_tags[2]),
					 .cdb_pr_tag3(cdb_pr_tags[3]),
					 .cdb_ar_tag0(cdb_ar_tags[0]),
					 .cdb_ar_tag1(cdb_ar_tags[1]),
					 .cdb_ar_tag2(cdb_ar_tags[2]),
					 .cdb_ar_tag3(cdb_ar_tags[3]),

					 // Outputs
					 .rob_p0told(rob_p0told),
					 .rob_p1told(rob_p1told),
					 .rs_pr_a1(rs_pr_a1),
					 .rs_pr_a2(rs_pr_a2),
					 .rs_pr_b1(rs_pr_b1),
					 .rs_pr_b2(rs_pr_b2),

					 .rs_pr_a1_ready(rs_pr_a1_ready),
					 .rs_pr_a2_ready(rs_pr_a2_ready),
					 .rs_pr_b1_ready(rs_pr_b1_ready),
					 .rs_pr_b2_ready(rs_pr_b2_ready)
					);
					
	
	// Generate System Clock
	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clock = ~clock;
	end

	// Compare the results with the correct ones
	always @(negedge clock)
	begin
	#(`VERILOG_CLOCK_PERIOD/4.0);
		$monitor("Time: %4.0f\n\nInput\n reset: %b\n id_dispatch_num: %b\n fl_pr0: %b\n fl_pr1: %b\n id_valid_inst0: %b\n id_opa_select0: %b\n id_opa_select1: %b\n id_valid_inst1: %b\n id_opb_select0: %b\n id_opb_select1: %b\n id_dest_idx0: %b\n id_ra_idx0: %b\n id_ra_idx1: %b\n id_dest_idx1: %b\n id_rb_idx0: %b\n id_rb_idx1: %b\n cdb_broadcast: %b\n cdb_pr_tags[0]: %b\n cdb_pr_tags[1]: %b\n cdb_pr_tags[2]: %b\n cdb_pr_tags[3]: %b\n cdb_ar_tags[0]: %b\n cdb_ar_tags[1]: %b\n cdb_ar_tags[2]: %b\n cdb_ar_tags[3]: %b\n\nOutput\n rs_pr_a1_ready: %b\n rs_pr_a1: %b\n rs_pr_a2_ready: %b\n rs_pr_a2: %b\n rs_pr_b1_ready: %b\n rs_pr_b1: %b\n rs_pr_b2_ready: %b\n rs_pr_b2: %b\n rob_p0told: %b\n rob_p1told: %b\n\n", $time, reset, id_dispatch_num, fl_pr0, fl_pr1, id_valid_inst0, id_opa_select0, id_opa_select1, id_valid_inst1, id_opb_select0, id_opb_select1, id_dest_idx0, id_ra_idx0, id_ra_idx1, id_dest_idx1, id_rb_idx0, id_rb_idx1, cdb_broadcast, cdb_pr_tags[0], cdb_pr_tags[1], cdb_pr_tags[2], cdb_pr_tags[3], cdb_ar_tags[0], cdb_ar_tags[1], cdb_ar_tags[2], cdb_ar_tags[3], rs_pr_a1_ready, rs_pr_a1, rs_pr_a2_ready, rs_pr_a2, rs_pr_b1_ready, rs_pr_b1, rs_pr_b2_ready, rs_pr_b2, rob_p0told, rob_p1told);

		

		

		correct = 0;
		if (id_valid_inst0 && rob_p0told != cr_rob_p0told)
			$display("*** rob_p0told is %b and it should be %b", rob_p0told, cr_rob_p0told);
		else if (id_valid_inst1 && rob_p1told != cr_rob_p1told)
			$display("*** rob_p1told is %b and it should be %b", rob_p1told, cr_rob_p1told);
		else if (id_opa_select0 && rs_pr_a1 != cr_rs_pr_a1)
			$display("*** rs_pr_a1 is %b and it should be %b", rs_pr_a1, cr_rs_pr_a1);
		else if (id_opa_select1 && rs_pr_a2 != cr_rs_pr_a2)
			$display("*** rs_pr_a2 is %b and it should be %b", rs_pr_a2, cr_rs_pr_a2);
		else if (id_opb_select0 && rs_pr_b1 != cr_rs_pr_b1)
			$display("*** rs_pr_b1 is %b and it should be %b", rs_pr_b1, cr_rs_pr_b1);
		else if (id_opb_select1 && rs_pr_b2 != cr_rs_pr_b2)
			$display("*** rs_pr_b2 is %b and it should be %b", rs_pr_b2, cr_rs_pr_b2);
		else if (id_opa_select0 && rs_pr_a1_ready != cr_rs_pr_a1_ready)
			$display("*** rs_pr_a1_ready is %b and it should be %b", rs_pr_a1_ready, cr_rs_pr_a1_ready);
		else if (id_opa_select1 && rs_pr_a2_ready != cr_rs_pr_a2_ready)
			$display("*** rs_pr_a2_ready is %b and it should be %b", rs_pr_a2_ready, cr_rs_pr_a2_ready);
		else if (id_opb_select0 && rs_pr_b1_ready != cr_rs_pr_b1_ready)
			$display("*** rs_pr_b1_ready is %b and it should be %b", rs_pr_b1_ready, cr_rs_pr_b1_ready);
		else if (id_opb_select1 && rs_pr_b2_ready != cr_rs_pr_b2_ready)
			$display("*** rs_pr_b2_ready is %b and it should be %b", rs_pr_b2_ready, cr_rs_pr_b2_ready);
		else

			correct = 1;

		if (~correct)
		begin
			$display("*** Incorrect at time %4.0f\n", $time);
			$finish;
		end
	end


	initial
	begin
		clock = 0;

		// Initializing

		// The input values
		reset = 1;

		id_dispatch_num = 0;
		fl_pr0 = 0;
		fl_pr1 = 0;

		id_valid_inst0 = 0;
		id_valid_inst1 = 0;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 0;
		id_dest_idx1 = 0;
		id_ra_idx0 = 0;
		id_rb_idx0 = 0;
		id_ra_idx1 = 0;
		id_rb_idx1 = 0;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 0;
		cr_rob_p1told = 0;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a1 = 0;

		cr_rs_pr_a2_ready = 0;
		cr_rs_pr_a2 = 0;

		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b1 = 0;

		cr_rs_pr_b2_ready = 0;
		cr_rs_pr_b2 = 0;

		@(negedge clock)//#5
	
		id_dispatch_num = 0;
		fl_pr0 = 0;
		fl_pr1 = 0;

		id_valid_inst0 = 0;
		id_valid_inst1 = 0;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 0;
		id_dest_idx1 = 0;
		id_ra_idx0 = 0;
		id_rb_idx0 = 0;
		id_ra_idx1 = 0;
		id_rb_idx1 = 0;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 0;
		cr_rob_p1told = 0;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a1 = 0;

		cr_rs_pr_a2_ready = 0;
		cr_rs_pr_a2 = 0;

		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b1 = 0;

		cr_rs_pr_b2_ready = 0;
		cr_rs_pr_b2 = 0;

		@(negedge clock)//#15
		@(negedge clock)//#25
		reset = 0;
		@(negedge clock)//#35

		id_dispatch_num = 0;
		fl_pr0 = 5;
		fl_pr1 = 0;

		id_valid_inst0 = 0;
		id_valid_inst1 = 0;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 0;
		id_dest_idx1 = 0;
		id_ra_idx0 = 0;
		id_rb_idx0 = 0;
		id_ra_idx1 = 0;
		id_rb_idx1 = 0;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 0;
		cr_rob_p1told = 0;
		cr_rs_pr_a1 = 0;
		cr_rs_pr_a2 = 0;
		cr_rs_pr_b1 = 0;
		cr_rs_pr_b2 = 0;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a2_ready = 0;
		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b2_ready = 0;
		

		@(negedge clock)//#45
		//Normal two dispatch and no complete
		//Note that the values here may be of future use
		//r3 is now p32, r4 is now p33
		id_dispatch_num = 2;
		fl_pr0 = 32;
		fl_pr1 = 33;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 3;
		id_dest_idx1 = 4;
		id_ra_idx0 = 5;
		id_rb_idx0 = 6;
		id_ra_idx1 = 7;
		id_rb_idx1 = 8;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 3;
		cr_rob_p1told = 4;
		cr_rs_pr_a1 = 5;
		cr_rs_pr_b1 = 6;
		cr_rs_pr_a2 = 7;
		cr_rs_pr_b2 = 8;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b2_ready = 1;
		
		@(negedge clock)//#55
		//Normal one dispatch and no complete
		//Note that the values here may be of future use
		//r9 is now p34
		id_dispatch_num = 1;
		fl_pr0 = 34;
		fl_pr1 = 35;

		id_valid_inst0 = 1;
		id_valid_inst1 = 0;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 9;
		id_dest_idx1 = 10;
		id_ra_idx0 = 11;
		id_rb_idx0 = 12;
		id_ra_idx1 = 13;
		id_rb_idx1 = 14;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 9;
		cr_rob_p1told = 10;
		cr_rs_pr_a1 = 11;
		cr_rs_pr_b1 = 12;
		cr_rs_pr_a2 = 13;
		cr_rs_pr_b2 = 14;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b2_ready = 1;

		


		@(negedge clock)//#65
		//Two dispatch on previous register, no complete
		// r3, r4 is tested
		//Note that the values here may be of future use
		//r15 is now p36, r16 is now p37
		id_dispatch_num = 2;
		fl_pr0 = 36;
		fl_pr1 = 37;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 15;
		id_dest_idx1 = 16;
		id_ra_idx0 = 3;
		id_rb_idx0 = 4;
		id_ra_idx1 = 5;
		id_rb_idx1 = 6;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 15;
		cr_rob_p1told = 16;
		cr_rs_pr_a1 = 32;
		cr_rs_pr_b1 = 33;
		cr_rs_pr_a2 = 5;
		cr_rs_pr_b2 = 6;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b2_ready = 1;
		
		@(negedge clock)//#75
		//No dispatch on previous registers, two completes
		// r3, r4 is complete
		//Note that the values here may be of future use
		id_dispatch_num = 0;
		fl_pr0 = 36;
		fl_pr1 = 37;

		id_valid_inst0 = 0;
		id_valid_inst1 = 0;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 15;
		id_dest_idx1 = 16;
		id_ra_idx0 = 3;
		id_rb_idx0 = 4;
		id_ra_idx1 = 5;
		id_rb_idx1 = 6;

		cdb_broadcast = 4'b0011;
		cdb_pr_tags[0] = 32;
		cdb_pr_tags[1] = 33;
		cdb_pr_tags[2] = 34;
		cdb_pr_tags[3] = 35;
		cdb_ar_tags[0] = 3;
		cdb_ar_tags[1] = 4;
		cdb_ar_tags[2] = 9;
		cdb_ar_tags[3] = 10;

		// The correct output values
		cr_rob_p0told = 36;
		cr_rob_p1told = 37;
		cr_rs_pr_a1 = 32;
		cr_rs_pr_b1 = 33;
		cr_rs_pr_a2 = 5;
		cr_rs_pr_b2 = 6;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b2_ready = 1;

		@(negedge clock)//#85
		begin
		//Dispatch two on the registers just completed, no complete
		// r3, r4 has been complete
		//Note that the values here may be of future use
		//r17 is now p38, r18 is now p39
		id_dispatch_num = 2;
		fl_pr0 = 38;
		fl_pr1 = 39;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 17;
		id_dest_idx1 = 18;
		id_ra_idx0 = 3;
		id_rb_idx0 = 4;
		id_ra_idx1 = 5;
		id_rb_idx1 = 6;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 5;
		cdb_pr_tags[1] = 6;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 5;
		cdb_ar_tags[1] = 6;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 17;
		cr_rob_p1told = 18;

		cr_rs_pr_a1 = 32;
		cr_rs_pr_b1 = 33;
		cr_rs_pr_a2 = 5;
		cr_rs_pr_b2 = 6;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b2_ready = 1;
		end
		@(negedge clock)//#95
		begin
		//Dispatch two same registers
		//Note that the values here may be of future use
		//r19 is now p40
		id_dispatch_num = 2;
		fl_pr0 = 40;
		fl_pr1 = 41;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 19;
		id_dest_idx1 = 19;
		id_ra_idx0 = 20;
		id_rb_idx0 = 23;
		id_ra_idx1 = 21;
		id_rb_idx1 = 22;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 5;
		cdb_pr_tags[1] = 6;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 5;
		cdb_ar_tags[1] = 6;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 19;
		cr_rob_p1told = 40;

		cr_rs_pr_a1 = 20;
		cr_rs_pr_b1 = 23;
		cr_rs_pr_a2 = 21;
		cr_rs_pr_b2 = 22;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b2_ready = 1;
		end
		@(negedge clock)//#105
		begin
		//Dispatch two same registers
		//One of the operands is the same with the same dest
		//completes two registers on other lines
		//Note that the values here may be of future use
		//r19 is now p40
		id_dispatch_num = 2;
		fl_pr0 = 41;
		fl_pr1 = 42;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 20;
		id_dest_idx1 = 20;
		id_ra_idx0 = 21;
		id_rb_idx0 = 20;
		id_ra_idx1 = 23;
		id_rb_idx1 = 24;

		cdb_broadcast = 4'b1100;
		cdb_pr_tags[0] = 0;
		cdb_pr_tags[1] = 0;
		cdb_pr_tags[2] = 38;
		cdb_pr_tags[3] = 39;
		cdb_ar_tags[0] = 0;
		cdb_ar_tags[1] = 0;
		cdb_ar_tags[2] = 17;
		cdb_ar_tags[3] = 18;

		// The correct output values
		cr_rob_p0told = 20;
		cr_rob_p1told = 41;

		cr_rs_pr_a1 = 21;
		cr_rs_pr_b1 = 41;
		cr_rs_pr_a2 = 23;
		cr_rs_pr_b2 = 24;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b2_ready = 1;
		end		

		@(negedge clock)//#115
		begin
		//Dispatch two same registers
		//One of the operands is the same with the same dest
		//Note that the values here may be of future use
		//r19 is now p40
		id_dispatch_num = 2;
		fl_pr0 = 43;
		fl_pr1 = 44;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 20;
		id_dest_idx1 = 28;
		id_ra_idx0 = 17;
		id_rb_idx0 = 18;
		id_ra_idx1 = 23;
		id_rb_idx1 = 24;

		cdb_broadcast = 0;
		cdb_pr_tags[0] = 5;
		cdb_pr_tags[1] = 6;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 5;
		cdb_ar_tags[1] = 6;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 42;
		cr_rob_p1told = 28;

		cr_rs_pr_a1 = 38;
		cr_rs_pr_b1 = 39;
		cr_rs_pr_a2 = 23;
		cr_rs_pr_b2 = 24;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b2_ready = 1;
		end	
		@(negedge clock)//#125
		begin
		//Dispatch two same registers
		//One of the operands is the same with the same dest
		//Note that the values here may be of future use
		//r19 is now p40
		id_dispatch_num = 2;
		fl_pr0 = 45;
		fl_pr1 = 46;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 5;
		id_dest_idx1 = 6;
		id_ra_idx0 = 17;
		id_rb_idx0 = 18;
		id_ra_idx1 = 23;
		id_rb_idx1 = 24;

		cdb_broadcast = 4'b0011;
		cdb_pr_tags[0] = 47;
		cdb_pr_tags[1] = 48;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 5;
		cdb_ar_tags[1] = 6;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 5;
		cr_rob_p1told = 6;

		cr_rs_pr_a1 = 38;
		cr_rs_pr_b1 = 39;
		cr_rs_pr_a2 = 23;
		cr_rs_pr_b2 = 24;

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b2_ready = 1;
		end	

		@(negedge clock)//#135
		begin
		//Dispatch two same registers
		//One of the operands is the same with the same dest
		//Note that the values here may be of future use
		//r19 is now p40
		id_dispatch_num = 2;
		fl_pr0 = 49;
		fl_pr1 = 50;

		id_valid_inst0 = 1;
		id_valid_inst1 = 1;
		id_opa_select0 = 0;
		id_opb_select0 = 0;
		id_opa_select1 = 0;
		id_opb_select1 = 0;

		id_dest_idx0 = 17;
		id_dest_idx1 = 18;
		id_ra_idx0 = 5;
		id_rb_idx0 = 6;
		id_ra_idx1 = 23;
		id_rb_idx1 = 24;

		cdb_broadcast = 4'b0000;
		cdb_pr_tags[0] = 47;
		cdb_pr_tags[1] = 48;
		cdb_pr_tags[2] = 0;
		cdb_pr_tags[3] = 0;
		cdb_ar_tags[0] = 5;
		cdb_ar_tags[1] = 6;
		cdb_ar_tags[2] = 0;
		cdb_ar_tags[3] = 0;

		// The correct output values
		cr_rob_p0told = 38;
		cr_rob_p1told = 39;

		cr_rs_pr_a1 = 45;
		cr_rs_pr_b1 = 46;
		cr_rs_pr_a2 = 23;
		cr_rs_pr_b2 = 24;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b2_ready = 1;
		end	
		@(negedge clock)
		$finish;
	end

endmodule
