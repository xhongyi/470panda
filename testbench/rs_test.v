module testbench;

reg					clock;
reg					reset;
reg	[31:0]	if_IR0;
reg	[31:0]	if_IR1;
reg					if_valid_inst0;
reg					if_valid_inst1;
reg	[63:0]	if_NPC0;
reg	[63:0]	if_NPC1;

reg					if_branch_taken0;
reg					if_branch_taken1;
reg	[63:0]	if_pred_addr0;
reg	[63:0]	if_pred_addr1;

reg	[1:0]		rob_cap; // rob capacity

///input of other signal for rs/////////////////////////////////////////
reg		[6:0]	fl_pr_dest_idx0;
reg		[6:0]	mt_pra_idx0;
reg		[6:0]	mt_prb_idx0;
reg					mt_pra_ready0; // *** If the reg is not valid, it is ready ***
reg					mt_prb_ready0;

reg		[6:0]	fl_pr_dest_idx1;
reg		[6:0]	mt_pra_idx1;
reg		[6:0]	mt_prb_idx1;
reg					mt_pra_ready1; // *** If the reg is not valid, it is ready ***
reg					mt_prb_ready1;

// Issue inputs
reg		[1:0]	alu_sim_avail; // For the simple calculations
reg		[1:0]	alu_mul_avail; // For the multiplication unit
reg		[1:0]	alu_mem_avail; // For access the memory

// Complete inputs
reg		[5:0]	cdb_broadcast;
reg		[6:0]	cdb_pr_tag0;
reg		[6:0]	cdb_pr_tag1;
reg		[6:0]	cdb_pr_tag2;
reg		[6:0]	cdb_pr_tag3;
reg		[6:0]	cdb_pr_tag4;
reg		[6:0]	cdb_pr_tag5;


// Dispatch wires
wire	[1:0]	id_rs_cap;

// Issue wires
wire	[63:0]	alu_sim_NPC0;
wire	[63:0]	alu_sim_NPC1;
wire	[31:0] alu_sim_IR0;
wire	[31:0]	alu_sim_IR1;

wire				alu_sim_branch_taken0;
wire				alu_sim_branch_taken1;
wire	[63:0]	alu_sim_pred_addr0;
wire	[63:0]	alu_sim_pred_addr1;

wire 	[6:0]	alu_sim_prf_pra_idx0; // Go to physical register file to get the value
wire	[6:0]	alu_sim_prf_pra_idx1;
wire	[6:0]	alu_sim_prf_prb_idx0;
wire	[6:0]	alu_sim_prf_prb_idx1;

wire	[1:0]	alu_sim_opa_select0;
wire	[1:0]	alu_sim_opa_select1;
wire	[1:0]	alu_sim_opb_select0;
wire	[1:0]	alu_sim_opb_select1;

wire	[4:0]	alu_sim_dest_ar_idx0;
wire	[4:0]	alu_sim_dest_ar_idx1;
wire	[6:0]	alu_sim_dest_pr_idx0;
wire	[6:0]	alu_sim_dest_pr_idx1;
wire	[4:0]	alu_sim_func0;
wire	[4:0]	alu_sim_func1;

wire				alu_sim_rd_mem0;
wire				alu_sim_rd_mem1;
wire				alu_sim_wr_mem0;
wire				alu_sim_wr_mem1;

wire				alu_sim_cond_branch0;
wire				alu_sim_cond_branch1;
wire				alu_sim_uncond_branch0;
wire				alu_sim_uncond_branch1;
wire				alu_sim_halt0;
wire				alu_sim_halt1;

wire				alu_sim_illegal_inst0;
wire				alu_sim_illegal_inst1;
wire				alu_sim_valid_inst0;
wire				alu_sim_valid_inst1;

wire	[63:0]	alu_mul_NPC0;
wire	[63:0]	alu_mul_NPC1;
wire	[31:0]	alu_mul_IR0;
wire	[31:0]	alu_mul_IR1;

wire				alu_mul_branch_taken0;
wire				alu_mul_branch_taken1;
wire	[63:0]	alu_mul_pred_addr0;
wire	[63:0]	alu_mul_pred_addr1;

wire	[6:0]	alu_mul_prf_pra_idx0; // Go to physical register file to get the value
wire	[6:0]	alu_mul_prf_pra_idx1;
wire	[6:0]	alu_mul_prf_prb_idx0;
wire	[6:0]	alu_mul_prf_prb_idx1;

wire	[1:0]	alu_mul_opa_select0;
wire	[1:0]	alu_mul_opa_select1;
wire	[1:0]	alu_mul_opb_select0;
wire	[1:0]	alu_mul_opb_select1;

wire	[4:0]	alu_mul_dest_ar_idx0;
wire	[4:0]	alu_mul_dest_ar_idx1;
wire	[6:0]	alu_mul_dest_pr_idx0;
wire	[6:0]	alu_mul_dest_pr_idx1;
wire	[4:0]	alu_mul_func0;
wire	[4:0]	alu_mul_func1;

wire				alu_mul_rd_mem0;
wire				alu_mul_rd_mem1;
wire				alu_mul_wr_mem0;
wire				alu_mul_wr_mem1;

wire				alu_mul_cond_branch0;
wire				alu_mul_cond_branch1;
wire				alu_mul_uncond_branch0;
wire				alu_mul_uncond_branch1;
wire				alu_mul_halt0;
wire				alu_mul_halt1;

wire				alu_mul_illegal_inst0;
wire				alu_mul_illegal_inst1;
wire				alu_mul_valid_inst0;
wire				alu_mul_valid_inst1;

wire	[63:0]	alu_mem_NPC0;
wire	[63:0]	alu_mem_NPC1;
wire	[31:0]	alu_mem_IR0;
wire	[31:0]	alu_mem_IR1;

wire				alu_mem_branch_taken0;
wire				alu_mem_branch_taken1;
wire	[63:0]	alu_mem_pred_addr0;
wire	[63:0]	alu_mem_pred_addr1;

wire 	[6:0]	alu_mem_prf_pra_idx0; // Go to physical register file to get the value
wire	[6:0]	alu_mem_prf_pra_idx1;
wire	[6:0]	alu_mem_prf_prb_idx0;
wire	[6:0]	alu_mem_prf_prb_idx1;

wire	[1:0]	alu_mem_opa_select0;
wire	[1:0]	alu_mem_opa_select1;
wire	[1:0]	alu_mem_opb_select0;
wire	[1:0]	alu_mem_opb_select1;

wire	[4:0]	alu_mem_dest_ar_idx0;
wire	[4:0]	alu_mem_dest_ar_idx1;
wire	[6:0]	alu_mem_dest_pr_idx0;
wire	[6:0]	alu_mem_dest_pr_idx1;
wire	[4:0]	alu_mem_func0;
wire	[4:0]	alu_mem_func1;

wire				alu_mem_rd_mem0;
wire				alu_mem_rd_mem1;
wire				alu_mem_wr_mem0;
wire				alu_mem_wr_mem1;

wire				alu_mem_cond_branch0;
wire				alu_mem_cond_branch1;
wire				alu_mem_uncond_branch0;
wire				alu_mem_uncond_branch1;
wire				alu_mem_halt0;
wire				alu_mem_halt1;

wire				alu_mem_illegal_inst0;
wire				alu_mem_illegal_inst1;
wire				alu_mem_valid_inst0;
wire				alu_mem_valid_inst1;


//wire between id and rs////////////////////////////////////////////////////////
wire	[63:0]	rs_NPC0;
wire	[63:0]	rs_NPC1;
wire	[31:0]	rs_IR0;
wire	[31:0]	rs_IR1;

wire	rs_branch_taken0;
wire	rs_branch_taken1;
wire	[63:0]	rs_pred_addr0;
wire	[63:0]	rs_pred_addr1;

wire	[4:0]	rs_mt_ra_idx0;
wire	[4:0]	rs_mt_ra_idx1;
wire	[4:0]	rs_mt_rb_idx0;
wire	[4:0]	rs_mt_rb_idx1;
wire	[4:0]	rs_mt_rc_idx0;
wire	[4:0]	rs_mt_rc_idx1;

wire	[1:0]	rs_mt_opa_select0;
wire	[1:0]	rs_mt_opa_select1;
wire	[1:0]	rs_mt_opb_select0;
wire	[1:0]	rs_mt_opb_select1;

wire	[4:0]	rs_mt_dest_idx0;
wire	[4:0]	rs_mt_dest_idx1;
wire	[4:0]	rs_alu_func0;
wire	[4:0]	rs_alu_func1;

wire	rs_rd_mem0;
wire	rs_rd_mem1;
wire	rs_wr_mem0;
wire	rs_wr_mem1;

wire	rs_ldl_mem0;
wire	rs_ldl_mem1;
wire	rs_stc_mem0;
wire	rs_stc_mem1;

wire	rs_cond_branch0;
wire	rs_cond_branch1;
wire	rs_uncond_branch0;
wire	rs_uncond_branch1;
wire	rs_halt0;
wire	rs_halt1;

wire	rs_rob_mt_illegal_inst0;
wire	rs_rob_mt_illegal_inst1;
wire	rs_rob_mt_valid_inst0;
wire	rs_rob_mt_valid_inst1;

wire	[1:0]	rs_rob_mt_if_dispatch_num;
/////////////////////////////////////////////////////////////////////////////////////wire for id

wire [1:0] if_inst_need_num;

//correct values///////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////id correct output

reg [1:0] cre_if_inst_need_num;

/////////////////////////////////////////////////////////////////////////////////////rs correct output
// Dispatch wires
reg	[1:0]	cre_id_rs_cap;

// Issue wires
reg	[63:0]	cre_alu_sim_NPC0;
reg	[63:0]	cre_alu_sim_NPC1;
reg	[31:0]	cre_alu_sim_IR0;
reg	[31:0]	cre_alu_sim_IR1;

reg				cre_alu_sim_branch_taken0;
reg				cre_alu_sim_branch_taken1;
reg	[63:0]	cre_alu_sim_pred_addr0;
reg	[63:0]	cre_alu_sim_pred_addr1;

reg 	[6:0]	cre_alu_sim_prf_pra_idx0; // Go to physical register file to get the value
reg	[6:0]	cre_alu_sim_prf_pra_idx1;
reg	[6:0]	cre_alu_sim_prf_prb_idx0;
reg	[6:0]	cre_alu_sim_prf_prb_idx1;

reg	[1:0]	cre_alu_sim_opa_select0;
reg	[1:0]	cre_alu_sim_opa_select1;
reg	[1:0]	cre_alu_sim_opb_select0;
reg	[1:0]	cre_alu_sim_opb_select1;

reg	[4:0]	cre_alu_sim_dest_ar_idx0;
reg	[4:0]	cre_alu_sim_dest_ar_idx1;
reg	[6:0]	cre_alu_sim_dest_pr_idx0;
reg	[6:0]	cre_alu_sim_dest_pr_idx1;
reg	[4:0]	cre_alu_sim_func0;
reg	[4:0]	cre_alu_sim_func1;

reg				cre_alu_sim_rd_mem0;
reg				cre_alu_sim_rd_mem1;
reg				cre_alu_sim_wr_mem0;
reg				cre_alu_sim_wr_mem1;
reg				cre_alu_sim_cond_branch0;
reg				cre_alu_sim_cond_branch1;
reg				cre_alu_sim_uncond_branch0;
reg				cre_alu_sim_uncond_branch1;
reg				cre_alu_sim_halt0;
reg				cre_alu_sim_halt1;

reg				cre_alu_sim_illegal_inst0;
reg				cre_alu_sim_illegal_inst1;
reg				cre_alu_sim_valid_inst0;
reg				cre_alu_sim_valid_inst1;

reg	[63:0]	cre_alu_mul_NPC0;
reg	[63:0]	cre_alu_mul_NPC1;
reg	[31:0]	cre_alu_mul_IR0;
reg	[31:0]	cre_alu_mul_IR1;

reg				cre_alu_mul_branch_taken0;
reg				cre_alu_mul_branch_taken1;
reg	[63:0]	cre_alu_mul_pred_addr0;
reg	[63:0]	cre_alu_mul_pred_addr1;

reg	[6:0]	cre_alu_mul_prf_pra_idx0; // Go to physical register file to get the value
reg	[6:0]	cre_alu_mul_prf_pra_idx1;
reg	[6:0]	cre_alu_mul_prf_prb_idx0;
reg	[6:0]	cre_alu_mul_prf_prb_idx1;

reg	[1:0]	cre_alu_mul_opa_select0;
reg	[1:0]	cre_alu_mul_opa_select1;
reg	[1:0]	cre_alu_mul_opb_select0;
reg	[1:0]	cre_alu_mul_opb_select1;

reg	[4:0]	cre_alu_mul_dest_ar_idx0;
reg	[4:0]	cre_alu_mul_dest_ar_idx1;
reg	[6:0]	cre_alu_mul_dest_pr_idx0;
reg	[6:0]	cre_alu_mul_dest_pr_idx1;
reg	[4:0]	cre_alu_mul_func0;
reg	[4:0]	cre_alu_mul_func1;

reg				cre_alu_mul_rd_mem0;
reg				cre_alu_mul_rd_mem1;
reg				cre_alu_mul_wr_mem0;
reg				cre_alu_mul_wr_mem1;

reg				cre_alu_mul_cond_branch0;
reg				cre_alu_mul_cond_branch1;
reg				cre_alu_mul_uncond_branch0;
reg				cre_alu_mul_uncond_branch1;
reg				cre_alu_mul_halt0;
reg				cre_alu_mul_halt1;

reg				cre_alu_mul_illegal_inst0;
reg				cre_alu_mul_illegal_inst1;
reg				cre_alu_mul_valid_inst0;
reg				cre_alu_mul_valid_inst1;

reg	[63:0]	cre_alu_mem_NPC0;
reg	[63:0]	cre_alu_mem_NPC1;
reg	[31:0]	cre_alu_mem_IR0;
reg	[31:0]	cre_alu_mem_IR1;

reg				cre_alu_mem_branch_taken0;
reg				cre_alu_mem_branch_taken1;
reg	[63:0]	cre_alu_mem_pred_addr0;
reg	[63:0]	cre_alu_mem_pred_addr1;

reg 	[6:0]	cre_alu_mem_prf_pra_idx0; // Go to physical register file to get the value
reg	[6:0]	cre_alu_mem_prf_pra_idx1;
reg	[6:0]	cre_alu_mem_prf_prb_idx0;
reg	[6:0]	cre_alu_mem_prf_prb_idx1;

reg	[1:0]	cre_alu_mem_opa_select0;
reg	[1:0]	cre_alu_mem_opa_select1;
reg	[1:0]	cre_alu_mem_opb_select0;
reg	[1:0]	cre_alu_mem_opb_select1;

reg	[4:0]	cre_alu_mem_dest_ar_idx0;
reg	[4:0]	cre_alu_mem_dest_ar_idx1;
reg	[6:0]	cre_alu_mem_dest_pr_idx0;
reg	[6:0]	cre_alu_mem_dest_pr_idx1;
reg	[4:0]	cre_alu_mem_func0;
reg	[4:0]	cre_alu_mem_func1;

reg				cre_alu_mem_rd_mem0;
reg				cre_alu_mem_rd_mem1;
reg				cre_alu_mem_wr_mem0;
reg				cre_alu_mem_wr_mem1;

reg				cre_alu_mem_cond_branch0;
reg				cre_alu_mem_cond_branch1;
reg				cre_alu_mem_uncond_branch0;
reg				cre_alu_mem_uncond_branch1;
reg				cre_alu_mem_halt0;
reg				cre_alu_mem_halt1;

reg				cre_alu_mem_illegal_inst0;
reg				cre_alu_mem_illegal_inst1;
reg				cre_alu_mem_valid_inst0;
reg				cre_alu_mem_valid_inst1;

reg				correct;

///rs and id module connection/////////////////////////////////////////////////////////

	id id_0(
				//Inputs
				clock,
				reset,
				if_IR0,
				if_IR1,
				if_valid_inst0,
				if_valid_inst1,
				if_NPC0,
				if_NPC1,

				if_branch_taken0,
				if_branch_taken1,
				if_pred_addr0,
				if_pred_addr1,

				rob_cap, // rob capacity
				id_rs_cap, // rs capacity

				//Outputs

				rs_NPC0,
				rs_NPC1,
				rs_IR0,
				rs_IR1,

				rs_branch_taken0,
				rs_branch_taken1,
				rs_pred_addr0,
				rs_pred_addr1,

				rs_mt_ra_idx0,
				rs_mt_ra_idx1,
				rs_mt_rb_idx0,
				rs_mt_rb_idx1,
				rs_mt_rc_idx0,
				rs_mt_rc_idx1,

				rs_mt_opa_select0,
				rs_mt_opa_select1,
				rs_mt_opb_select0,
				rs_mt_opb_select1,
				
				rs_mt_dest_idx0,
				rs_mt_dest_idx1,
				rs_alu_func0,
				rs_alu_func1,

				rs_rd_mem0,
				rs_rd_mem1,
				rs_wr_mem0,
				rs_wr_mem1,

				rs_ldl_mem0,
				rs_ldl_mem1,
				rs_stc_mem0,
				rs_stc_mem1,

				rs_cond_branch0,
				rs_cond_branch1,
				rs_uncond_branch0,
				rs_uncond_branch1,
				rs_halt0,
				rs_halt1,

				rs_rob_mt_illegal_inst0,
				rs_rob_mt_illegal_inst1,
				rs_rob_mt_valid_inst0,
				rs_rob_mt_valid_inst1,

				rs_rob_mt_if_dispatch_num,
				if_inst_need_num
				);

	rs rs_0(// Inputs
						clock,
						reset,
				
					// Dispatch inputs
						rs_NPC0,
						rs_IR0,
						rs_branch_taken0,
						rs_pred_addr0,
						rs_mt_opa_select0,
						rs_mt_opb_select0,
						rs_mt_dest_idx0,
						rs_alu_func0,
						rs_rd_mem0,
						rs_stc_mem0,
						rs_cond_branch0,
						rs_uncond_branch0,
						rs_halt0,
						rs_rob_mt_illegal_inst0,
						rs_rob_mt_valid_inst0,

						rs_NPC1,
						rs_IR1,
						rs_branch_taken1,
						rs_pred_addr1,
						rs_mt_opa_select1,
						rs_mt_opb_select1,
						rs_mt_dest_idx1,
						rs_alu_func1,
						rs_rd_mem1,
						rs_stc_mem1,
						rs_cond_branch1,
						rs_uncond_branch1,
						rs_halt1,
						rs_rob_mt_illegal_inst1,
						rs_rob_mt_valid_inst1,

						rs_rob_mt_if_dispatch_num,

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



always @(posedge clock) begin
	#4
	correct = 1;
	if (cre_alu_sim_valid_inst0) begin
		if (
		cre_alu_sim_NPC0 != alu_sim_NPC0 ||
		cre_alu_sim_IR0 != alu_sim_IR0 ||

		cre_alu_sim_branch_taken0 != alu_sim_branch_taken0 ||
		cre_alu_sim_pred_addr0 != alu_sim_pred_addr0 ||

		cre_alu_sim_prf_pra_idx0 != alu_sim_prf_pra_idx0 ||
		cre_alu_sim_prf_prb_idx0 != alu_sim_prf_prb_idx0 ||

		cre_alu_sim_opa_select0 != alu_sim_opa_select0 ||
		cre_alu_sim_opb_select0 != alu_sim_opb_select0 ||

		cre_alu_sim_dest_ar_idx0 != alu_sim_dest_ar_idx0 ||
		cre_alu_sim_dest_pr_idx0 != alu_sim_dest_pr_idx0 ||
		cre_alu_sim_func0 != alu_sim_func0 ||

		cre_alu_sim_rd_mem0 != alu_sim_rd_mem0 ||
		cre_alu_sim_wr_mem0 != alu_sim_wr_mem0 ||

		cre_alu_sim_cond_branch0 != alu_sim_cond_branch0 ||
		cre_alu_sim_uncond_branch0 != alu_sim_uncond_branch0 ||
		cre_alu_sim_halt0 != alu_sim_halt0 ||

		cre_alu_sim_illegal_inst0 != alu_sim_illegal_inst0 ||
		cre_alu_sim_valid_inst0 != alu_sim_valid_inst0
		) begin
	    $display("!!ERROR!! simple alu0 encountered an error!~");

			$display("cre_alu_sim_NPC0: %d	alu_sim_NPC0: %d\n", cre_alu_sim_NPC0, alu_sim_NPC0);
			$display("cre_alu_sim_IR0: %d	alu_sim_IR0: %d\n", cre_alu_sim_IR0, alu_sim_IR0);

			$display("cre_alu_sim_branch_taken0: %d	alu_sim_branch_taken0: %d\n", cre_alu_sim_branch_taken0, alu_sim_branch_taken0);
			$display("cre_alu_sim_pred_addr0: %d	alu_sim_pred_addr0: %d\n", cre_alu_sim_pred_addr0, alu_sim_pred_addr0);

			$display("cre_alu_sim_prf_pra_idx0: %d	alu_sim_prf_pra_idx0: %d\n", cre_alu_sim_prf_pra_idx0, alu_sim_prf_pra_idx0);
			$display("cre_alu_sim_prf_prb_idx0: %d	alu_sim_prf_prb_idx0: %d\n", cre_alu_sim_prf_prb_idx0, alu_sim_prf_prb_idx0);

			$display("cre_alu_sim_opa_select0: %d	alu_sim_opa_select0: %d\n", cre_alu_sim_opa_select0, alu_sim_opa_select0);
			$display("cre_alu_sim_opb_select0: %d	alu_sim_opb_select0: %d\n", cre_alu_sim_opb_select0, alu_sim_opb_select0);

			$display("cre_alu_sim_dest_ar_idx0: %d	alu_sim_dest_ar_idx0: %d\n", cre_alu_sim_dest_ar_idx0, alu_sim_dest_ar_idx0);
			$display("cre_alu_sim_dest_pr_idx0: %d	alu_sim_dest_pr_idx0: %d\n", cre_alu_sim_dest_pr_idx0, alu_sim_dest_pr_idx0);
			$display("cre_alu_sim_func0: %d	alu_sim_func0: %d\n", cre_alu_sim_func0, alu_sim_func0);

			$display("cre_alu_sim_rd_mem0: %d	alu_sim_rd_mem0: %d\n", cre_alu_sim_rd_mem0, alu_sim_rd_mem0);
			$display("cre_alu_sim_wr_mem0: %d	alu_sim_wr_mem0: %d\n", cre_alu_sim_wr_mem0, alu_sim_wr_mem0);

			$display("cre_alu_sim_cond_branch0: %d	alu_sim_cond_branch0: %d\n", cre_alu_sim_cond_branch0, alu_sim_cond_branch0);
			$display("cre_alu_sim_uncond_branch0: %d	alu_sim_uncond_branch0: %d\n", cre_alu_sim_uncond_branch0, alu_sim_uncond_branch0);
			$display("cre_alu_sim_halt0: %d	alu_sim_halt0: %d\n", cre_alu_sim_halt0, alu_sim_halt0);

			$display("cre_alu_sim_illegal_inst0: %d	alu_sim_illegal_inst0: %d\n", cre_alu_sim_illegal_inst0, alu_sim_illegal_inst0);
			$display("cre_alu_sim_valid_inst0: %d	alu_sim_valid_inst0: %d\n", cre_alu_sim_valid_inst0, alu_sim_valid_inst0);
				correct = 0;
			end
		end
	if (cre_alu_sim_valid_inst1) begin
		if (
		cre_alu_sim_NPC1 != alu_sim_NPC1 ||
		cre_alu_sim_IR1 != alu_sim_IR1 ||

		cre_alu_sim_branch_taken1 != alu_sim_branch_taken1 ||
		cre_alu_sim_pred_addr1 != alu_sim_pred_addr1 ||

		cre_alu_sim_prf_pra_idx1 != alu_sim_prf_pra_idx1 ||
		cre_alu_sim_prf_prb_idx1 != alu_sim_prf_prb_idx1 ||

		cre_alu_sim_opa_select1 != alu_sim_opa_select1 ||
		cre_alu_sim_opb_select1 != alu_sim_opb_select1 ||

		cre_alu_sim_dest_ar_idx1 != alu_sim_dest_ar_idx1 ||
		cre_alu_sim_dest_pr_idx1 != alu_sim_dest_pr_idx1 ||
		cre_alu_sim_func1 != alu_sim_func1 ||

		cre_alu_sim_rd_mem1 != alu_sim_rd_mem1 ||
		cre_alu_sim_wr_mem1 != alu_sim_wr_mem1 ||

		cre_alu_sim_cond_branch1 != alu_sim_cond_branch1 ||
		cre_alu_sim_uncond_branch1 != alu_sim_uncond_branch1 ||
		cre_alu_sim_halt1 != alu_sim_halt1 ||

		cre_alu_sim_illegal_inst1 != alu_sim_illegal_inst1 ||
		cre_alu_sim_valid_inst1 != alu_sim_valid_inst1
		) begin
	    $display("!!ERROR!! simple alu1 encountered an error!~");

			$display("cre_alu_sim_NPC1: %d	alu_sim_NPC1: %d\n", cre_alu_sim_NPC1, alu_sim_NPC1);
			$display("cre_alu_sim_IR1: %d	alu_sim_IR1: %d\n", cre_alu_sim_IR1, alu_sim_IR1);

			$display("cre_alu_sim_branch_taken1: %d	alu_sim_branch_taken1: %d\n", cre_alu_sim_branch_taken1, alu_sim_branch_taken1);
			$display("cre_alu_sim_pred_addr1: %d	alu_sim_pred_addr1: %d\n", cre_alu_sim_pred_addr1, alu_sim_pred_addr1);

			$display("cre_alu_sim_prf_pra_idx1: %d	alu_sim_prf_pra_idx1: %d\n", cre_alu_sim_prf_pra_idx1, alu_sim_prf_pra_idx1);
			$display("cre_alu_sim_prf_prb_idx1: %d	alu_sim_prf_prb_idx1: %d\n", cre_alu_sim_prf_prb_idx1, alu_sim_prf_prb_idx1);

			$display("cre_alu_sim_opa_select1: %d	alu_sim_opa_select1: %d\n", cre_alu_sim_opa_select1, alu_sim_opa_select1);
			$display("cre_alu_sim_opb_select1: %d	alu_sim_opb_select1: %d\n", cre_alu_sim_opb_select1, alu_sim_opb_select1);

			$display("cre_alu_sim_dest_ar_idx1: %d	alu_sim_dest_ar_idx1: %d\n", cre_alu_sim_dest_ar_idx1, alu_sim_dest_ar_idx1);
			$display("cre_alu_sim_dest_pr_idx1: %d	alu_sim_dest_pr_idx1: %d\n", cre_alu_sim_dest_pr_idx1, alu_sim_dest_pr_idx1);
			$display("cre_alu_sim_func1: %d	alu_sim_func1: %d\n", cre_alu_sim_func1, alu_sim_func1);

			$display("cre_alu_sim_rd_mem1: %d	alu_sim_rd_mem1: %d\n", cre_alu_sim_rd_mem1, alu_sim_rd_mem1);
			$display("cre_alu_sim_wr_mem1: %d	alu_sim_wr_mem1: %d\n", cre_alu_sim_wr_mem1, alu_sim_wr_mem1);

			$display("cre_alu_sim_cond_branch1: %d	alu_sim_cond_branch1: %d\n", cre_alu_sim_cond_branch1, alu_sim_cond_branch1);
			$display("cre_alu_sim_uncond_branch1: %d	alu_sim_uncond_branch1: %d\n", cre_alu_sim_uncond_branch1, alu_sim_uncond_branch1);
			$display("cre_alu_sim_halt1: %d	alu_sim_halt1: %d\n", cre_alu_sim_halt1, alu_sim_halt1);

			$display("cre_alu_sim_illegal_inst1: %d	alu_sim_illegal_inst1: %d\n", cre_alu_sim_illegal_inst1, alu_sim_illegal_inst1);
			$display("cre_alu_sim_valid_inst1: %d	alu_sim_valid_inst1: %d\n", cre_alu_sim_valid_inst1, alu_sim_valid_inst1);
	    correct = 0;
    end
  end
  if (cre_alu_mul_valid_inst0) begin
	  if (
		cre_alu_mul_NPC0 != alu_mul_NPC0 ||
		cre_alu_mul_IR0 != alu_mul_NPC0 ||

		cre_alu_mul_branch_taken0 != alu_mul_branch_taken0 ||
		cre_alu_mul_pred_addr0 != alu_mul_pred_addr0 ||

		cre_alu_mul_prf_pra_idx0 != alu_mul_prf_pra_idx0 ||
		cre_alu_mul_prf_prb_idx0 != alu_mul_prf_prb_idx0 ||

		cre_alu_mul_opa_select0 != alu_mul_opa_select0 ||
		cre_alu_mul_opb_select0 != alu_mul_opb_select0 ||

		cre_alu_mul_dest_ar_idx0 != alu_mul_dest_ar_idx0 ||
		cre_alu_mul_dest_pr_idx0 != alu_mul_dest_pr_idx0 ||
		cre_alu_mul_func0 != alu_mul_func0 ||

		cre_alu_mul_rd_mem0 != alu_mul_rd_mem0 ||
		cre_alu_mul_wr_mem0 != alu_mul_wr_mem0 ||

		cre_alu_mul_cond_branch0 != alu_mul_cond_branch0 ||
		cre_alu_mul_uncond_branch0 != alu_mul_uncond_branch0 ||
		cre_alu_mul_halt0 != alu_mul_halt0 ||

		cre_alu_mul_illegal_inst0 != alu_mul_illegal_inst0 ||
		cre_alu_mul_valid_inst0 != alu_mul_valid_inst0
		) begin
			$display("!!ERROR!! simple mul0 encountered an error!~");

			$display("cre_alu_mul_NPC0: %d	alu_mul_NPC0: %d\n", cre_alu_mul_NPC0, alu_mul_NPC0);
			$display("cre_alu_mul_IR0: %d	alu_mul_NPC0: %d\n", cre_alu_mul_IR0, alu_mul_NPC0);

			$display("cre_alu_mul_branch_taken0: %d	alu_mul_branch_taken0: %d\n", cre_alu_mul_branch_taken0, alu_mul_branch_taken0);
			$display("cre_alu_mul_pred_addr0: %d	alu_mul_pred_addr0: %d\n", cre_alu_mul_pred_addr0, alu_mul_pred_addr0);

			$display("cre_alu_mul_prf_pra_idx0: %d	alu_mul_prf_pra_idx0: %d\n", cre_alu_mul_prf_pra_idx0, alu_mul_prf_pra_idx0);
			$display("cre_alu_mul_prf_prb_idx0: %d	alu_mul_prf_prb_idx0: %d\n", cre_alu_mul_prf_prb_idx0, alu_mul_prf_prb_idx0);

			$display("cre_alu_mul_opa_select0: %d	alu_mul_opa_select0: %d\n", cre_alu_mul_opa_select0, alu_mul_opa_select0);
			$display("cre_alu_mul_opb_select0: %d	alu_mul_opb_select0: %d\n", cre_alu_mul_opb_select0, alu_mul_opb_select0);

			$display("cre_alu_mul_dest_ar_idx0: %d	alu_mul_dest_ar_idx0: %d\n", cre_alu_mul_dest_ar_idx0, alu_mul_dest_ar_idx0);
			$display("cre_alu_mul_dest_pr_idx0: %d	alu_mul_dest_pr_idx0: %d\n", cre_alu_mul_dest_pr_idx0, alu_mul_dest_pr_idx0);
			$display("cre_alu_mul_func0: %d	alu_mul_func0: %d\n", cre_alu_mul_func0, alu_mul_func0);

			$display("cre_alu_mul_rd_mem0: %d	alu_mul_rd_mem0: %d\n", cre_alu_mul_rd_mem0, alu_mul_rd_mem0);
			$display("cre_alu_mul_wr_mem0: %d	alu_mul_wr_mem0: %d\n", cre_alu_mul_wr_mem0, alu_mul_wr_mem0);

			$display("cre_alu_mul_cond_branch0: %d	alu_mul_cond_branch0: %d\n", cre_alu_mul_cond_branch0, alu_mul_cond_branch0);
			$display("cre_alu_mul_uncond_branch0: %d	alu_mul_uncond_branch0: %d\n", cre_alu_mul_uncond_branch0, alu_mul_uncond_branch0);
			$display("cre_alu_mul_halt0: %d	alu_mul_halt0: %d\n", cre_alu_mul_halt0, alu_mul_halt0);

			$display("cre_alu_mul_illegal_inst0: %d	alu_mul_illegal_inst0: %d\n", cre_alu_mul_illegal_inst0, alu_mul_illegal_inst0);
			$display("cre_alu_mul_valid_inst0: %d	alu_mul_valid_inst0: %d\n", cre_alu_mul_valid_inst0, alu_mul_valid_inst0);
			correct = 0;
		end
	end
  if (cre_alu_mul_valid_inst1) begin
	  if (
		cre_alu_mul_NPC1 != alu_mul_NPC1 ||
		cre_alu_mul_IR1 != alu_mul_NPC1 ||

		cre_alu_mul_branch_taken1 != alu_mul_branch_taken1 ||
		cre_alu_mul_pred_addr1 != alu_mul_pred_addr1 ||

		cre_alu_mul_prf_pra_idx1 != alu_mul_prf_pra_idx1 ||
		cre_alu_mul_prf_prb_idx1 != alu_mul_prf_prb_idx1 ||

		cre_alu_mul_opa_select1 != alu_mul_opa_select1 ||
		cre_alu_mul_opb_select1 != alu_mul_opb_select1 ||

		cre_alu_mul_dest_ar_idx1 != alu_mul_dest_ar_idx1 ||
		cre_alu_mul_dest_pr_idx1 != alu_mul_dest_pr_idx1 ||
		cre_alu_mul_func1 != alu_mul_func1 ||

		cre_alu_mul_rd_mem1 != alu_mul_rd_mem1 ||
		cre_alu_mul_wr_mem1 != alu_mul_wr_mem1 ||

		cre_alu_mul_cond_branch1 != alu_mul_cond_branch1 ||
		cre_alu_mul_uncond_branch1 != alu_mul_uncond_branch1 ||
		cre_alu_mul_halt1 != alu_mul_halt1 ||

		cre_alu_mul_illegal_inst1 != alu_mul_illegal_inst1 ||
		cre_alu_mul_valid_inst1 != alu_mul_valid_inst1
		) begin
			$display("!!ERROR!! simple mul1 encountered an error!~");
	    
	    $display("cre_alu_mul_NPC1: %d	alu_mul_NPC1: %d\n", cre_alu_mul_NPC1, alu_mul_NPC1);
			$display("cre_alu_mul_IR1: %d	alu_mul_NPC1: %d\n", cre_alu_mul_IR1, alu_mul_NPC1);

			$display("cre_alu_mul_branch_taken1: %d	alu_mul_branch_taken1: %d\n", cre_alu_mul_branch_taken1, alu_mul_branch_taken1);
			$display("cre_alu_mul_pred_addr1: %d	alu_mul_pred_addr1: %d\n", cre_alu_mul_pred_addr1, alu_mul_pred_addr1);

			$display("cre_alu_mul_prf_pra_idx1: %d	alu_mul_prf_pra_idx1: %d\n", cre_alu_mul_prf_pra_idx1, alu_mul_prf_pra_idx1);
			$display("cre_alu_mul_prf_prb_idx1: %d	alu_mul_prf_prb_idx1: %d\n", cre_alu_mul_prf_prb_idx1, alu_mul_prf_prb_idx1);

			$display("cre_alu_mul_opa_select1: %d	alu_mul_opa_select1: %d\n", cre_alu_mul_opa_select1, alu_mul_opa_select1);
			$display("cre_alu_mul_opb_select1: %d	alu_mul_opb_select1: %d\n", cre_alu_mul_opb_select1, alu_mul_opb_select1);

			$display("cre_alu_mul_dest_ar_idx1: %d	alu_mul_dest_ar_idx1: %d\n", cre_alu_mul_dest_ar_idx1, alu_mul_dest_ar_idx1);
			$display("cre_alu_mul_dest_pr_idx1: %d	alu_mul_dest_pr_idx1: %d\n", cre_alu_mul_dest_pr_idx1, alu_mul_dest_pr_idx1);
			$display("cre_alu_mul_func1: %d	alu_mul_func1: %d\n", cre_alu_mul_func1, alu_mul_func1);

			$display("cre_alu_mul_rd_mem1: %d	alu_mul_rd_mem1: %d\n", cre_alu_mul_rd_mem1, alu_mul_rd_mem1);
			$display("cre_alu_mul_wr_mem1: %d	alu_mul_wr_mem1: %d\n", cre_alu_mul_wr_mem1, alu_mul_wr_mem1);

			$display("cre_alu_mul_cond_branch1: %d	alu_mul_cond_branch1: %d\n", cre_alu_mul_cond_branch1, alu_mul_cond_branch1);
			$display("cre_alu_mul_uncond_branch1: %d	alu_mul_uncond_branch1: %d\n", cre_alu_mul_uncond_branch1, alu_mul_uncond_branch1);
			$display("cre_alu_mul_halt1: %d	alu_mul_halt1: %d\n", cre_alu_mul_halt1, alu_mul_halt1);

			$display("cre_alu_mul_illegal_inst1: %d	alu_mul_illegal_inst1: %d\n", cre_alu_mul_illegal_inst1, alu_mul_illegal_inst1);
			$display("cre_alu_mul_valid_inst1: %d	alu_mul_valid_inst1: %d\n", cre_alu_mul_valid_inst1, alu_mul_valid_inst1);
	    correct = 0;
	  end
	end
  if (cre_alu_mem_valid_inst0) begin
	  if (
		cre_alu_mem_NPC0 != alu_mem_NPC0 ||
		cre_alu_mem_IR0 != alu_mem_IR0 ||

		cre_alu_mem_branch_taken0 != alu_mem_branch_taken0 ||
		cre_alu_mem_pred_addr0 != alu_mem_pred_addr0 ||

		cre_alu_mem_prf_pra_idx0 != alu_mem_prf_pra_idx0 ||
		cre_alu_mem_prf_prb_idx0 != alu_mem_prf_prb_idx0 ||

		cre_alu_mem_opa_select0 != alu_mem_opa_select0 ||
		cre_alu_mem_opb_select0 != alu_mem_opb_select0 ||

		cre_alu_mem_dest_ar_idx0 != alu_mem_dest_ar_idx0 ||
		cre_alu_mem_dest_pr_idx0 != alu_mem_dest_pr_idx0 ||
		cre_alu_mem_func0 != alu_mem_func0 ||

		cre_alu_mem_rd_mem0 != alu_mem_rd_mem0 ||
		cre_alu_mem_wr_mem0 != alu_mem_wr_mem0 ||

		cre_alu_mem_cond_branch0 != alu_mem_cond_branch0 ||
		cre_alu_mem_uncond_branch0 != alu_mem_uncond_branch0 ||
		cre_alu_mem_halt0 != alu_mem_halt0 ||

		cre_alu_mem_illegal_inst0 != alu_mem_illegal_inst0 ||
		cre_alu_mem_valid_inst0 != alu_mem_valid_inst0
		) begin
	    $display("!!ERROR!! simple mem0 encountered an error!~");

			$display("cre_alu_mem_NPC0: %d	alu_mem_NPC0: %d\n", cre_alu_mem_NPC0, alu_mem_NPC0);
			$display("cre_alu_mem_IR0: %d	alu_mem_IR0: %d\n", cre_alu_mem_IR0, alu_mem_IR0);

			$display("cre_alu_mem_branch_taken0: %d	alu_mem_branch_taken0: %d\n", cre_alu_mem_branch_taken0, alu_mem_branch_taken0);
			$display("cre_alu_mem_pred_addr0: %d	alu_mem_pred_addr0: %d\n", cre_alu_mem_pred_addr0, alu_mem_pred_addr0);

			$display("cre_alu_mem_prf_pra_idx0: %d	alu_mem_prf_pra_idx0: %d\n", cre_alu_mem_prf_pra_idx0, alu_mem_prf_pra_idx0);
			$display("cre_alu_mem_prf_prb_idx0: %d	alu_mem_prf_prb_idx0: %d\n", cre_alu_mem_prf_prb_idx0, alu_mem_prf_prb_idx0);

			$display("cre_alu_mem_opa_select0: %d	alu_mem_opa_select0: %d\n", cre_alu_mem_opa_select0, alu_mem_opa_select0);
			$display("cre_alu_mem_opb_select0: %d	alu_mem_opb_select0: %d\n", cre_alu_mem_opb_select0, alu_mem_opb_select0);

			$display("cre_alu_mem_dest_ar_idx0: %d	alu_mem_dest_ar_idx0: %d\n", cre_alu_mem_dest_ar_idx0, alu_mem_dest_ar_idx0);
			$display("cre_alu_mem_dest_pr_idx0: %d	alu_mem_dest_pr_idx0: %d\n", cre_alu_mem_dest_pr_idx0, alu_mem_dest_pr_idx0);
			$display("cre_alu_mem_func0: %d	alu_mem_func0: %d\n", cre_alu_mem_func0, alu_mem_func0);

			$display("cre_alu_mem_rd_mem0: %d	alu_mem_rd_mem0: %d\n", cre_alu_mem_rd_mem0, alu_mem_rd_mem0);
			$display("cre_alu_mem_wr_mem0: %d	alu_mem_wr_mem0: %d\n", cre_alu_mem_wr_mem0, alu_mem_wr_mem0);

			$display("cre_alu_mem_cond_branch0: %d	alu_mem_cond_branch0: %d\n", cre_alu_mem_cond_branch0, alu_mem_cond_branch0);
			$display("cre_alu_mem_uncond_branch0: %d	alu_mem_uncond_branch0: %d\n", cre_alu_mem_uncond_branch0, alu_mem_uncond_branch0);
			$display("cre_alu_mem_halt0: %d	alu_mem_halt0: %d\n", cre_alu_mem_halt0, alu_mem_halt0);

			$display("cre_alu_mem_illegal_inst0: %d	alu_mem_illegal_inst0: %d\n", cre_alu_mem_illegal_inst0, alu_mem_illegal_inst0);
			$display("cre_alu_mem_valid_inst0: %d	alu_mem_valid_inst0: %d\n", cre_alu_mem_valid_inst0, alu_mem_valid_inst0);
	    correct = 0;
	   end
	end
  if (cre_alu_mem_valid_inst1) begin
	  if (
		cre_alu_mem_NPC1 != alu_mem_NPC1 ||
		cre_alu_mem_IR1 != alu_mem_IR1 ||

		cre_alu_mem_branch_taken1 != alu_mem_branch_taken1 ||
		cre_alu_mem_pred_addr1 != alu_mem_pred_addr1 ||

		cre_alu_mem_prf_pra_idx1 != alu_mem_prf_pra_idx1 ||
		cre_alu_mem_prf_prb_idx1 != alu_mem_prf_prb_idx1 ||

		cre_alu_mem_opa_select1 != alu_mem_opa_select1 ||
		cre_alu_mem_opb_select1 != alu_mem_opb_select1 ||

		cre_alu_mem_dest_ar_idx1 != alu_mem_dest_ar_idx1 ||
		cre_alu_mem_dest_pr_idx1 != alu_mem_dest_pr_idx1 ||
		cre_alu_mem_func1 != alu_mem_func1 ||

		cre_alu_mem_rd_mem1 != alu_mem_rd_mem1 ||
		cre_alu_mem_wr_mem1 != alu_mem_wr_mem1 ||

		cre_alu_mem_cond_branch1 != alu_mem_cond_branch1 ||
		cre_alu_mem_uncond_branch1 != alu_mem_uncond_branch1 ||
		cre_alu_mem_halt1 != alu_mem_halt1 ||

		cre_alu_mem_illegal_inst1 != alu_mem_illegal_inst1 ||
		cre_alu_mem_valid_inst1 != alu_mem_valid_inst1
		) begin
	    $display("!!ERROR!! simple mem1 encountered an error!~");

			$display("cre_alu_mem_NPC1: %d	alu_mem_NPC1: %d\n", cre_alu_mem_NPC1, alu_mem_NPC1);
			$display("cre_alu_mem_IR1: %d	alu_mem_IR1: %d\n", cre_alu_mem_IR1, alu_mem_IR1);

			$display("cre_alu_mem_branch_taken1: %d	alu_mem_branch_taken1: %d\n", cre_alu_mem_branch_taken1, alu_mem_branch_taken1);
			$display("cre_alu_mem_pred_addr1: %d	alu_mem_pred_addr1: %d\n", cre_alu_mem_pred_addr1, alu_mem_pred_addr1);

			$display("cre_alu_mem_prf_pra_idx1: %d	alu_mem_prf_pra_idx1: %d\n", cre_alu_mem_prf_pra_idx1, alu_mem_prf_pra_idx1);
			$display("cre_alu_mem_prf_prb_idx1: %d	alu_mem_prf_prb_idx1: %d\n", cre_alu_mem_prf_prb_idx1, alu_mem_prf_prb_idx1);

			$display("cre_alu_mem_opa_select1: %d	alu_mem_opa_select1: %d\n", cre_alu_mem_opa_select1, alu_mem_opa_select1);
			$display("cre_alu_mem_opb_select1: %d	alu_mem_opb_select1: %d\n", cre_alu_mem_opb_select1, alu_mem_opb_select1);

			$display("cre_alu_mem_dest_ar_idx1: %d	alu_mem_dest_ar_idx1: %d\n", cre_alu_mem_dest_ar_idx1, alu_mem_dest_ar_idx1);
			$display("cre_alu_mem_dest_pr_idx1: %d	alu_mem_dest_pr_idx1: %d\n", cre_alu_mem_dest_pr_idx1, alu_mem_dest_pr_idx1);
			$display("cre_alu_mem_func1: %d	alu_mem_func1: %d\n", cre_alu_mem_func1, alu_mem_func1);

			$display("cre_alu_mem_rd_mem1: %d	alu_mem_rd_mem1: %d\n", cre_alu_mem_rd_mem1, alu_mem_rd_mem1);
			$display("cre_alu_mem_wr_mem1: %d	alu_mem_wr_mem1: %d\n", cre_alu_mem_wr_mem1, alu_mem_wr_mem1);

			$display("cre_alu_mem_cond_branch1: %d	alu_mem_cond_branch1: %d\n", cre_alu_mem_cond_branch1, alu_mem_cond_branch1);
			$display("cre_alu_mem_uncond_branch1: %d	alu_mem_uncond_branch1: %d\n", cre_alu_mem_uncond_branch1, alu_mem_uncond_branch1);
			$display("cre_alu_mem_halt1: %d	alu_mem_halt1: %d\n", cre_alu_mem_halt1, alu_mem_halt1);

			$display("cre_alu_mem_illegal_inst1: %d	alu_mem_illegal_inst1: %d\n", cre_alu_mem_illegal_inst1, alu_mem_illegal_inst1);
			$display("cre_alu_mem_valid_inst1: %d	alu_mem_valid_inst1: %d\n", cre_alu_mem_valid_inst1, alu_mem_valid_inst1);
   		correct = 0;
  	end
  end

	if ((id_rs_cap != cre_id_rs_cap) || (cre_if_inst_need_num != if_inst_need_num)) begin
		$display("!!!!!!ERROR!!! RS or ID entry number is not correct!!!\n");
		
		$display("cre_id_rs_cap: %d\tid_rs_cap:%d\n", cre_id_rs_cap, id_rs_cap);
		$display("cre_if_inst_need_num: %d\tif_inst_need_num: %d\n", cre_if_inst_need_num, if_inst_need_num);
		correct = 0;
	end
	
  if (~correct) begin
		$display("*** Incorrect at time %4.0f\n", $time);
		$finish;
	end

end


  // Generate System Clock
always
  begin
    #5;
    clock = ~clock;
  end

initial begin

  //$vcdpluson;
	$monitor("Time:%4.0f \n",$time);

///////////////////////////////////////////origin inputs
	correct = 1;
	clock = 0;
	reset = 0;

///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 0; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
					mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
					mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 0;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Issue wires
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 = 0;
	cre_alu_sim_IR1 = 0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;

	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;

	cre_alu_mul_NPC0 = 0;
	cre_alu_mul_NPC1 = 0;
	cre_alu_mul_IR0 = 0;
	cre_alu_mul_IR1 = 0;

	cre_alu_mul_branch_taken0 = 0;
	cre_alu_mul_branch_taken1 = 0;
	cre_alu_mul_pred_addr0 = 0;
	cre_alu_mul_pred_addr1 = 0;

	cre_alu_mul_prf_pra_idx0 = 0;
	cre_alu_mul_prf_pra_idx1 = 0;
	cre_alu_mul_prf_prb_idx0 = 0;
	cre_alu_mul_prf_prb_idx1 = 0;

	cre_alu_mul_opa_select0 = 0;
	cre_alu_mul_opa_select1 = 0;
	cre_alu_mul_opb_select0 = 0;
	cre_alu_mul_opb_select1 = 0;

	cre_alu_mul_dest_ar_idx0 = 0;
	cre_alu_mul_dest_ar_idx1 = 0;
	cre_alu_mul_dest_pr_idx0 = 0;
	cre_alu_mul_dest_pr_idx1 = 0;
	cre_alu_mul_func0 = 0;
	cre_alu_mul_func1 = 0;

	cre_alu_mul_rd_mem0 = 0;
	cre_alu_mul_rd_mem1 = 0;
	cre_alu_mul_wr_mem0 = 0;
	cre_alu_mul_wr_mem1 = 0;

	cre_alu_mul_cond_branch0 = 0;
	cre_alu_mul_cond_branch1 = 0;
	cre_alu_mul_uncond_branch0 = 0;
	cre_alu_mul_uncond_branch1 = 0;
	cre_alu_mul_halt0 = 0;
	cre_alu_mul_halt1 = 0;

	cre_alu_mul_illegal_inst0 = 0;
	cre_alu_mul_illegal_inst1 = 0;
	cre_alu_mul_valid_inst0 = 0;
	cre_alu_mul_valid_inst1 = 0;

	cre_alu_mem_NPC0 = 0;
	cre_alu_mem_NPC1 = 0;
	cre_alu_mem_IR0 = 0;
	cre_alu_mem_IR1 = 0;

	cre_alu_mem_branch_taken0 = 0;
	cre_alu_mem_branch_taken1 = 0;
	cre_alu_mem_pred_addr0 = 0;
	cre_alu_mem_pred_addr1 = 0;

	cre_alu_mem_prf_pra_idx0 = 0;
	cre_alu_mem_prf_pra_idx1 = 0;
	cre_alu_mem_prf_prb_idx0 = 0;
	cre_alu_mem_prf_prb_idx1 = 0;

	cre_alu_mem_opa_select0 = 0;
	cre_alu_mem_opa_select1 = 0;
	cre_alu_mem_opb_select0 = 0;
	cre_alu_mem_opb_select1 = 0;

	cre_alu_mem_dest_ar_idx0 = 0;
	cre_alu_mem_dest_ar_idx1 = 0;
	cre_alu_mem_dest_pr_idx0 = 0;
	cre_alu_mem_dest_pr_idx1 = 0;
	cre_alu_mem_func0 = 0;
	cre_alu_mem_func1 = 0;

	cre_alu_mem_rd_mem0 = 0;
	cre_alu_mem_rd_mem1 = 0;
	cre_alu_mem_wr_mem0 = 0;
	cre_alu_mem_wr_mem1 = 0;

	cre_alu_mem_cond_branch0 = 0;
	cre_alu_mem_cond_branch1 = 0;
	cre_alu_mem_uncond_branch0 = 0;
	cre_alu_mem_uncond_branch1 = 0;
	cre_alu_mem_halt0 = 0;
	cre_alu_mem_halt1 = 0;

	cre_alu_mem_illegal_inst0 = 0;
	cre_alu_mem_illegal_inst1 = 0;
	cre_alu_mem_valid_inst0 = 0;
	cre_alu_mem_valid_inst1 = 0;

	cre_if_inst_need_num = 0;

//test reset and 1 dispatch with 0 retire.
@(negedge clock);
	reset = 1;
	cre_if_inst_need_num = 2;
	cre_id_rs_cap = 2;
@(negedge clock);
	reset = 0;
@(negedge clock); ////First test case for simple ALU;	#1
//////////////////////Checks 2 dispatch and issue 1 by 1.
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010402;
	if_IR1 = 32'h40010402;
	if_valid_inst0 = 1;
	if_valid_inst1 = 1;
	if_NPC0 = 0;
	if_NPC1 = 4;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 0;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 = 0;
	cre_alu_sim_IR1 = 0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
@(negedge clock); ////First test case for simple ALU; #2
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 2;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 1;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 5;
	mt_pra_idx1 = 3;
	mt_prb_idx1 = 4;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 = 32'h40010402;
	cre_alu_sim_IR1 = 0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 1;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 2;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 2;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
@(negedge clock); ////First test case for simple ALU; #3 // $1 and $2 have
//been broadcasted and they would be set ready on the next clocking edge, which means
//the instruction would be issued next cycle.
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000011;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 1;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 = 32'h40010402;
	cre_alu_sim_IR1 = 0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 1;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 2;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 2;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;//as this is set for the next cycle.
	cre_alu_sim_valid_inst1 = 0;
@(negedge clock); ////First test case for simple ALU; #4
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000011;
	cdb_pr_tag0 = 3;
	cdb_pr_tag1 = 4;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 4;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 = 32'h40010402;
	cre_alu_sim_IR1 = 0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 3;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 4;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 2;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 5;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;
	cre_alu_sim_valid_inst1 = 0;
@(negedge clock);
	cre_alu_sim_valid_inst0 = 0;
//----------------------------------------------------------------------------------2nd test case
@(negedge clock); ////2nd test case for simple ALU; #5
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010402;
	if_IR1 = 32'h40010402;
	if_valid_inst0 = 1;
	if_valid_inst1 = 1;
	if_NPC0 = 4;
	if_NPC1 = 8;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 = 0;
	cre_alu_sim_IR1 = 0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
@(negedge clock); ////2nd test case for simple ALU; #6
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 3;
	mt_pra_idx0 = 1;
	mt_prb_idx0 = 2;
	mt_pra_ready0 = 1; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 1;

	fl_pr_dest_idx1 = 6;
	mt_pra_idx1 = 4;
	mt_prb_idx1 = 5;
	mt_pra_ready1 = 1; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 1;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 4;
	cre_alu_sim_NPC1 = 8;
	cre_alu_sim_IR0 = 32'h40010402;
	cre_alu_sim_IR1 = 32'h40010402;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 1;
	cre_alu_sim_prf_pra_idx1 = 4;
	cre_alu_sim_prf_prb_idx0 = 2;
	cre_alu_sim_prf_prb_idx1 = 5;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = `ALU_OPB_IS_REGB;

	cre_alu_sim_dest_ar_idx0 = 2;
	cre_alu_sim_dest_ar_idx1 = 2;
	cre_alu_sim_dest_pr_idx0 = 3;
	cre_alu_sim_dest_pr_idx1 = 6;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = `ALU_ADDQ;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;
	cre_alu_sim_valid_inst1 = 1;
	
@(negedge clock); ////Reset everything.
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
@(negedge clock); ////Supertest insert instructions 0     1
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010400;
	if_IR1 = 32'h40010401;
	if_valid_inst0 = 1;
	if_valid_inst1 = 1;
	if_NPC0 = 0;
	if_NPC1 = 4;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;

	cre_if_inst_need_num = 2;

@(negedge clock); ////Supertest insert instructions 0 2   1
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010402;
	if_IR1 = 0;
	if_valid_inst0 = 1;
	if_valid_inst1 = 0;
	if_NPC0 = 8;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 10;
	mt_prb_idx0 = 11;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 1;
	mt_pra_idx1 = 12;
	mt_prb_idx1 = 13;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 2;
	
@(negedge clock); ////Supertest insert instructions 0 2   1 Finish
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 2;
	mt_pra_idx0 = 14;
	mt_prb_idx0 = 15;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 1;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 2;

@(negedge clock); ////Supertest Start! Give ins 3 4 to id
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010403;
	if_IR1 = 32'h40010404;
	if_valid_inst0 = 1;
	if_valid_inst1 = 1;
	if_NPC0 = 12;
	if_NPC1 = 16;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 1;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 1;

@(negedge clock); ////Supertest 1#! Give ins 5 to id
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010405;
	if_IR1 = 0;
	if_valid_inst0 = 1;
	if_valid_inst1 = 0;
	if_NPC0 = 20;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 3;
	mt_pra_idx0 = 16;
	mt_prb_idx0 = 17;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 0;
	
@(negedge clock); ////Supertest 2#! Ready ins #2 and dispatch it!
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000011;
	cdb_pr_tag0 = 14;
	cdb_pr_tag1 = 15;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Sim outputs
	cre_alu_sim_NPC0 = 8;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  32'h40010402;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 14;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 15;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 2;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 2;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 0;

@(negedge clock); ////Supertest 3#! ins #2 is issued
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 1;

// Sim outputs
	cre_alu_sim_NPC0 = 8;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  32'h40010402;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 14;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 15;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 2;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 2;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 1;
	
@(negedge clock); ////Supertest 4#! Give ins 6 to id
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 32'h40010406;
	if_IR1 = 0;
	if_valid_inst0 = 1;
	if_valid_inst1 = 0;
	if_NPC0 = 24;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 4;
	mt_pra_idx0 = 18;
	mt_prb_idx0 = 19;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 0;
	
@(negedge clock); ////Supertest 5#! Ready ins #4 & #1 and issue them on the rising clock
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b001111;
	cdb_pr_tag0 = 12;
	cdb_pr_tag1 = 13;
	cdb_pr_tag2 = 18;
	cdb_pr_tag3 = 19;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Sim outputs
	cre_alu_sim_NPC0 = 16;
	cre_alu_sim_NPC1 = 4;
	cre_alu_sim_IR0 =  32'h40010404;
	cre_alu_sim_IR1 =  32'h40010401;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 18;
	cre_alu_sim_prf_pra_idx1 = 12;
	cre_alu_sim_prf_prb_idx0 = 19;
	cre_alu_sim_prf_prb_idx1 = 13;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = `ALU_OPB_IS_REGB;

	cre_alu_sim_dest_ar_idx0 = 4;
	cre_alu_sim_dest_ar_idx1 = 1;
	cre_alu_sim_dest_pr_idx0 = 4;
	cre_alu_sim_dest_pr_idx1 = 1;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = `ALU_ADDQ;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;
	cre_alu_sim_valid_inst1 = 1;
	
	cre_if_inst_need_num = 0;

@(negedge clock); ////Supertest 6#! stop feeding. Entries #2 & #0 are emptied.
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 16;
	cre_alu_sim_NPC1 = 4;
	cre_alu_sim_IR0 =  32'h40010404;
	cre_alu_sim_IR1 =  32'h40010401;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 18;
	cre_alu_sim_prf_pra_idx1 = 14;
	cre_alu_sim_prf_prb_idx0 = 19;
	cre_alu_sim_prf_prb_idx1 = 15;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = `ALU_OPB_IS_REGB;

	cre_alu_sim_dest_ar_idx0 = 4;
	cre_alu_sim_dest_ar_idx1 = 1;
	cre_alu_sim_dest_pr_idx0 = 4;
	cre_alu_sim_dest_pr_idx1 = 1;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = `ALU_ADDQ;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 2;

@(negedge clock); ////Supertest 7#! ins #5 & #6 would then be sent in to RS. Ready half of the instructions of 0 5 3 6
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 5;
	mt_pra_idx0 = 20;
	mt_prb_idx0 = 21;
	mt_pra_ready0 = 1; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 6;
	mt_pra_idx1 = 22;
	mt_prb_idx1 = 23;
	mt_pra_ready1 = 1; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000101;
	cdb_pr_tag0 = 10;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 16;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 0;
	cre_alu_sim_IR0 =  0;
	cre_alu_sim_IR1 =  0;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 0;
	cre_alu_sim_prf_pra_idx1 = 0;
	cre_alu_sim_prf_prb_idx0 = 0;
	cre_alu_sim_prf_prb_idx1 = 0;

	cre_alu_sim_opa_select0 = 0;
	cre_alu_sim_opa_select1 = 0;
	cre_alu_sim_opb_select0 = 0;
	cre_alu_sim_opb_select1 = 0;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 0;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 0;
	cre_alu_sim_func0 = 0;
	cre_alu_sim_func1 = 0;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 0;
	cre_alu_sim_valid_inst1 = 0;
	
	cre_if_inst_need_num = 2;
	
@(negedge clock); ////Supertest 8#! Ready the other half of the instructions of 0 5 3 6 and 0 6 is issued(on the rising edge).
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b001111;
	cdb_pr_tag0 = 11;
	cdb_pr_tag1 = 21;
	cdb_pr_tag2 = 17;
	cdb_pr_tag3 = 23;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 0;

// Sim outputs
	cre_alu_sim_NPC0 = 0;
	cre_alu_sim_NPC1 = 24;
	cre_alu_sim_IR0 =  32'h40010400;
	cre_alu_sim_IR1 =  32'h40010406;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 10;
	cre_alu_sim_prf_pra_idx1 = 22;
	cre_alu_sim_prf_prb_idx0 = 11;
	cre_alu_sim_prf_prb_idx1 = 23;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = `ALU_OPB_IS_REGB;

	cre_alu_sim_dest_ar_idx0 = 0;
	cre_alu_sim_dest_ar_idx1 = 6;
	cre_alu_sim_dest_pr_idx0 = 0;
	cre_alu_sim_dest_pr_idx1 = 6;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = `ALU_ADDQ;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;
	cre_alu_sim_valid_inst1 = 1;
	
	cre_if_inst_need_num = 2;

@(negedge clock); ////Supertest 9#! issue 5 3
///////////////////////////////////////////origin inputs
///input of id//////////////////////////////////////////////////////////
	if_IR0 = 0;
	if_IR1 = 0;
	if_valid_inst0 = 0;
	if_valid_inst1 = 0;
	if_NPC0 = 0;
	if_NPC1 = 0;

	if_branch_taken0 = 0;
	if_branch_taken1 = 0;
	if_pred_addr0 = 0;
	if_pred_addr1 = 0;

	rob_cap = 2; // rob capacity

///input of other signal for rs/////////////////////////////////////////
	fl_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0 = 0;

	fl_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 2'b11; // For the simple calculations
	alu_mul_avail = 0; // For the multiplication unit
	alu_mem_avail = 0; // For access the memory

// Complete inputs
	cdb_broadcast = 6'b000000;
	cdb_pr_tag0 = 0;
	cdb_pr_tag1 = 0;
	cdb_pr_tag2 = 0;
	cdb_pr_tag3 = 0;
	cdb_pr_tag4 = 0;
	cdb_pr_tag5 = 0;

/////////////////////////////////////////correct output
	cre_id_rs_cap = 2;

// Sim outputs
	cre_alu_sim_NPC0 = 20;
	cre_alu_sim_NPC1 = 12;
	cre_alu_sim_IR0 =  32'h40010405;
	cre_alu_sim_IR1 =  32'h40010403;

	cre_alu_sim_branch_taken0 = 0;
	cre_alu_sim_branch_taken1 = 0;
	cre_alu_sim_pred_addr0 = 0;
	cre_alu_sim_pred_addr1 = 0;

	cre_alu_sim_prf_pra_idx0 = 20;
	cre_alu_sim_prf_pra_idx1 = 16;
	cre_alu_sim_prf_prb_idx0 = 21;
	cre_alu_sim_prf_prb_idx1 = 17;

	cre_alu_sim_opa_select0 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opa_select1 = `ALU_OPA_IS_REGA;
	cre_alu_sim_opb_select0 = `ALU_OPB_IS_REGB;
	cre_alu_sim_opb_select1 = `ALU_OPB_IS_REGB;

	cre_alu_sim_dest_ar_idx0 = 5;
	cre_alu_sim_dest_ar_idx1 = 3;
	cre_alu_sim_dest_pr_idx0 = 5;
	cre_alu_sim_dest_pr_idx1 = 3;
	cre_alu_sim_func0 = `ALU_ADDQ;
	cre_alu_sim_func1 = `ALU_ADDQ;

	cre_alu_sim_rd_mem0 = 0;
	cre_alu_sim_rd_mem1 = 0;
	cre_alu_sim_wr_mem0 = 0;
	cre_alu_sim_wr_mem1 = 0;
	cre_alu_sim_cond_branch0 = 0;
	cre_alu_sim_cond_branch1 = 0;
	cre_alu_sim_uncond_branch0 = 0;
	cre_alu_sim_uncond_branch1 = 0;
	cre_alu_sim_halt0 = 0;
	cre_alu_sim_halt1 = 0;

	cre_alu_sim_illegal_inst0 = 0;
	cre_alu_sim_illegal_inst1 = 0;
	cre_alu_sim_valid_inst0 = 1;
	cre_alu_sim_valid_inst1 = 1;
	
	cre_if_inst_need_num = 2;

@(negedge clock);
$finish;
end

endmodule


