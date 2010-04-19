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

						rs_alu_sim_prb_idx0, // New
						rs_alu_sim_prb_idx1,
						
						rs_alu_mul_prb_idx0,
						rs_alu_mul_prb_idx1,

						rs_alu_mem_prb_idx0,
						rs_alu_mem_prb_idx1,

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

						alu_sim_prb_value0, // New 
						alu_sim_prb_value1,

						alu_mem_prb_value0,
						alu_mem_prb_value1,

						alu_mul_prb_value0,
						alu_mul_prb_value1
						);

input				clock;
input				reset;
input	[6:0]	rs_alu_sim_pra_idx0;
input	[6:0]	rs_alu_sim_pra_idx1;
input	[6:0]	rs_alu_mul_pra_idx0;
input	[6:0]	rs_alu_mul_pra_idx1;
input	[6:0]	rs_alu_mem_pra_idx0;
input	[6:0]	rs_alu_mem_pra_idx1;

input	[6:0]	rs_alu_sim_prb_idx0;
input	[6:0]	rs_alu_sim_prb_idx1;
input	[6:0]	rs_alu_mul_prb_idx0;
input	[6:0]	rs_alu_mul_prb_idx1;
input	[6:0]	rs_alu_mem_prb_idx0;
input	[6:0]	rs_alu_mem_prb_idx1;

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

input					alu_mem_wr_enable1;
input	[6:0]		alu_mem_pr_idx1;
input	[63:0]	alu_mem_pr_value1;

	// Outputs
output	[63:0]	alu_sim_pra_value0;
output	[63:0]	alu_sim_pra_value1;
output	[63:0]	alu_mem_pra_value0;
output	[63:0]	alu_mem_pra_value1;
output	[63:0]	alu_mul_pra_value0;
output	[63:0]	alu_mul_pra_value1;

output	[63:0]	alu_sim_prb_value0;
output	[63:0]	alu_sim_prb_value1;
output	[63:0]	alu_mem_prb_value0;
output	[63:0]	alu_mem_prb_value1;
output	[63:0]	alu_mul_prb_value0;
output	[63:0]	alu_mul_prb_value1;


//Internal Memory

reg [63:0] register [95:0];

//Update on Internal Memory

reg [63:0] next_register[95:0];

//integers

integer i;

//Read

assign alu_sim_pra_value0 = register[rs_alu_sim_pra_idx0];
assign alu_sim_pra_value1 = register[rs_alu_sim_pra_idx1];
assign alu_mul_pra_value0 = register[rs_alu_mul_pra_idx0];
assign alu_mul_pra_value1 = register[rs_alu_mul_pra_idx1];
assign alu_mem_pra_value0 = register[rs_alu_mem_pra_idx0];
assign alu_mem_pra_value1 = register[rs_alu_mem_pra_idx1];

assign alu_sim_prb_value0 = register[rs_alu_sim_prb_idx0];
assign alu_sim_prb_value1 = register[rs_alu_sim_prb_idx1];
assign alu_mul_prb_value0 = register[rs_alu_mul_prb_idx0];
assign alu_mul_prb_value1 = register[rs_alu_mul_prb_idx1];
assign alu_mem_prb_value0 = register[rs_alu_mem_prb_idx0];
assign alu_mem_prb_value1 = register[rs_alu_mem_prb_idx1];

//Write

always @*
begin
	for (i = 0; i < 96; i = i+1)
		next_register[i] = register[i];
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
	begin
	  for ( i = 0; i < 96; i = i + 1)
		begin
			register[i] <= `SD 0;
		end
	end
	else
	begin
		for ( i = 0; i < 96; i = i + 1)
		begin
			register[i] <= `SD next_register[i];
		end
	end
end

genvar IDX;
generate
	for(IDX=0; IDX<96; IDX=IDX+1)
	begin : foo
wire	[63:0]	XREGISTER = register[IDX];
wire	[63:0]	XNEXT_REGISTER = next_register[IDX];
	end
endgenerate

endmodule
