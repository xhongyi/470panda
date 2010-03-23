/************************************************************
 * 
 * Module name: cdb.v
 * 
 * Description: common data bus
 *
 ************************************************************/

`timescale 1ns/100ps

module cdb (// Inputs
						clock,
						reset,
						alu_sim_complete0,
						alu_sim_pr_idx0,
						alu_sim_ar_idx0,
						alu_sim_exception0,

						alu_sim_complete1,
						alu_sim_pr_idx1,
						alu_sim_ar_idx1,
						alu_sim_exception1,

						alu_mul_complete0,
						alu_mul_pr_idx0,
						alu_mul_ar_idx0,

						alu_mul_complete1,
						alu_mul_pr_idx1,
						alu_mul_ar_idx1,

						alu_mem_complete0,
						alu_mem_pr_idx0,
						alu_mem_ar_idx0,
						alu_mem_exception0,

						alu_mem_complete1,
						alu_mem_pr_idx1,
						alu_mem_ar_idx1,
						alu_mem_exception1,

						// Outputs
						rs_rob_mt_broadcast,
						rs_rob_mt_pr_tag0,
						rs_rob_mt_pr_tag1,
						rs_rob_mt_pr_tag2,
						rs_rob_mt_pr_tag3,
						rs_rob_mt_pr_tag4,
						rs_rob_mt_pr_tag5,
						mt_ar_tag0,
						mt_ar_tag1,
						mt_ar_tag2,
						mt_ar_tag3,
						mt_ar_tag4,
						mt_ar_tag5,
						rob_exception0,
						rob_exception1,
						rob_exception2,
						rob_exception3,
						rob_exception4,
						rob_exception5
						);
input					clock;
input					reset;
input					alu_sim_complete0;
input	[6:0] 	alu_sim_pr_idx0;
input [4:0]		alu_sim_ar_idx0;
input 				alu_sim_exception0;

input					alu_sim_complete1;
input [6:0]		alu_sim_pr_idx1;
input	[4:0]		alu_sim_ar_idx1;
input 				alu_sim_exception1;

input 				alu_mul_complete0;
input [6:0]   alu_mul_pr_idx0;
input					alu_mul_ar_idx0;

input 				alu_mul_complete1;
input [6:0]		alu_mul_pr_idx1;
input [4:0]		alu_mul_ar_idx1;

input					alu_mem_complete0;
input	[6:0]		alu_mem_pr_idx0;
input [4:0]   alu_mem_ar_idx0;
input 				alu_mem_exception0;

input					alu_mem_complete1;
input [6:0]		alu_mem_pr_idx1;
input [4:0]   alu_mem_ar_idx1;
input 				alu_mem_exception1;

// Outputs
output [5:0]	rs_rob_mt_broadcast;
output [6:0]	rs_rob_mt_pr_tag0;
output [6:0]	rs_rob_mt_pr_tag1;
output [6:0]	rs_rob_mt_pr_tag2;
output [6:0]	rs_rob_mt_pr_tag3;
output [6:0]	rs_rob_mt_pr_tag4;
output [6:0]	rs_rob_mt_pr_tag5;
output [4:0]	mt_ar_tag0;
output [4:0] 	mt_ar_tag1;
output [4:0] 	mt_ar_tag2;
output [4:0]	mt_ar_tag3;
output [4:0]	mt_ar_tag4;
output [4:0]	mt_ar_tag5;
output				rob_exception0;
output				rob_exception1;
output				rob_exception2;
output				rob_exception3;
output				rob_exception4;
output				rob_exception5;


reg [5:0]	rs_rob_mt_broadcast;
reg [6:0]	rs_rob_mt_pr_tag0;
reg [6:0]	rs_rob_mt_pr_tag1;
reg [6:0]	rs_rob_mt_pr_tag2;
reg [6:0]	rs_rob_mt_pr_tag3;
reg [6:0]	rs_rob_mt_pr_tag4;
reg [6:0]	rs_rob_mt_pr_tag5;
reg [4:0]	mt_ar_tag0;
reg [4:0] mt_ar_tag1;
reg [4:0] mt_ar_tag2;
reg [4:0]	mt_ar_tag3;
reg [4:0]	mt_ar_tag4;
reg [4:0]	mt_ar_tag5;
reg				rob_exception0;
reg				rob_exception1;
reg				rob_exception2;
reg				rob_exception3;
reg				rob_exception4;
reg				rob_exception5;

always @ (posedge clock)
begin
		if(reset)
		begin
			rs_rob_mt_broadcast <= `SD 0;
			rs_rob_mt_pr_tag0 <= `SD 0;
			rs_rob_mt_pr_tag1 <= `SD 0;
			rs_rob_mt_pr_tag2 <= `SD 0;
			rs_rob_mt_pr_tag3 <= `SD 0;
			rs_rob_mt_pr_tag4 <= `SD 0;
			rs_rob_mt_pr_tag5 <= `SD 0;
			mt_ar_tag0 <=	`SD 0;
			mt_ar_tag1 <= `SD 0;
			mt_ar_tag2 <= `SD 0;
			mt_ar_tag3 <= `SD 0;
			mt_ar_tag4 <= `SD 0;
			mt_ar_tag5 <= `SD 0;
			rob_exception0 <= `SD 0;
			rob_exception1 <= `SD 0;
			rob_exception2 <= `SD 0;
			rob_exception3 <= `SD 0;
			rob_exception4 <= `SD 0;
			rob_exception5 <= `SD 0;
		end
		else
		begin
			rs_rob_mt_broadcast[0] <= `SD alu_sim_complete0;
			rs_rob_mt_broadcast[1] <= `SD alu_sim_complete1;
			rs_rob_mt_broadcast[2] <= `SD alu_mul_complete0;
			rs_rob_mt_broadcast[3] <= `SD alu_mul_complete1;
			rs_rob_mt_broadcast[4] <= `SD alu_mem_complete0;
			rs_rob_mt_broadcast[5] <= `SD alu_mem_complete1;
			rs_rob_mt_pr_tag0 <= `SD alu_sim_pr_idx0;
			rs_rob_mt_pr_tag1 <= `SD alu_sim_pr_idx1;
			rs_rob_mt_pr_tag2 <= `SD alu_mul_pr_idx0;
			rs_rob_mt_pr_tag3 <= `SD alu_mul_pr_idx1;
			rs_rob_mt_pr_tag4 <= `SD alu_mem_pr_idx0;
			rs_rob_mt_pr_tag5 <= `SD alu_mem_pr_idx1;
			mt_ar_tag0 <=	`SD alu_sim_ar_idx0;
			mt_ar_tag1 <= `SD alu_sim_ar_idx1;
			mt_ar_tag2 <= `SD alu_mul_ar_idx0;
			mt_ar_tag3 <= `SD alu_mul_ar_idx1;
			mt_ar_tag4 <= `SD alu_mem_ar_idx0;
			mt_ar_tag5 <= `SD alu_mem_ar_idx1;
			rob_exception0 <= `SD alu_sim_exception0;
			rob_exception1 <= `SD alu_sim_exception1;
			rob_exception2 <= `SD 0;
			rob_exception3 <= `SD 0;
			rob_exception4 <= `SD alu_mem_exception0;
			rob_exception5 <= `SD alu_mem_exception1;
		end

	end	








endmodule

