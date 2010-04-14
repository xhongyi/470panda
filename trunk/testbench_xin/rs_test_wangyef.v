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

// Issue regs
reg		[1:0]	alu_sim_avail; // For the simple calculations
reg		[1:0]	alu_mul_avail; // For the multiplication unit
reg		[1:0]	alu_mem_avail; // For access the memory

// Complete regs
reg		[5:0]	cdb_broadcast;
reg		[6:0]	cdb_pr_tag0;
reg		[6:0]	cdb_pr_tag1;
reg		[6:0]	cdb_pr_tag2;
reg		[6:0]	cdb_pr_tag3;
reg		[6:0]	cdb_pr_tag4;
reg		[6:0]	cdb_pr_tag5;


// Dispatch outputs
wire	[1:0]	id_rs_cap;

// Issue outputs
wire [63:0]	alu_sim_NPC0;
wire [63:0]	alu_sim_NPC1;
wire [31:0] alu_sim_IR0;
wire [31:0]	alu_sim_IR1;

wire				alu_sim_branch_taken0;
wire				alu_sim_branch_taken1;
wire [63:0]	alu_sim_pred_addr0;
wire [63:0]	alu_sim_pred_addr1;

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

wire [63:0]	alu_mul_NPC0;
wire [63:0]	alu_mul_NPC1;
wire [31:0] alu_mul_IR0;
wire [31:0]	alu_mul_IR1;

wire				alu_mul_branch_taken0;
wire				alu_mul_branch_taken1;
wire [63:0]	alu_mul_pred_addr0;
wire [63:0]	alu_mul_pred_addr1;

wire 	[6:0]	alu_mul_prf_pra_idx0; // Go to physical register file to get the value
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

wire [63:0]	alu_mem_NPC0;
wire [63:0]	alu_mem_NPC1;
wire [31:0] alu_mem_IR0;
wire [31:0]	alu_mem_IR1;

wire				alu_mem_branch_taken0;
wire				alu_mem_branch_taken1;
wire [63:0]	alu_mem_pred_addr0;
wire [63:0]	alu_mem_pred_addr1;

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
///rs and id module connection/////////////////////////////////////////////////////////

reg correct;
	
	rs rs0(// Inputs
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

always @(posedge clock) begin
	#4
	correct = 1;
end

  // Generate System Clock
always
  begin
    #5;
    clock = ~clock;
  end

initial begin

  //$vcdpluson;
	$monitor("Time: %4.0f\n\alu_sim_NPC0: = %h\nalu_sim_NPC1: = %h\nalu_sim_IR0: = %h\nalu_sim_IR1: = %h\nalu_sim_branch_taken0: = %h\nalu_sim_branch_taken1: = %h\nalu_sim_pred_addr0: = %h\nalu_sim_pred_addr1: = %h\nalu_sim_prf_pra_idx0: = %h\nalu_sim_prf_pra_idx1: = %h\nalu_sim_prf_prb_idx0: = %h\nalu_sim_prf_prb_idx1: = %h\nalu_sim_opa_select0: = %h\nalu_sim_opa_select1: = %h\nalu_sim_opb_select0: = %h\nalu_sim_opb_select1: = %h\nalu_sim_dest_ar_idx0: = %h\nalu_sim_dest_ar_idx1: = %h\nalu_sim_dest_pr_idx0: = %h\nalu_sim_dest_pr_idx1: = %h\nalu_sim_func0: = %h\nalu_sim_func1: = %h\nalu_sim_rd_mem0: = %h\nalu_sim_rd_mem1: = %h\nalu_sim_wr_mem0: = %h\nalu_sim_wr_mem1: = %h\nalu_sim_cond_branch0: = %h\nalu_sim_cond_branch1: = %h\nalu_sim_uncond_branch0: = %h\nalu_sim_uncond_branch1: = %h\nalu_sim_halt0: = %h\nalu_sim_halt1: = %h\nalu_sim_illegal_inst0: = %h\nalu_sim_illegal_inst1: = %h\nalu_sim_valid_inst0: = %h\nalu_sim_valid_inst1: = %h\nalu_mul_NPC0: = %h\nalu_mul_NPC1: = %h\nalu_mul_IR0: = %h\nalu_mul_IR1: = %h\nalu_mul_branch_taken0: = %h\nalu_mul_branch_taken1: = %h\nalu_mul_pred_addr0: = %h\nalu_mul_pred_addr1: = %h\nalu_mul_prf_pra_idx0: = %h\nalu_mul_prf_pra_idx1: = %h\nalu_mul_prf_prb_idx0: = %h\nalu_mul_prf_prb_idx1: = %h\nalu_mul_opa_select0: = %h\nalu_mul_opa_select1: = %h\nalu_mul_opb_select0: = %h\nalu_mul_opb_select1: = %h\nalu_mul_dest_ar_idx0: = %h\nalu_mul_dest_ar_idx1: = %h\nalu_mul_dest_pr_idx0: = %h\nalu_mul_dest_pr_idx1: = %h\nalu_mul_func0: = %h\nalu_mul_func1: = %h\nalu_mul_rd_mem0: = %h\nalu_mul_rd_mem1: = %h\nalu_mul_wr_mem0: = %h\nalu_mul_wr_mem1: = %h\nalu_mul_cond_branch0: = %h\nalu_mul_cond_branch1: = %h\nalu_mul_uncond_branch0: = %h\nalu_mul_uncond_branch1: = %h\nalu_mul_halt0: = %h\nalu_mul_halt1: = %h\nalu_mul_illegal_inst0: = %h\nalu_mul_illegal_inst1: = %h\nalu_mul_valid_inst0: = %h\nalu_mul_valid_inst1: = %h\nalu_mem_NPC0: = %h\nalu_mem_NPC1: = %h\nalu_mem_IR0: = %h\nalu_mem_IR1: = %h\nalu_mem_branch_taken0: = %h\nalu_mem_branch_taken1: = %h\nalu_mem_pred_addr0: = %h\nalu_mem_pred_addr1: = %h\nalu_mem_prf_pra_idx0: = %h\nalu_mem_prf_pra_idx1: = %h\nalu_mem_prf_prb_idx0: = %h\nalu_mem_prf_prb_idx1: = %h\nalu_mem_opa_select0: = %h\nalu_mem_opa_select1: = %h\nalu_mem_opb_select0: = %h\nalu_mem_opb_select1: = %h\nalu_mem_dest_ar_idx0: = %h\nalu_mem_dest_ar_idx1: = %h\nalu_mem_dest_pr_idx0: = %h\nalu_mem_dest_pr_idx1: = %h\nalu_mem_func0: = %h\nalu_mem_func1: = %h\nalu_mem_rd_mem0: = %h\nalu_mem_rd_mem1: = %h\nalu_mem_wr_mem0: = %h\nalu_mem_wr_mem1: = %h\nalu_mem_cond_branch0: = %h\nalu_mem_cond_branch1: = %h\nalu_mem_uncond_branch0: = %h\nalu_mem_uncond_branch1: = %h\nalu_mem_halt0: = %h\nalu_mem_halt1: = %h\nalu_mem_illegal_inst0: = %h\nalu_mem_illegal_inst1: = %h\nalu_mem_valid_inst0: = %h\nalu_mem_valid_inst1= %h ",$time, alu_sim_NPC0,alu_sim_NPC1,alu_sim_IR0,alu_sim_IR1,alu_sim_branch_taken0,alu_sim_branch_taken1,alu_sim_pred_addr0,alu_sim_pred_addr1,alu_sim_prf_pra_idx0,alu_sim_prf_pra_idx1,alu_sim_prf_prb_idx0,alu_sim_prf_prb_idx1,alu_sim_opa_select0,alu_sim_opa_select1,alu_sim_opb_select0,alu_sim_opb_select1,alu_sim_dest_ar_idx0,alu_sim_dest_ar_idx1,alu_sim_dest_pr_idx0,alu_sim_dest_pr_idx1,alu_sim_func0,alu_sim_func1,alu_sim_rd_mem0,alu_sim_rd_mem1,alu_sim_wr_mem0,alu_sim_wr_mem1,alu_sim_cond_branch0,alu_sim_cond_branch1,alu_sim_uncond_branch0,alu_sim_uncond_branch1,alu_sim_halt0,alu_sim_halt1,alu_sim_illegal_inst0,alu_sim_illegal_inst1,alu_sim_valid_inst0,alu_sim_valid_inst1,alu_mul_NPC0,alu_mul_NPC1,alu_mul_IR0,alu_mul_IR1,alu_mul_branch_taken0,alu_mul_branch_taken1,alu_mul_pred_addr0,alu_mul_pred_addr1,alu_mul_prf_pra_idx0,alu_mul_prf_pra_idx1,alu_mul_prf_prb_idx0,alu_mul_prf_prb_idx1,alu_mul_opa_select0,alu_mul_opa_select1,alu_mul_opb_select0,alu_mul_opb_select1,alu_mul_dest_ar_idx0,alu_mul_dest_ar_idx1,alu_mul_dest_pr_idx0,alu_mul_dest_pr_idx1,alu_mul_func0,alu_mul_func1,alu_mul_rd_mem0,alu_mul_rd_mem1,alu_mul_wr_mem0,alu_mul_wr_mem1,alu_mul_cond_branch0,alu_mul_cond_branch1,alu_mul_uncond_branch0,alu_mul_uncond_branch1,alu_mul_halt0,alu_mul_halt1,alu_mul_illegal_inst0,alu_mul_illegal_inst1,alu_mul_valid_inst0,alu_mul_valid_inst1,alu_mem_NPC0,alu_mem_NPC1,alu_mem_IR0,alu_mem_IR1,alu_mem_branch_taken0,alu_mem_branch_taken1,alu_mem_pred_addr0,alu_mem_pred_addr1,alu_mem_prf_pra_idx0,alu_mem_prf_pra_idx1,alu_mem_prf_prb_idx0,alu_mem_prf_prb_idx1,alu_mem_opa_select0,alu_mem_opa_select1,alu_mem_opb_select0,alu_mem_opb_select1,alu_mem_dest_ar_idx0,alu_mem_dest_ar_idx1,alu_mem_dest_pr_idx0,alu_mem_dest_pr_idx1,alu_mem_func0,alu_mem_func1,alu_mem_rd_mem0,alu_mem_rd_mem1,alu_mem_wr_mem0,alu_mem_wr_mem1,alu_mem_cond_branch0,alu_mem_cond_branch1,alu_mem_uncond_branch0,alu_mem_uncond_branch1,alu_mem_halt0,alu_mem_halt1,alu_mem_illegal_inst0,alu_mem_illegal_inst1,alu_mem_valid_inst0,alu_mem_valid_inst1);

///////////////////////////////////////////origin inputs
	clock = 0;
	reset = 1;

	// Dispatch inputs
	id_NPC0=0;
	id_IR0=0;
	id_branch_taken0=0;
	id_pred_addr0=0;
	id_opa_select0=0;
	id_opb_select0=0;
	id_dest_idx0=0;
	id_alu_func0=0;
	id_rd_mem0=0;
	id_wr_mem0=0;
	id_cond_branch0=0;
	id_uncond_branch0=0;
	id_halt0=0;
	id_illegal_inst0=0;
	id_valid_inst0=0;

	id_NPC1=0;
	id_IR1=0;
	id_branch_taken1=0;
	id_pred_addr1=0;
	id_opa_select1=0;
	id_opb_select1=0;
	id_dest_idx1=0;
	id_alu_func1=0;
	id_rd_mem1=0;
	id_wr_mem1=0;
	id_cond_branch1=0;
	id_uncond_branch1=0;
	id_halt1=0;
	id_illegal_inst1=0;
	id_valid_inst1=0;

	id_dispatch_num=0;

	fl_pr_dest_idx0=0;
	mt_pra_idx0=0;
	mt_prb_idx0=0;
	mt_pra_ready0=0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0=0;

	fl_pr_dest_idx1=0;
	mt_pra_idx1=0;
	mt_prb_idx1=0;
	mt_pra_ready1=0; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1=0;

	// Issue inputs
	alu_sim_avail=0;// For the simple calculations
	alu_mul_avail=0;// For the multiplication unit
	alu_mem_avail=0;// For access the memory

	// Complete inputs
	cdb_broadcast=0;
	cdb_pr_tag0=0;
	cdb_pr_tag1=0;
	cdb_pr_tag2=0;
	cdb_pr_tag3=0;
	cdb_pr_tag4=0;
	cdb_pr_tag5=0;



//test reset and 1 dispatch with 0 retire.
@(negedge clock);
	reset = 1;
@(negedge clock);
	reset = 0;
@(negedge clock);
	id_NPC0=64'h1234;
	id_IR0=32'h12345678;
	id_branch_taken0=0;
	id_pred_addr0=0;
	id_opa_select0=0;
	id_opb_select0=0;
	id_dest_idx0=0;
	id_alu_func0=0;
	id_rd_mem0=0;
	id_wr_mem0=0;
	id_cond_branch0=0;
	id_uncond_branch0=0;
	id_halt0=0;
	id_illegal_inst0=0;
	id_valid_inst0=1;

	id_NPC1=64'h5678;
	id_IR1=32'h56781234;
	id_branch_taken1=0;
	id_pred_addr1=0;
	id_opa_select1=0;
	id_opb_select1=0;
	id_dest_idx1=0;
	id_alu_func1=0;
	id_rd_mem1=0;
	id_wr_mem1=0;
	id_cond_branch1=0;
	id_uncond_branch1=0;
	id_halt1=0;
	id_illegal_inst1=0;
	id_valid_inst1=1;

	id_dispatch_num=2;

	fl_pr_dest_idx0=3;
	mt_pra_idx0=4;
	mt_prb_idx0=5;
	mt_pra_ready0=6; // *** If the reg is not valid, it is ready ***
	mt_prb_ready0=7;

	fl_pr_dest_idx1=8;
	mt_pra_idx1=9;
	mt_prb_idx1=10;
	mt_pra_ready0=11; // *** If the reg is not valid, it is ready ***
	mt_prb_ready1=12;

	// Issue inputs
	alu_sim_avail=2;// For the simple calculations
	alu_mul_avail=2;// For the multiplication unit
	alu_mem_avail=2;// For access the memory

	// Complete inputs
	cdb_broadcast=0;
	cdb_pr_tag0=0;
	cdb_pr_tag1=0;
	cdb_pr_tag2=0;
	cdb_pr_tag3=0;
	cdb_pr_tag4=0;
	cdb_pr_tag5=0;
@(negedge clock);
$finish;
end

endmodule


