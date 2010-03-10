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

reg [31:0] inst0;
reg [63:0] pc0;
reg [31:0] inst1;
reg [63:0] pc1;

reg [6:0] fl_pr0;
reg [6:0] fl_pr1;
reg [1:0] rs_avail;
reg [6:0] mt_p0told;
reg [6:0] mt_p1told;

reg [3:0] cdb_pr_ready; //Note: the bandwidth is CDB_WIDTH;
reg [6:0] cdb_pr_tag_0;  //Note: the bandwidth is CDB_WIDTH;
reg [6:0] cdb_pr_tag_1;
reg [6:0] cdb_pr_tag_2;
reg [6:0] cdb_pr_tag_3;


wire [63:0] tail_pc;

wire [4:0] rs_mt_ar_a;
wire [4:0] rs_mt_ar_b;
wire [4:0] mt_ar_a1;
wire [4:0] mt_ar_b1;
wire [4:0] mt_ar_a2;
wire [4:0] mt_ar_b2;
wire 		 mt_ar_a1_valid;
wire		 mt_ar_b1_valid;
wire 		 mt_ar_a2_valid;
wire		 mt_ar_b2_valid;
wire [20:0] rs_immediate0;
wire [20:0] rs_immediate1;
wire [5:0]  rs_opcode0;
wire [5:0]  rs_opcode1;
wire [1:0] rs_mt_fl_dispatch_num;

wire [6:0] fl_retire_tag_a;
wire [6:0] fl_retire_tag_b;
wire [1:0] fl_retire_num;


reg correct;
reg done;
  // Instantiate the Pipeline
rob    testee (//inputs
			reset,
			clock,
			//fetch
			inst0,
			inst1,
			pc0,
			pc1,
			//dispatch
			fl_pr0,
			fl_pr1,
			rs_avail,
			mt_p0told,
			mt_p1told,
			//complete
			cdb_pr_ready,
			cdb_pr_tag_0,
			cdb_pr_tag_1,
			cdb_pr_tag_2,
			cdb_pr_tag_3,
			//outputs
			//fetch
			tail_pc,
			//dispatch
			rs_mt_ar_a,
			rs_mt_ar_b,
			mt_ar_a1,
			mt_ar_b1,
			mt_ar_a2,
			mt_ar_b2,
			rs_mt_ar_a_valid,
			rs_mt_ar_b_valid,
			mt_ar_a1_valid,
			mt_ar_a2_valid,
			mt_ar_b1_valid,
			mt_ar_b2_valid,
			rs_immediate0,
			rs_immediate1,
			rs_opcode0,
			rs_opcode1,
			//rs_inst0,
			//rs_inst1,
			rs_mt_fl_dispatch_num,
			//retire
			fl_retire_tag_a,
			fl_retire_tag_b,
			fl_retire_num



);
	
always @(posedge clock)
begin
  correct  = 1;
  //3# 
  if(!correct) begin 
    $display("Incorrect at time %4.0f",$time);
    //$display("cres = %h result = %h",cres,result);
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
  $monitor("Time:%4.0f inst0: %h inst1: %h pc0: %h pc1: %h fl_pr0: %h fl_pr1: %h rs_avail: %h mt_p0told: %h mt_p1told: %h cdb_pr_ready: %h cdb_pr_tag_0: %h cdb_pr_tag_1: %h cdb_pr_tag_2: %h cdb_pr_tag_3: %h tail_pc: %h mt_ar_a: %h mt_ar_b: %h mt_ar_a1: %h mt_ar_b1: %h mt_ar_a2: %h mt_ar_b2: %h mt_ar_ar_a1_valid: %h mt_ar_a2_valid: %h mt_ar_b1_valid: %h mt_ar_b2_valid: %h rs_immediate0: %h rs_immediate1: %h rs_opcode0: %h rs_opcode1: %h rs_mt_fl_dispatch_num: %h fl_retire_tag_a: %h fl_retire_tag_b: %h fl_retire_num: %h",$time,inst0, inst1, pc0, pc1, fl_pr0, fl_pr1, rs_avail, mt_p0told, mt_p1told, cdb_pr_ready, cdb_pr_tag_0, cdb_pr_tag_1, cdb_pr_tag_2, cdb_pr_tag_3, tail_pc, rs_mt_ar_a,rs_mt_ar_b, mt_ar_a1, mt_ar_b1, mt_ar_a2, mt_ar_b2, mt_ar_a1_valid, mt_ar_a2_valid, mt_ar_b1_valid, mt_ar_b2_valid, rs_immediate0, rs_immediate1, rs_opcode0, rs_opcode1, rs_mt_fl_dispatch_num,fl_retire_tag_a, fl_retire_tag_b, fl_retire_num);
 inst0 = 0;
 inst1 = 0;
 pc0 = 0;
 pc1 = 4;
 fl_pr0 = 0;
 fl_pr1 = 1;
 rs_avail = 0;
 mt_p0told = 0;
 mt_p1told = 0;
 cdb_pr_ready = 0;
 cdb_pr_tag_0 = 0;
 cdb_pr_tag_1 = 0;
 cdb_pr_tag_2 = 0;
 cdb_pr_tag_3 = 0;
 reset = 1;
 clock = 1;
//test reset and 1 dispatch with 0 retire.
@(negedge clock);
//scenario
inst0 = 32'h12345678;
inst1 = 32'h23456789;
pc0 = 4;
pc1 = 8;
fl_pr0 = 32;
fl_pr1 = 33;
rs_avail = 2;
mt_p0told = 4;
mt_p1told = 5;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 27;
cdb_pr_tag_1 = 28;
cdb_pr_tag_2 = 29;
cdb_pr_tag_3 =30;
//prediction
correct = 1;

@(negedge clock);
reset=0;
@(negedge clock);
inst0 = 32'h82345678;
inst1 = 32'hc3456789;
pc0 = 12;
pc1 = 16;
fl_pr0 = 34;
fl_pr1 = 35;
rs_avail = 0;
mt_p0told = 4;
mt_p1told = 5;
cdb_pr_ready = 3;
cdb_pr_tag_0 = 27;
cdb_pr_tag_1 = 28;
cdb_pr_tag_2 = 29;
cdb_pr_tag_3 =32;
//prediction
correct = 1;
@(negedge clock);
inst0 = 32'hc2345678;
inst1 = 32'hf3456789;
pc0 = 16;
pc1 = 20;
fl_pr0 = 36;
fl_pr1 = 37;
rs_avail = 2;
mt_p0told = 6;
mt_p1told = 7;
cdb_pr_ready = 3;
cdb_pr_tag_0 = 30;
cdb_pr_tag_1 = 31;
cdb_pr_tag_2 = 32;
cdb_pr_tag_3 =33;
//prediction
correct = 1;
@(negedge clock);

@(negedge clock);
//test 2 dispatch with 0 retire.
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);




$finish;
end

endmodule


