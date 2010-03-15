/*************************************************************
 *
 * Module: 				rs.v
 *	
 * Description:		Reservation station
 *
 *************************************************************/

module rs(// Inputs
						clock,
						reset,
				
					// Dispatch inputs
						id_NPC0,
						id_IR0,
						id_branch_taken0,
						id_pred_addr0,
						id_opa_select0,
						id_opb_select0,
						id_dest_idx0,
						id_alu_func0,
						id_rd_mem0,
						id_wr_mem0,
						id_cond_branch0,
						id_uncond_branch0,
						id_halt0,
						id_illegal_inst0,
						id_valid_inst0,

						id_NPC1,
						id_IR1,
						id_branch_taken1,
						id_pred_addr1,
						id_opa_select1,
						id_opb_select1,
						id_dest_idx1,
						id_alu_func1,
						id_rd_mem1,
						id_wr_mem1,
						id_cond_branch1,
						id_uncond_branch1,
						id_halt1,
						id_illegal_inst1,
						id_valid_inst1,

						id_dispatch_num,

						mt_pr_dest_idx0,
						mt_pra_idx0,
						mt_prb_idx0,
						mt_pra_ready0, // *** If the reg is not valid, it is ready ***
						mt_prb_ready0,

						mt_pr_dest_idx1,
						mt_pra_idx1,
						mt_prb_idx1,
						mt_pra_ready1, // *** If the reg is not valid, it is ready ***
						mt_prb_ready1,

					// Issue inputs
						alu_sim_avail, // For the simple calculations
						alu_mul_avail, // For the multiplication unit
						alu_mem_avail, // For access the memory

					// Complete inputs
						cdb_broadcast,
						cdb_pr_tag0,
						cdb_pr_tag1,
						cdb_pr_tag2,
						cdb_pr_tag3,
						cdb_pr_tag4,
						cdb_pr_tag5,

					// Dispatch outputs
						id_rs_cap,

					// Issue outputs
						alu_sim_NPC0,
						alu_sim_NPC1,
						alu_sim_IR0,
						alu_sim_IR1,

						alu_sim_branch_taken0,
						alu_sim_branch_taken1,
						alu_sim_pred_addr0,
						alu_sim_pred_addr1,

						alu_sim_prf_pra_idx0, // Go to physical register file to get the value
						alu_sim_prf_pra_idx1,
						alu_sim_prf_prb_idx0,
						alu_sim_prf_prb_idx1,

						alu_sim_opa_select0,
						alu_sim_opa_select1,
						alu_sim_opb_select0,
						alu_sim_opb_select1,
						
						alu_sim_dest_ar_idx0,
						alu_sim_dest_ar_idx1,
						alu_sim_dest_pr_idx0,
						alu_sim_dest_pr_idx1,
						alu_sim_func0,
						alu_sim_func1,

						alu_sim_rd_mem0,
						alu_sim_rd_mem1,
						alu_sim_wr_mem0,
						alu_sim_wr_mem1,

						alu_sim_cond_branch0,
						alu_sim_cond_branch1,
						alu_sim_uncond_branch0,
						alu_sim_uncond_branch1,
						alu_sim_halt0,
						alu_sim_halt1,

						alu_sim_illegal_inst0,
						alu_sim_illegal_inst1,
						alu_sim_valid_inst0,
						alu_sim_valid_inst1,

						alu_mul_NPC0,
						alu_mul_NPC1,
						alu_mul_IR0,
						alu_mul_IR1,

						alu_mul_branch_taken0,
						alu_mul_branch_taken1,
						alu_mul_pred_addr0,
						alu_mul_pred_addr1,

						alu_mul_prf_pra_idx0, // Go to physical register file to get the value
						alu_mul_prf_pra_idx1,
						alu_mul_prf_prb_idx0,
						alu_mul_prf_prb_idx1,

						alu_mul_opa_select0,
						alu_mul_opa_select1,
						alu_mul_opb_select0,
						alu_mul_opb_select1,
						
						alu_mul_dest_ar_idx0,
						alu_mul_dest_ar_idx1,
						alu_mul_dest_pr_idx0,
						alu_mul_dest_pr_idx1,
						alu_mul_func0,
						alu_mul_func1,

						alu_mul_rd_mem0,
						alu_mul_rd_mem1,
						alu_mul_wr_mem0,
						alu_mul_wr_mem1,

						alu_mul_cond_branch0,
						alu_mul_cond_branch1,
						alu_mul_uncond_branch0,
						alu_mul_uncond_branch1,
						alu_mul_halt0,
						alu_mul_halt1,

						alu_mul_illegal_inst0,
						alu_mul_illegal_inst1,
						alu_mul_valid_inst0,
						alu_mul_valid_inst1,

						alu_mem_NPC0,
						alu_mem_NPC1,
						alu_mem_IR0,
						alu_mem_IR1,

						alu_mem_branch_taken0,
						alu_mem_branch_taken1,
						alu_mem_pred_addr0,
						alu_mem_pred_addr1,

						alu_mem_prf_pra_idx0, // Go to physical register file to get the value
						alu_mem_prf_pra_idx1,
						alu_mem_prf_prb_idx0,
						alu_mem_prf_prb_idx1,

						alu_mem_opa_select0,
						alu_mem_opa_select1,
						alu_mem_opb_select0,
						alu_mem_opb_select1,
						
						alu_mem_dest_ar_idx0,
						alu_mem_dest_ar_idx1,
						alu_mem_dest_pr_idx0,
						alu_mem_dest_pr_idx1,
						alu_mem_func0,
						alu_mem_func1,

						alu_mem_rd_mem0,
						alu_mem_rd_mem1,
						alu_mem_wr_mem0,
						alu_mem_wr_mem1,

						alu_mem_cond_branch0,
						alu_mem_cond_branch1,
						alu_mem_uncond_branch0,
						alu_mem_uncond_branch1,
						alu_mem_halt0,
						alu_mem_halt1,

						alu_mem_illegal_inst0,
						alu_mem_illegal_inst1,
						alu_mem_valid_inst0,
						alu_mem_valid_inst1
						);

`ifndef NUM_RS_ENTRIES
`define	NUM_RS_ENTRIES	32
`endif

`ifndef	LOG_NUM_RS_ENTRIES
`define	LOG_NUM_RS_ENTRIES	5
`endif

input					clock;
input					reset;

input	 [63:0]	id_NPC0;
input	 [31:0]	id_IR0;
input					id_branch_taken0;
input	 [63:0]	id_pred_addr0;
input		[1:0]	id_opa_select0;
input		[1:0]	id_opb_select0;
input		[4:0]	id_dest_idx0;
input		[4:0]	id_alu_func0;
input					id_rd_mem0;
input					id_wr_mem0;
input					id_cond_branch0;
input					id_uncond_branch0;
input					id_halt0;
input					id_illegal_inst0;
input					id_valid_inst0;


input	 [63:0]	id_NPC1;
input	 [31:0]	id_IR1;
input					id_branch_taken1;
input	 [63:0]	id_pred_addr1;
input		[1:0]	id_opa_select1;
input		[1:0]	id_opb_select1;
input		[4:0]	id_dest_idx1;
input		[4:0]	id_alu_func1;
input					id_rd_mem1;
input					id_wr_mem1;
input					id_cond_branch1;
input					id_uncond_branch1;
input					id_halt1;
input					id_illegal_inst1;
input					id_valid_inst1;

input		[1:0]	id_dispatch_num;

input		[6:0]	mt_pr_dest_idx0;
input		[6:0]	mt_pra_idx0;
input		[6:0]	mt_prb_idx0;
input					mt_pra_ready0; // *** If the reg is not valid, it is ready ***
input					mt_prb_ready0;

input		[6:0]	mt_pr_dest_idx1;
input		[6:0]	mt_pra_idx1;
input		[6:0]	mt_prb_idx1;
input					mt_pra_ready1; // *** If the reg is not valid, it is ready ***
input					mt_prb_ready1;

// Issue inputs
input		[1:0]	alu_sim_avail; // For the simple calculations
input		[1:0]	alu_mul_avail; // For the multiplication unit
input		[1:0]	alu_mem_avail; // For access the memory

// Complete inputs
input		[5:0]	cdb_broadcast;
input		[6:0]	cdb_pr_tag0;
input		[6:0]	cdb_pr_tag1;
input		[6:0]	cdb_pr_tag2;
input		[6:0]	cdb_pr_tag3;
input		[6:0]	cdb_pr_tag4;
input		[6:0]	cdb_pr_tag5;


// Dispatch outputs
output	[1:0]	id_rs_cap;

// Issue outputs
output [63:0]	alu_sim_NPC0;
output [63:0]	alu_sim_NPC1;
output [31:0] alu_sim_IR0;
output [31:0]	alu_sim_IR1;

output				alu_sim_branch_taken0;
output				alu_sim_branch_taken1;
output [63:0]	alu_sim_pred_addr0;
output [63:0]	alu_sim_pred_addr1;

output 	[6:0]	alu_sim_prf_pra_idx0; // Go to physical register file to get the value
output	[6:0]	alu_sim_prf_pra_idx1;
output	[6:0]	alu_sim_prf_prb_idx0;
output	[6:0]	alu_sim_prf_prb_idx1;

output	[1:0]	alu_sim_opa_select0;
output	[1:0]	alu_sim_opa_select1;
output	[1:0]	alu_sim_opb_select0;
output	[1:0]	alu_sim_opb_select1;

output	[4:0]	alu_sim_dest_ar_idx0;
output	[4:0]	alu_sim_dest_ar_idx1;
output	[6:0]	alu_sim_dest_pr_idx0;
output	[6:0]	alu_sim_dest_pr_idx1;
output	[4:0]	alu_sim_func0;
output	[4:0]	alu_sim_func1;

output				alu_sim_rd_mem0;
output				alu_sim_rd_mem1;
output				alu_sim_wr_mem0;
output				alu_sim_wr_mem1;

output				alu_sim_cond_branch0;
output				alu_sim_cond_branch1;
output				alu_sim_uncond_branch0;
output				alu_sim_uncond_branch1;
output				alu_sim_halt0;
output				alu_sim_halt1;

output				alu_sim_illegal_inst0;
output				alu_sim_illegal_inst1;
output				alu_sim_valid_inst0;
output				alu_sim_valid_inst1;

output [63:0]	alu_mul_NPC0;
output [63:0]	alu_mul_NPC1;
output [31:0] alu_mul_IR0;
output [31:0]	alu_mul_IR1;

output				alu_mul_branch_taken0;
output				alu_mul_branch_taken1;
output [63:0]	alu_mul_pred_addr0;
output [63:0]	alu_mul_pred_addr1;

output 	[6:0]	alu_mul_prf_pra_idx0; // Go to physical register file to get the value
output	[6:0]	alu_mul_prf_pra_idx1;
output	[6:0]	alu_mul_prf_prb_idx0;
output	[6:0]	alu_mul_prf_prb_idx1;

output	[1:0]	alu_mul_opa_select0;
output	[1:0]	alu_mul_opa_select1;
output	[1:0]	alu_mul_opb_select0;
output	[1:0]	alu_mul_opb_select1;

output	[4:0]	alu_mul_dest_ar_idx0;
output	[4:0]	alu_mul_dest_ar_idx1;
output	[6:0]	alu_mul_dest_pr_idx0;
output	[6:0]	alu_mul_dest_pr_idx1;
output	[4:0]	alu_mul_func0;
output	[4:0]	alu_mul_func1;

output				alu_mul_rd_mem0;
output				alu_mul_rd_mem1;
output				alu_mul_wr_mem0;
output				alu_mul_wr_mem1;

output				alu_mul_cond_branch0;
output				alu_mul_cond_branch1;
output				alu_mul_uncond_branch0;
output				alu_mul_uncond_branch1;
output				alu_mul_halt0;
output				alu_mul_halt1;

output				alu_mul_illegal_inst0;
output				alu_mul_illegal_inst1;
output				alu_mul_valid_inst0;
output				alu_mul_valid_inst1;

output [63:0]	alu_mem_NPC0;
output [63:0]	alu_mem_NPC1;
output [31:0] alu_mem_IR0;
output [31:0]	alu_mem_IR1;

output				alu_mem_branch_taken0;
output				alu_mem_branch_taken1;
output [63:0]	alu_mem_pred_addr0;
output [63:0]	alu_mem_pred_addr1;

output 	[6:0]	alu_mem_prf_pra_idx0; // Go to physical register file to get the value
output	[6:0]	alu_mem_prf_pra_idx1;
output	[6:0]	alu_mem_prf_prb_idx0;
output	[6:0]	alu_mem_prf_prb_idx1;

output	[1:0]	alu_mem_opa_select0;
output	[1:0]	alu_mem_opa_select1;
output	[1:0]	alu_mem_opb_select0;
output	[1:0]	alu_mem_opb_select1;

output	[4:0]	alu_mem_dest_ar_idx0;
output	[4:0]	alu_mem_dest_ar_idx1;
output	[6:0]	alu_mem_dest_pr_idx0;
output	[6:0]	alu_mem_dest_pr_idx1;
output	[4:0]	alu_mem_func0;
output	[4:0]	alu_mem_func1;

output				alu_mem_rd_mem0;
output				alu_mem_rd_mem1;
output				alu_mem_wr_mem0;
output				alu_mem_wr_mem1;

output				alu_mem_cond_branch0;
output				alu_mem_cond_branch1;
output				alu_mem_uncond_branch0;
output				alu_mem_uncond_branch1;
output				alu_mem_halt0;
output				alu_mem_halt1;

output				alu_mem_illegal_inst0;
output				alu_mem_illegal_inst1;
output				alu_mem_valid_inst0;
output				alu_mem_valid_inst1;

reg	 [63:0]	alu_sim_NPC0;
reg	 [63:0]	alu_sim_NPC1;
reg	 [31:0] alu_sim_IR0;
reg	 [31:0]	alu_sim_IR1;

reg					alu_sim_branch_taken0;
reg					alu_sim_branch_taken1;
reg	 [63:0]	alu_sim_pred_addr0;
reg	 [63:0]	alu_sim_pred_addr1;

reg	 	[6:0]	alu_sim_prf_pra_idx0; // Go to physical register file to get the value
reg		[6:0]	alu_sim_prf_pra_idx1;
reg		[6:0]	alu_sim_prf_prb_idx0;
reg		[6:0]	alu_sim_prf_prb_idx1;

reg		[1:0]	alu_sim_opa_select0;
reg		[1:0]	alu_sim_opa_select1;
reg		[1:0]	alu_sim_opb_select0;
reg		[1:0]	alu_sim_opb_select1;

reg		[4:0]	alu_sim_dest_ar_idx0;
reg		[4:0]	alu_sim_dest_ar_idx1;
reg		[6:0]	alu_sim_dest_pr_idx0;
reg		[6:0]	alu_sim_dest_pr_idx1;
reg		[4:0]	alu_sim_func0;
reg		[4:0]	alu_sim_func1;

reg					alu_sim_rd_mem0;
reg					alu_sim_rd_mem1;
reg					alu_sim_wr_mem0;
reg					alu_sim_wr_mem1;

reg					alu_sim_cond_branch0;
reg					alu_sim_cond_branch1;
reg					alu_sim_uncond_branch0;
reg					alu_sim_uncond_branch1;
reg					alu_sim_halt0;
reg					alu_sim_halt1;

reg					alu_sim_illegal_inst0;
reg					alu_sim_illegal_inst1;
reg					alu_sim_valid_inst0;
reg					alu_sim_valid_inst1;

reg	 [63:0]	alu_mul_NPC0;
reg	 [63:0]	alu_mul_NPC1;
reg	 [31:0] alu_mul_IR0;
reg	 [31:0]	alu_mul_IR1;

reg					alu_mul_branch_taken0;
reg					alu_mul_branch_taken1;
reg	 [63:0]	alu_mul_pred_addr0;
reg	 [63:0]	alu_mul_pred_addr1;

reg	 	[6:0]	alu_mul_prf_pra_idx0; // Go to physical register file to get the value
reg		[6:0]	alu_mul_prf_pra_idx1;
reg		[6:0]	alu_mul_prf_prb_idx0;
reg		[6:0]	alu_mul_prf_prb_idx1;

reg		[1:0]	alu_mul_opa_select0;
reg		[1:0]	alu_mul_opa_select1;
reg		[1:0]	alu_mul_opb_select0;
reg		[1:0]	alu_mul_opb_select1;

reg		[4:0]	alu_mul_dest_ar_idx0;
reg		[4:0]	alu_mul_dest_ar_idx1;
reg		[6:0]	alu_mul_dest_pr_idx0;
reg		[6:0]	alu_mul_dest_pr_idx1;
reg		[4:0]	alu_mul_func0;
reg		[4:0]	alu_mul_func1;

reg					alu_mul_rd_mem0;
reg					alu_mul_rd_mem1;
reg					alu_mul_wr_mem0;
reg					alu_mul_wr_mem1;

reg					alu_mul_cond_branch0;
reg					alu_mul_cond_branch1;
reg					alu_mul_uncond_branch0;
reg					alu_mul_uncond_branch1;
reg					alu_mul_halt0;
reg					alu_mul_halt1;

reg					alu_mul_illegal_inst0;
reg					alu_mul_illegal_inst1;
reg					alu_mul_valid_inst0;
reg					alu_mul_valid_inst1;

reg	 [63:0]	alu_mem_NPC0;
reg	 [63:0]	alu_mem_NPC1;
reg	 [31:0] alu_mem_IR0;
reg	 [31:0]	alu_mem_IR1;

reg					alu_mem_branch_taken0;
reg					alu_mem_branch_taken1;
reg	 [63:0]	alu_mem_pred_addr0;
reg	 [63:0]	alu_mem_pred_addr1;

reg	 	[6:0]	alu_mem_prf_pra_idx0; // Go to physical register file to get the value
reg		[6:0]	alu_mem_prf_pra_idx1;
reg		[6:0]	alu_mem_prf_prb_idx0;
reg		[6:0]	alu_mem_prf_prb_idx1;

reg		[1:0]	alu_mem_opa_select0;
reg		[1:0]	alu_mem_opa_select1;
reg		[1:0]	alu_mem_opb_select0;
reg		[1:0]	alu_mem_opb_select1;

reg		[4:0]	alu_mem_dest_ar_idx0;
reg		[4:0]	alu_mem_dest_ar_idx1;
reg		[6:0]	alu_mem_dest_pr_idx0;
reg		[6:0]	alu_mem_dest_pr_idx1;
reg		[4:0]	alu_mem_func0;
reg		[4:0]	alu_mem_func1;

reg					alu_mem_rd_mem0;
reg					alu_mem_rd_mem1;
reg					alu_mem_wr_mem0;
reg					alu_mem_wr_mem1;

reg					alu_mem_cond_branch0;
reg					alu_mem_cond_branch1;
reg					alu_mem_uncond_branch0;
reg					alu_mem_uncond_branch1;
reg					alu_mem_halt0;
reg					alu_mem_halt1;

reg					alu_mem_illegal_inst0;
reg					alu_mem_illegal_inst1;
reg					alu_mem_valid_inst0;
reg					alu_mem_valid_inst1;

// RS entries

reg		[1:0]	alu_type			[`NUM_RS_ENTRIES-1:0];
reg	 [63:0]	npc						[`NUM_RS_ENTRIES-1:0];
reg	 [31:0]	ir						[`NUM_RS_ENTRIES-1:0];
reg					branch_taken	[`NUM_RS_ENTRIES-1:0];
reg	 [63:0]	pred_addr			[`NUM_RS_ENTRIES-1:0];
reg		[1:0]	opa_select		[`NUM_RS_ENTRIES-1:0];
reg		[1:0]	opb_select		[`NUM_RS_ENTRIES-1:0];
reg		[4:0]	dest_ar_idx		[`NUM_RS_ENTRIES-1:0];
reg		[6:0]	dest_pr_idx		[`NUM_RS_ENTRIES-1:0];
reg		[6:0]	pra_idx				[`NUM_RS_ENTRIES-1:0];
reg					pra_ready			[`NUM_RS_ENTRIES-1:0];
reg		[6:0]	prb_idx				[`NUM_RS_ENTRIES-1:0];
reg					prb_ready			[`NUM_RS_ENTRIES-1:0];
reg		[4:0]	alu_func			[`NUM_RS_ENTRIES-1:0];
reg					rd_mem				[`NUM_RS_ENTRIES-1:0];
reg					wr_mem				[`NUM_RS_ENTRIES-1:0];
reg					cond_branch		[`NUM_RS_ENTRIES-1:0];					
reg					uncond_branch	[`NUM_RS_ENTRIES-1:0];
reg					halt					[`NUM_RS_ENTRIES-1:0];
reg					illegal_inst	[`NUM_RS_ENTRIES-1:0];
reg					valid_inst		[`NUM_RS_ENTRIES-1:0];

reg		[`NUM_RS_ENTRIES-1:0]	sim_ready;
reg		[`NUM_RS_ENTRIES-1:0]	mul_ready;
reg		[`NUM_RS_ENTRIES-1:0]	mem_ready;
reg		[`NUM_RS_ENTRIES-1:0] entry_taken;

reg		[`LOG_NUM_RS_ENTRIES:0]		num_empty_entries;
reg		[`LOG_NUM_RS_ENTRIES:0]		num_ready_sim;
reg		[`LOG_NUM_RS_ENTRIES:0]		num_ready_mul;
reg		[`LOG_NUM_RS_ENTRIES:0]		num_ready_mem;
reg		[`LOG_NUM_RS_ENTRIES-1:0]	avail_entry_idx		[`NUM_RS_ENTRIES-1:0];
reg		[`LOG_NUM_RS_ENTRIES-1:0] ready_sim_idx			[`NUM_RS_ENTRIES-1:0];
reg		[`LOG_NUM_RS_ENTRIES-1:0]	ready_mul_idx			[`NUM_RS_ENTRIES-1:0];
reg		[`LOG_NUM_RS_ENTRIES-1:0]	ready_mem_idx			[`NUM_RS_ENTRIES-1:0];

reg		[`NUM_RS_ENTRIES-1:0]	next_sim_ready;
reg		[`NUM_RS_ENTRIES-1:0]	next_mul_ready;
reg		[`NUM_RS_ENTRIES-1:0]	next_mem_ready;
reg		[`NUM_RS_ENTRIES-1:0] next_entry_taken;

reg		[`LOG_NUM_RS_ENTRIES:0]		next_num_empty_entries;
reg		[`LOG_NUM_RS_ENTRIES:0]		next_num_ready_sim;
reg		[`LOG_NUM_RS_ENTRIES:0]		next_num_ready_mul;
reg		[`LOG_NUM_RS_ENTRIES:0]		next_num_ready_mem;

reg		[`LOG_NUM_RS_ENTRIES-1:0]	next_avail_entry_idx		[`NUM_RS_ENTRIES-1:0];
reg		[`LOG_NUM_RS_ENTRIES-1:0] next_ready_sim_idx			[`NUM_RS_ENTRIES-1:0];
reg		[`LOG_NUM_RS_ENTRIES-1:0]	next_ready_mul_idx			[`NUM_RS_ENTRIES-1:0];
reg		[`LOG_NUM_RS_ENTRIES-1:0]	next_ready_mem_idx			[`NUM_RS_ENTRIES-1:0];

wire	[1:0]	actual_dispatch_num = id_dispatch_num - ((id_dispatch_num[1])? ~id_valid_inst1 : 0) - 
																	((id_dispatch_num > 0) ? ~id_valid_inst0 : 0);

integer i;

/*assign next_num_empty_entries = num_empty_entries - id_dispatch_num -
																// The dispatched inst may be not valid
																((id_dispatch_num[1])? ~id_valid_inst1 : 0) -
																((id_dispatch_num > 0)? ~id_valid_inst0 : 0); 
*/
assign id_rs_cap = (num_empty_entries == 0) ? 2'b00:
									 (num_empty_entries == 1) ? 2'b01: 2'b10;



// Issue instructions

always @ *
begin
	for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
	begin
		next_avail_entry_idx[i] = avail_entry_idx[i];
	end
	next_num_empty_entries= num_empty_entries;
	next_entry_taken			= entry_taken;

	next_sim_ready 			= sim_ready;
	next_num_ready_sim 	= num_ready_sim;
	for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
	begin
		next_ready_sim_idx[i] = ready_sim_idx[i];
	end
	if (alu_sim_avail[1] && alu_sim_avail[0])
	begin
		if (num_ready_sim > 1)
		begin
			alu_sim_NPC0					= npc[ready_sim_idx[0]];
			alu_sim_IR0 					= ir[ready_sim_idx[0]];
			alu_sim_branch_taken0 = branch_taken[ready_sim_idx[0]];
			alu_sim_pred_addr0 		= pred_addr[ready_sim_idx[0]];
			alu_sim_prf_pra_idx0 	= pra_idx[ready_sim_idx[0]];
			alu_sim_prf_prb_idx0 	= prb_idx[ready_sim_idx[0]];
			alu_sim_opa_select0		= opa_select[ready_sim_idx[0]];
			alu_sim_opb_select0		= opb_select[ready_sim_idx[0]];
			alu_sim_dest_ar_idx0	= dest_ar_idx[ready_sim_idx[0]];
			alu_sim_dest_pr_idx0	= dest_pr_idx[ready_sim_idx[0]];
			alu_sim_func0					= alu_func[ready_sim_idx[0]];
			alu_sim_rd_mem0				= rd_mem[ready_sim_idx[0]];
			alu_sim_wr_mem0				= wr_mem[ready_sim_idx[0]];
			alu_sim_cond_branch0	= cond_branch[ready_sim_idx[0]];
			alu_sim_uncond_branch0		= uncond_branch[ready_sim_idx[0]];
			alu_sim_halt0					= halt[ready_sim_idx[0]];
			alu_sim_illegal_inst0	= illegal_inst[ready_sim_idx[0]];
			alu_sim_valid_inst0		= valid_inst[ready_sim_idx[0]];

			alu_sim_NPC1					= npc[ready_sim_idx[1]];
			alu_sim_IR1 					= ir[ready_sim_idx[1]];
			alu_sim_branch_taken1 = branch_taken[ready_sim_idx[1]];
			alu_sim_pred_addr1 		= pred_addr[ready_sim_idx[1]];
			alu_sim_prf_pra_idx1 	= pra_idx[ready_sim_idx[1]];
			alu_sim_prf_prb_idx1 	= prb_idx[ready_sim_idx[1]];
			alu_sim_opa_select1		= opa_select[ready_sim_idx[1]];
			alu_sim_opb_select1		= opb_select[ready_sim_idx[1]];
			alu_sim_dest_ar_idx1	= dest_ar_idx[ready_sim_idx[1]];
			alu_sim_dest_pr_idx1	= dest_pr_idx[ready_sim_idx[1]];
			alu_sim_func1					= alu_func[ready_sim_idx[1]];
			alu_sim_rd_mem1				= rd_mem[ready_sim_idx[1]];
			alu_sim_wr_mem1				= wr_mem[ready_sim_idx[1]];
			alu_sim_cond_branch1	= cond_branch[ready_sim_idx[1]];
			alu_sim_uncond_branch1		= uncond_branch[ready_sim_idx[1]];
			alu_sim_halt1					= halt[ready_sim_idx[1]];
			alu_sim_illegal_inst1	= illegal_inst[ready_sim_idx[1]];
			alu_sim_valid_inst1		= valid_inst[ready_sim_idx[1]];

			next_sim_ready[ready_sim_idx[0]] = 0;
			next_sim_ready[ready_sim_idx[1]] = 0;
			next_num_ready_sim							 = next_num_ready_sim - 2;
			for (i = 2; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_ready_sim_idx[i-2] = next_ready_sim_idx[i];
			end

			next_num_empty_entries = next_num_empty_entries - 2;
			next_entry_taken[ready_sim_idx[0]] = 0;
			next_entry_taken[ready_sim_idx[1]] = 0;
			for (i = 2; i < `NUM_RS_ENTRIES; i = i+1)
			begin
				next_avail_entry_idx[i-2] = next_avail_entry_idx[i];
			end
		end
		else if (num_ready_sim == 1)
		begin
			alu_sim_NPC0					= npc[ready_sim_idx[0]];
			alu_sim_IR0 					= ir[ready_sim_idx[0]];
			alu_sim_branch_taken0 = branch_taken[ready_sim_idx[0]];
			alu_sim_pred_addr0 		= pred_addr[ready_sim_idx[0]];
			alu_sim_prf_pra_idx0 	= pra_idx[ready_sim_idx[0]];
			alu_sim_prf_prb_idx0 	= prb_idx[ready_sim_idx[0]];
			alu_sim_opa_select0		= opa_select[ready_sim_idx[0]];
			alu_sim_opb_select0		= opb_select[ready_sim_idx[0]];
			alu_sim_dest_ar_idx0	= dest_ar_idx[ready_sim_idx[0]];
			alu_sim_dest_pr_idx0	= dest_pr_idx[ready_sim_idx[0]];
			alu_sim_func0					= alu_func[ready_sim_idx[0]];
			alu_sim_rd_mem0				= rd_mem[ready_sim_idx[0]];
			alu_sim_wr_mem0				= wr_mem[ready_sim_idx[0]];
			alu_sim_cond_branch0	= cond_branch[ready_sim_idx[0]];
			alu_sim_uncond_branch0		= uncond_branch[ready_sim_idx[0]];
			alu_sim_halt0					= halt[ready_sim_idx[0]];
			alu_sim_illegal_inst0	= illegal_inst[ready_sim_idx[0]];
			alu_sim_valid_inst0		= valid_inst[ready_sim_idx[0]];

			alu_sim_valid_inst1 	=	0;

			next_sim_ready[ready_sim_idx[0]]	= 0;
			next_num_ready_sim								= next_num_ready_sim - 1;
			for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_ready_sim_idx[i-1] = next_ready_sim_idx[i];
			end

			next_num_empty_entries = next_num_empty_entries - 1;
			next_entry_taken[ready_sim_idx[0]] = 0;
			for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
			end
		end
	end
	else if (alu_sim_avail[0])
	begin
		if (num_ready_sim > 0)
		begin
				alu_sim_NPC0					= npc[ready_sim_idx[0]];
				alu_sim_IR0 					= ir[ready_sim_idx[0]];
				alu_sim_branch_taken0 = branch_taken[ready_sim_idx[0]];
				alu_sim_pred_addr0 		= pred_addr[ready_sim_idx[0]];
				alu_sim_prf_pra_idx0 	= pra_idx[ready_sim_idx[0]];
				alu_sim_prf_prb_idx0 	= prb_idx[ready_sim_idx[0]];
				alu_sim_opa_select0		= opa_select[ready_sim_idx[0]];
				alu_sim_opb_select0		= opb_select[ready_sim_idx[0]];
				alu_sim_dest_ar_idx0	= dest_ar_idx[ready_sim_idx[0]];
				alu_sim_dest_pr_idx0	= dest_pr_idx[ready_sim_idx[0]];
				alu_sim_func0					= alu_func[ready_sim_idx[0]];
				alu_sim_rd_mem0				= rd_mem[ready_sim_idx[0]];
				alu_sim_wr_mem0				= wr_mem[ready_sim_idx[0]];
				alu_sim_cond_branch0	= cond_branch[ready_sim_idx[0]];
				alu_sim_uncond_branch0		= uncond_branch[ready_sim_idx[0]];
				alu_sim_halt0					= halt[ready_sim_idx[0]];
				alu_sim_illegal_inst0	= illegal_inst[ready_sim_idx[0]];
				alu_sim_valid_inst0		= valid_inst[ready_sim_idx[0]];

				alu_sim_valid_inst1 	=	0;

				next_sim_ready[ready_sim_idx[0]]	= 0;
				next_num_ready_sim								= next_num_ready_sim - 1;
				for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
				begin
					next_ready_sim_idx[i-1] = next_ready_sim_idx[i];
				end

				next_num_empty_entries = next_num_empty_entries - 1;
				next_entry_taken[ready_sim_idx[0]] = 0;
				for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
				begin
					next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
				end
		end
	end
	else if (alu_sim_avail[1])
	begin
			if (num_ready_sim > 0)
			begin
					alu_sim_NPC1					= npc[ready_sim_idx[0]];
					alu_sim_IR1 					= ir[ready_sim_idx[0]];
					alu_sim_branch_taken1 = branch_taken[ready_sim_idx[0]];
					alu_sim_pred_addr1 		= pred_addr[ready_sim_idx[0]];
					alu_sim_prf_pra_idx1 	= pra_idx[ready_sim_idx[0]];
					alu_sim_prf_prb_idx1 	= prb_idx[ready_sim_idx[0]];
					alu_sim_opa_select1		= opa_select[ready_sim_idx[0]];
					alu_sim_opb_select1		= opb_select[ready_sim_idx[0]];
					alu_sim_dest_ar_idx1	= dest_ar_idx[ready_sim_idx[0]];
					alu_sim_dest_pr_idx1	= dest_pr_idx[ready_sim_idx[0]];
					alu_sim_func1					= alu_func[ready_sim_idx[0]];
					alu_sim_rd_mem1				= rd_mem[ready_sim_idx[0]];
					alu_sim_wr_mem1				= wr_mem[ready_sim_idx[0]];
					alu_sim_cond_branch1	= cond_branch[ready_sim_idx[0]];
					alu_sim_uncond_branch1		= uncond_branch[ready_sim_idx[0]];
					alu_sim_halt1					= halt[ready_sim_idx[0]];
					alu_sim_illegal_inst1	= illegal_inst[ready_sim_idx[0]];
					alu_sim_valid_inst1		= valid_inst[ready_sim_idx[0]];

					alu_sim_valid_inst0 	=	0;

					next_sim_ready[ready_sim_idx[0]]	= 0;
					next_num_ready_sim								= next_num_ready_sim - 1;
					for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
					begin
						next_ready_sim_idx[i-1] = next_ready_sim_idx[i];
					end

					next_num_empty_entries = next_num_empty_entries - 1;
					next_entry_taken[ready_sim_idx[0]] = 0;
					for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
					begin
						next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
					end
			end
	end



	next_mul_ready 			= mul_ready;
	next_num_ready_mul 	= num_ready_mul;
	for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
	begin
		next_ready_mul_idx[i] = ready_mul_idx[i];
	end
	if (alu_mul_avail[1] && alu_mul_avail[0])
	begin
		if (num_ready_mul > 1)
		begin
			alu_mul_NPC0					= npc[ready_mul_idx[0]];
			alu_mul_IR0 					= ir[ready_mul_idx[0]];
			alu_mul_branch_taken0 = branch_taken[ready_mul_idx[0]];
			alu_mul_pred_addr0 		= pred_addr[ready_mul_idx[0]];
			alu_mul_prf_pra_idx0 	= pra_idx[ready_mul_idx[0]];
			alu_mul_prf_prb_idx0 	= prb_idx[ready_mul_idx[0]];
			alu_mul_opa_select0		= opa_select[ready_mul_idx[0]];
			alu_mul_opb_select0		= opb_select[ready_mul_idx[0]];
			alu_mul_dest_ar_idx0	= dest_ar_idx[ready_mul_idx[0]];
			alu_mul_dest_pr_idx0	= dest_pr_idx[ready_mul_idx[0]];
			alu_mul_func0					= alu_func[ready_mul_idx[0]];
			alu_mul_rd_mem0				= rd_mem[ready_mul_idx[0]];
			alu_mul_wr_mem0				= wr_mem[ready_mul_idx[0]];
			alu_mul_cond_branch0	= cond_branch[ready_mul_idx[0]];
			alu_mul_uncond_branch0		= uncond_branch[ready_mul_idx[0]];
			alu_mul_halt0					= halt[ready_mul_idx[0]];
			alu_mul_illegal_inst0	= illegal_inst[ready_mul_idx[0]];
			alu_mul_valid_inst0		= valid_inst[ready_mul_idx[0]];

			alu_mul_NPC1					= npc[ready_mul_idx[1]];
			alu_mul_IR1 					= ir[ready_mul_idx[1]];
			alu_mul_branch_taken1 = branch_taken[ready_mul_idx[1]];
			alu_mul_pred_addr1 		= pred_addr[ready_mul_idx[1]];
			alu_mul_prf_pra_idx1 	= pra_idx[ready_mul_idx[1]];
			alu_mul_prf_prb_idx1 	= prb_idx[ready_mul_idx[1]];
			alu_mul_opa_select1		= opa_select[ready_mul_idx[1]];
			alu_mul_opb_select1		= opb_select[ready_mul_idx[1]];
			alu_mul_dest_ar_idx1	= dest_ar_idx[ready_mul_idx[1]];
			alu_mul_dest_pr_idx1	= dest_pr_idx[ready_mul_idx[1]];
			alu_mul_func1					= alu_func[ready_mul_idx[1]];
			alu_mul_rd_mem1				= rd_mem[ready_mul_idx[1]];
			alu_mul_wr_mem1				= wr_mem[ready_mul_idx[1]];
			alu_mul_cond_branch1	= cond_branch[ready_mul_idx[1]];
			alu_mul_uncond_branch1		= uncond_branch[ready_mul_idx[1]];
			alu_mul_halt1					= halt[ready_mul_idx[1]];
			alu_mul_illegal_inst1	= illegal_inst[ready_mul_idx[1]];
			alu_mul_valid_inst1		= valid_inst[ready_mul_idx[1]];

			next_mul_ready[ready_mul_idx[0]] = 0;
			next_mul_ready[ready_mul_idx[1]] = 0;
			next_num_ready_mul							 = next_num_ready_mul - 2;
			for (i = 2; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_ready_mul_idx[i-2] = next_ready_mul_idx[i];
			end

			next_num_empty_entries = next_num_empty_entries - 2;
			next_entry_taken[ready_mul_idx[0]] = 0;
			next_entry_taken[ready_mul_idx[1]] = 0;
			for (i = 2; i < `NUM_RS_ENTRIES; i = i+1)
			begin
				next_avail_entry_idx[i-2] = next_avail_entry_idx[i];
			end
		end
		else if (num_ready_mul == 1)
		begin
			alu_mul_NPC0					= npc[ready_mul_idx[0]];
			alu_mul_IR0 					= ir[ready_mul_idx[0]];
			alu_mul_branch_taken0 = branch_taken[ready_mul_idx[0]];
			alu_mul_pred_addr0 		= pred_addr[ready_mul_idx[0]];
			alu_mul_prf_pra_idx0 	= pra_idx[ready_mul_idx[0]];
			alu_mul_prf_prb_idx0 	= prb_idx[ready_mul_idx[0]];
			alu_mul_opa_select0		= opa_select[ready_mul_idx[0]];
			alu_mul_opb_select0		= opb_select[ready_mul_idx[0]];
			alu_mul_dest_ar_idx0	= dest_ar_idx[ready_mul_idx[0]];
			alu_mul_dest_pr_idx0	= dest_pr_idx[ready_mul_idx[0]];
			alu_mul_func0					= alu_func[ready_mul_idx[0]];
			alu_mul_rd_mem0				= rd_mem[ready_mul_idx[0]];
			alu_mul_wr_mem0				= wr_mem[ready_mul_idx[0]];
			alu_mul_cond_branch0	= cond_branch[ready_mul_idx[0]];
			alu_mul_uncond_branch0		= uncond_branch[ready_mul_idx[0]];
			alu_mul_halt0					= halt[ready_mul_idx[0]];
			alu_mul_illegal_inst0	= illegal_inst[ready_mul_idx[0]];
			alu_mul_valid_inst0		= valid_inst[ready_mul_idx[0]];

			alu_mul_valid_inst1 	=	0;

			next_mul_ready[ready_mul_idx[0]]	= 0;
			next_num_ready_mul								= next_num_ready_mul - 1;
			for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_ready_mul_idx[i-1] = next_ready_mul_idx[i];
			end

			next_num_empty_entries = next_num_empty_entries - 1;
			next_entry_taken[ready_mul_idx[0]] = 0;
			for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
			end
		end
	end
	else if (alu_mul_avail[0])
	begin
		if (num_ready_mul > 0)
		begin
				alu_mul_NPC0					= npc[ready_mul_idx[0]];
				alu_mul_IR0 					= ir[ready_mul_idx[0]];
				alu_mul_branch_taken0 = branch_taken[ready_mul_idx[0]];
				alu_mul_pred_addr0 		= pred_addr[ready_mul_idx[0]];
				alu_mul_prf_pra_idx0 	= pra_idx[ready_mul_idx[0]];
				alu_mul_prf_prb_idx0 	= prb_idx[ready_mul_idx[0]];
				alu_mul_opa_select0		= opa_select[ready_mul_idx[0]];
				alu_mul_opb_select0		= opb_select[ready_mul_idx[0]];
				alu_mul_dest_ar_idx0	= dest_ar_idx[ready_mul_idx[0]];
				alu_mul_dest_pr_idx0	= dest_pr_idx[ready_mul_idx[0]];
				alu_mul_func0					= alu_func[ready_mul_idx[0]];
				alu_mul_rd_mem0				= rd_mem[ready_mul_idx[0]];
				alu_mul_wr_mem0				= wr_mem[ready_mul_idx[0]];
				alu_mul_cond_branch0	= cond_branch[ready_mul_idx[0]];
				alu_mul_uncond_branch0		= uncond_branch[ready_mul_idx[0]];
				alu_mul_halt0					= halt[ready_mul_idx[0]];
				alu_mul_illegal_inst0	= illegal_inst[ready_mul_idx[0]];
				alu_mul_valid_inst0		= valid_inst[ready_mul_idx[0]];

				alu_mul_valid_inst1 	=	0;

				next_mul_ready[ready_mul_idx[0]]	= 0;
				next_num_ready_mul								= next_num_ready_mul - 1;
				for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
				begin
					next_ready_mul_idx[i-1] = next_ready_mul_idx[i];
				end

				next_num_empty_entries = next_num_empty_entries - 1;
				next_entry_taken[ready_mul_idx[0]] = 0;
				for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
				begin
					next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
				end
		end
	end
	else if (alu_mul_avail[1])
	begin
			if (num_ready_mul > 0)
			begin
					alu_mul_NPC1					= npc[ready_mul_idx[0]];
					alu_mul_IR1 					= ir[ready_mul_idx[0]];
					alu_mul_branch_taken1 = branch_taken[ready_mul_idx[0]];
					alu_mul_pred_addr1 		= pred_addr[ready_mul_idx[0]];
					alu_mul_prf_pra_idx1 	= pra_idx[ready_mul_idx[0]];
					alu_mul_prf_prb_idx1 	= prb_idx[ready_mul_idx[0]];
					alu_mul_opa_select1		= opa_select[ready_mul_idx[0]];
					alu_mul_opb_select1		= opb_select[ready_mul_idx[0]];
					alu_mul_dest_ar_idx1	= dest_ar_idx[ready_mul_idx[0]];
					alu_mul_dest_pr_idx1	= dest_pr_idx[ready_mul_idx[0]];
					alu_mul_func1					= alu_func[ready_mul_idx[0]];
					alu_mul_rd_mem1				= rd_mem[ready_mul_idx[0]];
					alu_mul_wr_mem1				= wr_mem[ready_mul_idx[0]];
					alu_mul_cond_branch1	= cond_branch[ready_mul_idx[0]];
					alu_mul_uncond_branch1		= uncond_branch[ready_mul_idx[0]];
					alu_mul_halt1					= halt[ready_mul_idx[0]];
					alu_mul_illegal_inst1	= illegal_inst[ready_mul_idx[0]];
					alu_mul_valid_inst1		= valid_inst[ready_mul_idx[0]];

					alu_mul_valid_inst0 	=	0;

					next_mul_ready[ready_mul_idx[0]]	= 0;
					next_num_ready_mul								= next_num_ready_mul - 1;
					for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
					begin
						next_ready_mul_idx[i-1] = next_ready_mul_idx[i];
					end

					next_num_empty_entries = next_num_empty_entries - 1;
					next_entry_taken[ready_mul_idx[0]] = 0;
					for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
					begin
						next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
					end
			end
	end




	next_mem_ready 			= mem_ready;
	next_num_ready_mem 	= num_ready_mem;
	for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
	begin
		next_ready_mem_idx[i] = ready_mem_idx[i];
	end
	if (alu_mem_avail[1] && alu_mem_avail[0])
	begin
		if (num_ready_mem > 1)
		begin
			alu_mem_NPC0					= npc[ready_mem_idx[0]];
			alu_mem_IR0 					= ir[ready_mem_idx[0]];
			alu_mem_branch_taken0 = branch_taken[ready_mem_idx[0]];
			alu_mem_pred_addr0 		= pred_addr[ready_mem_idx[0]];
			alu_mem_prf_pra_idx0 	= pra_idx[ready_mem_idx[0]];
			alu_mem_prf_prb_idx0 	= prb_idx[ready_mem_idx[0]];
			alu_mem_opa_select0		= opa_select[ready_mem_idx[0]];
			alu_mem_opb_select0		= opb_select[ready_mem_idx[0]];
			alu_mem_dest_ar_idx0	= dest_ar_idx[ready_mem_idx[0]];
			alu_mem_dest_pr_idx0	= dest_pr_idx[ready_mem_idx[0]];
			alu_mem_func0					= alu_func[ready_mem_idx[0]];
			alu_mem_rd_mem0				= rd_mem[ready_mem_idx[0]];
			alu_mem_wr_mem0				= wr_mem[ready_mem_idx[0]];
			alu_mem_cond_branch0	= cond_branch[ready_mem_idx[0]];
			alu_mem_uncond_branch0		= uncond_branch[ready_mem_idx[0]];
			alu_mem_halt0					= halt[ready_mem_idx[0]];
			alu_mem_illegal_inst0	= illegal_inst[ready_mem_idx[0]];
			alu_mem_valid_inst0		= valid_inst[ready_mem_idx[0]];

			alu_mem_NPC1					= npc[ready_mem_idx[1]];
			alu_mem_IR1 					= ir[ready_mem_idx[1]];
			alu_mem_branch_taken1 = branch_taken[ready_mem_idx[1]];
			alu_mem_pred_addr1 		= pred_addr[ready_mem_idx[1]];
			alu_mem_prf_pra_idx1 	= pra_idx[ready_mem_idx[1]];
			alu_mem_prf_prb_idx1 	= prb_idx[ready_mem_idx[1]];
			alu_mem_opa_select1		= opa_select[ready_mem_idx[1]];
			alu_mem_opb_select1		= opb_select[ready_mem_idx[1]];
			alu_mem_dest_ar_idx1	= dest_ar_idx[ready_mem_idx[1]];
			alu_mem_dest_pr_idx1	= dest_pr_idx[ready_mem_idx[1]];
			alu_mem_func1					= alu_func[ready_mem_idx[1]];
			alu_mem_rd_mem1				= rd_mem[ready_mem_idx[1]];
			alu_mem_wr_mem1				= wr_mem[ready_mem_idx[1]];
			alu_mem_cond_branch1	= cond_branch[ready_mem_idx[1]];
			alu_mem_uncond_branch1		= uncond_branch[ready_mem_idx[1]];
			alu_mem_halt1					= halt[ready_mem_idx[1]];
			alu_mem_illegal_inst1	= illegal_inst[ready_mem_idx[1]];
			alu_mem_valid_inst1		= valid_inst[ready_mem_idx[1]];

			next_mem_ready[ready_mem_idx[0]] = 0;
			next_mem_ready[ready_mem_idx[1]] = 0;
			next_num_ready_mem							 = next_num_ready_mem - 2;
			for (i = 2; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_ready_mem_idx[i-2] = next_ready_mem_idx[i];
			end

			next_num_empty_entries = next_num_empty_entries - 2;
			next_entry_taken[ready_mem_idx[0]] = 0;
			next_entry_taken[ready_mem_idx[1]] = 0;
			for (i = 2; i < `NUM_RS_ENTRIES; i = i+1)
			begin
				next_avail_entry_idx[i-2] = next_avail_entry_idx[i];
			end
		end
		else if (num_ready_mem == 1)
		begin
			alu_mem_NPC0					= npc[ready_mem_idx[0]];
			alu_mem_IR0 					= ir[ready_mem_idx[0]];
			alu_mem_branch_taken0 = branch_taken[ready_mem_idx[0]];
			alu_mem_pred_addr0 		= pred_addr[ready_mem_idx[0]];
			alu_mem_prf_pra_idx0 	= pra_idx[ready_mem_idx[0]];
			alu_mem_prf_prb_idx0 	= prb_idx[ready_mem_idx[0]];
			alu_mem_opa_select0		= opa_select[ready_mem_idx[0]];
			alu_mem_opb_select0		= opb_select[ready_mem_idx[0]];
			alu_mem_dest_ar_idx0	= dest_ar_idx[ready_mem_idx[0]];
			alu_mem_dest_pr_idx0	= dest_pr_idx[ready_mem_idx[0]];
			alu_mem_func0					= alu_func[ready_mem_idx[0]];
			alu_mem_rd_mem0				= rd_mem[ready_mem_idx[0]];
			alu_mem_wr_mem0				= wr_mem[ready_mem_idx[0]];
			alu_mem_cond_branch0	= cond_branch[ready_mem_idx[0]];
			alu_mem_uncond_branch0		= uncond_branch[ready_mem_idx[0]];
			alu_mem_halt0					= halt[ready_mem_idx[0]];
			alu_mem_illegal_inst0	= illegal_inst[ready_mem_idx[0]];
			alu_mem_valid_inst0		= valid_inst[ready_mem_idx[0]];

			alu_mem_valid_inst1 	=	0;

			next_mem_ready[ready_mem_idx[0]]	= 0;
			next_num_ready_mem								= next_num_ready_mem - 1;
			for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_ready_mem_idx[i-1] = next_ready_mem_idx[i];
			end

			next_num_empty_entries = next_num_empty_entries - 1;
			next_entry_taken[ready_mem_idx[0]] = 0;
			for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
			begin
				next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
			end
		end
	end
	else if (alu_mem_avail[0])
	begin
		if (num_ready_mem > 0)
		begin
				alu_mem_NPC0					= npc[ready_mem_idx[0]];
				alu_mem_IR0 					= ir[ready_mem_idx[0]];
				alu_mem_branch_taken0 = branch_taken[ready_mem_idx[0]];
				alu_mem_pred_addr0 		= pred_addr[ready_mem_idx[0]];
				alu_mem_prf_pra_idx0 	= pra_idx[ready_mem_idx[0]];
				alu_mem_prf_prb_idx0 	= prb_idx[ready_mem_idx[0]];
				alu_mem_opa_select0		= opa_select[ready_mem_idx[0]];
				alu_mem_opb_select0		= opb_select[ready_mem_idx[0]];
				alu_mem_dest_ar_idx0	= dest_ar_idx[ready_mem_idx[0]];
				alu_mem_dest_pr_idx0	= dest_pr_idx[ready_mem_idx[0]];
				alu_mem_func0					= alu_func[ready_mem_idx[0]];
				alu_mem_rd_mem0				= rd_mem[ready_mem_idx[0]];
				alu_mem_wr_mem0				= wr_mem[ready_mem_idx[0]];
				alu_mem_cond_branch0	= cond_branch[ready_mem_idx[0]];
				alu_mem_uncond_branch0		= uncond_branch[ready_mem_idx[0]];
				alu_mem_halt0					= halt[ready_mem_idx[0]];
				alu_mem_illegal_inst0	= illegal_inst[ready_mem_idx[0]];
				alu_mem_valid_inst0		= valid_inst[ready_mem_idx[0]];

				alu_mem_valid_inst1 	=	0;

				next_mem_ready[ready_mem_idx[0]]	= 0;
				next_num_ready_mem								= next_num_ready_mem - 1;
				for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
				begin
					next_ready_mem_idx[i-1] = next_ready_mem_idx[i];
				end

				next_num_empty_entries = next_num_empty_entries - 1;
				next_entry_taken[ready_mem_idx[0]] = 0;
				for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
				begin
					next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
				end
		end
	end
	else if (alu_mem_avail[1])
	begin
			if (num_ready_mem > 0)
			begin
					alu_mem_NPC1					= npc[ready_mem_idx[0]];
					alu_mem_IR1 					= ir[ready_mem_idx[0]];
					alu_mem_branch_taken1 = branch_taken[ready_mem_idx[0]];
					alu_mem_pred_addr1 		= pred_addr[ready_mem_idx[0]];
					alu_mem_prf_pra_idx1 	= pra_idx[ready_mem_idx[0]];
					alu_mem_prf_prb_idx1 	= prb_idx[ready_mem_idx[0]];
					alu_mem_opa_select1		= opa_select[ready_mem_idx[0]];
					alu_mem_opb_select1		= opb_select[ready_mem_idx[0]];
					alu_mem_dest_ar_idx1	= dest_ar_idx[ready_mem_idx[0]];
					alu_mem_dest_pr_idx1	= dest_pr_idx[ready_mem_idx[0]];
					alu_mem_func1					= alu_func[ready_mem_idx[0]];
					alu_mem_rd_mem1				= rd_mem[ready_mem_idx[0]];
					alu_mem_wr_mem1				= wr_mem[ready_mem_idx[0]];
					alu_mem_cond_branch1	= cond_branch[ready_mem_idx[0]];
					alu_mem_uncond_branch1		= uncond_branch[ready_mem_idx[0]];
					alu_mem_halt1					= halt[ready_mem_idx[0]];
					alu_mem_illegal_inst1	= illegal_inst[ready_mem_idx[0]];
					alu_mem_valid_inst1		= valid_inst[ready_mem_idx[0]];

					alu_mem_valid_inst0 	=	0;

					next_mem_ready[ready_mem_idx[0]]	= 0;
					next_num_ready_mem								= next_num_ready_mem - 1;
					for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
					begin
						next_ready_mem_idx[i-1] = next_ready_mem_idx[i];
					end

					next_num_empty_entries = next_num_empty_entries - 1;
					next_entry_taken[ready_mem_idx[0]] = 0;
					for (i = 1; i < `NUM_RS_ENTRIES; i = i + 1)
					begin
						next_avail_entry_idx[i-1] = next_avail_entry_idx[i];
					end
			end
	end

end



always @(posedge clock)
begin
	if (reset)
	begin
		sim_ready			<= `SD `NUM_RS_ENTRIES'b0;
		mul_ready			<= `SD `NUM_RS_ENTRIES'b0;
		mem_ready 		<= `SD `NUM_RS_ENTRIES'b0;
		entry_taken		<= `SD `NUM_RS_ENTRIES'b0;

		num_empty_entries	<= `SD {1'b1, {`LOG_NUM_RS_ENTRIES{1'b0}}};
		num_ready_sim			<= `SD 0;
		num_ready_mul			<= `SD 0;
		num_ready_mem			<= `SD 0;

		for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
			avail_entry_idx[i] <= `SD i;
	end
end

endmodule
