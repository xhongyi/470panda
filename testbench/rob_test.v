/////////////////////////////////////////////////////////////////////////
//   EECS470 Project Team Panda                                        //
//                                                                     //
//  ROB Testcases									                   									 //
/////////////////////////////////////////////////////////////////////////

//

`timescale 1ns/100ps
module testbench;

  // Registers and wires used in the testbench
reg reset;
reg clock;

reg [6:0] fl_pr0;
reg [6:0] fl_pr1;
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

reg [1:0]  cre_id_cap;
reg [6:0]  cre_fl_retire_tag_a;
reg [6:0]  cre_fl_retire_tag_b;
reg [6:0]  cre_fl_retire_num;
reg [6:0]  cre_retire_halt;

reg correct;
reg done;

integer i;
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
		if (id_cap != id_cap_pred) begin
			$display("*** incorrect id_cap: %d, predicted: %d ***", id_cap, cre_id_cap);
			correct = 0;
		end
		if ((cre_fl_retire_num != 0) && (fl_retire_tag_a != cre_fl_retire_tag_a)) begin
			$display("*** incorrect fl_retire_tag_a: %d, predicted; %d ***", fl_retire_tag_a, cre_fl_retire_tag_a);
			correct = 0;
		end
		if ((cre_fl_retire_num == 2) && (fl_retire_tag_b != fl_retire_tag_b_pred)) begin
			$display("*** incorrect fl_retire_tag_b: %d, predicted; %d ***", fl_retire_tag_b, cre_fl_retire_tag_b);
			correct = 0;
		end
		if (fl_retire_num != cre_fl_retire_num) begin
			$display("*** incorrect fl_retire_num: %d, predicted; %d ***", fl_retire_num, cre_fl_retire_num);
			correct = 0;
		end
		if (cre_retire_halt != retire_halt) begin
			$display("*** incorrect retire_halt: %d, predicted; %d ***", retire_halt, cre_retire_halt);
			correct = 0;
		end

		if (~correct) begin
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
 fl_pr1 = 0;
 id_dispatch_num = 0;
 id_valid_inst0 = 0;
 id_valid_inst1 = 0;
 mt_p0told = 0;
 mt_p1told = 0;
 id_halt0 = 0;
 id_halt1 = 0;
 cdb_pr_ready = 0;
 cdb_pr_tag_0 = 0;
 cdb_pr_tag_1 = 0;
 cdb_pr_tag_2 = 0;
 cdb_pr_tag_3 = 0;
 cdb_pr_tag_4 = 0;
 cdb_pr_tag_5 = 0;
 reset = 1;
 clock = 0;
 cre_retire_halt = 0;
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
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;
@(negedge clock);
reset=0;

//Halt test #1, insert an halt instruction
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 1;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 0;
mt_p1told = 1;
id_halt0 = 0;
id_halt1 = 1;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Halt test #2, validate the 2 instrcutions.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 1;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;
cre_retire_halt = 0;

//Halt test #3, halt!
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 6'b000000;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 1;
cre_fl_retire_num = 0;
cre_retire_halt = 1;

//Basic test #1, insert ins0 and ins1
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 1;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 0;
mt_p1told = 1;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Basic test #2, insert ins2
@(negedge clock);
fl_pr0 = 2;
fl_pr1 = 0;
id_dispatch_num = 1;
id_valid_inst0  = 1;
id_valid_inst1 = 0;
mt_p0told = 2;
mt_p1told = 0;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Basic test #3, ready ins0 and ins1
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 1;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Basic test #4, ins0 and ins1 shall be retired.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000000;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 1;
cre_fl_retire_num = 2;

//Basic test #5, ins2 shall be valid.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000001;
cdb_pr_tag_0 = 2;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Basic test #6, ins2 shall be retired.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000000;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 2;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 1;

//Advanced test #1, ins3 and ins4 is inserted
@(negedge clock);
fl_pr0 = 3;
fl_pr1 = 4;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 3;
mt_p1told = 4;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Advanced test #2, ins4 shall be valid.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000001;
cdb_pr_tag_0 = 4;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Advanced test #3, Here shall have no output.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000000;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Advanced test #4, ins3 shall be valid.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000001;
cdb_pr_tag_0 = 4;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 0;
cre_fl_retire_tag_b = 0;
cre_fl_retire_num = 0;

//Advanced test #5, ins3 & ins4 shall be retired.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
cdb_pr_ready = 6'b000000;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_fl_retire_tag_a = 3;
cre_fl_retire_tag_b = 4;
cre_fl_retire_num = 2;

//Iteration test
for(i=0; i<32; i=i+1) begin
	@(negedge clock);
	fl_pr0 = i+4;
	fl_pr1 = i+5;
	id_dispatch_num = 2;
	id_valid_inst0 = 1;
	id_valid_inst1 = 1;
	mt_p0told = i+4;
	mt_p1told = i+5;
	cdb_pr_ready = 0;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	if(i < 30)
		cre_id_cap = 2;
	else
		cre_id_cap = 31-i;
	cre_fl_retire_tag_a = 0;
	cre_fl_retire_tag_b = 0;
	cre_fl_retire_num = 0;
end

for(i=31; i>0; i=i-4) begin
@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	cdb_pr_ready = 6'b001111;
	cdb_pr_tag_0 = i+4;
	cdb_pr_tag_1 = i+3;
	cdb_pr_tag_2 = i+2;
	cdb_pr_tag_3 = i+1;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	cre_id_cap = 0;
	cre_fl_retire_tag_a = 0;
	cre_fl_retire_tag_b = 0;
	cre_fl_retire_num = 0;
end

@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	cdb_pr_ready = 6'b000000;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	cre_id_cap = 0;
	cre_fl_retire_tag_a = 4;
	cre_fl_retire_tag_b = 5;
	cre_fl_retire_num = 2;

for(i=2; i<32; i=i+2) begin
@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	cdb_pr_ready = 6'b000000;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	cre_id_cap = 2;
	cre_fl_retire_tag_a = i+4;
	cre_fl_retire_tag_b = i+5;
	cre_fl_retire_num = 2;
end

@(negedge clock);
$finish;
end

endmodule


