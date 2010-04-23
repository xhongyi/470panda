/************************************************************
 * 
 * Module name: pipeline.v
 * 
 * Description: Top-level module of panda pipeline
 *
 ************************************************************/


 module pipeline (// Inputs
                 clock,
                 reset,
                 mem2proc_response,
                 mem2proc_data,
                 mem2proc_tag,
                 
                 // Outputs
                 proc2mem_command,
                 proc2mem_addr,
                 proc2mem_data,

                 pipeline_completed_insts,
                 pipeline_error_status,
                 pipeline_commit_wr_data,
                 pipeline_commit_wr_idx,
                 pipeline_commit_wr_en,
                 pipeline_commit_NPC,
								 pipeline_commit_inst0,
								 pipeline_commit_inst1,


                 // testing hooks (these must be exported so we can test
                 // the synthesized version) data is tested by looking at
                 // the final values in memory
								 if_NPC0,
								 if_IR0,
								 if_valid_inst0,
								 id_NPC0,
								 id_IR0,
								 id_valid_inst0,
								 rs_sim_NPC0,
								 rs_sim_IR0,
								 rs_sim_valid_inst0,
								 rs_mul_NPC0,
								 rs_mul_IR0,
								 rs_mul_valid_inst0,
								 rs_mem_NPC0,
								 rs_mem_IR0,
								 rs_mem_valid_inst0,

								 if_NPC1,
								 if_IR1,
								 if_valid_inst1,
								 id_NPC1,
								 id_IR1,
								 id_valid_inst1,
								 rs_sim_NPC1,
								 rs_sim_IR1,
								 rs_sim_valid_inst1,
								 rs_mul_NPC1,
								 rs_mul_IR1,
								 rs_mul_valid_inst1,
								 rs_mem_NPC1,
								 rs_mem_IR1,
								 rs_mem_valid_inst1,

								 cdb_broadcast,
								 cdb_pr_tag0,
								 cdb_pr_tag1,
								 cdb_pr_tag2,
								 cdb_pr_tag3,
								 cdb_pr_tag4,
								 cdb_pr_tag5,
								 rob_retire_num,
								 rob_retire_tag_a,
								 rob_retire_tag_b,

								 pipeline_recover

                );


  input         clock;             // System clock
  input         reset;             // System reset
  input  [3:0]  mem2proc_response; // Tag from memory about current request
  input  [63:0] mem2proc_data;     // Data coming back from memory
  input  [3:0]  mem2proc_tag;      // Tag from memory about current reply

  output [1:0]  proc2mem_command;  // command sent to memory
  output [63:0] proc2mem_addr;     // Address sent to memory
  output [63:0] proc2mem_data;     // Data sent to memory

  output [3:0]  pipeline_completed_insts;
  output [3:0]  pipeline_error_status;
  output [4:0]  pipeline_commit_wr_idx;
  output [63:0] pipeline_commit_wr_data;
  output        pipeline_commit_wr_en;
  output [63:0] pipeline_commit_NPC;
	output [31:0]	pipeline_commit_inst0;
	output [31:0]	pipeline_commit_inst1;

  output [63:0] if_NPC0; //proc2Imem_addr
  output [31:0] if_IR0;
  output        if_valid_inst0;
  output [63:0] id_NPC0;
  output [31:0] id_IR0;
  output        id_valid_inst0;
	output [63:0] rs_sim_NPC0;
	output [31:0]	rs_sim_IR0;
	output				rs_sim_valid_inst0;
	output [63:0] rs_mul_NPC0;
	output [31:0]	rs_mul_IR0;
	output				rs_mul_valid_inst0;
	output [63:0] rs_mem_NPC0;
	output [31:0]	rs_mem_IR0;
	output				rs_mem_valid_inst0;

	output [63:0] if_NPC1; //proc2Imem_addr
  output [31:0] if_IR1;
  output        if_valid_inst1;
  output [63:0] id_NPC1;
  output [31:0] id_IR1;
  output        id_valid_inst1;
	output [63:0] rs_sim_NPC1;
	output [31:0]	rs_sim_IR1;
	output				rs_sim_valid_inst1;
	output [63:0] rs_mul_NPC1;
	output [31:0]	rs_mul_IR1;
	output				rs_mul_valid_inst1;
	output [63:0] rs_mem_NPC1;
	output [31:0]	rs_mem_IR1;
	output				rs_mem_valid_inst1;

	output	[5:0]	cdb_broadcast;
	output	[6:0]	cdb_pr_tag0;
	output	[6:0]	cdb_pr_tag1;
	output	[6:0]	cdb_pr_tag2;
	output	[6:0]	cdb_pr_tag3;
	output	[6:0]	cdb_pr_tag4;
	output	[6:0]	cdb_pr_tag5;
	output	[1:0]	rob_retire_num;
	output	[6:0]	rob_retire_tag_a;
	output	[6:0]	rob_retire_tag_b;

	output				pipeline_recover;

	/*
	 * Output from Icache mem
	 */
  wire [63:0] Icachemem_data;
  wire        Icachemem_valid;

	/*
	 * Output from Dcache mem
	 */
  wire [63:0] Dcachemem_data;
  wire        Dcachemem_valid;
  wire				Dcachemem_dirty;
  wire [63:0] Dcachemem_dirty_data;
  wire [63:0] halt_Dmem_addr;
  wire [63:0] halt_Dmem_data;
  wire [1:0]  halt_Dmem_cmd;
  /*
	 * Intermediate wires for icache and dcache respectively
	 */
	 
  wire [3:0]  Imem2proc_response;
  wire [3:0]  Dmem2proc_response;

	/*
	 * Output from icache
	 */
  wire [63:0] proc2Imem_addr;//
  wire [1:0]  proc2Imem_command;//
  wire  [6:0] Icache_rd_idx;//
  wire [21:0] Icache_rd_tag;//
  wire  [6:0] Icache_wr_idx;//
  wire [21:0] Icache_wr_tag;//
  wire        Icache_wr_en;//
  wire [63:0] Icache_data_out;//

  wire        Icache_valid_out;//

	/*
	 * Outputs from Dcache
	 */
	
	wire  [1:0] 					Dcache_Dmem_command;//store? load? none?
  wire [63:0] 					Dcache_Dmem_addr;//addr to dmem
  wire [63:0] 					Dcache_Dmem_data;
  wire									Dcache_lsq_load_avail;
  wire [63:0] 					Dcache_prf_data_out;     // value is memory[proc2Dcache_addr]
  wire        					Dcache_valid_out;
  wire 									Dcache_load_en;//Dcache_valid_out & Dcache_load_en are intermediate signal. They would be oprands for Decache_cdb_complete.
	wire	[6:0] 					Dcache_cdb_prf_pr_idx;
	wire  [4:0] 					Dcache_cdb_ar_idx;
  wire  [6:0] 					dcache_rd_idx;
  wire [21:0] 					dcache_rd_tag;
  wire  [6:0] 					dcache_wr_idx1;
  wire [21:0] 					dcache_wr_tag1;
	wire  [6:0] 					dcache_wr_idx0;
  wire [21:0] 					dcache_wr_tag0;
  wire        					dcache_wr_en1;
	wire        					dcache_wr_en0;
	wire [63:0] 					dcache_wr_data;
	wire								  dcache_halt;
	wire									Dcache_cdb_prf_complete;//additional wire. Determine cdb_complete(Dcache only for load)
	
	/*
	 * Output from IF
	 */
	wire	 [63:0]	if_id_bht_NPC0;
	wire	 [63:0]	if_id_bht_NPC1;
	wire	 [31:0]	if_id_IR0;
	wire	 [31:0]	if_id_IR1;
	wire					if_id_valid_inst0;
	wire					if_id_valid_inst1;
	wire					if_id_branch_taken0;
	wire					if_id_branch_taken1;
	wire	 [63:0]	if_id_pred_addr0;
	wire	 [63:0]	if_id_pred_addr1;
	wire					if_bht_valid_cond0;
	wire					if_bht_valid_cond1;
  wire [63:0]		if_proc2Icache_addr;

	/*
	 * Output from ID
	 */
	wire	 [63:0]	id_rs_NPC0;
	wire	 [63:0]	id_rs_NPC1;
	wire	 [31:0]	id_rs_IR0;
	wire	 [31:0]	id_rs_IR1;

	wire					id_rs_branch_taken0;
	wire	 				id_rs_branch_taken1;
	wire	 [63:0]	id_rs_pred_addr0;
	wire	 [63:0]	id_rs_pred_addr1;

	wire		[4:0]	id_rs_mt_ra_idx0;
	wire		[4:0]	id_rs_mt_ra_idx1;
	wire		[4:0]	id_rs_mt_rb_idx0;
	wire		[4:0]	id_rs_mt_rb_idx1;
	wire		[4:0]	id_rs_mt_rc_idx0;
	wire		[4:0]	id_rs_mt_rc_idx1;

	wire		[1:0]	id_rs_mt_opa_select0;
	wire		[1:0]	id_rs_mt_opa_select1;
	wire		[1:0]	id_rs_mt_opb_select0;
	wire		[1:0]	id_rs_mt_opb_select1;

	wire		[4:0]	id_rs_mt_dest_idx0;
	wire		[4:0]	id_rs_mt_dest_idx1;
	wire		[4:0]	id_rs_alu_func0;
	wire		[4:0]	id_rs_alu_func1;

	wire					id_rs_rob_lsq_rd_mem0;
	wire					id_rs_rob_lsq_rd_mem1;
	wire					id_rs_rob_lsq_wr_mem0;
	wire					id_rs_rob_lsq_wr_mem1;

	wire					id_rs_ldl_mem0;
	wire					id_rs_ldl_mem1;
	wire					id_rs_stc_mem0;
	wire					id_rs_stc_mem1;

	wire					id_rs_cond_branch0;
	wire					id_rs_cond_branch1;
	wire					id_rs_uncond_branch0;
	wire					id_rs_uncond_branch1;
	wire					id_rs_rob_halt0;
	wire					id_rs_rob_halt1;
	
	wire [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] id_rob_bhr0;
	wire [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] id_rob_bhr1;

	wire					id_rs_rob_mt_illegal_inst0;
	wire					id_rs_rob_mt_illegal_inst1;
	wire					id_rs_rob_mt_valid_inst0;
	wire					id_rs_rob_mt_valid_inst1;
	
	wire		[1:0]	id_rs_rob_mt_dispatch_num;
	wire		[1:0]	id_if_inst_need_num;

	/*
	 * Output from Map Table
	 */
	wire		[6:0]	mt_rob_p0told;
	wire		[6:0]	mt_rob_p1told;
	wire		[6:0]	mt_rs_pr_a1;
	wire		[6:0]	mt_rs_pr_a2;
	wire		[6:0]	mt_rs_pr_b1;
	wire		[6:0]	mt_rs_pr_b2;

	wire					mt_rs_pr_a1_ready;
	wire					mt_rs_pr_a2_ready;
	wire					mt_rs_pr_b1_ready;
	wire					mt_rs_pr_b2_ready;

	/*
	 * Output from free list
	 */
	wire		[6:0]	fl_rob_rs_mt_pr0;
	wire		[6:0]	fl_rob_rs_mt_pr1;

	/*
	 * Output from ROB		'
	 */
	wire	 [1:0] rob_id_cap;
	wire  [4:0]  rob_mt_retire_ar_a;
	wire  [4:0]  rob_mt_retire_ar_b;
	wire	 [6:0] rob_mt_retire_taga;
	wire	 [6:0] rob_mt_retire_tagb;
	wire	 [6:0] rob_fl_retire_tolda;
	wire	 [6:0] rob_fl_retire_toldb;
	wire	 [1:0] rob_mt_fl_bht_lsq_recover_retire_num;

	wire  			 rob_bht_recover_cond_branch0;
	wire [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] rob_bht_recover_retire_bhr0;
	wire  [63:0] rob_bht_recover_NPC0;
	wire  			 rob_bht_actual_taken0;
	wire   			 rob_recover_uncond_branch0;
	wire  [63:0] rob_recover_actual_addr0;

	wire   			 rob_bht_recover_cond_branch1;
	wire [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] rob_bht_recover_retire_bhr1;
	wire  [63:0] rob_bht_recover_NPC1;
	wire         rob_bht_actual_taken1;
	wire         rob_recover_uncond_branch1;
	wire  [63:0] rob_recover_actual_addr1;
	
	wire				 rob_lsq_retire_wr_mem0;//new
	wire				 rob_lsq_retire_wr_mem1;//new

	wire	[31:0] rob_retire_IR0;
	wire	[31:0] rob_retire_IR1;
	
	wire         rob_recover_exception;
	wire				 rob_retire_halt;
	wire				 rob_halt;
	wire				rob_Dcache_wr_mem;
	/*
	 * Output from RS
	 */
	// Dispatch outputs
	wire		[1:0]	rs_id_cap;

	// Issue outputs
	wire	 [63:0]	rs_alu_sim_NPC0;
	wire	 [63:0]	rs_alu_sim_NPC1;
	wire	 [31:0] rs_alu_sim_IR0;
	wire	 [31:0]	rs_alu_sim_IR1;

	wire					rs_alu_sim_branch_taken0;
	wire					rs_alu_sim_branch_taken1;
	wire	 [63:0]	rs_alu_sim_pred_addr0;
	wire	 [63:0]	rs_alu_sim_pred_addr1;

	wire	 	[6:0]	rs_alu_sim_prf_pra_idx0; // Go to physical register file to get the value
	wire		[6:0]	rs_alu_sim_prf_pra_idx1;
	wire		[6:0]	rs_alu_sim_prf_prb_idx0;
	wire		[6:0]	rs_alu_sim_prf_prb_idx1;

	wire		[1:0]	rs_alu_sim_opa_select0;
	wire		[1:0]	rs_alu_sim_opa_select1;
	wire		[1:0]	rs_alu_sim_opb_select0;
	wire		[1:0]	rs_alu_sim_opb_select1;

	wire		[4:0]	rs_alu_sim_dest_ar_idx0;
	wire		[4:0]	rs_alu_sim_dest_ar_idx1;
	wire		[6:0]	rs_alu_sim_dest_pr_idx0;
	wire		[6:0]	rs_alu_sim_dest_pr_idx1;
	wire		[4:0]	rs_alu_sim_func0;
	wire		[4:0]	rs_alu_sim_func1;

	wire					rs_alu_sim_rd_mem0;
	wire					rs_alu_sim_rd_mem1;
	wire					rs_alu_sim_wr_mem0;
	wire					rs_alu_sim_wr_mem1;

	wire					rs_alu_sim_cond_branch0;
	wire					rs_alu_sim_cond_branch1;
	wire					rs_alu_sim_uncond_branch0;
	wire					rs_alu_sim_uncond_branch1;
	wire					rs_alu_sim_halt0;
	wire					rs_alu_sim_halt1;

	wire					rs_alu_sim_illegal_inst0;
	wire					rs_alu_sim_illegal_inst1;
	wire					rs_alu_sim_valid_inst0;
	wire					rs_alu_sim_valid_inst1;

	wire	 [63:0]	rs_alu_mul_NPC0;
	wire	 [63:0]	rs_alu_mul_NPC1;
	wire	 [31:0] rs_alu_mul_IR0;
	wire	 [31:0]	rs_alu_mul_IR1;

	wire					rs_alu_mul_branch_taken0;
	wire					rs_alu_mul_branch_taken1;
	wire	 [63:0]	rs_alu_mul_pred_addr0;
	wire	 [63:0]	rs_alu_mul_pred_addr1;

	wire	 	[6:0]	rs_alu_mul_prf_pra_idx0; // Go to physical register file to get the value
	wire		[6:0]	rs_alu_mul_prf_pra_idx1;
	wire		[6:0]	rs_alu_mul_prf_prb_idx0;
	wire		[6:0]	rs_alu_mul_prf_prb_idx1;

	wire		[1:0]	rs_alu_mul_opa_select0;
	wire		[1:0]	rs_alu_mul_opa_select1;
	wire		[1:0]	rs_alu_mul_opb_select0;
	wire		[1:0]	rs_alu_mul_opb_select1;

	wire		[4:0]	rs_alu_mul_dest_ar_idx0;
	wire		[4:0]	rs_alu_mul_dest_ar_idx1;
	wire		[6:0]	rs_alu_mul_dest_pr_idx0;
	wire		[6:0]	rs_alu_mul_dest_pr_idx1;
	wire		[4:0]	rs_alu_mul_func0;
	wire		[4:0]	rs_alu_mul_func1;

	wire					rs_alu_mul_rd_mem0;
	wire					rs_alu_mul_rd_mem1;
	wire					rs_alu_mul_wr_mem0;
	wire					rs_alu_mul_wr_mem1;

	wire					rs_alu_mul_cond_branch0;
	wire					rs_alu_mul_cond_branch1;
	wire					rs_alu_mul_uncond_branch0;
	wire					rs_alu_mul_uncond_branch1;
	wire					rs_alu_mul_halt0;
	wire					rs_alu_mul_halt1;

	wire					rs_alu_mul_illegal_inst0;
	wire					rs_alu_mul_illegal_inst1;
	wire					rs_alu_mul_valid_inst0;
	wire					rs_alu_mul_valid_inst1;

	wire	 [63:0]	rs_alu_mem_NPC0;
	wire	 [63:0]	rs_alu_mem_NPC1;
	wire	 [31:0] rs_alu_mem_IR0;
	wire	 [31:0]	rs_alu_mem_IR1;

	wire					rs_alu_mem_branch_taken0;
	wire					rs_alu_mem_branch_taken1;
	wire	 [63:0]	rs_alu_mem_pred_addr0;
	wire	 [63:0]	rs_alu_mem_pred_addr1;

	wire	 	[6:0]	rs_alu_mem_prf_pra_idx0; // Go to physical register file to get the value
	wire		[6:0]	rs_alu_mem_prf_pra_idx1;
	wire		[6:0]	rs_alu_mem_prf_prb_idx0;
	wire		[6:0]	rs_alu_mem_prf_prb_idx1;

	wire		[1:0]	rs_alu_mem_opa_select0;
	wire		[1:0]	rs_alu_mem_opa_select1;
	wire		[1:0]	rs_alu_mem_opb_select0;
	wire		[1:0]	rs_alu_mem_opb_select1;

	wire		[4:0]	rs_alu_mem_dest_ar_idx0;
	wire		[4:0]	rs_alu_mem_dest_ar_idx1;
	wire		[6:0]	rs_alu_mem_dest_pr_idx0;
	wire		[6:0]	rs_alu_mem_dest_pr_idx1;
	wire		[4:0]	rs_alu_mem_func0;
	wire		[4:0]	rs_alu_mem_func1;

	wire					rs_alu_mem_rd_mem0;
	wire					rs_alu_mem_rd_mem1;
	wire					rs_alu_mem_wr_mem0;
	wire					rs_alu_mem_wr_mem1;

	wire					rs_alu_mem_cond_branch0;
	wire					rs_alu_mem_cond_branch1;
	wire					rs_alu_mem_uncond_branch0;
	wire					rs_alu_mem_uncond_branch1;
	wire					rs_alu_mem_halt0;
	wire					rs_alu_mem_halt1;

	wire					rs_alu_mem_illegal_inst0;
	wire					rs_alu_mem_illegal_inst1;
	wire					rs_alu_mem_valid_inst0;
	wire					rs_alu_mem_valid_inst1;
	
	wire	[`BIT_STQ-1:0]	rs_alu_mem_issue_age0;
	wire	[`BIT_STQ-1:0]	rs_alu_mem_issue_age1;
	wire					rs_alu_mem_issue_old0;
	wire					rs_alu_mem_issue_old1;
	
	wire					rs_lsq_wr_mem0_peer;
	wire					rs_lsq_wr_mem1_peer;

	/*
	 * Outputs from physical register file
	 */
	wire	[63:0]	prf_alu_sim_pra_value0;
	wire	[63:0]	prf_alu_sim_pra_value1;
	wire	[63:0]	prf_alu_sim_prb_value0;
	wire	[63:0]	prf_alu_sim_prb_value1;

	wire	[63:0]	prf_alu_mul_pra_value0;
	wire	[63:0]	prf_alu_mul_pra_value1;
	wire	[63:0]	prf_alu_mul_prb_value0;
	wire	[63:0]	prf_alu_mul_prb_value1;

	wire	[63:0]	prf_alu_mem_pra_value0;
	wire	[63:0]	prf_alu_mem_pra_value1;
	wire	[63:0]	prf_alu_mem_prb_value0;
	wire	[63:0]	prf_alu_mem_prb_value1;


	/*
	 * Outputs from CDB
	 */

	wire	[`CDB_WIDTH-1:0]	cdb_rs_rob_mt_broadcast;
	wire		[6:0]	cdb_rs_rob_mt_pr_tag0;
	wire		[6:0]	cdb_rs_rob_mt_pr_tag1;
	wire		[6:0]	cdb_rs_rob_mt_pr_tag2;
	wire		[6:0]	cdb_rs_rob_mt_pr_tag3;
	wire		[6:0]	cdb_rs_rob_mt_pr_tag4;
	wire		[6:0]	cdb_rs_rob_mt_pr_tag5;
	wire		[4:0]	cdb_mt_ar_tag0;
	wire		[4:0]	cdb_mt_ar_tag1;
	wire		[4:0]	cdb_mt_ar_tag2;
	wire		[4:0]	cdb_mt_ar_tag3;
	wire		[4:0]	cdb_mt_ar_tag4;
	wire		[4:0]	cdb_mt_ar_tag5;
	wire					cdb_rob_exception0;
	wire					cdb_rob_exception1;
//	wire					cdb_rob_exception2;
//	wire					cdb_rob_exception3;
//	wire					cdb_rob_exception4;
//	wire					cdb_rob_exception5;

	wire  [63:0]	cdb_rob_actual_addr0;
	wire  				cdb_rob_actual_taken0;
//	wire 					cdb_rob_cond_branch0;
//	wire 					cdb_rob_uncond_branch0;

	wire  [63:0] 	cdb_rob_actual_addr1;
	wire 				 	cdb_rob_actual_taken1;
//	wire 				 	cdb_rob_cond_branch1;
//	wire 				 	cdb_rob_uncond_branch1;
	/*
	 * Outputs from simple ALU
	 */
  wire	 [63:0] alu_sim_prf_value0;   // ALU result
  wire	 [63:0] alu_sim_prf_value1;   // ALU result
	wire	 				alu_sim_prf_wr_enable0;
	wire					alu_sim_prf_wr_enable1;
	wire					alu_sim_cdb_complete0;
	wire					alu_sim_cdb_complete1;
	wire		[4:0]	alu_sim_cdb_ar_idx0;
	wire		[4:0]	alu_sim_cdb_ar_idx1;
	wire		[6:0]	alu_sim_cdb_prf_pr_idx0;
	wire		[6:0]	alu_sim_cdb_prf_pr_idx1;
	wire					alu_sim_cdb_exception0;
	wire				  alu_sim_cdb_exception1;
	wire	 [63:0]	alu_sim_cdb_actual_addr0;
	wire	 [63:0]	alu_sim_cdb_actual_addr1;
	wire					alu_sim_cdb_actual_taken0;
	wire					alu_sim_cdb_actual_taken1;
  wire	 [1:0]	alu_sim_rs_avail;
	/*
	 * Outputs from multiplier
	 */
  wire	 [63:0] alu_mul_prf_value0;   // ALU result
  wire	 [63:0] alu_mul_prf_value1;   // ALU result
	wire	 				alu_mul_prf_wr_enable0;
	wire					alu_mul_prf_wr_enable1;
	wire					alu_mul_cdb_complete0;
	wire					alu_mul_cdb_complete1;
	wire		[4:0]	alu_mul_cdb_ar_idx0;
	wire		[4:0]	alu_mul_cdb_ar_idx1;
	wire		[6:0]	alu_mul_cdb_prf_pr_idx0;
	wire		[6:0]	alu_mul_cdb_prf_pr_idx1;
//	wire					alu_mul_cdb_exception0;
//	wire				  alu_mul_cdb_exception1;
  wire	 [1:0]	alu_mul_rs_avail;

	/*
	 * Output from memory LSQ
	 */
	wire	[`BIT_STQ-1:0]	lsq_rs_disp_age0;
	wire	[`BIT_STQ-1:0]	lsq_rs_disp_age1;
	wire									lsq_rs_disp_old0;
	wire									lsq_rs_disp_old1;
	
	wire	[1:0]						lsq_rs_avail;
	wire									lsq_cdb_complete;
	wire	[6:0]						lsq_cdb_prf_pr_idx;
	wire	[4:0]						lsq_cdb_ar_idx;
	wire									lsq_prf_pr_wr_enable;
	wire	[63:0]					lsq_prf_pr_value;
	
	wire									lsq_Dcache_rd_mem;
	wire									lsq_Dcache_wr_mem;
	wire	[63:0]					lsq_Dcache_addr;
	wire	[6:0]						lsq_Dcache_pr_idx;
	wire	[4:0]						lsq_Dcache_ar_idx;
	
	wire	[63:0]					lsq_Dcache_st_value;
	wire	[63:0]					lsq_Dcache_st_addr;

	
	/*
	 * Outputs from BHT
	 */

	wire				bht_if_branch_taken0;
	wire				bht_if_branch_taken1;
	wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_id_bhr0;
  wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_id_bhr1;

	/*
	 * Outputs from BTB
	 */

	wire	 [63:0]	btb_if_pred_addr0;
	wire	 [63:0]	btb_if_pred_addr1;
	
	/*
	 * Outputs from Recover
	 */
	 
	wire					recover_if_reset;
	wire					recover_if_recover;
	wire	[63:0]	recover_if_recover_addr;
	
	wire					recover_bht_reset;
	wire					recover_bht_recover;
	wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] recover_bht_bhr;
	
	wire					recover_btb_reset;
	wire					recover_btb_recover;
	wire	[63:0]	recover_btb_NPC;
	wire	[63:0]	recover_btb_actual_addr;
	
	wire					recover_fl_reset;
	wire					recover_fl_recover;
	
	wire					recover_mt_reset;
	wire					recover_mt_recover;
	
	wire					recover_other_reset;

	wire					pipeline_recover;

	/*
	 * Reset for each module
	 *
	 * When there is no exception, they are just equal to reset
	 */
	wire		if_reset;
	wire		id_reset;
	wire		mt_reset;
	wire		rob_reset;
	wire		rs_reset;
	wire		fl_reset;
	wire		prf_reset;
	wire		alu_sim_reset;
	wire		alu_mul_reset;
	wire		lsq_reset;//new
	wire		cdb_reset;
	wire		cachemem_reset;
	wire		icache_reset;
	wire		dcache_reset;
	wire		bht_reset;
	wire		btb_reset;

	
	

	// Default assignment
	
	// To be changed in the future

	
  assign proc2mem_command =
           (dcache_halt)?Dcache_Dmem_command:(Dcache_Dmem_command==`BUS_NONE)? proc2Imem_command : Dcache_Dmem_command;
  assign proc2mem_addr =
           (dcache_halt)?Dcache_Dmem_addr:(Dcache_Dmem_command==`BUS_NONE)? proc2Imem_addr : Dcache_Dmem_addr;
	assign proc2mem_data			= (dcache_halt)?Dcache_Dmem_data:(Dcache_Dmem_command ==  `BUS_NONE)? 64'b0 : Dcache_Dmem_data;
	
	
	
	assign Imem2proc_response = 
      (Dcache_Dmem_command==`BUS_NONE) ? mem2proc_response : 0;
  assign Dmem2proc_response = (Dcache_Dmem_command != `BUS_NONE) ? mem2proc_response : 0;
	//assign Dmem2proc_response = mem2proc_response;

	assign pipeline_completed_inst	= 0;
	assign pipeline_error_status		= rob_retire_halt ? `HALTED_ON_HALT : `NO_ERROR;
	assign pipeline_commit_wr_idx		= 64'b0;
	assign pipeline_commit_wr_data	= 64'b0;
	assign pipeline_commit_wr_en		= 0;
	assign pipeline_commit_NPC			= 64'b0;
	assign pipeline_commit_inst0		= ((rob_retire_num[0] | rob_retire_num[1]) & ~pipeline_recover)? rob_retire_IR0 : 32'bx;
	assign pipeline_commit_inst1		= (rob_retire_num[1] & ~pipeline_recover)? rob_retire_IR1 : 32'bx;
	//The following two are actually output signals and are already covered in dcache.
	//assign proc2Dmem_addr						= 64'b0;
	//assign Dcache_Dmem_command				= `BUS_NONE;

	assign  rob_Dcache_wr_mem = (rob_mt_fl_bht_lsq_recover_retire_num != 0) & (rob_lsq_retire_wr_mem0 | ((rob_mt_fl_bht_lsq_recover_retire_num == 2'd2) & rob_lsq_retire_wr_mem1)) & ~pipeline_recover;




	// Outputs of pipeline
	assign if_NPC0						= if_id_bht_NPC0;
	assign if_IR0							= if_id_IR0;
	assign if_valid_inst0			= if_id_valid_inst0;
	assign id_NPC0						= id_rs_NPC0;
	assign id_IR0							= id_rs_IR0;
	assign id_valid_inst0			= id_rs_rob_mt_valid_inst0;
	assign rs_sim_NPC0				= rs_alu_sim_NPC0;
	assign rs_sim_IR0					= rs_alu_sim_IR0;
	assign rs_sim_valid_inst0 = rs_alu_sim_valid_inst0;
	assign rs_mul_NPC0				= rs_alu_mul_NPC0;
	assign rs_mul_IR0					= rs_alu_mul_IR0;
	assign rs_mul_valid_inst0 = rs_alu_mul_valid_inst0;
	assign rs_mem_NPC0				= rs_alu_mem_NPC0;
	assign rs_mem_IR0					= rs_alu_mem_IR0;
	assign rs_mem_valid_inst0 = rs_alu_mem_valid_inst0;

	assign if_NPC1						= if_id_bht_NPC1;
	assign if_IR1							= if_id_IR1;
	assign if_valid_inst1			= if_id_valid_inst1;
	assign id_NPC1						= id_rs_NPC1;
	assign id_IR1							= id_rs_IR1;
	assign id_valid_inst1			= id_rs_rob_mt_valid_inst1;
	assign rs_sim_NPC1				= rs_alu_sim_NPC1;
	assign rs_sim_IR1					= rs_alu_sim_IR1;
	assign rs_sim_valid_inst1 = rs_alu_sim_valid_inst1;
	assign rs_mul_NPC1				= rs_alu_mul_NPC1;
	assign rs_mul_IR1					= rs_alu_mul_IR1;
	assign rs_mul_valid_inst1 = rs_alu_mul_valid_inst1;
	assign rs_mem_NPC1				= rs_alu_mem_NPC1;
	assign rs_mem_IR1					= rs_alu_mem_IR1;
	assign rs_mem_valid_inst1 = rs_alu_mem_valid_inst1;

	assign cdb_broadcast				= cdb_rs_rob_mt_broadcast;
	assign cdb_pr_tag0					= cdb_rs_rob_mt_pr_tag0;
	assign cdb_pr_tag1					= cdb_rs_rob_mt_pr_tag1;
	assign cdb_pr_tag2					= cdb_rs_rob_mt_pr_tag2;
	assign cdb_pr_tag3					= cdb_rs_rob_mt_pr_tag3;
	assign cdb_pr_tag4					= cdb_rs_rob_mt_pr_tag4;
	assign cdb_pr_tag5					= cdb_rs_rob_mt_pr_tag5;
	assign rob_retire_num				= rob_mt_fl_bht_lsq_recover_retire_num;
	assign rob_retire_tag_a			= rob_mt_retire_taga;
	assign rob_retire_tag_b			= rob_mt_retire_tagb;

	assign id_reset = recover_other_reset;
	assign rob_reset = recover_other_reset;
	assign rs_reset = recover_other_reset;
	assign alu_sim_reset = recover_other_reset;
	assign alu_mul_reset = recover_other_reset;
	assign alu_mem_reset = recover_other_reset;
	assign cdb_reset = recover_other_reset;
	assign lsq_reset = recover_other_reset;
	assign dcache_reset = recover_other_reset;
	assign mt_reset = recover_mt_reset;
	assign fl_reset = recover_fl_reset;
	assign if_reset = recover_if_reset;
	assign bht_reset = recover_bht_reset;
	assign btb_reset = recover_btb_reset;
	
	assign prf_reset = reset;
	assign cachemem_reset = reset;
	assign icache_reset = reset;

//cdb dcache complete
	//assign Dcache_cdb_prf_complete = Dcache_load_en & Dcache_valid_out;//Is this right??

  // Actual cache (data and tag RAMs)
  icachemem Icachememory (// inputs
                              .clock(clock),
                              .reset(cachemem_reset),
                              .wr1_en(Icache_wr_en),
                              .wr1_idx(Icache_wr_idx),
                              .wr1_tag(Icache_wr_tag),
                              .wr1_data(mem2proc_data),
                                  
                              .rd1_idx(Icache_rd_idx),
                              .rd1_tag(Icache_rd_tag),

                              // outputs
                              .rd1_data(Icachemem_data),
                              .rd1_valid(Icachemem_valid)
                             );
	// Dcache
	dcachemem Dcachememory (// inputs
                       .clock(clock),
                       .reset(cachemem_reset), 
                       .wr1_en(dcache_wr_en1),
                       .wr1_tag(dcache_wr_tag1),
                       .wr1_idx(dcache_wr_idx1),
                       .wr1_data(dcache_wr_data),
											 .wr0_en(dcache_wr_en0),
											 .wr0_tag(dcache_wr_tag0),
											 .wr0_idx(dcache_wr_idx0),
											 .wr0_data(mem2proc_data),
                       .rd1_tag(dcache_rd_tag),
                       .rd1_idx(dcache_rd_idx),
											 .dcache_halt(dcache_halt),
											 .Dmem_response(Dmem2proc_response),
                       // outputs
                       .rd1_data(Dcachemem_data),
                       .rd1_valid(Dcachemem_valid),
                       
                       .rob_halt_complete(rob_retire_halt)
                       
                      );

  // Cache controller
  icache icache0(// inputs 
                  .clock(clock),
                  .reset(icache_reset),

                  .Imem2proc_response(Imem2proc_response),
                  .Imem2proc_data(mem2proc_data),
                  .Imem2proc_tag(mem2proc_tag),

                  .proc2Icache_addr(if_proc2Icache_addr),
                  .cachemem_data(Icachemem_data),
                  .cachemem_valid(Icachemem_valid),

                   // outputs
                  .proc2Imem_command(proc2Imem_command),
                  .proc2Imem_addr(proc2Imem_addr),

                  .Icache_data_out(Icache_data_out),
                  .Icache_valid_out(Icache_valid_out),
                  .current_index(Icache_rd_idx),
                  .current_tag(Icache_rd_tag),
                  .last_index(Icache_wr_idx),
                  .last_tag(Icache_wr_tag),
                  .data_write_enable(Icache_wr_en)
                 );
  
  dcache	dcache0(// inputs
              .clock(clock),
              .reset(dcache_reset),
              
              .Dmem2proc_response(Dmem2proc_response),
              .Dmem2proc_data(mem2proc_data),//no wire
              .Dmem2proc_tag(mem2proc_tag),//no wire
              .rob_halt(rob_halt & ~pipeline_recover),
              .proc2Dcache_addr(lsq_Dcache_addr),
              .proc2Dcache_st_data(lsq_Dcache_st_value),
              .proc2Dcache_st_addr(lsq_Dcache_st_addr),
              .cachemem_data(Dcachemem_data),
              .cachemem_valid(Dcachemem_valid),
           
              .rob_wr_mem(rob_Dcache_wr_mem & ~pipeline_recover),//I think this is from lsq, see lsq signal: "lsq_Dcache_rd_mem"
              .lsq_rd_mem(lsq_Dcache_rd_mem),
              .lsq_pr(lsq_Dcache_pr_idx),
              .lsq_ar(lsq_Dcache_ar_idx),
              // outputs
              .proc2Dmem_command(Dcache_Dmem_command),
              .proc2Dmem_addr(Dcache_Dmem_addr),
              .proc2Dmem_data(Dcache_Dmem_data),
              .lsq_load_avail(Dcache_lsq_load_avail),
              .Dcache_data_out(Dcache_prf_data_out),
              .Dcache_valid_out(Dcache_valid_out),   
              .cdb_load_en(Dcache_cdb_prf_complete),
              .cdb_pr(Dcache_cdb_prf_pr_idx),
              .cdb_ar(Dcache_cdb_ar_idx),
              .cachemem_halt(dcache_halt),
              .dcache_wr_data(dcache_wr_data),
              .dcache_rd_idx(dcache_rd_idx),
              .dcache_rd_tag(dcache_rd_tag),
              .dcache_wr_idx1(dcache_wr_idx1),
              .dcache_wr_tag1(dcache_wr_tag1),
              .dcache_wr_idx0(dcache_wr_idx0),
              .dcache_wr_tag0(dcache_wr_tag0),
              .dcache_wr_en1(dcache_wr_en1),
              .dcache_wr_en0(dcache_wr_en0)
             );

	// IF module
	if_mod if_mod0 (// Inputs
								.clock(clock),
								.reset(if_reset),
								.bht_branch_taken0(bht_if_branch_taken0),
								.bht_branch_taken1(bht_if_branch_taken1),
								.btb_pred_addr0(btb_if_pred_addr0),
								.btb_pred_addr1(btb_if_pred_addr1),
								.Imem2proc_data(Icache_data_out),
								.Imem_valid(Icache_valid_out),
								.id_dispatch_num(id_if_inst_need_num),
								.recover(recover_if_recover),
								.recover_addr(recover_if_recover_addr),
								 //Danger: inconsistent interface
										//outputs
								.id_bht_NPC0(if_id_bht_NPC0),
								.id_bht_NPC1(if_id_bht_NPC1),
								.id_IR0(if_id_IR0),
								.id_IR1(if_id_IR1),
								.proc2Imem_addr(if_proc2Icache_addr),
								.id_branch_taken0(if_id_branch_taken0),
								.id_branch_taken1(if_id_branch_taken1),
								.id_pred_addr0(if_id_pred_addr0),
								.id_pred_addr1(if_id_pred_addr1),
								.id_valid_inst0(if_id_valid_inst0),
								.id_valid_inst1(if_id_valid_inst1),
								.bht_valid_cond0(if_bht_valid_cond0),
								.bht_valid_cond1(if_bht_valid_cond1)
		);

		// ID

	id id0 (// Inputs
					.clock(clock),
					.reset(id_reset),

					.if_IR0(if_id_IR0),
					.if_IR1(if_id_IR1),
					.if_valid_inst0(if_id_valid_inst0),
					.if_valid_inst1(if_id_valid_inst1),
					.if_NPC0(if_id_bht_NPC0),
					.if_NPC1(if_id_bht_NPC1),
					.bht_bhr0(bht_id_bhr0),
					.bht_bhr1(bht_id_bhr1),
					.if_branch_taken0(if_id_branch_taken0),
					.if_branch_taken1(if_id_branch_taken1),
					.if_pred_addr0(if_id_pred_addr0),
					.if_pred_addr1(if_id_pred_addr1),

					.rob_cap(rob_id_cap),
					.rs_cap(rs_id_cap),

					// Outputs
					.rs_NPC0(id_rs_NPC0),
					.rs_IR0(id_rs_IR0),

					.rs_branch_taken0(id_rs_branch_taken0),
					.rs_pred_addr0(id_rs_pred_addr0),

					.rs_mt_ra_idx0(id_rs_mt_ra_idx0),
					.rs_mt_rb_idx0(id_rs_mt_rb_idx0),
					.rs_mt_rc_idx0(id_rs_mt_rc_idx0),

					.rs_mt_opa_select0(id_rs_mt_opa_select0),
					.rs_mt_opb_select0(id_rs_mt_opb_select0),
				
					.rs_mt_dest_idx0(id_rs_mt_dest_idx0),
					.rs_alu_func0(id_rs_alu_func0),

					.rs_rd_mem0(id_rs_rob_lsq_rd_mem0),
					.rs_wr_mem0(id_rs_rob_lsq_wr_mem0),

					.rs_ldl_mem0(id_rs_ldl_mem0),
					.rs_stc_mem0(id_rs_stc_mem0),

					.rs_cond_branch0(id_rs_cond_branch0),
					.rs_uncond_branch0(id_rs_uncond_branch0),
					.rs_halt0(id_rs_rob_halt0),

					.rs_rob_mt_illegal_inst0(id_rs_rob_mt_illegal_inst0),
					.rs_rob_mt_valid_inst0(id_rs_rob_mt_valid_inst0),

					.rs_NPC1(id_rs_NPC1),
					.rs_IR1(id_rs_IR1),

					.rs_branch_taken1(id_rs_branch_taken1),
					.rs_pred_addr1(id_rs_pred_addr1),

					.rs_mt_ra_idx1(id_rs_mt_ra_idx1),
					.rs_mt_rb_idx1(id_rs_mt_rb_idx1),
					.rs_mt_rc_idx1(id_rs_mt_rc_idx1),

					.rs_mt_opa_select1(id_rs_mt_opa_select1),
					.rs_mt_opb_select1(id_rs_mt_opb_select1),
				
					.rs_mt_dest_idx1(id_rs_mt_dest_idx1),
					.rs_alu_func1(id_rs_alu_func1),

					.rs_rd_mem1(id_rs_rob_lsq_rd_mem1),
					.rs_wr_mem1(id_rs_rob_lsq_wr_mem1),

					.rs_ldl_mem1(id_rs_ldl_mem1),
					.rs_stc_mem1(id_rs_stc_mem1),

					.rs_cond_branch1(id_rs_cond_branch1),
					.rs_uncond_branch1(id_rs_uncond_branch1),
					.rs_halt1(id_rs_rob_halt1),

					.rs_rob_mt_illegal_inst1(id_rs_rob_mt_illegal_inst1),
					.rs_rob_mt_valid_inst1(id_rs_rob_mt_valid_inst1),
					
					.rob_bhr0(id_rob_bhr0),
					.rob_bhr1(id_rob_bhr1),
					.rs_rob_mt_dispatch_num(id_rs_rob_mt_dispatch_num),
					.if_inst_need_num(id_if_inst_need_num)
	);

	// ROB

	rob rob0(// Inputs
					 .clock(clock),
					 .reset(rob_reset),
					 
					 .id_dispatch_num(id_rs_rob_mt_dispatch_num),
					 
					 .fl_pr0(fl_rob_rs_mt_pr0),
					 .mt_p0told(mt_rob_p0told),
					 .id_NPC0(id_rs_NPC0),
					 .id_IR0(id_rs_IR0),
					 .id_dest_idx0(id_rs_mt_dest_idx0),
					 .id_valid_inst0(id_rs_rob_mt_valid_inst0),
					 .id_cond_branch0(id_rs_cond_branch0),
					 .id_uncond_branch0(id_rs_uncond_branch0),
					 .id_halt0(id_rs_rob_halt0),

					 .fl_pr1(fl_rob_rs_mt_pr1),
					 .mt_p1told(mt_rob_p1told),
					 .id_NPC1(id_rs_NPC1),
					 .id_IR1(id_rs_IR1),
					 .id_dest_idx1(id_rs_mt_dest_idx1),
					 .id_valid_inst1(id_rs_rob_mt_valid_inst1),
					 .id_cond_branch1(id_rs_cond_branch1),
					 .id_uncond_branch1(id_rs_uncond_branch1),
					 .id_halt1(id_rs_rob_halt1),
					 
 					 .id_wr_mem0(id_rs_rob_lsq_wr_mem0),//new!!
					 .id_wr_mem1(id_rs_rob_lsq_wr_mem1),//new!!

					 .id_bhr0(id_rob_bhr0),
					 .id_bhr1(id_rob_bhr1),

					 .cdb_pr_ready(cdb_rs_rob_mt_broadcast),
					 .cdb_pr_tag_0(cdb_rs_rob_mt_pr_tag0),
					 .cdb_pr_tag_1(cdb_rs_rob_mt_pr_tag1),
					 .cdb_pr_tag_2(cdb_rs_rob_mt_pr_tag2),
					 .cdb_pr_tag_3(cdb_rs_rob_mt_pr_tag3),
					 .cdb_pr_tag_4(cdb_rs_rob_mt_pr_tag4),
					 .cdb_pr_tag_5(cdb_rs_rob_mt_pr_tag5),
					 .cdb_exception0(cdb_rob_exception0),
					 .cdb_exception1(cdb_rob_exception1),
//					 .cdb_exception2(cdb_rob_exception2),
//					 .cdb_exception3(cdb_rob_exception3),
//					 .cdb_exception4(0),
//					 .cdb_exception5(0),
					 
					 .cdb_actual_addr0(cdb_rob_actual_addr0),
					 .cdb_actual_taken0(cdb_rob_actual_taken0),
					 .cdb_actual_addr1(cdb_rob_actual_addr1),
					 .cdb_actual_taken1(cdb_rob_actual_taken1),

		
					 // Outputs
					 .id_cap(rob_id_cap),

					 .mt_retire_ar_a(rob_mt_retire_ar_a),
					 .mt_retire_ar_b(rob_mt_retire_ar_b),	 
					 .mt_retire_taga(rob_mt_retire_taga),
					 .mt_retire_tagb(rob_mt_retire_tagb),
					 .fl_retire_tolda(rob_fl_retire_tolda),
					 .fl_retire_toldb(rob_fl_retire_toldb),
					 

					 .lsq_mt_fl_bht_recover_retire_num(rob_mt_fl_bht_lsq_recover_retire_num),

					 .bht_recover_cond_branch0(rob_bht_recover_cond_branch0),
					 .bht_recover_retire_bhr0(rob_bht_recover_retire_bhr0),
					 .bht_recover_NPC0(rob_bht_recover_NPC0),
					 .bht_actual_taken0(rob_bht_actual_taken0),
					 .recover_uncond_branch0(rob_recover_uncond_branch0),
					 .recover_actual_addr0(rob_recover_actual_addr0),
					 
					 .bht_recover_cond_branch1(rob_bht_recover_cond_branch1),
					 .bht_recover_retire_bhr1(rob_bht_recover_retire_bhr1),
					 .bht_recover_NPC1(rob_bht_recover_NPC1),
					 .bht_actual_taken1(rob_bht_actual_taken1),
					 .recover_uncond_branch1(rob_recover_uncond_branch1),
					 .recover_actual_addr1(rob_recover_actual_addr1),
					 
					 .lsq_retire_wr_mem0(rob_lsq_retire_wr_mem0),//new
					 .lsq_retire_wr_mem1(rob_lsq_retire_wr_mem1),//new

					 .rob_retire_IR0(rob_retire_IR0),
					 .rob_retire_IR1(rob_retire_IR1),
					 
					 .recover_exception(rob_recover_exception),
					 .retire_halt(rob_halt)
	);

	// Map table

	mt mt0(// Inputs
				 .clock(clock),
				 .reset(mt_reset),
				 .id_dispatch_num(id_rs_rob_mt_dispatch_num),

				 .fl_pr0(fl_rob_rs_mt_pr0),
				 .fl_pr1(fl_rob_rs_mt_pr1),

				 .id_valid_inst0(id_rs_rob_mt_valid_inst0),
				 .id_opa_select0(id_rs_mt_opa_select0),
				 .id_opb_select0(id_rs_mt_opb_select0),

				 .id_ra_idx0(id_rs_mt_ra_idx0),
				 .id_rb_idx0(id_rs_mt_rb_idx0),
				 .id_dest_idx0(id_rs_mt_dest_idx0),

				 .id_valid_inst1(id_rs_rob_mt_valid_inst1),
				 .id_opa_select1(id_rs_mt_opa_select1),
				 .id_opb_select1(id_rs_mt_opb_select1),

				 .id_ra_idx1(id_rs_mt_ra_idx1),
				 .id_rb_idx1(id_rs_mt_rb_idx1),
				 .id_dest_idx1(id_rs_mt_dest_idx1),

				 .cdb_broadcast(cdb_rs_rob_mt_broadcast),
				 .cdb_pr_tag0(cdb_rs_rob_mt_pr_tag0),
				 .cdb_pr_tag1(cdb_rs_rob_mt_pr_tag1),
				 .cdb_pr_tag2(cdb_rs_rob_mt_pr_tag2),
				 .cdb_pr_tag3(cdb_rs_rob_mt_pr_tag3),
				 .cdb_pr_tag4(cdb_rs_rob_mt_pr_tag4),
				 .cdb_pr_tag5(cdb_rs_rob_mt_pr_tag5),
				 .cdb_ar_tag0(cdb_mt_ar_tag0),
				 .cdb_ar_tag1(cdb_mt_ar_tag1),
				 .cdb_ar_tag2(cdb_mt_ar_tag2),
				 .cdb_ar_tag3(cdb_mt_ar_tag3),
				 .cdb_ar_tag4(cdb_mt_ar_tag4),
				 .cdb_ar_tag5(cdb_mt_ar_tag5),
				 
				 .recover(recover_mt_recover),
				 .rob_retire_num(rob_mt_fl_bht_lsq_recover_retire_num),
				 .rob_retire_ar0(rob_mt_retire_ar_a),
				 .rob_retire_ar1(rob_mt_retire_ar_b),
				 .rob_retire_pr0(rob_mt_retire_taga),
				 .rob_retire_pr1(rob_mt_retire_tagb),

				// Outputs
				 .rob_p0told(mt_rob_p0told),
				 .rob_p1told(mt_rob_p1told),

				 .rs_pr_a1(mt_rs_pr_a1),
				 .rs_pr_a2(mt_rs_pr_a2),
				 .rs_pr_b1(mt_rs_pr_b1),
				 .rs_pr_b2(mt_rs_pr_b2),

				 .rs_pr_a1_ready(mt_rs_pr_a1_ready),
				 .rs_pr_a2_ready(mt_rs_pr_a2_ready),
				 .rs_pr_b1_ready(mt_rs_pr_b1_ready),
				 .rs_pr_b2_ready(mt_rs_pr_b2_ready)
	);

	// Free list

	fl fl0 (// Inputs
					.clock(clock),
					.reset(fl_reset),
					.id_dispatch_num(id_rs_rob_mt_dispatch_num),
					.rob_retire_num(rob_mt_fl_bht_lsq_recover_retire_num),
					.rob_retire_tag_0(rob_fl_retire_tolda),
					.rob_retire_tag_1(rob_fl_retire_toldb),
					
					.recover(recover_fl_recover),
					// Outputs
					.rob_rs_mt_pr0(fl_rob_rs_mt_pr0),
					.rob_rs_mt_pr1(fl_rob_rs_mt_pr1)
			);

	// RS
	
	rs rs0 (// Inputs
					.clock(clock),
					.reset(rs_reset),

					.id_NPC0(id_rs_NPC0),
					.id_IR0(id_rs_IR0),
					.id_branch_taken0(id_rs_branch_taken0),
					.id_pred_addr0(id_rs_pred_addr0),
					.id_opa_select0(id_rs_mt_opa_select0),
					.id_opb_select0(id_rs_mt_opb_select0),
					.id_dest_idx0(id_rs_mt_dest_idx0),
					.id_alu_func0(id_rs_alu_func0),
					.id_rd_mem0(id_rs_rob_lsq_rd_mem0),
					.id_wr_mem0(id_rs_rob_lsq_wr_mem0),
					.id_cond_branch0(id_rs_cond_branch0),
					.id_uncond_branch0(id_rs_uncond_branch0),
					.id_halt0(id_rs_rob_halt0),
					.id_illegal_inst0(id_rs_rob_mt_illegal_inst0),
					.id_valid_inst0(id_rs_rob_mt_valid_inst0),

					.id_NPC1(id_rs_NPC1),
					.id_IR1(id_rs_IR1),
					.id_branch_taken1(id_rs_branch_taken1),
					.id_pred_addr1(id_rs_pred_addr1),
					.id_opa_select1(id_rs_mt_opa_select1),
					.id_opb_select1(id_rs_mt_opb_select1),
					.id_dest_idx1(id_rs_mt_dest_idx1),
					.id_alu_func1(id_rs_alu_func1),
					.id_rd_mem1(id_rs_rob_lsq_rd_mem1),
					.id_wr_mem1(id_rs_rob_lsq_wr_mem1),
					.id_cond_branch1(id_rs_cond_branch1),
					.id_uncond_branch1(id_rs_uncond_branch1),
					.id_halt1(id_rs_rob_halt1),
					.id_illegal_inst1(id_rs_rob_mt_illegal_inst1),
					.id_valid_inst1(id_rs_rob_mt_valid_inst1),

					.id_dispatch_num(id_rs_rob_mt_dispatch_num),

					.fl_pr_dest_idx0(fl_rob_rs_mt_pr0),
					.mt_pra_idx0(mt_rs_pr_a1),
					.mt_prb_idx0(mt_rs_pr_a2),
					.mt_pra_ready0(mt_rs_pr_a1_ready),
					.mt_prb_ready0(mt_rs_pr_a2_ready),

					.fl_pr_dest_idx1(fl_rob_rs_mt_pr1),
					.mt_pra_idx1(mt_rs_pr_b1),
					.mt_prb_idx1(mt_rs_pr_b2),
					.mt_pra_ready1(mt_rs_pr_b1_ready),
					.mt_prb_ready1(mt_rs_pr_b2_ready),

					.alu_sim_avail(alu_sim_rs_avail), 
					.alu_mul_avail(alu_mul_rs_avail),
					.alu_mem_avail(lsq_rs_avail),

					.cdb_broadcast(cdb_rs_rob_mt_broadcast),
					.cdb_pr_tag0(cdb_rs_rob_mt_pr_tag0),
					.cdb_pr_tag1(cdb_rs_rob_mt_pr_tag1),
					.cdb_pr_tag2(cdb_rs_rob_mt_pr_tag2),
					.cdb_pr_tag3(cdb_rs_rob_mt_pr_tag3),
					.cdb_pr_tag4(cdb_rs_rob_mt_pr_tag4),
					.cdb_pr_tag5(cdb_rs_rob_mt_pr_tag5),

					.lsq_rs_disp_age0(lsq_rs_disp_age0),//new
					.lsq_rs_disp_age1(lsq_rs_disp_age1),//new
					.lsq_rs_disp_old0(lsq_rs_disp_old0),//new
					.lsq_rs_disp_old1(lsq_rs_disp_old1),//new
					//Outputs
					.id_rs_cap(rs_id_cap),

					.alu_sim_NPC0(rs_alu_sim_NPC0),
					.alu_sim_IR0(rs_alu_sim_IR0),

					.alu_sim_branch_taken0(rs_alu_sim_branch_taken0),
					.alu_sim_pred_addr0(rs_alu_sim_pred_addr0),

					.alu_sim_prf_pra_idx0(rs_alu_sim_prf_pra_idx0), 
					.alu_sim_prf_prb_idx0(rs_alu_sim_prf_prb_idx0),

					.alu_sim_opa_select0(rs_alu_sim_opa_select0),
					.alu_sim_opb_select0(rs_alu_sim_opb_select0),
						
					.alu_sim_dest_ar_idx0(rs_alu_sim_dest_ar_idx0),
					.alu_sim_dest_pr_idx0(rs_alu_sim_dest_pr_idx0),
					.alu_sim_func0(rs_alu_sim_func0),

					.alu_sim_rd_mem0(rs_alu_sim_rd_mem0),
					.alu_sim_wr_mem0(rs_alu_sim_wr_mem0),

					.alu_sim_cond_branch0(rs_alu_sim_cond_branch0),
					.alu_sim_uncond_branch0(rs_alu_sim_uncond_branch0),
					.alu_sim_halt0(rs_alu_sim_halt0),

					.alu_sim_illegal_inst0(rs_alu_sim_illegal_inst0),
					.alu_sim_valid_inst0(rs_alu_sim_valid_inst0),

					.alu_sim_NPC1(rs_alu_sim_NPC1),
					.alu_sim_IR1(rs_alu_sim_IR1),

					.alu_sim_branch_taken1(rs_alu_sim_branch_taken1),
					.alu_sim_pred_addr1(rs_alu_sim_pred_addr1),

					.alu_sim_prf_pra_idx1(rs_alu_sim_prf_pra_idx1), 
					.alu_sim_prf_prb_idx1(rs_alu_sim_prf_prb_idx1),

					.alu_sim_opa_select1(rs_alu_sim_opa_select1),
					.alu_sim_opb_select1(rs_alu_sim_opb_select1),
						
					.alu_sim_dest_ar_idx1(rs_alu_sim_dest_ar_idx1),
					.alu_sim_dest_pr_idx1(rs_alu_sim_dest_pr_idx1),
					.alu_sim_func1(rs_alu_sim_func1),

					.alu_sim_rd_mem1(rs_alu_sim_rd_mem1),
					.alu_sim_wr_mem1(rs_alu_sim_wr_mem1),

					.alu_sim_cond_branch1(rs_alu_sim_cond_branch1),
					.alu_sim_uncond_branch1(rs_alu_sim_uncond_branch1),
					.alu_sim_halt1(rs_alu_sim_halt1),

					.alu_sim_illegal_inst1(rs_alu_sim_illegal_inst1),
					.alu_sim_valid_inst1(rs_alu_sim_valid_inst1),

					.alu_mul_NPC0(rs_alu_mul_NPC0),
					.alu_mul_IR0(rs_alu_mul_IR0),

					.alu_mul_branch_taken0(rs_alu_mul_branch_taken0),
					.alu_mul_pred_addr0(rs_alu_mul_pred_addr0),

					.alu_mul_prf_pra_idx0(rs_alu_mul_prf_pra_idx0), 
					.alu_mul_prf_prb_idx0(rs_alu_mul_prf_prb_idx0),

					.alu_mul_opa_select0(rs_alu_mul_opa_select0),
					.alu_mul_opb_select0(rs_alu_mul_opb_select0),
						
					.alu_mul_dest_ar_idx0(rs_alu_mul_dest_ar_idx0),
					.alu_mul_dest_pr_idx0(rs_alu_mul_dest_pr_idx0),
					.alu_mul_func0(rs_alu_mul_func0),

					.alu_mul_rd_mem0(rs_alu_mul_rd_mem0),
					.alu_mul_wr_mem0(rs_alu_mul_wr_mem0),

					.alu_mul_cond_branch0(rs_alu_mul_cond_branch0),
					.alu_mul_uncond_branch0(rs_alu_mul_uncond_branch0),
					.alu_mul_halt0(rs_alu_mul_halt0),

					.alu_mul_illegal_inst0(rs_alu_mul_illegal_inst0),
					.alu_mul_valid_inst0(rs_alu_mul_valid_inst0),

					.alu_mul_NPC1(rs_alu_mul_NPC1),
					.alu_mul_IR1(rs_alu_mul_IR1),

					.alu_mul_branch_taken1(rs_alu_mul_branch_taken1),
					.alu_mul_pred_addr1(rs_alu_mul_pred_addr1),

					.alu_mul_prf_pra_idx1(rs_alu_mul_prf_pra_idx1), 
					.alu_mul_prf_prb_idx1(rs_alu_mul_prf_prb_idx1),

					.alu_mul_opa_select1(rs_alu_mul_opa_select1),
					.alu_mul_opb_select1(rs_alu_mul_opb_select1),
						
					.alu_mul_dest_ar_idx1(rs_alu_mul_dest_ar_idx1),
					.alu_mul_dest_pr_idx1(rs_alu_mul_dest_pr_idx1),
					.alu_mul_func1(rs_alu_mul_func1),

					.alu_mul_rd_mem1(rs_alu_mul_rd_mem1),
					.alu_mul_wr_mem1(rs_alu_mul_wr_mem1),

					.alu_mul_cond_branch1(rs_alu_mul_cond_branch1),
					.alu_mul_uncond_branch1(rs_alu_mul_uncond_branch1),
					.alu_mul_halt1(rs_alu_mul_halt1),

					.alu_mul_illegal_inst1(rs_alu_mul_illegal_inst1),
					.alu_mul_valid_inst1(rs_alu_mul_valid_inst1),

					.alu_mem_NPC0(rs_alu_mem_NPC0),
					.alu_mem_IR0(rs_alu_mem_IR0),

					.alu_mem_branch_taken0(rs_alu_mem_branch_taken0),
					.alu_mem_pred_addr0(rs_alu_mem_pred_addr0),

					.alu_mem_prf_pra_idx0(rs_alu_mem_prf_pra_idx0), 
					.alu_mem_prf_prb_idx0(rs_alu_mem_prf_prb_idx0),

					.alu_mem_opa_select0(rs_alu_mem_opa_select0),
					.alu_mem_opb_select0(rs_alu_mem_opb_select0),
						
					.alu_mem_dest_ar_idx0(rs_alu_mem_dest_ar_idx0),
					.alu_mem_dest_pr_idx0(rs_alu_mem_dest_pr_idx0),
					.alu_mem_func0(rs_alu_mem_func0),

					.alu_mem_rd_mem0(rs_alu_mem_rd_mem0),
					.alu_mem_wr_mem0(rs_alu_mem_wr_mem0),

					.alu_mem_cond_branch0(rs_alu_mem_cond_branch0),
					.alu_mem_uncond_branch0(rs_alu_mem_uncond_branch0),
					.alu_mem_halt0(rs_alu_mem_halt0),

					.alu_mem_illegal_inst0(rs_alu_mem_illegal_inst0),
					.alu_mem_valid_inst0(rs_alu_mem_valid_inst0),

					.alu_mem_NPC1(rs_alu_mem_NPC1),
					.alu_mem_IR1(rs_alu_mem_IR1),

					.alu_mem_branch_taken1(rs_alu_mem_branch_taken1),
					.alu_mem_pred_addr1(rs_alu_mem_pred_addr1),

					.alu_mem_prf_pra_idx1(rs_alu_mem_prf_pra_idx1), 
					.alu_mem_prf_prb_idx1(rs_alu_mem_prf_prb_idx1),

					.alu_mem_opa_select1(rs_alu_mem_opa_select1),
					.alu_mem_opb_select1(rs_alu_mem_opb_select1),
						
					.alu_mem_dest_ar_idx1(rs_alu_mem_dest_ar_idx1),
					.alu_mem_dest_pr_idx1(rs_alu_mem_dest_pr_idx1),
					.alu_mem_func1(rs_alu_mem_func1),

					.alu_mem_rd_mem1(rs_alu_mem_rd_mem1),
					.alu_mem_wr_mem1(rs_alu_mem_wr_mem1),

					.alu_mem_cond_branch1(rs_alu_mem_cond_branch1),
					.alu_mem_uncond_branch1(rs_alu_mem_uncond_branch1),
					.alu_mem_halt1(rs_alu_mem_halt1),

					.alu_mem_illegal_inst1(rs_alu_mem_illegal_inst1),
					.alu_mem_valid_inst1(rs_alu_mem_valid_inst1),
					
					.alu_mem_issue_age0(rs_alu_mem_issue_age0),
					.alu_mem_issue_age1(rs_alu_mem_issue_age1),
					.alu_mem_issue_old0(rs_alu_mem_issue_old0),
					.alu_mem_issue_old1(rs_alu_mem_issue_old1),
					
					.lsq_wr_mem0_peer(rs_lsq_wr_mem0_peer),
					.lsq_wr_mem1_peer(rs_lsq_wr_mem1_peer)
	);


	/*
	 * Physical register file
	 */

	prf prf0 (// Inputs
						.clock(clock),
						.reset(prf_reset),
						.rs_alu_sim_pra_idx0(rs_alu_sim_prf_pra_idx0),
						.rs_alu_sim_pra_idx1(rs_alu_sim_prf_pra_idx1),
						.rs_alu_mul_pra_idx0(rs_alu_mul_prf_pra_idx0),
						.rs_alu_mul_pra_idx1(rs_alu_mul_prf_pra_idx1),
						.rs_alu_mem_pra_idx0(rs_alu_mem_prf_pra_idx0),
						.rs_alu_mem_pra_idx1(rs_alu_mem_prf_pra_idx1),

						.rs_alu_sim_prb_idx0(rs_alu_sim_prf_prb_idx0),
						.rs_alu_sim_prb_idx1(rs_alu_sim_prf_prb_idx1),
						.rs_alu_mul_prb_idx0(rs_alu_mul_prf_prb_idx0),
						.rs_alu_mul_prb_idx1(rs_alu_mul_prf_prb_idx1),
						.rs_alu_mem_prb_idx0(rs_alu_mem_prf_prb_idx0),
						.rs_alu_mem_prb_idx1(rs_alu_mem_prf_prb_idx1),

						.alu_sim_wr_enable0(alu_sim_prf_wr_enable0),
						.alu_sim_pr_idx0(alu_sim_cdb_prf_pr_idx0),
						.alu_sim_pr_value0(alu_sim_prf_value0),

						.alu_sim_wr_enable1(alu_sim_prf_wr_enable1),
						.alu_sim_pr_idx1(alu_sim_cdb_prf_pr_idx1),
						.alu_sim_pr_value1(alu_sim_prf_value1),

						.alu_mul_wr_enable0(alu_mul_prf_wr_enable0),
						.alu_mul_pr_idx0(alu_mul_cdb_prf_pr_idx0),
						.alu_mul_pr_value0(alu_mul_prf_value0),

						.alu_mul_wr_enable1(alu_mul_prf_wr_enable1),
						.alu_mul_pr_idx1(alu_mul_cdb_prf_pr_idx1),
						.alu_mul_pr_value1(alu_mul_prf_value1),

						.alu_mem_wr_enable0(lsq_prf_pr_wr_enable),
						.alu_mem_pr_idx0(lsq_cdb_prf_pr_idx),
						.alu_mem_pr_value0(lsq_prf_pr_value),

						.alu_mem_wr_enable1(Dcache_cdb_prf_complete),
						.alu_mem_pr_idx1(Dcache_cdb_prf_pr_idx),
						.alu_mem_pr_value1(Dcache_prf_data_out),

						// Outputs
						.alu_sim_pra_value0(prf_alu_sim_pra_value0),
						.alu_sim_pra_value1(prf_alu_sim_pra_value1),

						.alu_mul_pra_value0(prf_alu_mul_pra_value0),
						.alu_mul_pra_value1(prf_alu_mul_pra_value1),

						.alu_mem_pra_value0(prf_alu_mem_pra_value0),
						.alu_mem_pra_value1(prf_alu_mem_pra_value1),

						.alu_sim_prb_value0(prf_alu_sim_prb_value0),
						.alu_sim_prb_value1(prf_alu_sim_prb_value1),

						.alu_mul_prb_value0(prf_alu_mul_prb_value0),
						.alu_mul_prb_value1(prf_alu_mul_prb_value1),

						.alu_mem_prb_value0(prf_alu_mem_prb_value0),
						.alu_mem_prb_value1(prf_alu_mem_prb_value1)
	);


	/*
	 * Common data bus
	 */

	cdb cdb0(// Inputs
						.clock(clock),
						.reset(cdb_reset),
						
						.alu_sim_complete0(alu_sim_cdb_complete0),
						.alu_sim_pr_idx0(alu_sim_cdb_prf_pr_idx0),
						.alu_sim_ar_idx0(alu_sim_cdb_ar_idx0),
						.alu_sim_exception0(alu_sim_cdb_exception0),

						.alu_sim_complete1(alu_sim_cdb_complete1),
						.alu_sim_pr_idx1(alu_sim_cdb_prf_pr_idx1),
						.alu_sim_ar_idx1(alu_sim_cdb_ar_idx1),
						.alu_sim_exception1(alu_sim_cdb_exception1),
						
						.alu_sim_actual_addr0(alu_sim_cdb_actual_addr0),
						.alu_sim_actual_taken0(alu_sim_cdb_actual_taken0),
						.alu_sim_actual_addr1(alu_sim_cdb_actual_addr1),
						.alu_sim_actual_taken1(alu_sim_cdb_actual_taken1),

						.alu_mul_complete0(alu_mul_cdb_complete0),
						.alu_mul_pr_idx0(alu_mul_cdb_prf_pr_idx0),
						.alu_mul_ar_idx0(alu_mul_cdb_ar_idx0),

						.alu_mul_complete1(alu_mul_cdb_complete1),
						.alu_mul_pr_idx1(alu_mul_cdb_prf_pr_idx1),
						.alu_mul_ar_idx1(alu_mul_cdb_ar_idx1),

						.alu_mem_complete0(lsq_cdb_complete),
						.alu_mem_pr_idx0(lsq_cdb_prf_pr_idx),
						.alu_mem_ar_idx0(lsq_cdb_ar_idx),
//						.alu_mem_exception0(alu_mem_cdb_exception0),

						.alu_mem_complete1(Dcache_cdb_prf_complete),
						.alu_mem_pr_idx1(Dcache_cdb_prf_pr_idx),
						.alu_mem_ar_idx1(Dcache_cdb_ar_idx),
//						.alu_mem_exception1(alu_mem_cdb_exception1),

						// Outputs
						.rs_rob_mt_broadcast(cdb_rs_rob_mt_broadcast),
						.rs_rob_mt_pr_tag0(cdb_rs_rob_mt_pr_tag0),
						.rs_rob_mt_pr_tag1(cdb_rs_rob_mt_pr_tag1),
						.rs_rob_mt_pr_tag2(cdb_rs_rob_mt_pr_tag2),
						.rs_rob_mt_pr_tag3(cdb_rs_rob_mt_pr_tag3),
						.rs_rob_mt_pr_tag4(cdb_rs_rob_mt_pr_tag4),
						.rs_rob_mt_pr_tag5(cdb_rs_rob_mt_pr_tag5),

						.mt_ar_tag0(cdb_mt_ar_tag0),
						.mt_ar_tag1(cdb_mt_ar_tag1),
						.mt_ar_tag2(cdb_mt_ar_tag2),
						.mt_ar_tag3(cdb_mt_ar_tag3),
						.mt_ar_tag4(cdb_mt_ar_tag4),
						.mt_ar_tag5(cdb_mt_ar_tag5),

						.rob_exception0(cdb_rob_exception0),
						.rob_exception1(cdb_rob_exception1),
//						.rob_exception2(cdb_rob_exception2),
//						.rob_exception3(cdb_rob_exception3),
//						.rob_exception4(cdb_rob_exception4),
//						.rob_exception5(cdb_rob_exception5),
						
						.rob_actual_addr0(cdb_rob_actual_addr0),
						.rob_actual_taken0(cdb_rob_actual_taken0),
//						.rob_cond_branch0(cdb_rob_cond_branch0),
//						.rob_uncond_branch0(cdb_rob_uncond_branch0),

						.rob_actual_addr1(cdb_rob_actual_addr1),
						.rob_actual_taken1(cdb_rob_actual_taken1)
//						.rob_cond_branch1(cdb_rob_cond_branch1),
//						.rob_uncond_branch1(cdb_rob_uncond_branch1)
	);

	/*
	 * ALU simple
	 */

	alu_sim alu_sim0(// Inputs
										.clock(clock),
										.reset(alu_sim_reset),
										
										.rs_NPC0(rs_alu_sim_NPC0),
										.rs_IR0(rs_alu_sim_IR0),
										.prf_pra0(prf_alu_sim_pra_value0),
										.prf_prb0(prf_alu_sim_prb_value0),
										.rs_dest_ar_idx0(rs_alu_sim_dest_ar_idx0),
										.rs_dest_pr_idx0(rs_alu_sim_dest_pr_idx0),
										.rs_opa_select0(rs_alu_sim_opa_select0),
										.rs_opb_select0(rs_alu_sim_opb_select0),
										.rs_alu_func0(rs_alu_sim_func0),
										.rs_cond_branch0(rs_alu_sim_cond_branch0),
										.rs_uncond_branch0(rs_alu_sim_uncond_branch0),
										.rs_branch_taken0(rs_alu_sim_branch_taken0),
										.rs_pred_addr0(rs_alu_sim_pred_addr0),
										.rs_valid_inst0(rs_alu_sim_valid_inst0),

										.rs_NPC1(rs_alu_sim_NPC1),
										.rs_IR1(rs_alu_sim_IR1),
										.prf_pra1(prf_alu_sim_pra_value1),
										.prf_prb1(prf_alu_sim_prb_value1),
										.rs_dest_ar_idx1(rs_alu_sim_dest_ar_idx1),
										.rs_dest_pr_idx1(rs_alu_sim_dest_pr_idx1),
										.rs_opa_select1(rs_alu_sim_opa_select1),
										.rs_opb_select1(rs_alu_sim_opb_select1),
										.rs_alu_func1(rs_alu_sim_func1),
										.rs_cond_branch1(rs_alu_sim_cond_branch1),
										.rs_uncond_branch1(rs_alu_sim_uncond_branch1),
										.rs_branch_taken1(rs_alu_sim_branch_taken1),
										.rs_pred_addr1(rs_alu_sim_pred_addr1),
										.rs_valid_inst1(rs_alu_sim_valid_inst1),

										// Outputs
										.cdb_complete0(alu_sim_cdb_complete0),
										.cdb_dest_ar_idx0(alu_sim_cdb_ar_idx0),
										.cdb_prf_dest_pr_idx0(alu_sim_cdb_prf_pr_idx0),
										.cdb_exception0(alu_sim_cdb_exception0),
										.prf_result0(alu_sim_prf_value0),
										.prf_write_enable0(alu_sim_prf_wr_enable0),

										.cdb_complete1(alu_sim_cdb_complete1),
										.cdb_dest_ar_idx1(alu_sim_cdb_ar_idx1),
										.cdb_prf_dest_pr_idx1(alu_sim_cdb_prf_pr_idx1),
										.cdb_exception1(alu_sim_cdb_exception1),
										.prf_result1(alu_sim_prf_value1),
										.prf_write_enable1(alu_sim_prf_wr_enable1),
										
										.cdb_actual_addr0(alu_sim_cdb_actual_addr0),
										.cdb_actual_addr1(alu_sim_cdb_actual_addr1),
										.cdb_actual_taken0(alu_sim_cdb_actual_taken0),
										.cdb_actual_taken1(alu_sim_cdb_actual_taken1),

										.rs_alu_avail(alu_sim_rs_avail)
										);

	alu_mul alu_mul0( // Inputs
										.clock(clock),
										.reset(alu_mul_reset),

										.rs_NPC0(rs_alu_mul_NPC0),
										.rs_IR0(rs_alu_mul_IR0),
										.prf_pra0(prf_alu_mul_pra_value0),
										.prf_prb0(prf_alu_mul_prb_value0),
										.rs_dest_ar_idx0(rs_alu_mul_dest_ar_idx0),
										.rs_dest_pr_idx0(rs_alu_mul_dest_pr_idx0),
										.rs_opa_select0(rs_alu_mul_opa_select0),
										.rs_opb_select0(rs_alu_mul_opb_select0),
										.rs_valid_inst0(rs_alu_mul_valid_inst0),

										.rs_NPC1(rs_alu_mul_NPC1),
										.rs_IR1(rs_alu_mul_IR1),
										.prf_pra1(prf_alu_mul_pra_value1),
										.prf_prb1(prf_alu_mul_prb_value1),
										.rs_dest_ar_idx1(rs_alu_mul_dest_ar_idx1),
										.rs_dest_pr_idx1(rs_alu_mul_dest_pr_idx1),
										.rs_opa_select1(rs_alu_mul_opa_select1),
										.rs_opb_select1(rs_alu_mul_opb_select1),
										.rs_valid_inst1(rs_alu_mul_valid_inst1),

										// Outputs
										.cdb_complete0(alu_mul_cdb_complete0),
										.cdb_dest_ar_idx0(alu_mul_cdb_ar_idx0),
										.cdb_prf_dest_pr_idx0(alu_mul_cdb_prf_pr_idx0),
//										.cdb_exception0(alu_mul_cdb_exception0),
										.prf_result0(alu_mul_prf_value0),
										.prf_write_enable0(alu_mul_prf_wr_enable0),

										.cdb_complete1(alu_mul_cdb_complete1),
										.cdb_dest_ar_idx1(alu_mul_cdb_ar_idx1),
										.cdb_prf_dest_pr_idx1(alu_mul_cdb_prf_pr_idx1),
//										.cdb_exception1(alu_mul_cdb_exception1),
										.prf_result1(alu_mul_prf_value1),
										.prf_write_enable1(alu_mul_prf_wr_enable1),

										.rs_alu_avail(alu_mul_rs_avail)
								);

  /*
	 * LSQ
	 */
 lsq lsq0(// Inputs
						.clock(clock),
						.reset(lsq_reset),
						// Give the age of each ld
						.id_rd_mem0(id_rs_rob_lsq_rd_mem0),
						.id_rd_mem1(id_rs_rob_lsq_rd_mem1),

						// Put the store in the queue at dispatch
						.id_wr_mem0(id_rs_rob_lsq_wr_mem0),
						.id_wr_mem1(id_rs_rob_lsq_wr_mem1),
						
						// At the issue stage, pass the ready load and store 
						// from rs to lsq
						.rs_IR0(rs_alu_mem_IR0),
						.prf_pra_value0(prf_alu_mem_pra_value0),
						.prf_prb_value0(prf_alu_mem_prb_value0),
						.rs_issue_age0(rs_alu_mem_issue_age0),
						.rs_issue_old0(rs_alu_mem_issue_old0),
						.rs_dest_ar_idx0(rs_alu_mem_dest_ar_idx0),
						.rs_dest_pr_idx0(rs_alu_mem_dest_pr_idx0),
						.rs_rd_mem0(rs_alu_mem_rd_mem0),
						.rs_wr_mem0(rs_alu_mem_wr_mem0),
						.rs_valid_inst0(rs_alu_mem_valid_inst0),

						.rs_IR1(rs_alu_mem_IR1),
						.prf_pra_value1(prf_alu_mem_pra_value1),
						.prf_prb_value1(prf_alu_mem_prb_value1),
						.rs_issue_age1(rs_alu_mem_issue_age1),
						.rs_issue_old1(rs_alu_mem_issue_old1),
						.rs_dest_ar_idx1(rs_alu_mem_dest_ar_idx1),
						.rs_dest_pr_idx1(rs_alu_mem_dest_pr_idx1),
						.rs_rd_mem1(rs_alu_mem_rd_mem1),
						.rs_wr_mem1(rs_alu_mem_wr_mem1),
						.rs_valid_inst1(rs_alu_mem_valid_inst1),

						// Retire the stores
						.rob_retire_num(rob_mt_fl_bht_lsq_recover_retire_num),
						.rob_retire_wr_mem0(rob_lsq_retire_wr_mem0),
						.rob_retire_wr_mem1(rob_lsq_retire_wr_mem1),

						.Dcache_avail(Dcache_lsq_load_avail),
						
						.rs_wr_mem0_peer(rs_lsq_wr_mem0_peer),
						.rs_wr_mem1_peer(rs_lsq_wr_mem1_peer),

						// Outputs
						// Give back the age of ld at dispatch
						.rs_disp_age0(lsq_rs_disp_age0),
						.rs_disp_old0(lsq_rs_disp_old0),
						.rs_disp_age1(lsq_rs_disp_age1),
						.rs_disp_old1(lsq_rs_disp_old1),

						// How many ld lsq can eat
						.rs_avail(lsq_rs_avail),//!!problem!

						// If the value of load is found if the previous store
						// complete the inst and write the value
						// Also complete the ready store
						.cdb_complete(lsq_cdb_complete),
						.cdb_prf_pr_idx(lsq_cdb_prf_pr_idx),
						.cdb_ar_idx(lsq_cdb_ar_idx),
						.prf_pr_wr_enable(lsq_prf_pr_wr_enable),
						.prf_pr_value(lsq_prf_pr_value),

						// The load value of the address is not found,
						// throw the load to cache
	
						// When Dcache commit the ld, it will write the value to 
						// the second interface for alu_mem of prf
						.Dcache_rd_mem(lsq_Dcache_rd_mem),
						.Dcache_wr_mem(lsq_Dcache_wr_mem),
						.Dcache_addr(lsq_Dcache_addr),
						.Dcache_pr_idx(lsq_Dcache_pr_idx),
						.Dcache_ar_idx(lsq_Dcache_ar_idx),

						// For the retired store value
						.Dcache_st_value(lsq_Dcache_st_value),

						.Dcache_st_addr(lsq_Dcache_st_addr)
						);
	 


  /*
	 * Branch History Table
	 */
 bht bht0(//Inputs
						.clock(clock),
						.reset(bht_reset),///bht_reset later, tho I dont kno why.....
						
						.if_NPC0(if_id_bht_NPC0),
						.if_NPC1(if_id_bht_NPC1),//not implemented yet
									
						.if_valid_cond0(if_bht_valid_cond0),
						.if_valid_cond1(if_bht_valid_cond1),

						.recover_cond(recover_bht_recover),
						.recover_bhr(recover_bht_bhr),//stored by ROB to use in recovery.
						
						.rob_retire_cond0(rob_bht_recover_cond_branch0),
						.rob_retire_NPC0(rob_bht_recover_NPC0),
						.rob_retire_BHR0(rob_bht_recover_retire_bhr0),
						.rob_actual_taken0(rob_bht_actual_taken0),
						
						.rob_retire_cond1(rob_bht_recover_cond_branch1),
						.rob_retire_NPC1(rob_bht_recover_NPC1),
						.rob_retire_BHR1(rob_bht_recover_retire_bhr1),
						.rob_actual_taken1(rob_bht_actual_taken1),
						
						//Outputs
						.if_branch_taken0(bht_if_branch_taken0),
						.if_branch_taken1(bht_if_branch_taken1),
						.id_bhr0(bht_id_bhr0),//these inputs are given to if rather than rob. These value would eventually be given to ROB by id.
						.id_bhr1(bht_id_bhr1)
						);
	/*
	 * Branch Target Buffer
	 */					
 btb btb0(//inputs
					.clock(clock),
					.reset(btb_reset),//btb_reset, although I dont know why
					
					.if_NPC0(if_id_bht_NPC0),
					.if_NPC1(if_id_bht_NPC1),

					.recover_uncond(recover_btb_recover),
					.recover_NPC(recover_btb_NPC),
					.recover_actual_addr(recover_btb_actual_addr),
					
					//outputs
					.if_pred_addr0(btb_if_pred_addr0),
					.if_pred_addr1(btb_if_pred_addr1)
					);
		

	/*
	 * Branch Target Buffer
	 */					
 recover recover(//inputs
							.clock(clock),
							.reset(reset),

							.rob_retire_num(rob_mt_fl_bht_lsq_recover_retire_num),
							.rob_exception(rob_recover_exception),

							.rob_cond_branch0(rob_bht_recover_cond_branch0),
							.rob_bhr0(rob_bht_recover_retire_bhr0),
							.rob_NPC0(rob_bht_recover_NPC0),
							.rob_uncond_branch0(rob_recover_uncond_branch0),
							.rob_actual_addr0(rob_recover_actual_addr0),

							.rob_cond_branch1(rob_bht_recover_cond_branch1),
							.rob_bhr1(rob_bht_recover_retire_bhr1),
							.rob_NPC1(rob_bht_recover_NPC1),
							.rob_uncond_branch1(rob_recover_uncond_branch1),
							.rob_actual_addr1(rob_recover_actual_addr1),
							//outputs
							//if
							.if_reset(recover_if_reset),
							.if_recover(recover_if_recover),
							.if_recover_addr(recover_if_recover_addr),
							//bht
							.bht_reset(recover_bht_reset),
							.bht_recover(recover_bht_recover),
							.bht_bhr(recover_bht_bhr),
							//btb
							.btb_reset(recover_btb_reset),
							.btb_recover(recover_btb_recover),
							.btb_NPC(recover_btb_NPC),
							.btb_actual_addr(recover_btb_actual_addr),
							//fl
							.fl_reset(recover_fl_reset),
							.fl_recover(recover_fl_recover),
							//mt
							.mt_reset(recover_mt_reset),
							.mt_recover(recover_mt_recover),
							//universal reset: id,rob,rs,alu_sim,alu_mul,cdb
							.other_reset(recover_other_reset),

							.pipeline_recover(pipeline_recover)
							);
 					
					
					
					
					
endmodule
