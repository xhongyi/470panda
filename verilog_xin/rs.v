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

						fl_pr_dest_idx0,
						mt_pra_idx0,
						mt_prb_idx0,
						mt_pra_ready0, // *** If the reg is not valid, it is ready ***
						mt_prb_ready0,

						fl_pr_dest_idx1,
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

input		[6:0]	fl_pr_dest_idx0;
input		[6:0]	mt_pra_idx0;
input		[6:0]	mt_prb_idx0;
input					mt_pra_ready0; // *** If the reg is not valid, it is ready ***
input					mt_prb_ready0;

input		[6:0]	fl_pr_dest_idx1;
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

reg		[1:0]	next_alu_type				[`NUM_RS_ENTRIES-1:0];
reg	 [63:0]	next_npc						[`NUM_RS_ENTRIES-1:0];
reg	 [31:0]	next_ir							[`NUM_RS_ENTRIES-1:0];
reg					next_branch_taken		[`NUM_RS_ENTRIES-1:0];
reg	 [63:0]	next_pred_addr			[`NUM_RS_ENTRIES-1:0];
reg		[1:0]	next_opa_select			[`NUM_RS_ENTRIES-1:0];
reg		[1:0]	next_opb_select			[`NUM_RS_ENTRIES-1:0];
reg		[4:0]	next_dest_ar_idx		[`NUM_RS_ENTRIES-1:0];
reg		[6:0]	next_dest_pr_idx		[`NUM_RS_ENTRIES-1:0];
reg		[6:0]	next_pra_idx				[`NUM_RS_ENTRIES-1:0];
reg					next_pra_ready			[`NUM_RS_ENTRIES-1:0];
reg		[6:0]	next_prb_idx				[`NUM_RS_ENTRIES-1:0];
reg					next_prb_ready			[`NUM_RS_ENTRIES-1:0];
reg		[4:0]	next_alu_func				[`NUM_RS_ENTRIES-1:0];
reg					next_rd_mem					[`NUM_RS_ENTRIES-1:0];
reg					next_wr_mem					[`NUM_RS_ENTRIES-1:0];
reg					next_cond_branch		[`NUM_RS_ENTRIES-1:0];					
reg					next_uncond_branch	[`NUM_RS_ENTRIES-1:0];
reg					next_halt						[`NUM_RS_ENTRIES-1:0];
reg					next_illegal_inst		[`NUM_RS_ENTRIES-1:0];
reg					next_valid_inst			[`NUM_RS_ENTRIES-1:0];


reg		[1:0]	dispatch_valid_inst;
reg		[`LOG_NUM_RS_ENTRIES-1:0]	dispatch_rs_idx;

reg		[`NUM_RS_ENTRIES-1:0]	sim_ready;
reg		[`NUM_RS_ENTRIES-1:0]	mul_ready;
reg		[`NUM_RS_ENTRIES-1:0]	mem_ready;
reg		[`NUM_RS_ENTRIES-1:0] ent_taken; // ent means entry
reg		[`NUM_RS_ENTRIES-1:0] ent_avail;

reg		[`NUM_RS_ENTRIES-1:0]	next_sim_ready;
reg		[`NUM_RS_ENTRIES-1:0]	next_mul_ready;
reg		[`NUM_RS_ENTRIES-1:0]	next_mem_ready;
reg		[`NUM_RS_ENTRIES-1:0] next_ent_taken;
reg		[`NUM_RS_ENTRIES-1:0] next_ent_avail;

wire				ready_sim_valid;
wire	[4:0]	ready_sim_high_idx;
wire	[4:0]	ready_sim_low_idx;	

wire				ready_mul_valid;
wire	[4:0]	ready_mul_high_idx;
wire	[4:0]	ready_mul_low_idx;

wire				ready_mem_valid;
wire	[4:0]	ready_mem_high_idx;
wire	[4:0]	ready_mem_low_idx;

wire				ent_taken_valid;
wire	[4:0]	ent_taken_high_idx;
wire	[4:0]	ent_taken_low_idx;

wire				ent_avail_valid;
wire	[4:0]	ent_avail_high_idx;
wire	[4:0]	ent_avail_low_idx;

integer i;

assign id_rs_cap = (~ent_avail_valid) ? 2'b00 :
									 (ent_avail_high_idx == ent_avail_low_idx) ? 2'b01 : 2'b10;

// Issue instructions

prien	prien_sim(.decode(sim_ready),
								.encode_high(ready_sim_high_idx),
								.encode_low(ready_sim_low_idx),
								.valid(ready_sim_valid));

prien	prien_mul(.decode(mul_ready),
								.encode_high(ready_mul_high_idx),
								.encode_low(ready_mul_low_idx),
								.valid(ready_mul_valid));

prien	prien_mem(.decode(mem_ready),
								.encode_high(ready_mem_high_idx),
								.encode_low(ready_mem_low_idx),
								.valid(ready_mem_valid));

prien prien_ent_taken(.decode(ent_taken),
											.encode_high(ent_taken_high_idx),
											.encode_low(ent_taken_low_idx),
											.valid(ent_taken_valid));

prien prien_ent_avail(.decode(ent_avail),
											.encode_high(ent_avail_high_idx),
											.encode_low(ent_avail_low_idx),
											.valid(ent_avail_valid));

always @ *
begin
// default outputs:
	alu_sim_NPC0 = 0;
	alu_sim_NPC1 = 0;
	alu_sim_IR0 = 0;
	alu_sim_IR1 = 0;

	alu_sim_branch_taken0 = 0;
	alu_sim_branch_taken1 = 0;
	alu_sim_pred_addr0 = 0;
	alu_sim_pred_addr1 = 0;

	alu_sim_prf_pra_idx0 = 0; // Go to physical register file to get the value
	alu_sim_prf_pra_idx1 = 0;
	alu_sim_prf_prb_idx0 = 0;
	alu_sim_prf_prb_idx1 = 0;

	alu_sim_opa_select0 = 0;
	alu_sim_opa_select1 = 0;
	alu_sim_opb_select0 = 0;
	alu_sim_opb_select1 = 0;

	alu_sim_dest_ar_idx0 = 0;
	alu_sim_dest_ar_idx1 = 0;
	alu_sim_dest_pr_idx0 = 0;
	alu_sim_dest_pr_idx1 = 0;
	alu_sim_func0 = 0;
	alu_sim_func1 = 0;

	alu_sim_rd_mem0 = 0;
	alu_sim_rd_mem1 = 0;
	alu_sim_wr_mem0 = 0;
	alu_sim_wr_mem1 = 0;

	alu_sim_cond_branch0 = 0;
	alu_sim_cond_branch1 = 0;
	alu_sim_uncond_branch0 = 0;
	alu_sim_uncond_branch1 = 0;
	alu_sim_halt0 = 0;
	alu_sim_halt1 = 0;

	alu_sim_illegal_inst0 = 0;
	alu_sim_illegal_inst1 = 0;
	alu_sim_valid_inst0 = 0;
	alu_sim_valid_inst1 = 0;

	alu_mul_NPC0 = 0;
	alu_mul_NPC1 = 0;
	alu_mul_IR0 = 0;
	alu_mul_IR1 = 0;

	alu_mul_branch_taken0 = 0;
	alu_mul_branch_taken1 = 0;
	alu_mul_pred_addr0 = 0;
	alu_mul_pred_addr1 = 0;

	alu_mul_prf_pra_idx0 = 0; // Go to physical register file to get the value
	alu_mul_prf_pra_idx1 = 0;
	alu_mul_prf_prb_idx0 = 0;
	alu_mul_prf_prb_idx1 = 0;

	alu_mul_opa_select0 = 0;
	alu_mul_opa_select1 = 0;
	alu_mul_opb_select0 = 0;
	alu_mul_opb_select1 = 0;

	alu_mul_dest_ar_idx0 = 0;
	alu_mul_dest_ar_idx1 = 0;
	alu_mul_dest_pr_idx0 = 0;
	alu_mul_dest_pr_idx1 = 0;
	alu_mul_func0 = 0;
	alu_mul_func1 = 0;

	alu_mul_rd_mem0 = 0;
	alu_mul_rd_mem1 = 0;
	alu_mul_wr_mem0 = 0;
	alu_mul_wr_mem1 = 0;

	alu_mul_cond_branch0 = 0;
	alu_mul_cond_branch1 = 0;
	alu_mul_uncond_branch0 = 0;
	alu_mul_uncond_branch1 = 0;
	alu_mul_halt0 = 0;
	alu_mul_halt1 = 0;

	alu_mul_illegal_inst0 = 0;
	alu_mul_illegal_inst1 = 0;
	alu_mul_valid_inst0 = 0;
	alu_mul_valid_inst1 = 0;

	alu_mem_NPC0 = 0;
	alu_mem_NPC1 = 0;
	alu_mem_IR0 = 0;
	alu_mem_IR1 = 0;

	alu_mem_branch_taken0 = 0;
	alu_mem_branch_taken1 = 0;
	alu_mem_pred_addr0 = 0;
	alu_mem_pred_addr1 = 0;

	alu_mem_prf_pra_idx0 = 0; // Go to physical register file to get the value
	alu_mem_prf_pra_idx1 = 0;
	alu_mem_prf_prb_idx0 = 0;
	alu_mem_prf_prb_idx1 = 0;

	alu_mem_opa_select0 = 0;
	alu_mem_opa_select1 = 0;
	alu_mem_opb_select0 = 0;
	alu_mem_opb_select1 = 0;

	alu_mem_dest_ar_idx0 = 0;
	alu_mem_dest_ar_idx1 = 0;
	alu_mem_dest_pr_idx0 = 0;
	alu_mem_dest_pr_idx1 = 0;
	alu_mem_func0 = 0;
	alu_mem_func1 = 0;

	alu_mem_rd_mem0 = 0;
	alu_mem_rd_mem1 = 0;
	alu_mem_wr_mem0 = 0;
	alu_mem_wr_mem1 = 0;

	alu_mem_cond_branch0 = 0;
	alu_mem_cond_branch1 = 0;
	alu_mem_uncond_branch0 = 0;
	alu_mem_uncond_branch1 = 0;
	alu_mem_halt0 = 0;
	alu_mem_halt1 = 0;

	alu_mem_illegal_inst0 = 0;
	alu_mem_illegal_inst1 = 0;
	alu_mem_valid_inst0 = 0;
	alu_mem_valid_inst1 = 0;
// default: if there is nothing dispatched or issued, then everything stays the same.
	for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
	begin
		next_alu_type[i]			= alu_type[i];
		next_npc[i]						= npc[i];
		next_ir[i]						= ir[i];
		next_branch_taken[i]	= branch_taken[i];
		next_pred_addr[i]			= pred_addr[i];
		next_opa_select[i]		= opa_select[i];
		next_opb_select[i]		= opb_select[i];
		next_dest_ar_idx[i]		= dest_ar_idx[i];
		next_dest_pr_idx[i]		= dest_pr_idx[i];
		next_pra_idx[i]				= pra_idx[i];
		next_pra_ready[i]			= pra_ready[i];
		next_prb_idx[i]				= prb_idx[i];
		next_prb_ready[i]			= prb_ready[i];
		next_alu_func[i]			= alu_func[i];
		next_rd_mem[i]				= rd_mem[i];
		next_wr_mem[i]				= wr_mem[i];
		next_cond_branch[i]		= cond_branch[i];
		next_uncond_branch[i]	= uncond_branch[i];
		next_halt[i]					= halt[i];
		next_illegal_inst[i]	= illegal_inst[i];
		next_valid_inst[i]		= valid_inst[i];
	end

	next_sim_ready = sim_ready;
	next_mul_ready = mul_ready;
	next_mem_ready = mem_ready;
	next_ent_taken = ent_taken; // ent means entry
	next_ent_avail = ent_avail;
//--------------------------------------------------------------ISSUE LOGIC
//////////////////////////////////////////////////////////////////////////////////////////////////Here is the simple alu
	if (ready_sim_valid) begin
		if (alu_sim_avail[1] && alu_sim_avail[0]) begin
			if (ready_sim_high_idx != ready_sim_low_idx) begin
				alu_sim_NPC0					= npc[ready_sim_high_idx];
				alu_sim_IR0 					= ir[ready_sim_high_idx];
				alu_sim_branch_taken0 = branch_taken[ready_sim_high_idx];
				alu_sim_pred_addr0 		= pred_addr[ready_sim_high_idx];
				alu_sim_prf_pra_idx0 	= pra_idx[ready_sim_high_idx];
				alu_sim_prf_prb_idx0 	= prb_idx[ready_sim_high_idx];
				alu_sim_opa_select0		= opa_select[ready_sim_high_idx];
				alu_sim_opb_select0		= opb_select[ready_sim_high_idx];
				alu_sim_dest_ar_idx0	= dest_ar_idx[ready_sim_high_idx];
				alu_sim_dest_pr_idx0	= dest_pr_idx[ready_sim_high_idx];
				alu_sim_func0					= alu_func[ready_sim_high_idx];
				alu_sim_rd_mem0				= rd_mem[ready_sim_high_idx];
				alu_sim_wr_mem0				= wr_mem[ready_sim_high_idx];
				alu_sim_cond_branch0	= cond_branch[ready_sim_high_idx];
				alu_sim_uncond_branch0	= uncond_branch[ready_sim_high_idx];
				alu_sim_halt0					= halt[ready_sim_high_idx];
				alu_sim_illegal_inst0	= illegal_inst[ready_sim_high_idx];
				alu_sim_valid_inst0		= valid_inst[ready_sim_high_idx];

				alu_sim_NPC1					= npc[ready_sim_low_idx];
				alu_sim_IR1 					= ir[ready_sim_low_idx];
				alu_sim_branch_taken1 = branch_taken[ready_sim_low_idx];
				alu_sim_pred_addr1 		= pred_addr[ready_sim_low_idx];
				alu_sim_prf_pra_idx1 	= pra_idx[ready_sim_low_idx];
				alu_sim_prf_prb_idx1 	= prb_idx[ready_sim_low_idx];
				alu_sim_opa_select1		= opa_select[ready_sim_low_idx];
				alu_sim_opb_select1		= opb_select[ready_sim_low_idx];
				alu_sim_dest_ar_idx1	= dest_ar_idx[ready_sim_low_idx];
				alu_sim_dest_pr_idx1	= dest_pr_idx[ready_sim_low_idx];
				alu_sim_func1					= alu_func[ready_sim_low_idx];
				alu_sim_rd_mem1				= rd_mem[ready_sim_low_idx];
				alu_sim_wr_mem1				= wr_mem[ready_sim_low_idx];
				alu_sim_cond_branch1	= cond_branch[ready_sim_low_idx];
				alu_sim_uncond_branch1	= uncond_branch[ready_sim_low_idx];
				alu_sim_halt1					= halt[ready_sim_low_idx];
				alu_sim_illegal_inst1	= illegal_inst[ready_sim_low_idx];
				alu_sim_valid_inst1		= valid_inst[ready_sim_low_idx];

				next_sim_ready[ready_sim_high_idx] = 0;
				next_sim_ready[ready_sim_low_idx] = 0;

				next_ent_taken[ready_sim_high_idx] = 0;
				next_ent_taken[ready_sim_low_idx] = 0;
				next_ent_avail[ready_sim_high_idx] = 1'b1;
				next_ent_avail[ready_sim_low_idx] = 1'b1;
			end
			else begin
				alu_sim_NPC0					= npc[ready_sim_high_idx];
				alu_sim_IR0 					= ir[ready_sim_high_idx];
				alu_sim_branch_taken0 = branch_taken[ready_sim_high_idx];
				alu_sim_pred_addr0 		= pred_addr[ready_sim_high_idx];
				alu_sim_prf_pra_idx0 	= pra_idx[ready_sim_high_idx];
				alu_sim_prf_prb_idx0 	= prb_idx[ready_sim_high_idx];
				alu_sim_opa_select0		= opa_select[ready_sim_high_idx];
				alu_sim_opb_select0		= opb_select[ready_sim_high_idx];
				alu_sim_dest_ar_idx0	= dest_ar_idx[ready_sim_high_idx];
				alu_sim_dest_pr_idx0	= dest_pr_idx[ready_sim_high_idx];
				alu_sim_func0					= alu_func[ready_sim_high_idx];
				alu_sim_rd_mem0				= rd_mem[ready_sim_high_idx];
				alu_sim_wr_mem0				= wr_mem[ready_sim_high_idx];
				alu_sim_cond_branch0	= cond_branch[ready_sim_high_idx];
				alu_sim_uncond_branch0		= uncond_branch[ready_sim_high_idx];
				alu_sim_halt0					= halt[ready_sim_high_idx];
				alu_sim_illegal_inst0	= illegal_inst[ready_sim_high_idx];
				alu_sim_valid_inst0		= valid_inst[ready_sim_high_idx];

				alu_sim_valid_inst1 	=	0;//Tell the alu_sim that only instruction0 is valid

				next_sim_ready[ready_sim_high_idx]	= 0;
				
				next_ent_taken[ready_sim_high_idx] = 0;
				next_ent_avail[ready_sim_high_idx] = 1'b1;
			end
		end
		else if (alu_sim_avail[0]) begin
			alu_sim_NPC0					= npc[ready_sim_high_idx];
			alu_sim_IR0 					= ir[ready_sim_high_idx];
			alu_sim_branch_taken0 = branch_taken[ready_sim_high_idx];
			alu_sim_pred_addr0 		= pred_addr[ready_sim_high_idx];
			alu_sim_prf_pra_idx0 	= pra_idx[ready_sim_high_idx];
			alu_sim_prf_prb_idx0 	= prb_idx[ready_sim_high_idx];
			alu_sim_opa_select0		= opa_select[ready_sim_high_idx];
			alu_sim_opb_select0		= opb_select[ready_sim_high_idx];
			alu_sim_dest_ar_idx0	= dest_ar_idx[ready_sim_high_idx];
			alu_sim_dest_pr_idx0	= dest_pr_idx[ready_sim_high_idx];
			alu_sim_func0					= alu_func[ready_sim_high_idx];
			alu_sim_rd_mem0				= rd_mem[ready_sim_high_idx];
			alu_sim_wr_mem0				= wr_mem[ready_sim_high_idx];
			alu_sim_cond_branch0	= cond_branch[ready_sim_high_idx];
			alu_sim_uncond_branch0		= uncond_branch[ready_sim_high_idx];
			alu_sim_halt0					= halt[ready_sim_high_idx];
			alu_sim_illegal_inst0	= illegal_inst[ready_sim_high_idx];
			alu_sim_valid_inst0		= valid_inst[ready_sim_high_idx];

			alu_sim_valid_inst1 	=	0;//Tell the alu_sim that only instruction0 is valid

			next_sim_ready[ready_sim_high_idx]	= 0;
			
			next_ent_taken[ready_sim_high_idx] = 0;
			next_ent_avail[ready_sim_high_idx] = 1'b1;
		end
		else if (alu_sim_avail[1]) begin
			alu_sim_NPC1					= npc[ready_sim_high_idx];
			alu_sim_IR1 					= ir[ready_sim_high_idx];
			alu_sim_branch_taken1 = branch_taken[ready_sim_high_idx];
			alu_sim_pred_addr1 		= pred_addr[ready_sim_high_idx];
			alu_sim_prf_pra_idx1 	= pra_idx[ready_sim_high_idx];
			alu_sim_prf_prb_idx1 	= prb_idx[ready_sim_high_idx];
			alu_sim_opa_select1		= opa_select[ready_sim_high_idx];
			alu_sim_opb_select1		= opb_select[ready_sim_high_idx];
			alu_sim_dest_ar_idx1	= dest_ar_idx[ready_sim_high_idx];
			alu_sim_dest_pr_idx1	= dest_pr_idx[ready_sim_high_idx];
			alu_sim_func1					= alu_func[ready_sim_high_idx];
			alu_sim_rd_mem1				= rd_mem[ready_sim_high_idx];
			alu_sim_wr_mem1				= wr_mem[ready_sim_high_idx];
			alu_sim_cond_branch1	= cond_branch[ready_sim_high_idx];
			alu_sim_uncond_branch1		= uncond_branch[ready_sim_high_idx];
			alu_sim_halt1					= halt[ready_sim_high_idx];
			alu_sim_illegal_inst1	= illegal_inst[ready_sim_high_idx];
			alu_sim_valid_inst1		= valid_inst[ready_sim_high_idx];

			alu_sim_valid_inst0 	=	0;//Tell the alu_sim that only instruction1 is valid

			next_sim_ready[ready_sim_high_idx]	= 0;
			
			next_ent_taken[ready_sim_high_idx] = 0;
			next_ent_avail[ready_sim_high_idx] = 1'b1;
		end
		else begin
			alu_sim_valid_inst0		= 0;
			alu_sim_valid_inst1		= 0;
		end
	end
	else begin
		alu_sim_valid_inst0		= 0;
		alu_sim_valid_inst1		= 0;
	end

////////////////////////////////////////////////////////////////////////////////////////Here starts the multiply
	if (ready_mul_valid) begin
		if (alu_mul_avail[1] && alu_mul_avail[0]) begin
			if (ready_mul_high_idx != ready_mul_low_idx) begin
				alu_mul_NPC0					= npc[ready_mul_high_idx];
				alu_mul_IR0 					= ir[ready_mul_high_idx];
				alu_mul_branch_taken0 = branch_taken[ready_mul_high_idx];
				alu_mul_pred_addr0 		= pred_addr[ready_mul_high_idx];
				alu_mul_prf_pra_idx0 	= pra_idx[ready_mul_high_idx];
				alu_mul_prf_prb_idx0 	= prb_idx[ready_mul_high_idx];
				alu_mul_opa_select0		= opa_select[ready_mul_high_idx];
				alu_mul_opb_select0		= opb_select[ready_mul_high_idx];
				alu_mul_dest_ar_idx0	= dest_ar_idx[ready_mul_high_idx];
				alu_mul_dest_pr_idx0	= dest_pr_idx[ready_mul_high_idx];
				alu_mul_func0					= alu_func[ready_mul_high_idx];
				alu_mul_rd_mem0				= rd_mem[ready_mul_high_idx];
				alu_mul_wr_mem0				= wr_mem[ready_mul_high_idx];
				alu_mul_cond_branch0	= cond_branch[ready_mul_high_idx];
				alu_mul_uncond_branch0		= uncond_branch[ready_mul_high_idx];
				alu_mul_halt0					= halt[ready_mul_high_idx];
				alu_mul_illegal_inst0	= illegal_inst[ready_mul_high_idx];
				alu_mul_valid_inst0		= valid_inst[ready_mul_high_idx];

				alu_mul_NPC1					= npc[ready_mul_low_idx];
				alu_mul_IR1 					= ir[ready_mul_low_idx];
				alu_mul_branch_taken1 = branch_taken[ready_mul_low_idx];
				alu_mul_pred_addr1 		= pred_addr[ready_mul_low_idx];
				alu_mul_prf_pra_idx1 	= pra_idx[ready_mul_low_idx];
				alu_mul_prf_prb_idx1 	= prb_idx[ready_mul_low_idx];
				alu_mul_opa_select1		= opa_select[ready_mul_low_idx];
				alu_mul_opb_select1		= opb_select[ready_mul_low_idx];
				alu_mul_dest_ar_idx1	= dest_ar_idx[ready_mul_low_idx];
				alu_mul_dest_pr_idx1	= dest_pr_idx[ready_mul_low_idx];
				alu_mul_func1					= alu_func[ready_mul_low_idx];
				alu_mul_rd_mem1				= rd_mem[ready_mul_low_idx];
				alu_mul_wr_mem1				= wr_mem[ready_mul_low_idx];
				alu_mul_cond_branch1	= cond_branch[ready_mul_low_idx];
				alu_mul_uncond_branch1		= uncond_branch[ready_mul_low_idx];
				alu_mul_halt1					= halt[ready_mul_low_idx];
				alu_mul_illegal_inst1	= illegal_inst[ready_mul_low_idx];
				alu_mul_valid_inst1		= valid_inst[ready_mul_low_idx];

				next_mul_ready[ready_mul_high_idx] = 0;
				next_mul_ready[ready_mul_low_idx] = 0;

				next_ent_taken[ready_mul_high_idx] = 0;
				next_ent_taken[ready_mul_low_idx] = 0;
				next_ent_avail[ready_mul_high_idx] = 1'b1;
				next_ent_avail[ready_mul_low_idx] = 1'b1;
			end
			else begin
				alu_mul_NPC0					= npc[ready_mul_high_idx];
				alu_mul_IR0 					= ir[ready_mul_high_idx];
				alu_mul_branch_taken0 = branch_taken[ready_mul_high_idx];
				alu_mul_pred_addr0 		= pred_addr[ready_mul_high_idx];
				alu_mul_prf_pra_idx0 	= pra_idx[ready_mul_high_idx];
				alu_mul_prf_prb_idx0 	= prb_idx[ready_mul_high_idx];
				alu_mul_opa_select0		= opa_select[ready_mul_high_idx];
				alu_mul_opb_select0		= opb_select[ready_mul_high_idx];
				alu_mul_dest_ar_idx0	= dest_ar_idx[ready_mul_high_idx];
				alu_mul_dest_pr_idx0	= dest_pr_idx[ready_mul_high_idx];
				alu_mul_func0					= alu_func[ready_mul_high_idx];
				alu_mul_rd_mem0				= rd_mem[ready_mul_high_idx];
				alu_mul_wr_mem0				= wr_mem[ready_mul_high_idx];
				alu_mul_cond_branch0	= cond_branch[ready_mul_high_idx];
				alu_mul_uncond_branch0		= uncond_branch[ready_mul_high_idx];
				alu_mul_halt0					= halt[ready_mul_high_idx];
				alu_mul_illegal_inst0	= illegal_inst[ready_mul_high_idx];
				alu_mul_valid_inst0		= valid_inst[ready_mul_high_idx];

				alu_mul_valid_inst1 	=	0;//Tell the alu_mult that only instruction0 is valid

				next_mul_ready[ready_mul_high_idx]	= 0;
				
				next_ent_taken[ready_mul_high_idx] = 0;
				next_ent_avail[ready_mul_high_idx] = 1'b1;
			end
		end
		else if (alu_mul_avail[0]) begin
			alu_mul_NPC0					= npc[ready_mul_high_idx];
			alu_mul_IR0 					= ir[ready_mul_high_idx];
			alu_mul_branch_taken0 = branch_taken[ready_mul_high_idx];
			alu_mul_pred_addr0 		= pred_addr[ready_mul_high_idx];
			alu_mul_prf_pra_idx0 	= pra_idx[ready_mul_high_idx];
			alu_mul_prf_prb_idx0 	= prb_idx[ready_mul_high_idx];
			alu_mul_opa_select0		= opa_select[ready_mul_high_idx];
			alu_mul_opb_select0		= opb_select[ready_mul_high_idx];
			alu_mul_dest_ar_idx0	= dest_ar_idx[ready_mul_high_idx];
			alu_mul_dest_pr_idx0	= dest_pr_idx[ready_mul_high_idx];
			alu_mul_func0					= alu_func[ready_mul_high_idx];
			alu_mul_rd_mem0				= rd_mem[ready_mul_high_idx];
			alu_mul_wr_mem0				= wr_mem[ready_mul_high_idx];
			alu_mul_cond_branch0	= cond_branch[ready_mul_high_idx];
			alu_mul_uncond_branch0		= uncond_branch[ready_mul_high_idx];
			alu_mul_halt0					= halt[ready_mul_high_idx];
			alu_mul_illegal_inst0	= illegal_inst[ready_mul_high_idx];
			alu_mul_valid_inst0		= valid_inst[ready_mul_high_idx];

			alu_mul_valid_inst1 	=	0;//Tell the alu_mult that only instruction0 is valid

			next_mul_ready[ready_mul_high_idx]	= 0;
			
			next_ent_taken[ready_mul_high_idx] = 0;
			next_ent_avail[ready_mul_high_idx] = 1'b1;
		end
		else if (alu_mul_avail[1]) begin
			alu_mul_NPC1					= npc[ready_mul_high_idx];
			alu_mul_IR1 					= ir[ready_mul_high_idx];
			alu_mul_branch_taken1 = branch_taken[ready_mul_high_idx];
			alu_mul_pred_addr1 		= pred_addr[ready_mul_high_idx];
			alu_mul_prf_pra_idx1 	= pra_idx[ready_mul_high_idx];
			alu_mul_prf_prb_idx1 	= prb_idx[ready_mul_high_idx];
			alu_mul_opa_select1		= opa_select[ready_mul_high_idx];
			alu_mul_opb_select1		= opb_select[ready_mul_high_idx];
			alu_mul_dest_ar_idx1	= dest_ar_idx[ready_mul_high_idx];
			alu_mul_dest_pr_idx1	= dest_pr_idx[ready_mul_high_idx];
			alu_mul_func1					= alu_func[ready_mul_high_idx];
			alu_mul_rd_mem1				= rd_mem[ready_mul_high_idx];
			alu_mul_wr_mem1				= wr_mem[ready_mul_high_idx];
			alu_mul_cond_branch1	= cond_branch[ready_mul_high_idx];
			alu_mul_uncond_branch1		= uncond_branch[ready_mul_high_idx];
			alu_mul_halt1					= halt[ready_mul_high_idx];
			alu_mul_illegal_inst1	= illegal_inst[ready_mul_high_idx];
			alu_mul_valid_inst1		= valid_inst[ready_mul_high_idx];

			alu_mul_valid_inst0 	=	0;//Tell the alu_mult that only instruction1 is valid

			next_mul_ready[ready_mul_high_idx]	= 0;

			next_ent_taken[ready_mul_high_idx] = 0;
			next_ent_avail[ready_mul_high_idx] = 1'b1;
		end
		else begin
			alu_mul_valid_inst0		= 0;
			alu_mul_valid_inst1		= 0;
		end
	end
	else begin
		alu_mul_valid_inst0		= 0;
		alu_mul_valid_inst1		= 0;
	end
//////////////////////////////////////////////////////////////////////////////Here is the LSQ
	if (ready_mem_valid) begin
		if (alu_mem_avail[1] && alu_mem_avail[0]) begin
			if (ready_mem_high_idx != ready_mem_low_idx) begin
				alu_mem_NPC0					= npc[ready_mem_high_idx];
				alu_mem_IR0 					= ir[ready_mem_high_idx];
				alu_mem_branch_taken0 = branch_taken[ready_mem_high_idx];
				alu_mem_pred_addr0 		= pred_addr[ready_mem_high_idx];
				alu_mem_prf_pra_idx0 	= pra_idx[ready_mem_high_idx];
				alu_mem_prf_prb_idx0 	= prb_idx[ready_mem_high_idx];
				alu_mem_opa_select0		= opa_select[ready_mem_high_idx];
				alu_mem_opb_select0		= opb_select[ready_mem_high_idx];
				alu_mem_dest_ar_idx0	= dest_ar_idx[ready_mem_high_idx];
				alu_mem_dest_pr_idx0	= dest_pr_idx[ready_mem_high_idx];
				alu_mem_func0					= alu_func[ready_mem_high_idx];
				alu_mem_rd_mem0				= rd_mem[ready_mem_high_idx];
				alu_mem_wr_mem0				= wr_mem[ready_mem_high_idx];
				alu_mem_cond_branch0	= cond_branch[ready_mem_high_idx];
				alu_mem_uncond_branch0		= uncond_branch[ready_mem_high_idx];
				alu_mem_halt0					= halt[ready_mem_high_idx];
				alu_mem_illegal_inst0	= illegal_inst[ready_mem_high_idx];
				alu_mem_valid_inst0		= valid_inst[ready_mem_high_idx];

				alu_mem_NPC1					= npc[ready_mem_low_idx];
				alu_mem_IR1 					= ir[ready_mem_low_idx];
				alu_mem_branch_taken1 = branch_taken[ready_mem_low_idx];
				alu_mem_pred_addr1 		= pred_addr[ready_mem_low_idx];
				alu_mem_prf_pra_idx1 	= pra_idx[ready_mem_low_idx];
				alu_mem_prf_prb_idx1 	= prb_idx[ready_mem_low_idx];
				alu_mem_opa_select1		= opa_select[ready_mem_low_idx];
				alu_mem_opb_select1		= opb_select[ready_mem_low_idx];
				alu_mem_dest_ar_idx1	= dest_ar_idx[ready_mem_low_idx];
				alu_mem_dest_pr_idx1	= dest_pr_idx[ready_mem_low_idx];
				alu_mem_func1					= alu_func[ready_mem_low_idx];
				alu_mem_rd_mem1				= rd_mem[ready_mem_low_idx];
				alu_mem_wr_mem1				= wr_mem[ready_mem_low_idx];
				alu_mem_cond_branch1	= cond_branch[ready_mem_low_idx];
				alu_mem_uncond_branch1		= uncond_branch[ready_mem_low_idx];
				alu_mem_halt1					= halt[ready_mem_low_idx];
				alu_mem_illegal_inst1	= illegal_inst[ready_mem_low_idx];
				alu_mem_valid_inst1		= valid_inst[ready_mem_low_idx];

				next_mem_ready[ready_mem_high_idx] = 0;
				next_mem_ready[ready_mem_low_idx] = 0;

				next_ent_taken[ready_mem_high_idx] = 0;
				next_ent_taken[ready_mem_low_idx] = 0;
				next_ent_avail[ready_mem_high_idx] = 1'b1;
				next_ent_avail[ready_mem_low_idx] = 1'b1;
			end
			else begin
				alu_mem_NPC0					= npc[ready_mem_high_idx];
				alu_mem_IR0 					= ir[ready_mem_high_idx];
				alu_mem_branch_taken0 = branch_taken[ready_mem_high_idx];
				alu_mem_pred_addr0 		= pred_addr[ready_mem_high_idx];
				alu_mem_prf_pra_idx0 	= pra_idx[ready_mem_high_idx];
				alu_mem_prf_prb_idx0 	= prb_idx[ready_mem_high_idx];
				alu_mem_opa_select0		= opa_select[ready_mem_high_idx];
				alu_mem_opb_select0		= opb_select[ready_mem_high_idx];
				alu_mem_dest_ar_idx0	= dest_ar_idx[ready_mem_high_idx];
				alu_mem_dest_pr_idx0	= dest_pr_idx[ready_mem_high_idx];
				alu_mem_func0					= alu_func[ready_mem_high_idx];
				alu_mem_rd_mem0				= rd_mem[ready_mem_high_idx];
				alu_mem_wr_mem0				= wr_mem[ready_mem_high_idx];
				alu_mem_cond_branch0	= cond_branch[ready_mem_high_idx];
				alu_mem_uncond_branch0		= uncond_branch[ready_mem_high_idx];
				alu_mem_halt0					= halt[ready_mem_high_idx];
				alu_mem_illegal_inst0	= illegal_inst[ready_mem_high_idx];
				alu_mem_valid_inst0		= valid_inst[ready_mem_high_idx];

				alu_mem_valid_inst1 	=	0;

				next_mem_ready[ready_mem_high_idx] = 0;

				next_ent_taken[ready_mem_high_idx] = 0;
				next_ent_avail[ready_mem_high_idx] = 1'b1;
			end
		end
		else if (alu_mem_avail[0]) begin
			alu_mem_NPC0					= npc[ready_mem_high_idx];
			alu_mem_IR0 					= ir[ready_mem_high_idx];
			alu_mem_branch_taken0 = branch_taken[ready_mem_high_idx];
			alu_mem_pred_addr0 		= pred_addr[ready_mem_high_idx];
			alu_mem_prf_pra_idx0 	= pra_idx[ready_mem_high_idx];
			alu_mem_prf_prb_idx0 	= prb_idx[ready_mem_high_idx];
			alu_mem_opa_select0		= opa_select[ready_mem_high_idx];
			alu_mem_opb_select0		= opb_select[ready_mem_high_idx];
			alu_mem_dest_ar_idx0	= dest_ar_idx[ready_mem_high_idx];
			alu_mem_dest_pr_idx0	= dest_pr_idx[ready_mem_high_idx];
			alu_mem_func0					= alu_func[ready_mem_high_idx];
			alu_mem_rd_mem0				= rd_mem[ready_mem_high_idx];
			alu_mem_wr_mem0				= wr_mem[ready_mem_high_idx];
			alu_mem_cond_branch0	= cond_branch[ready_mem_high_idx];
			alu_mem_uncond_branch0		= uncond_branch[ready_mem_high_idx];
			alu_mem_halt0					= halt[ready_mem_high_idx];
			alu_mem_illegal_inst0	= illegal_inst[ready_mem_high_idx];
			alu_mem_valid_inst0		= valid_inst[ready_mem_high_idx];

			alu_mem_valid_inst1 	=	0;

			next_mem_ready[ready_mem_high_idx]	= 0;
			
			next_ent_taken[ready_mem_high_idx] = 0;
			next_ent_avail[ready_mem_high_idx] = 1'b1;
		end
		else if (alu_mem_avail[1]) begin
			alu_mem_NPC1					= npc[ready_mem_high_idx];
			alu_mem_IR1 					= ir[ready_mem_high_idx];
			alu_mem_branch_taken1 = branch_taken[ready_mem_high_idx];
			alu_mem_pred_addr1 		= pred_addr[ready_mem_high_idx];
			alu_mem_prf_pra_idx1 	= pra_idx[ready_mem_high_idx];
			alu_mem_prf_prb_idx1 	= prb_idx[ready_mem_high_idx];
			alu_mem_opa_select1		= opa_select[ready_mem_high_idx];
			alu_mem_opb_select1		= opb_select[ready_mem_high_idx];
			alu_mem_dest_ar_idx1	= dest_ar_idx[ready_mem_high_idx];
			alu_mem_dest_pr_idx1	= dest_pr_idx[ready_mem_high_idx];
			alu_mem_func1					= alu_func[ready_mem_high_idx];
			alu_mem_rd_mem1				= rd_mem[ready_mem_high_idx];
			alu_mem_wr_mem1				= wr_mem[ready_mem_high_idx];
			alu_mem_cond_branch1	= cond_branch[ready_mem_high_idx];
			alu_mem_uncond_branch1		= uncond_branch[ready_mem_high_idx];
			alu_mem_halt1					= halt[ready_mem_high_idx];
			alu_mem_illegal_inst1	= illegal_inst[ready_mem_high_idx];
			alu_mem_valid_inst1		= valid_inst[ready_mem_high_idx];

			alu_mem_valid_inst0 	=	0;

			next_mem_ready[ready_mem_high_idx]	= 0;

			next_ent_taken[ready_mem_high_idx] = 0;
			next_ent_avail[ready_mem_high_idx] = 1'b1;
		end
		else begin
			alu_mem_valid_inst0		= 0;
			alu_mem_valid_inst1		= 0;
		end
	end
	else begin
		alu_mem_valid_inst0		= 0;
		alu_mem_valid_inst1		= 0;
	end

//------------------------------------------------------------------------DISPATCH LOGIC
	if (id_valid_inst0 & ~id_illegal_inst0) begin
		case (id_IR0[31:26])
			`MULQ_INST: 
				next_alu_type[ent_avail_high_idx] = `ALU_MUL;
			`LDQ_INST, `LDQ_L_INST,
			`STQ_INST, `STQ_C_INST:
				next_alu_type[ent_avail_high_idx] = `ALU_MEM;
			default:
				next_alu_type[ent_avail_high_idx] = `ALU_SIM;
		endcase
/////////////////////////////////////////////////////////////////////////////????
		next_npc[ent_avail_high_idx]					= id_NPC0;
		next_ir[ent_avail_high_idx]						= id_IR0;
		next_branch_taken[ent_avail_high_idx]	= id_branch_taken0;
		next_pred_addr[ent_avail_high_idx]		= id_pred_addr0;
		next_opa_select[ent_avail_high_idx]		= id_opa_select0;
		next_opb_select[ent_avail_high_idx]		= id_opb_select0;
		next_dest_ar_idx[ent_avail_high_idx]	= id_dest_idx0;
		next_dest_pr_idx[ent_avail_high_idx]	= fl_pr_dest_idx0;
		next_pra_idx[ent_avail_high_idx]			= mt_pra_idx0;
		next_pra_ready[ent_avail_high_idx]		= mt_pra_ready0;
		next_prb_idx[ent_avail_high_idx]			= mt_prb_idx0;
		next_prb_ready[ent_avail_high_idx]		= mt_prb_ready0;
		next_alu_func[ent_avail_high_idx]			= id_alu_func0;
		next_rd_mem[ent_avail_high_idx]				= id_rd_mem0;
		next_wr_mem[ent_avail_high_idx]				= id_wr_mem0;
		next_cond_branch[ent_avail_high_idx]	= id_cond_branch0;
		next_uncond_branch[ent_avail_high_idx]= id_uncond_branch0;
		next_halt[ent_avail_high_idx]					= id_halt0;
		next_illegal_inst[ent_avail_high_idx]	= id_illegal_inst0;
		next_valid_inst[ent_avail_high_idx]		= id_valid_inst0;

		next_ent_avail[ent_avail_high_idx]		= 0;
		next_ent_taken[ent_avail_high_idx]		= 1;
	end


	if (id_valid_inst1 & ~id_illegal_inst1)
	begin
		case (id_IR1[31:26])
			`MULQ_INST: 
				next_alu_type[ent_avail_low_idx] = `ALU_MUL;
			`LDQ_INST, `LDQ_L_INST,
			`STQ_INST, `STQ_C_INST:
				next_alu_type[ent_avail_low_idx] = `ALU_MEM;
			default:
				next_alu_type[ent_avail_low_idx] = `ALU_SIM;
		endcase

		next_npc[ent_avail_low_idx]					= id_NPC1;
		next_ir[ent_avail_low_idx]						= id_IR1;
		next_branch_taken[ent_avail_low_idx]	= id_branch_taken1;
		next_pred_addr[ent_avail_low_idx]		= id_pred_addr1;
		next_opa_select[ent_avail_low_idx]		= id_opa_select1;
		next_opb_select[ent_avail_low_idx]		= id_opb_select1;
		next_dest_ar_idx[ent_avail_low_idx]	= id_dest_idx1;
		next_dest_pr_idx[ent_avail_low_idx]	= fl_pr_dest_idx1;
		next_pra_idx[ent_avail_low_idx]			= mt_pra_idx1;
		next_pra_ready[ent_avail_low_idx]		= mt_pra_ready1;
		next_prb_idx[ent_avail_low_idx]			= mt_prb_idx1;
		next_prb_ready[ent_avail_low_idx]		= mt_prb_ready1;
		next_alu_func[ent_avail_low_idx]			= id_alu_func1;
		next_rd_mem[ent_avail_low_idx]				= id_rd_mem1;
		next_wr_mem[ent_avail_low_idx]				= id_wr_mem1;
		next_cond_branch[ent_avail_low_idx]	= id_cond_branch1;
		next_uncond_branch[ent_avail_low_idx]= id_uncond_branch1;
		next_halt[ent_avail_low_idx]					= id_halt1;
		next_illegal_inst[ent_avail_low_idx]	= id_illegal_inst1;
		next_valid_inst[ent_avail_low_idx]		= id_valid_inst1;

		next_ent_avail[ent_avail_low_idx]		= 0;
		next_ent_taken[ent_avail_low_idx]		= 1;
	end

	// Complete
	if (cdb_broadcast[0])
	begin
		for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
		begin
			if (ent_taken[i])
			begin
				if (cdb_pr_tag0 == pra_idx[i]) next_pra_ready[i] = 1;
				if (cdb_pr_tag0 == prb_idx[i]) next_prb_ready[i] = 1;
			end
		end
	end

	if (cdb_broadcast[1])
	begin
		for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
		begin
			if (ent_taken[i])
			begin
				if (cdb_pr_tag1 == pra_idx[i]) next_pra_ready[i] = 1;
				if (cdb_pr_tag1 == prb_idx[i]) next_prb_ready[i] = 1;
			end
		end
	end

	if (cdb_broadcast[2])
	begin
		for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
		begin
			if (ent_taken[i])
			begin
				if (cdb_pr_tag2 == pra_idx[i]) next_pra_ready[i] = 1;
				if (cdb_pr_tag2 == prb_idx[i]) next_prb_ready[i] = 1;
			end
		end
	end

	if (cdb_broadcast[3])
	begin
		for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
		begin
			if (ent_taken[i])
			begin
				if (cdb_pr_tag3 == pra_idx[i]) next_pra_ready[i] = 1;
				if (cdb_pr_tag3 == prb_idx[i]) next_prb_ready[i] = 1;
			end
		end
	end

	if (cdb_broadcast[4])
	begin
		for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
		begin
			if (ent_taken[i])
			begin
				if (cdb_pr_tag4 == pra_idx[i]) next_pra_ready[i] = 1;
				if (cdb_pr_tag4 == prb_idx[i]) next_prb_ready[i] = 1;
			end
		end
	end

	if (cdb_broadcast[5])
	begin
		for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
		begin
			if (ent_taken[i])
			begin
				if (cdb_pr_tag5 == pra_idx[i]) next_pra_ready[i] = 1;
				if (cdb_pr_tag5 == prb_idx[i]) next_prb_ready[i] = 1;
			end
		end
	end
	
	for (i = 0; i < `NUM_RS_ENTRIES; i = i + 1)
	begin
		if (next_ent_taken[i])
		begin
			`ifndef VCS
				$assert(next_mem_ready[i] != `ALU_INV);
			`endif
			if (next_pra_ready[i] & next_prb_ready[i])
			begin
				case (next_alu_type[i])
					`ALU_SIM: next_sim_ready[i] = 1;
					`ALU_MUL: next_mul_ready[i] = 1;
					`ALU_MEM: next_mem_ready[i] = 1;
				endcase
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
		ent_taken			<= `SD `NUM_RS_ENTRIES'b0;
		ent_avail			<= {`NUM_RS_ENTRIES{1'b1}};
		
		for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
		begin
			alu_type[i]			<= `SD `ALU_INV;
			npc[i]					<= `SD 0;
			ir[i]						<= `SD `NOOP_INST;
			branch_taken[i]	<= `SD 0;
			pred_addr[i]		<= `SD 0;
			opa_select[i]		<= `SD 0;
			opb_select[i]		<= `SD 0;
			dest_ar_idx[i]	<= `SD `ZERO_REG;
			dest_pr_idx[i]	<= `SD 0;
			pra_idx[i]			<= `SD 0;
			pra_ready[i]		<= `SD 0;
			prb_idx[i]			<= `SD 0;
			prb_ready[i]		<= `SD 0;
			alu_func[i]			<= `SD 0;
			rd_mem[i]				<= `SD 0;
			wr_mem[i]				<= `SD 0;
			cond_branch[i]	<= `SD 0;
			uncond_branch[i]<= `SD 0;
			halt[i]					<= `SD 0;
			illegal_inst[i]	<= `SD 0;
			valid_inst[i]		<= `SD 0;
		end
	end
	else
	begin
		sim_ready					<= `SD next_sim_ready;
		mul_ready					<= `SD next_mul_ready;
		mem_ready					<= `SD next_mem_ready;
		ent_taken					<= `SD next_ent_taken;
		ent_avail					<= `SD next_ent_avail;

		for (i = 0; i < `NUM_RS_ENTRIES; i = i+1)
		begin
			alu_type[i]			<= `SD next_alu_type[i];
			npc[i]					<= `SD next_npc[i];
			ir[i]						<= `SD next_ir[i];
			branch_taken[i]	<= `SD next_branch_taken[i];
			pred_addr[i]		<= `SD next_pred_addr[i];
			opa_select[i]		<= `SD next_opa_select[i];
			opb_select[i]		<= `SD next_opb_select[i];
			dest_ar_idx[i]	<= `SD next_dest_ar_idx[i];
			dest_pr_idx[i]	<= `SD next_dest_pr_idx[i];
			pra_idx[i]			<= `SD next_pra_idx[i];
			pra_ready[i]		<= `SD next_pra_ready[i];
			prb_idx[i]			<= `SD next_prb_idx[i];
			prb_ready[i]		<= `SD next_prb_ready[i];
			alu_func[i]			<= `SD next_alu_func[i];
			rd_mem[i]				<= `SD next_rd_mem[i];
			wr_mem[i]				<= `SD next_wr_mem[i];
			cond_branch[i]	<= `SD next_cond_branch[i];
			uncond_branch[i]<= `SD next_uncond_branch[i];
			halt[i]					<= `SD next_halt[i];
			illegal_inst[i]	<= `SD next_illegal_inst[i];
			valid_inst[i]		<= `SD next_valid_inst[i];
		end

	end
end

genvar IDX;
generate
	for(IDX=0; IDX<`NUM_RS_ENTRIES; IDX=IDX+1)
	begin : foo
		wire		[1:0]	ALU_TYPE = alu_type[IDX];
		wire	 [63:0]	NPC = npc[IDX];
		wire	 [31:0]	IR = ir[IDX];
		wire					BRANCH_TAKEN = branch_taken[IDX];
		wire	 [63:0]	PRED_ADDR = pred_addr[IDX];
		wire		[1:0]	OPA_SELECT = opa_select[IDX];
		wire		[1:0]	OPB_SELECT = opb_select[IDX];
		wire		[4:0]	DEST_AR_IDX = dest_ar_idx[IDX];
		wire		[6:0]	DEST_PR_IDX = dest_pr_idx[IDX];
		wire		[6:0]	PRA_IDX = pra_idx[IDX];
		wire					PRA_READY = pra_ready[IDX];
		wire		[6:0]	PRB_IDX = prb_idx[IDX];
		wire					PRB_READY = prb_ready[IDX];
		wire		[4:0]	ALU_FUNC = alu_func[IDX];
		wire					RD_MEM = rd_mem[IDX];
		wire					WR_MEM = wr_mem[IDX];
		wire					COND_BRANCH = cond_branch[IDX];
		wire					UNCOND_BRANCH = uncond_branch[IDX];
		wire					HALT = halt[IDX];
		wire					ILLEGAL_INST = illegal_inst[IDX];
		wire					VALID_INST = valid_inst[IDX];
		
		wire		[1:0]	NEXT_ALU_TYPE = next_alu_type[IDX];
		wire	 [63:0]	NEXT_NPC = next_npc[IDX];
		wire	 [31:0]	NEXT_IR = next_ir[IDX];
		wire					NEXT_BRANCH_TAKEN = next_branch_taken[IDX];
		wire	 [63:0]	NEXT_PRED_ADDR = next_pred_addr[IDX];
		wire		[1:0]	NEXT_OPA_SELECT = next_opa_select[IDX];
		wire		[1:0]	NEXT_OPB_SELECT = next_opb_select[IDX];
		wire		[4:0]	NEXT_DEST_AR_IDX = next_dest_ar_idx[IDX];
		wire		[6:0]	NEXT_DEST_PR_IDX = next_dest_pr_idx[IDX];
		wire		[6:0]	NEXT_PRA_IDX = next_pra_idx[IDX];
		wire					NEXT_PRA_READY = next_pra_ready[IDX];
		wire		[6:0]	NEXT_PRB_IDX = next_prb_idx[IDX];
		wire					NEXT_PRB_READY = next_prb_ready[IDX];
		wire		[4:0]	NEXT_ALU_FUNC = next_alu_func[IDX];
		wire					NEXT_RD_MEM = next_rd_mem[IDX];
		wire					NEXT_WR_MEM = next_wr_mem[IDX];
		wire					NEXT_COND_BRANCH = next_cond_branch[IDX];
		wire					NEXT_UNCOND_BRANCH = next_uncond_branch[IDX];
		wire					NEXT_HALT = next_halt[IDX];
		wire					NEXT_ILLEGAL_INST = next_illegal_inst[IDX];
		wire					NEXT_VALID_INST = next_valid_inst[IDX];
		
		wire					SIM_READY = sim_ready[IDX];
		wire					MUL_READY = mul_ready[IDX];
		wire					MEM_READY = mem_ready[IDX];
		wire					ENT_TAKEN = ent_taken[IDX]; // ent means entry
		wire					ENT_AVAIL = ent_avail[IDX];
 
end
endgenerate

endmodule
