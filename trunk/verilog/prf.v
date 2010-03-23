/************************************************************
 * 
 * Module name: prf.v
 * 
 * Description: physical register file
 *
 ************************************************************/

`timescale 1ns/100ps

module prf (// Inputs
						clock,
						reset,
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
						alu_mul_pra_value1
						);

input				clock;
input				reset;
input	[6:0]	rs_alu_sim_pra_idx0;
input	[6:0]	rs_alu_sim_pra_idx1;
	
input	[6:0]	rs_alu_mul_pra_idx0;
input	[6:0]	rs_alu_mul_pra_idx1;

input	[6:0]	rs_alu_mem_pra_idx0;
input	[6:0]	rs_alu_mem_pra_idx1;

input					alu_sim_wr_enable0;
input	[6:0]		alu_sim_pr_idx0;
input	[63:0]	alu_sim_pr_value0;

input					alu_sim_wr_enable1;
input	[6:0]		alu_sim_pr_idx1;
input	[63:0]	alu_sim_pr_value1;

input					alu_mul_wr_enable0;
input	[6:0]		alu_mul_pr_idx0;
input	[63:0]	alu_mul_pr_value0;

input					alu_mul_wr_enable1;
input	[6:0]		alu_mul_pr_idx1;
input	[63:0]	alu_mul_pr_value1;

input					alu_mem_wr_enable0;
input	[6:0]		alu_mem_pr_idx0;
input	[63:0]	alu_mem_pr_value0;

input					alu_mem_wr_enable1,
input	[6:0]		alu_mem_pr_idx1,
input	[63:0]	alu_mem_pr_value1,

	// Outputs
output	[63:0]	alu_sim_pra_value0,
output	[63:0]	alu_sim_pra_value1,

output	[63:0]	alu_mem_pra_value0,
output	[63:0]	alu_mem_pra_value1,

output	[63:0]	alu_mul_pra_value0,
output	[63:0]	alu_mul_pra_value1,

//Internal Memory

reg [63:0] register [95:0];

//Update on Internal Memory

reg [63:0] next_register[95:0];


//Read

assign alu_sim_pra_value0 = register[rs_alu_sim_pra_idx0];
assign alu_sim_pra_value1 = register[rs_alu_sim_pra_idx1];
assign alu_mul_pra_value0 = register[rs_alu_mul_pra_idx0];
assign alu_mul_pra_value1 = register[rs_alu_mul_pra_idx1];
assign alu_mem_pra_value0 = register[rs_alu_mem_pra_idx0];
assign alu_mem_pra_value1 = register[rs_alu_mem_pra_idx1];

//Write

always @*
begin
	next_register = register;
	if(alu_sim_wr_enable0) next_register[alu_sim_pr_idx0] = alu_sim_pr_value0;
	if(alu_sim_wr_enable1) next_register[alu_sim_pr_idx1] = alu_sim_pr_value1;
	if(alu_mul_wr_enable0) next_register[alu_mul_pr_idx0] = alu_mul_pr_value0;
	if(alu_mul_wr_enable1) next_register[alu_mul_pr_idx1] = alu_mul_pr_value1;
	if(alu_mem_wr_enable0) next_register[alu_mem_pr_idx0] = alu_mem_pr_value0;
	if(alu_mem_wr_enable1) next_register[alu_mem_pr_idx1] = alu_mem_pr_value1;
end

//Update Internal State
always @ (posedge clock)
begin
	if(reset) 
	register <= `SD next_register;
end


endmodule
