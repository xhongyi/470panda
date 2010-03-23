/************************************************************
 * 
 * Module name: prf.v
 * 
 * Description: physical register file
 *
 ************************************************************/

`timescale 1ns/100ps

module prf (// Inputs
						rs_alu_sim_pra_idx0,
						rs_alu_sim_pra_idx1,
						
						rs_alu_mul_pra_idx0,
						rs_alu_mul_pra_idx1,

						rs_alu_mem_pra_idx0,
						rs_alu_mem_pra_idx1,

						alu_sim_wr_enable0,
						alu_sim_pr_idx0,
						alu_sim_pr_value0,

						alu_sim_wr_enable1,
						alu_sim_pr_idx1,
						alu_sim_pr_value1,

						alu_mul_wr_enable0,
						alu_mul_pr_idx0,
						alu_mul_pr_value0,

						alu_mul_wr_enable1,
						alu_mul_pr_idx1,
						alu_mul_pr_value1,

						alu_mem_wr_enable0,
						alu_mem_pr_idx0,
						alu_mem_pr_value0,

						alu_mem_wr_enable1,
						alu_mem_pr_idx1,
						alu_mem_pr_value1,

						// Outputs
						alu_sim_pra_value0,
						alu_sim_pra_value1,

						alu_mem_pra_value0,
						alu_mem_pra_value1,

						alu_mul_pra_value0,
						alu_mul_pra_value1,
						);


endmodule
