/************************************************************
 * 
 * Module name: pipeline.v
 * 
 * Description: Top-level module of panda pipeline
 *
 ************************************************************/

 `timescale 1ns/100ps
 
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


                 // testing hooks (these must be exported so we can test
                 // the synthesized version) data is tested by looking at
                 // the final values in memory
                 if_NPC_out,
                 if_IR_out,
                 if_valid_inst_out,
                 if_id_NPC,
                 if_id_IR,
                 if_id_valid_inst,
                 id_ex_NPC,
                 id_ex_IR,
                 id_ex_valid_inst,
                 ex_mem_NPC,
                 ex_mem_IR,
                 ex_mem_valid_inst,
                 mem_wb_NPC,
                 mem_wb_IR,
                 mem_wb_valid_inst
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

  output [63:0] if_NPC_out;
  output [31:0] if_IR_out;
  output        if_valid_inst_out;
  output [63:0] if_id_NPC;
  output [31:0] if_id_IR;
  output        if_id_valid_inst;
  output [63:0] id_ex_NPC;
  output [31:0] id_ex_IR;
  output        id_ex_valid_inst;
  output [63:0] ex_mem_NPC;
  output [31:0] ex_mem_IR;
  output        ex_mem_valid_inst;
  output [63:0] mem_wb_NPC;
  output [31:0] mem_wb_IR;
  output        mem_wb_valid_inst;

	/*
	 * Output from IF
	 */
	wire	 [63:0]	if_id_NPC0;
	wire	 [63:0]	if_id_NPC1;
	wire	 [31:0]	if_id_IR0;
	wire	 [31:0]	if_id_IR1;
	wire					if_id_valid_inst0;
	wire					if_id_valid_inst1;

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

	wire					id_rs_rd_mem0;
	wire					id_rs_rd_mem1;
	wire					id_rs_wr_mem0;
	wire					id_rs_wr_mem1;

	wire					id_rs_ldl_mem0;
	wire					id_rs_ldl_mem1;
	wire					id_rs_stc_mem0;
	wire					id_rs_stc_mem1;

	wire					id_rs_cond_branch0;
	wire					id_rs_cond_branch1;
	wire					id_rs_uncond_branch0;
	wire					id_rs_uncond_branch1;
	wire					id_rs_halt0;
	wire					id_rs_halt1;

	wire					id_rs_rob_mt_illegal_inst0;
	wire					id_rs_rob_mt_illegal_inst1;
	wire					id_rs_rob_mt_valid_inst0;
	wire					id_rs_rob_mt_valid_inst1;

	wire		[1:0]	id_rs_rob_mt_if_dispatch_num;
	wire		[1:0]	id_isnt_need_num;

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
	wire		[6:0]	fl_rob_rs_mt_pr0
	wire		[6:0]	fl_rob_rs_mt_pr1;

	/*
	 * Output from ROB
	 */
	wire	 [1:0] rob_id_cap;
	wire	 [6:0] rob_fl_retire_tag_a;
	wire	 [6:0] rob_fl_retire_tag_b;
	wire	 [1:0] rob_fl_retire_num;
	wire				 retire_halt;

	/*
	 * Output from RS
	 */
	// Dispatch outputs
	wire		[1:0]	rs_id_rs_cap;

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

	/*
	 * Outputs from physical register file
	 */
	wire	[63:0]	alu_sim_pra_value0,
	wire	[63:0]	alu_sim_pra_value1,

	wire	[63:0]	alu_mem_pra_value0,
	wire	[63:0]	alu_mem_pra_value1,

	wire	[63:0]	alu_mul_pra_value0,
	wire	[63:0]	alu_mul_pra_value1,


	/*
	 * Outputs from CDB
	 */
	wire	[CDB_WIDTH-1:0]	cdb_rs_rob_mt_broadcast;
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
	wire					cdb_rob_exception2;
	wire					cdb_rob_exception3;
	wire					cdb_rob_exception4;
	wire					cdb_rob_exception5;

	/*
	 * Outputs from simple ALU
	 */

	/*
	 * Outputs from multiplier
	 */

	/*
	 * Output from memory ALU
	 */

	/*
	 * Outputs from branch history table
	 */

	wire				bht_if_branch_taken0;
	wire				bht_if_branch_taken1;

	/*
	 * Outputs from brach target buffer
	 */

	wire [63:0]	btb_if_pred_taken0;
	wire [63:0]	btb_if_pred_taken1;

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
	wire		alu_mem_reset;
	wire		cdb_reset;
	wire		ic_reset;
	wire		dc_reset;

	assign	if_reset 			= reset;
	assign	id_reset 			= reset;
	assign	mt_reset 			= reset;
	assign	rob_reset 		= reset;
	assign	rs_reset 			= reset;
	assign	fl_reset 			= reset;
	assign	prf_reset 		= reset;
	assign	alu_sim_reset = reset;
	assign	alu_mul_reset = reset;
	assign	alu_mem_reset = reset;
	assign	cdb_reset 		= reset;
	assign	ic_reset 			= reset;
	assign	dc_reset 			= reset;

if_mod if_mod0 (// Inputs
								.clock(clock),
								.reset(if_reset),
								.bht_branch_taken0(bht_if_branch_taken0),
								.bht_branch_taken1(bht_if_branch_taken1),
								.btb_pred_addr0(btb_if_pred_addr0),
								.btb_pred_addr1(btb_if_pred_aadr0),
								.Imem2proc_data(Imem2proc_data),
								.Imem_valid(Imem_valid),
								.id_inst_need_num(id_if_need_num),

								.id_NPC
								
