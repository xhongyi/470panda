module testbench;

reg					clock;
reg					reset;

reg	 [63:0]	id_NPC0;
reg	 [31:0]	id_IR0;
reg					id_branch_taken0;
reg	 [63:0]	id_pred_addr0;
reg		[1:0]	id_opa_select0;
reg		[1:0]	id_opb_select0;
reg		[4:0]	id_dest_idx0;
reg		[4:0]	id_alu_func0;
reg					id_rd_mem0;
reg					id_wr_mem0;
reg					id_cond_branch0;
reg					id_uncond_branch0;
reg					id_halt0;
reg					id_illegal_inst0;
reg					id_valid_inst0;


reg	 [63:0]	id_NPC1;
reg	 [31:0]	id_IR1;
reg					id_branch_taken1;
reg	 [63:0]	id_pred_addr1;
reg		[1:0]	id_opa_select1;
reg		[1:0]	id_opb_select1;
reg		[4:0]	id_dest_idx1;
reg		[4:0]	id_alu_func1;
reg					id_rd_mem1;
reg					id_wr_mem1;
reg					id_cond_branch1;
reg					id_uncond_branch1;
reg					id_halt1;
reg					id_illegal_inst1;
reg					id_valid_inst1;

reg		[1:0]	id_dispatch_num;

reg		[6:0]	mt_pr_dest_idx0;
reg		[6:0]	mt_pra_idx0;
reg		[6:0]	mt_prb_idx0;
reg					mt_pra_ready0; // *** If the reg is not valid, it is ready ***
reg					mt_prb_ready0;

reg		[6:0]	mt_pr_dest_idx1;
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

//correct values///////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////////////


always @(posedge clock) begin
  #2
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
    $display("Incorrect at time %4.0f",$time);
    $display("!!ERROR!! simple alu0 encountered an error!~")
    $display("
				cre_alu_sim_NPC0: %d   alu_sim_NPC0: %d\n
				cre_alu_sim_IR0: %d   alu_sim_IR0: %d\n

				cre_alu_sim_branch_taken0: %d   alu_sim_branch_taken0: %d\n
				cre_alu_sim_pred_addr0: %d   alu_sim_pred_addr0: %d\n

				cre_alu_sim_prf_pra_idx0: %d   alu_sim_prf_pra_idx0: %d\n
				cre_alu_sim_prf_prb_idx0: %d   alu_sim_prf_prb_idx0: %d\n

				cre_alu_sim_opa_select0: %d   alu_sim_opa_select0: %d\n
				cre_alu_sim_opb_select0: %d   alu_sim_opb_select0: %d\n

				cre_alu_sim_dest_ar_idx0: %d   alu_sim_dest_ar_idx0: %d\n
				cre_alu_sim_dest_pr_idx0: %d   alu_sim_dest_pr_idx0: %d\n
				cre_alu_sim_func0: %d   alu_sim_func0: %d\n

				cre_alu_sim_rd_mem0: %d   alu_sim_rd_mem0: %d\n
				cre_alu_sim_wr_mem0: %d   alu_sim_wr_mem0: %d\n

				cre_alu_sim_cond_branch0: %d   alu_sim_cond_branch0: %d\n
				cre_alu_sim_uncond_branch0: %d   alu_sim_uncond_branch0: %d\n
				cre_alu_sim_halt0: %d   alu_sim_halt0: %d\n

				cre_alu_sim_illegal_inst0: %d   alu_sim_illegal_inst0: %d\n
				cre_alu_sim_valid_inst0: %d   alu_sim_valid_inst0: %d\n
						);
    $finish;
	end
	else if (
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
    $display("Incorrect at time %4.0f",$time);
    $display("!!ERROR!! simple alu1 encountered an error!~")
    $display("
				cre_alu_sim_NPC1: %d   alu_sim_NPC1: %d\n
				cre_alu_sim_IR1: %d   alu_sim_IR1: %d\n

				cre_alu_sim_branch_taken1: %d   alu_sim_branch_taken1: %d\n
				cre_alu_sim_pred_addr1: %d   alu_sim_pred_addr1: %d\n

				cre_alu_sim_prf_pra_idx1: %d   alu_sim_prf_pra_idx1: %d\n
				cre_alu_sim_prf_prb_idx1: %d   alu_sim_prf_prb_idx1: %d\n

				cre_alu_sim_opa_select1: %d   alu_sim_opa_select1: %d\n
				cre_alu_sim_opb_select1: %d   alu_sim_opb_select1: %d\n

				cre_alu_sim_dest_ar_idx1: %d   alu_sim_dest_ar_idx1: %d\n
				cre_alu_sim_dest_pr_idx1: %d   alu_sim_dest_pr_idx1: %d\n
				cre_alu_sim_func1: %d   alu_sim_func1: %d\n

				cre_alu_sim_rd_mem1: %d   alu_sim_rd_mem1: %d\n
				cre_alu_sim_wr_mem1: %d   alu_sim_wr_mem1: %d\n

				cre_alu_sim_cond_branch1: %d   alu_sim_cond_branch1: %d\n
				cre_alu_sim_uncond_branch1: %d   alu_sim_uncond_branch1: %d\n
				cre_alu_sim_halt1: %d   alu_sim_halt1: %d\n

				cre_alu_sim_illegal_inst1: %d   alu_sim_illegal_inst1: %d\n
				cre_alu_sim_valid_inst1: %d   alu_sim_valid_inst1: %d\n
		);
    $finish;
  end
  else if (
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
    $display("Incorrect at time %4.0f",$time);
    $display("!!ERROR!! simple mul0 encountered an error!~")
    $display("
			cre_alu_mul_NPC0 : %d    alu_mul_NPC0: %d\n
			cre_alu_mul_IR0 : %d    alu_mul_NPC0: %d\n

			cre_alu_mul_branch_taken0 : %d    alu_mul_branch_taken0: %d\n
			cre_alu_mul_pred_addr0 : %d    alu_mul_pred_addr0: %d\n

			cre_alu_mul_prf_pra_idx0 : %d    alu_mul_prf_pra_idx0: %d\n
			cre_alu_mul_prf_prb_idx0 : %d    alu_mul_prf_prb_idx0: %d\n

			cre_alu_mul_opa_select0 : %d    alu_mul_opa_select0: %d\n
			cre_alu_mul_opb_select0 : %d    alu_mul_opb_select0: %d\n

			cre_alu_mul_dest_ar_idx0 : %d    alu_mul_dest_ar_idx0: %d\n
			cre_alu_mul_dest_pr_idx0 : %d    alu_mul_dest_pr_idx0: %d\n
			cre_alu_mul_func0 : %d    alu_mul_func0: %d\n

			cre_alu_mul_rd_mem0 : %d    alu_mul_rd_mem0: %d\n
			cre_alu_mul_wr_mem0 : %d    alu_mul_wr_mem0: %d\n
	
			cre_alu_mul_cond_branch0 : %d    alu_mul_cond_branch0: %d\n
			cre_alu_mul_uncond_branch0 : %d    alu_mul_uncond_branch0: %d\n
			cre_alu_mul_halt0 : %d    alu_mul_halt0: %d\n

			cre_alu_mul_illegal_inst0 : %d    alu_mul_illegal_inst0: %d\n
			cre_alu_mul_valid_inst0 : %d    alu_mul_valid_inst0: %d\n
			);
    $finish;
  end
  else if (
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
    $display("Incorrect at time %4.0f",$time);
    $display("!!ERROR!! simple mul1 encountered an error!~")
    $display("
			cre_alu_mul_NPC1 : %d    alu_mul_NPC1: %d\n
			cre_alu_mul_IR1 : %d    alu_mul_NPC1: %d\n

			cre_alu_mul_branch_taken1 : %d    alu_mul_branch_taken1: %d\n
			cre_alu_mul_pred_addr1 : %d    alu_mul_pred_addr1: %d\n

			cre_alu_mul_prf_pra_idx1 : %d    alu_mul_prf_pra_idx1: %d\n
			cre_alu_mul_prf_prb_idx1 : %d    alu_mul_prf_prb_idx1: %d\n

			cre_alu_mul_opa_select1 : %d    alu_mul_opa_select1: %d\n
			cre_alu_mul_opb_select1 : %d    alu_mul_opb_select1: %d\n

			cre_alu_mul_dest_ar_idx1 : %d    alu_mul_dest_ar_idx1: %d\n
			cre_alu_mul_dest_pr_idx1 : %d    alu_mul_dest_pr_idx1: %d\n
			cre_alu_mul_func1 : %d    alu_mul_func1: %d\n

			cre_alu_mul_rd_mem1 : %d    alu_mul_rd_mem1: %d\n
			cre_alu_mul_wr_mem1 : %d    alu_mul_wr_mem1: %d\n
	
			cre_alu_mul_cond_branch1 : %d    alu_mul_cond_branch1: %d\n
			cre_alu_mul_uncond_branch1 : %d    alu_mul_uncond_branch1: %d\n
			cre_alu_mul_halt1 : %d    alu_mul_halt1: %d\n

			cre_alu_mul_illegal_inst1 : %d    alu_mul_illegal_inst1: %d\n
			cre_alu_mul_valid_inst1 : %d    alu_mul_valid_inst1: %d\n
			);
    $finish;
  end
  else if (
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
    $display("Incorrect at time %4.0f",$time);
    $display("!!ERROR!! simple mem0 encountered an error!~")
    $display("
			cre_alu_mem_NPC0 : %d    alu_mem_NPC0 %d\n 
			cre_alu_mem_IR0 : %d    alu_mem_IR0 %d\n 

			cre_alu_mem_branch_taken0 : %d    alu_mem_branch_taken0 %d\n 
			cre_alu_mem_pred_addr0 : %d    alu_mem_pred_addr0 %d\n 

			cre_alu_mem_prf_pra_idx0 : %d    alu_mem_prf_pra_idx0 %d\n 
			cre_alu_mem_prf_prb_idx0 : %d    alu_mem_prf_prb_idx0 %d\n 

			cre_alu_mem_opa_select0 : %d    alu_mem_opa_select0 %d\n 
			cre_alu_mem_opb_select0 : %d    alu_mem_opb_select0 %d\n 

			cre_alu_mem_dest_ar_idx0 : %d    alu_mem_dest_ar_idx0 %d\n 
			cre_alu_mem_dest_pr_idx0 : %d    alu_mem_dest_pr_idx0 %d\n 
			cre_alu_mem_func0 : %d    alu_mem_func0 %d\n 

			cre_alu_mem_rd_mem0 : %d    alu_mem_rd_mem0 %d\n 
			cre_alu_mem_wr_mem0 : %d    alu_mem_wr_mem0 %d\n 

			cre_alu_mem_cond_branch0 : %d    alu_mem_cond_branch0 %d\n 
			cre_alu_mem_uncond_branch0 : %d    alu_mem_uncond_branch0 %d\n 
			cre_alu_mem_halt0 : %d    alu_mem_halt0 %d\n 

			cre_alu_mem_illegal_inst0 : %d    alu_mem_illegal_inst0 %d\n 
			cre_alu_mem_valid_inst0 : %d    alu_mem_valid_inst0
			);
    $finish;
  end
  else if (
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
    $display("Incorrect at time %4.0f",$time);
    $display("!!ERROR!! simple mem1 encountered an error!~")
    $display("
			cre_alu_mem_NPC1 : %d    alu_mem_NPC1 %d\n 
			cre_alu_mem_IR1 : %d    alu_mem_IR1 %d\n 

			cre_alu_mem_branch_taken1 : %d    alu_mem_branch_taken1 %d\n 
			cre_alu_mem_pred_addr1 : %d    alu_mem_pred_addr1 %d\n 

			cre_alu_mem_prf_pra_idx1 : %d    alu_mem_prf_pra_idx1 %d\n 
			cre_alu_mem_prf_prb_idx1 : %d    alu_mem_prf_prb_idx1 %d\n 

			cre_alu_mem_opa_select1 : %d    alu_mem_opa_select1 %d\n 
			cre_alu_mem_opb_select1 : %d    alu_mem_opb_select1 %d\n 

			cre_alu_mem_dest_ar_idx1 : %d    alu_mem_dest_ar_idx1 %d\n 
			cre_alu_mem_dest_pr_idx1 : %d    alu_mem_dest_pr_idx1 %d\n 
			cre_alu_mem_func1 : %d    alu_mem_func1 %d\n 

			cre_alu_mem_rd_mem1 : %d    alu_mem_rd_mem1 %d\n 
			cre_alu_mem_wr_mem1 : %d    alu_mem_wr_mem1 %d\n 

			cre_alu_mem_cond_branch1 : %d    alu_mem_cond_branch1 %d\n 
			cre_alu_mem_uncond_branch1 : %d    alu_mem_uncond_branch1 %d\n 
			cre_alu_mem_halt1 : %d    alu_mem_halt1 %d\n 

			cre_alu_mem_illegal_inst1 : %d    alu_mem_illegal_inst1 %d\n 
			cre_alu_mem_valid_inst1 : %d    alu_mem_valid_inst1
			);
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
	$monitor("Time:%4.0f decode: %h, encode_low: %d, encode_high: %d, cre_low: %d, cre_high: %d",$time, decode, encode_low, encode_high, cre_low, cre_high);

///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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


//test reset and 1 dispatch with 0 retire.
@(negedge clock); ////First test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////Second test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////Third test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////4th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////5th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////6th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////7th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////8th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////9th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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
@(negedge clock); ////10th test case;
///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 0;

	id_NPC0 = 0;
	id_IR0 = 0;
	id_branch_taken0 = 0;
	id_pred_addr0 = 0;
	id_opa_select0 = 0;
	id_opb_select0 = 0;
	id_dest_idx0 = 0;
	id_alu_func0 = 0;
	id_rd_mem0 = 0;
	id_wr_mem0 = 0;
	id_cond_branch0 = 0;
	id_uncond_branch0 = 0;
	id_halt0 = 0;
	id_illegal_inst0 = 0;
	id_valid_inst0 = 0;


	id_NPC1 = 0;
	id_IR1 = 0;
	id_branch_taken1 = 0;
	id_pred_addr1 = 0;
	id_opa_select1 = 0;
	id_opb_select1 = 0;
	id_dest_idx1 = 0;
	id_alu_func1 = 0;
	id_rd_mem1 = 0;
	id_wr_mem1 = 0;
	id_cond_branch1 = 0;
	id_uncond_branch1 = 0;
	id_halt1 = 0;
	id_illegal_inst1 = 0;
	id_valid_inst1 = 0;

	id_dispatch_num = 0;

	mt_pr_dest_idx0 = 0;
	mt_pra_idx0 = 0;
	mt_prb_idx0 = 0;
	mt_pra_ready0 = 0;
	mt_prb_ready0 = 0;

	mt_pr_dest_idx1 = 0;
	mt_pra_idx1 = 0;
	mt_prb_idx1 = 0;
	mt_pra_ready1 = 0;
	mt_prb_ready1 = 0;

// Issue inputs
	alu_sim_avail = 0;
	alu_mul_avail = 0;
	alu_mem_avail = 0;

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

@(negedge clock);
$finish;
end

endmodule


