/************************************************************
 * 
 * Module name: prf.v
 * 
 * Description: Top-level module of panda pipeline
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

						// Outputs
						alu_sim_pra_value0,
						alu_sim_pra_value1,

						alu_mem_pra_value0,
						alu_mem_pra_value1,

						alu_mul_pra_value0,
						alu_mul_pra_value1,
						);


endmodule
