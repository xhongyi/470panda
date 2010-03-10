/*
 * Module name: mt_test.v
 * Description: Test whether the map table module is correct
 */


`timescale 1ns/100ps

module mt_test;

	reg			clock;
	reg			reset;

	wire	[1:0]	rob_dispatch_num;
	wire	[6:0]	fl_pr0;
	wire	[6:0]	fl_pr1;

	wire				rob_ar_a_valid;
	wire				rob_ar_b_valid;
	wire				rob_ar_a1_valid;
	wire				rob_ar_b1_valid;
	wire				rob_ar_a2_valid;
	wire				rob_ar_b2_valid;

	wire	[4:0]	rob_ar_a;
	wire	[4:0]	rob_ar_b;
	wire	[4:0]	rob_ar_a1;
	wire	[4:0]	rob_ar_b1;
	wire	[4:0]	rob_ar_a2;
	wire	[4:0]	rob_ar_b2;

	wire	[`CDB_WIDTH-1:0]	cdb_broadcast;
	wire	[6:0]	cdb_pr_tags[3:0];
	wire	[4:0]	cdb_ar_tags[3:0];

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
	wire	[6:0]	cr_rob_p0told;
	wire	[6:0]	cr_rob_p1told;
	wire	[6:0]	cr_rs_pr_a1;
	wire	[6:0]	cr_rs_pr_a2;
	wire	[6:0]	cr_rs_pr_b1;
	wire	[6:0]	cr_rs_pr_b2;

	wire				cr_rs_pr_a1_ready;
	wire				cr_rs_pr_a2_ready;
	wire				cr_rs_pr_b1_ready;
	wire				cr_rs_pr_b2_ready;

	// For test case
	reg					correct;

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
	always @(posedge clock)
	begin
		#2
		correct = 0;
		if (rob_p0told != cr_rob_p0told)
			$display("rob_p0told is %b and it should be %b", rob_p0told, cr_rob_p0told);
		else if (rob_p1told != cr_rob_p1told)
			$display("rob_p1told is %b and it should be %b", rob_p1told, cr_rob_p1told);
		else if (rs_pr_a1 != cr_rs_pr_a1)
			$display("rs_pr_a1 is %b and it should be %b", rs_pr_a1, cr_rs_pr_a1);
		else if (rs_pr_a2 != cr_rs_pr_a2)
			$display("rs_pr_a2 is %b and it should be %b", rs_pr_a2, cr_rs_pr_a2);
		else if (rs_pr_b1 != cr_rs_pr_b1)
			$display("rs_pr_b1 is %b and it should be %b", rs_pr_b1, cr_rs_pr_b1);
		else if (rs_pr_b2 != cr_rs_pr_b2)
			$display("rs_pr_b2 is %b and it should be %b", rs_pr_b2, cr_rs_pr_b2);
		else if (rs_pr_a1_ready != cr_rs_pr_a1_ready)
			$display("rs_pr_a1_ready is %b and it should be %b", rs_pr_a1_ready, cr_rs_pr_a1_ready);
		else if (rs_pr_a2_ready != cr_rs_pr_a2_ready)
			$display("rs_pr_a2_ready is %b and it should be %b", rs_pr_a2_ready, cr_rs_pr_a2_ready);
		else if (rs_pr_b1_ready != cr_rs_pr_b1_ready)
			$display("rs_pr_b1_ready is %b and it should be %b", rs_pr_b1_ready, cr_rs_pr_b1_ready);
		else if (rs_pr_b2_ready != cr_rs_pr_b2_ready)
			$display("rs_pr_b2_ready is %b and it should be %b", rs_pr_b2_ready, cr_rs_pr_b2_ready);
		else
			correct = 1;

		if (~correct)
		begin
			$display("Incorrect at time %4.0f", $time);
			$finish;
		end
	end


	initial
	begin
		$finish;
	end

endmodule
