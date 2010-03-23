/************************************************************
 * 
 * Module name: cdb.v
 * 
 * Description: common data bus
 *
 ************************************************************/

`timescale 1ns/100ps

module cdb (// Inputs
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

endmodule

