/*
 * Module name: mt_test.v
 * Description: Test whether the map table module is correct
 */


`timescale 1ns/100ps

module mt_test;

	reg			clock;
	reg			reset;

	reg	[1:0]	rob_dispatch_num;
	reg	[6:0]	fl_pr0;
	reg	[6:0]	fl_pr1;

	reg				rob_ar_a_valid;
	reg				rob_ar_b_valid;
	reg				rob_ar_a1_valid;
	reg				rob_ar_b1_valid;
	reg				rob_ar_a2_valid;
	reg				rob_ar_b2_valid;

	reg	[4:0]	rob_ar_a;
	reg	[4:0]	rob_ar_b;
	reg	[4:0]	rob_ar_a1;
	reg	[4:0]	rob_ar_b1;
	reg	[4:0]	rob_ar_a2;
	reg	[4:0]	rob_ar_b2;

	reg	[`CDB_WIDTH-1:0]	cdb_broadcast;
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
	
	integer i;

	mt mt_0 (// Inputs
					 .clock(clock),
					 .reset(reset),
					 .rob_dispatch_num(rob_dispatch_num),
					 .fl_pr0(fl_pr0),
					 .fl_pr1(fl_pr1),

					 .rob_ar_a_valid(rob_ar_a_valid),
					 .rob_ar_b_valid(rob_ar_b_valid),
					 .rob_ar_a1_valid(rob_ar_a1_valid),
					 .rob_ar_b1_valid(rob_ar_b1_valid),
					 .rob_ar_a2_valid(rob_ar_a2_valid),
					 .rob_ar_b2_valid(rob_ar_b2_valid),

					 .rob_ar_a(rob_ar_a),
					 .rob_ar_b(rob_ar_b),
					 .rob_ar_a1(rob_ar_a1),
					 .rob_ar_b1(rob_ar_b1),
					 .rob_ar_a2(rob_ar_a2),
					 .rob_ar_b2(rob_ar_b2),

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
		$monitor("Time: %4.0f\n\nInput\n reset: %d\n rob_dispatch_num: %d\n fl_pr0: %d\n fl_pr1: %d\n rob_ar_a_valid: %d\n rob_ar_a1_valid: %d\n rob_ar_a2_valid: %d\n rob_ar_b_valid: %d\n rob_ar_b1_valid: %d\n rob_ar_b2_valid: %d\n rob_ar_a: %d\n rob_ar_a1: %d\n rob_ar_a2: %d\n rob_ar_b: %d\n rob_ar_b1: %d\n rob_ar_b2: %d\n cdb_broadcast: %d\n cdb_pr_tags[0]: %d\n cdb_pr_tags[1]: %d\n cdb_pr_tags[2]: %d\n cdb_pr_tags[3]: %d\n cdb_ar_tags[0]: %d\n cdb_ar_tags[1]: %d\n cdb_ar_tags[2]: %d\n cdb_ar_tags[3]: %d\n\nOutput\n rs_pr_a1_ready: %d\n rs_pr_a1: %d\n rs_pr_a2_ready: %d\n rs_pr_a2: %d\n rs_pr_b1_ready: %d\n rs_pr_b1: %d\n rs_pr_b2_ready: %d\n rs_pr_b2: %d\n rob_p0told: %d\n rob_p1told: %d\n\n", $time, reset, rob_dispatch_num, fl_pr0, fl_pr1, rob_ar_a_valid, rob_ar_a1_valid, rob_ar_a2_valid, rob_ar_b_valid, rob_ar_b1_valid, rob_ar_b2_valid, rob_ar_a, rob_ar_a1, rob_ar_a2, rob_ar_b, rob_ar_b1, rob_ar_b2, cdb_broadcast, cdb_pr_tags[0], cdb_pr_tags[1], cdb_pr_tags[2], cdb_pr_tags[3], cdb_ar_tags[0], cdb_ar_tags[1], cdb_ar_tags[2], cdb_ar_tags[3], rs_pr_a1_ready, rs_pr_a1, rs_pr_a2_ready, rs_pr_a2, rs_pr_b1_ready, rs_pr_b1, rs_pr_b2_ready, rs_pr_b2, rob_p0told, rob_p1told);

		#(`VERILOG_CLOCK_PERIOD/4.0);

		

		correct = 0;
		if (rob_ar_a_valid && rob_p0told != cr_rob_p0told)
			$display("*** rob_p0told is %d and it should be %d", rob_p0told, cr_rob_p0told);
		else if (rob_ar_b_valid && rob_p1told != cr_rob_p1told)
			$display("*** rob_p1told is %d and it should be %d", rob_p1told, cr_rob_p1told);
		else if (rob_ar_a1_valid && rs_pr_a1 != cr_rs_pr_a1)
			$display("*** rs_pr_a1 is %d and it should be %d", rs_pr_a1, cr_rs_pr_a1);
		else if (rob_ar_a2_valid && rs_pr_a2 != cr_rs_pr_a2)
			$display("*** rs_pr_a2 is %d and it should be %d", rs_pr_a2, cr_rs_pr_a2);
		else if (rob_ar_b1_valid && rs_pr_b1 != cr_rs_pr_b1)
			$display("*** rs_pr_b1 is %d and it should be %d", rs_pr_b1, cr_rs_pr_b1);
		else if (rob_ar_b2_valid && rs_pr_b2 != cr_rs_pr_b2)
			$display("*** rs_pr_b2 is %d and it should be %d", rs_pr_b2, cr_rs_pr_b2);
		else if (rob_ar_a1_valid && rs_pr_a1_ready != cr_rs_pr_a1_ready)
			$display("*** rs_pr_a1_ready is %d and it should be %d", rs_pr_a1_ready, cr_rs_pr_a1_ready);
		else if (rob_ar_a2_valid && rs_pr_a2_ready != cr_rs_pr_a2_ready)
			$display("*** rs_pr_a2_ready is %d and it should be %d", rs_pr_a2_ready, cr_rs_pr_a2_ready);
		else if (rob_ar_b1_valid && rs_pr_b1_ready != cr_rs_pr_b1_ready)
			$display("*** rs_pr_b1_ready is %d and it should be %d", rs_pr_b1_ready, cr_rs_pr_b1_ready);
		else if (rob_ar_b2_valid && rs_pr_b2_ready != cr_rs_pr_b2_ready)
			$display("*** rs_pr_b2_ready is %d and it should be %d", rs_pr_b2_ready, cr_rs_pr_b2_ready);
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

		rob_dispatch_num = 0;
		fl_pr0 = 0;
		fl_pr1 = 0;

		rob_ar_a_valid = 0;
		rob_ar_b_valid = 0;
		rob_ar_a1_valid = 0;
		rob_ar_b1_valid = 0;
		rob_ar_a2_valid = 0;
		rob_ar_b2_valid = 0;

		rob_ar_a = 0;
		rob_ar_b = 0;
		rob_ar_a1 = 0;
		rob_ar_b1 = 0;
		rob_ar_a2 = 0;
		rob_ar_b2 = 0;

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

@(posedge clock)
@(posedge clock)
reset = 0;

for (i = 0; i <= 31; i = i+4)
begin
	@(posedge clock)

		rob_dispatch_num = 2;
		fl_pr0 = 0;
		fl_pr1 = 0;

		rob_ar_a_valid = 0;
		rob_ar_b_valid = 0;
		rob_ar_a1_valid = 1;
		rob_ar_a2_valid = 1;
		rob_ar_b1_valid = 1;
		rob_ar_b2_valid = 1;

		rob_ar_a = 0;
		rob_ar_b = 0;
		rob_ar_a1 = i;
		rob_ar_a2 = i+1;
		rob_ar_b1 = i+2;
		rob_ar_b2 = i+3;

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

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a1 = i;

		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_a2 = i+1;

		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b1 = i+2;

		cr_rs_pr_b2_ready = 1;
		cr_rs_pr_b2 = i+3;
end

for (i = 0; i <= 31; i = i+4)
begin
	@(posedge clock)

		rob_dispatch_num = 2;
		fl_pr0 = 0;
		fl_pr1 = 0;

		rob_ar_a_valid = 0;
		rob_ar_b_valid = 0;
		rob_ar_a1_valid = 1;
		rob_ar_a2_valid = 1;
		rob_ar_b1_valid = 1;
		rob_ar_b2_valid = 1;

		rob_ar_a = 0;
		rob_ar_b = 0;
		rob_ar_a1 = i;
		rob_ar_a2 = i+1;
		rob_ar_b1 = i+2;
		rob_ar_b2 = i+3;

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

		cr_rs_pr_a1_ready = 1;
		cr_rs_pr_a1 = i;

		cr_rs_pr_a2_ready = 1;
		cr_rs_pr_a2 = i+1;

		cr_rs_pr_b1_ready = 1;
		cr_rs_pr_b1 = i+2;

		cr_rs_pr_b2_ready = 1;
		cr_rs_pr_b2 = i+3;
end

for (i = 0; i <= 31; i = i+2)
begin
	@(posedge clock)
		rob_dispatch_num = 2;
		fl_pr0 = i+32;
		fl_pr1 = i+33;

		rob_ar_a_valid = 1;
		rob_ar_b_valid = 1;
		rob_ar_a1_valid = 0;
		rob_ar_a2_valid = 0;
		rob_ar_b1_valid = 0;
		rob_ar_b2_valid = 0;

		rob_ar_a = i;
		rob_ar_b = i+1;
		rob_ar_a1 = 0;
		rob_ar_a2 = 0;
		rob_ar_b1 = 0;
		rob_ar_b2 = 0;

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
		cr_rob_p0told = i;
		cr_rob_p1told = i+1;

		cr_rs_pr_a1_ready = 0;
		cr_rs_pr_a1 = 0;

		cr_rs_pr_a2_ready = 0;
		cr_rs_pr_a2 = 0;

		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b1 = 0;

		cr_rs_pr_b2_ready = 0;
		cr_rs_pr_b2 = 0;

	@(posedge clock)
		rob_dispatch_num = 1;
		fl_pr0 = 0;
		fl_pr1 = 0;

		rob_ar_a_valid = 0;
		rob_ar_b_valid = 0;
		rob_ar_a1_valid = 1;
		rob_ar_a2_valid = 1;
		rob_ar_b1_valid = 0;
		rob_ar_b2_valid = 0;

		rob_ar_a = 0;
		rob_ar_b = 0;
		rob_ar_a1 = i;
		rob_ar_a2 = i+1;
		rob_ar_b1 = 0;
		rob_ar_b2 = 0;

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
		cr_rs_pr_a1 = i+32;

		cr_rs_pr_a2_ready = 0;
		cr_rs_pr_a2 = i+33;

		cr_rs_pr_b1_ready = 0;
		cr_rs_pr_b1 = 0;

		cr_rs_pr_b2_ready = 0;
		cr_rs_pr_b2 = 0;
end
		@(negedge clock)
		$finish;
	end

endmodule
