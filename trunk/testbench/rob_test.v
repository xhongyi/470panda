/////////////////////////////////////////////////////////////////////////
//   EECS470 Project Team Panda                                        //
//                                                                     //
//  ROB Testcases									                   //
/////////////////////////////////////////////////////////////////////////

//

`timescale 1ns/100ps
module testbench;

  // Registers and wires used in the testbench
reg reset;
reg clock;

reg [6:0] fl_pr0;
reg [6:0] fl_pr1;
reg [1:0] rs_avail;
reg [6:0] mt_p0told;
reg [6:0] mt_p1told;
reg [1:0] id_dispatch_num;
reg 	  id_valid_inst0;
reg		  id_valid_inst1;
reg			id_halt0;
reg			id_halt1;

reg [5:0] cdb_pr_ready; //Note: the bandwidth is CDB_WIDTH;
reg [6:0] cdb_pr_tag_0;  //Note: the bandwidth is CDB_WIDTH;
reg [6:0] cdb_pr_tag_1;
reg [6:0] cdb_pr_tag_2;
reg [6:0] cdb_pr_tag_3;
reg [6:0] cdb_pr_tag_4;
reg [6:0] cdb_pr_tag_5;

wire [1:0] id_cap;

wire [6:0] fl_retire_tag_a;
wire [6:0] fl_retire_tag_b;
wire [1:0] fl_retire_num;

wire	retire_halt;


reg [1:0]  id_cap_pred;
reg [6:0]  fl_retire_tag_a_pred;
reg [6:0]  fl_retire_tag_b_pred;
reg [6:0]  fl_retire_num_pred;



reg correct;
reg done;
  // Instantiate the Pipeline
rob testee(//inputs
			reset,
			clock,
			//dispatch
			fl_pr0,
			fl_pr1,
			mt_p0told,
			mt_p1told,
			id_dispatch_num,
			id_valid_inst0,
			id_valid_inst1,
			id_halt0,
			id_halt1,
			//complete
			cdb_pr_ready,
			cdb_pr_tag_0,
			cdb_pr_tag_1,
			cdb_pr_tag_2,
			cdb_pr_tag_3,
			cdb_pr_tag_4,
			cdb_pr_tag_5,
			//outputs
			//dispatch
			id_cap,
			//retire
			fl_retire_tag_a,
			fl_retire_tag_b,
			fl_retire_num,

			retire_halt //new it is true when halt inst is retired

);
	
// Compare the results with the correct ones
	always @(posedge clock)
	begin
		#(`VERILOG_CLOCK_PERIOD/4.0);
		correct = 1;
		if (id_cap != id_cap_pred)
			$display("*** incorrect id_cap: %d, predicted: %d ***", id_cap, id_cap_pred);
		else if (fl_retire_tag_a != fl_retire_tag_a_pred)
			$display("*** incorrect fl_retire_tag_a: %d, predicted; %d ***", fl_retire_tag_a, fl_retire_tag_a_pred);
		else if (fl_retire_tag_b != fl_retire_tag_b_pred)
			$display("*** incorrect fl_retire_tag_b: %d, predicted; %d ***", fl_retire_tag_b, fl_retire_tag_b_pred);
		else if (fl_retire_num != fl_retire_num_pred)
			$display("*** incorrect fl_retire_num: %d, predicted; %d ***", fl_retire_tag_a, fl_retire_tag_a_pred);
		
		else
			correct = 1;

		if (~correct)
		begin
			$display("*** Incorrect at time %4.0f\n", $time);
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
  $monitor("Time:%4.0f fl_pr0: %h\n fl_pr1: %h\n id_dispatch_num: %h\n mt_p0told: %h\n mt_p1told: %h\n cdb_pr_ready: %h\n cdb_pr_tag_0: %h\n cdb_pr_tag_1: %h\n cdb_pr_tag_2: %h\n cdb_pr_tag_3: %h\n  id_cap: %h\n fl_retire_tag_a: %h\n fl_retire_tag_b: %h\n fl_retire_num: %h",$time, fl_pr0, fl_pr1, id_dispatch_num, mt_p0told, mt_p1told, cdb_pr_ready, cdb_pr_tag_0, cdb_pr_tag_1, cdb_pr_tag_2, cdb_pr_tag_3, id_cap ,fl_retire_tag_a, fl_retire_tag_b, fl_retire_num);
 
 fl_pr0 = 0;
 fl_pr1 = 1;
 id_dispatch_num = 0;
 id_valid_inst0 = 0;
 id_valid_inst1 = 0;
 mt_p0told = 0;
 mt_p1told = 0;
 cdb_pr_ready = 0;
 cdb_pr_tag_0 = 0;
 cdb_pr_tag_1 = 0;
 cdb_pr_tag_2 = 0;
 cdb_pr_tag_3 = 0;
 cdb_pr_tag_4 = 0;
 cdb_pr_tag_5 = 0;
 reset = 1;
 clock = 0;
//test reset and 1 dispatch with 0 retire.
@(negedge clock);
//scenario
fl_pr0 = 32;
fl_pr1 = 33;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 4;
mt_p1told = 5;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 27;
cdb_pr_tag_1 = 28;
cdb_pr_tag_2 = 29;
cdb_pr_tag_3 = 30;
cdb_pr_tag_4 = 31;
cdb_pr_tag_5 = 32;
//prediction


@(negedge clock);
reset=0;
@(negedge clock);

fl_pr0 = 34;
fl_pr1 = 35;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 4;
mt_p1told = 5;
cdb_pr_ready = 6'b1111;
cdb_pr_tag_0 = 27;
cdb_pr_tag_1 = 28;
cdb_pr_tag_2 = 29;
cdb_pr_tag_3 = 32;
cdb_pr_tag_4 = 33;
cdb_pr_tag_5 = 34;
//prediction

@(negedge clock);

fl_pr0 = 36;
fl_pr1 = 37;
id_dispatch_num = 2;
id_valid_inst0 = 0;
id_valid_inst1 = 1;
mt_p0told = 6;
mt_p1told = 7;
cdb_pr_ready = 6'b111111;
cdb_pr_tag_0 = 30;
cdb_pr_tag_1 = 31;
cdb_pr_tag_2 = 32;
cdb_pr_tag_3 = 33;
cdb_pr_tag_4 = 34;
cdb_pr_tag_5 = 35;
//prediction


@(negedge clock);
$finish;
end

endmodule


