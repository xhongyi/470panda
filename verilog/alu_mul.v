// This is one stage of an 8 stage (9 depending on how you look at it)
// pipelined multiplier that multiplies 2 64-bit integers and returns
// the low 64 bits of the result.  This is not an ideal multiplier but
// is sufficient to allow a faster clock period than straight *
module mult_stage(clock, reset, 
                  product_in,  mplier_in,  mcand_in,  start,
                  product_out, mplier_out, mcand_out, done);

  input clock, reset, start;
  input [63:0] product_in, mplier_in, mcand_in;

  output done;
  output [63:0] product_out, mplier_out, mcand_out;

  reg  [63:0] prod_in_reg, partial_prod_reg;
  wire [63:0] partial_product, next_mplier, next_mcand;

  reg [63:0] mplier_out, mcand_out;
  reg done;
  
  assign product_out = prod_in_reg + partial_prod_reg;

  assign partial_product = mplier_in[15:0] * mcand_in;

  assign next_mplier = {16'b0,mplier_in[63:16]};
  assign next_mcand = {mcand_in[47:0],16'b0};

  always @(posedge clock)
  begin
    prod_in_reg      <= #1 product_in;
    partial_prod_reg <= #1 partial_product;
    mplier_out       <= #1 next_mplier;
    mcand_out        <= #1 next_mcand;
  end

  always @(posedge clock)
  begin
    if(reset)
      done <= #1 1'b0;
    else
      done <= #1 start;
  end

endmodule

////////////////////////////////////////////////////////////
////Pipelined Multiplier																////
////////////////////////////////////////////////////////////
module mult(clock, reset, mplier, mcand, start, product, done);

  input clock, reset, start;
  input [63:0] mcand, mplier;

  output [63:0] product;
  output done;

  wire [63:0] mcand_out, mplier_out;
  wire [(3*64)-1:0] internal_products, internal_mcands, internal_mpliers;
  wire [2:0] internal_dones;
  
  mult_stage mstage [3:0] 
    (.clock(clock),
     .reset(reset),
     .product_in({internal_products,64'h0}),
     .mplier_in({internal_mpliers,mplier}),
     .mcand_in({internal_mcands,mcand}),
     .start({internal_dones,start}),
     .product_out({product,internal_products}),
     .mplier_out({mplier_out,internal_mpliers}),
     .mcand_out({mcand_out,internal_mcands}),
     .done({done,internal_dones})
    );

endmodule

module alu_mul(
								clock,
								reset,
								rs_NPC0,
								rs_NPC1,
								rs_IR0,
								rs_IR1,
								prf_pra0,
								prf_pra1,
								prf_prb0,
								prf_prb1,
								rs_dest_ar_idx0,
								rs_dest_ar_idx1,
								rs_dest_pr_idx0,
								rs_dest_pr_idx1,
								rs_opa_select0,
								rs_opa_select1,
								rs_opb_select0,
								rs_opb_select1,
								rs_valid_inst0,
								rs_valid_inst1,
								// Outputs
								cdb_complete0,
								cdb_complete1,
								cdb_dest_ar_idx0,
								cdb_dest_ar_idx1,
								cdb_prf_dest_pr_idx0,
								cdb_prf_dest_pr_idx1,
//								cdb_exception0,
//								cdb_exception1,
								prf_result0,
								prf_result1,
								prf_write_enable0,
								prf_write_enable1,
								rs_alu_avail
								);
	input         clock;               // system clock
  input         reset;               // system reset
  input  [63:0] rs_NPC0;           // incoming instruction PC+4
  input  [63:0] rs_NPC1;           // incoming instruction PC+4
  input  [31:0] rs_IR0;            // incoming instruction
  input  [31:0] rs_IR1;            // incoming instruction
  input  [63:0] prf_pra0;          // register A value from reg file   
  input  [63:0] prf_pra1;          // register A value from reg file

  input  [63:0] prf_prb0;          // register B value from reg file
  input  [63:0] prf_prb1;          // register B value from reg file
	input	 [4:0] rs_dest_ar_idx0;
	input	 [4:0] rs_dest_ar_idx1;
	input	 [6:0] rs_dest_pr_idx0;
	input	 [6:0] rs_dest_pr_idx1;
  input   [1:0] rs_opa_select0;    // opA mux select from decoder
  input   [1:0] rs_opa_select1;    // opA mux select from decoder

  input   [1:0] rs_opb_select0;    // opB mux select from decoder
  input   [1:0] rs_opb_select1;    // opB mux select from decoder

  
	input 				rs_valid_inst0;
	input					rs_valid_inst1;
	
	
  output [63:0] prf_result0;   // ALU result
  output [63:0] prf_result1;   // ALU result
	output 				prf_write_enable0;
	output				prf_write_enable1;
	output				cdb_complete0;
	output				cdb_complete1;
	output	[4:0]	cdb_dest_ar_idx0;
	output	[4:0]	cdb_dest_ar_idx1;
	output	[6:0]	cdb_prf_dest_pr_idx0;
	output	[6:0]	cdb_prf_dest_pr_idx1;
//	output				cdb_exception0;
//	output			  cdb_exception1;
  output [1:0]	rs_alu_avail;
	//Internal State
	reg  [63:0] NPC0;           // incoming instruction PC+4
  reg  [63:0] NPC1;           // incoming instruction PC+4
  reg  [31:0] IR0;            // incoming instruction
  reg  [31:0] IR1;            // incoming instruction
  reg  [63:0] pra0;          // register A value from reg file   
  reg  [63:0] pra1;          // register A value from reg file

  reg  [63:0] prb0;          // register B value from reg file
  reg  [63:0] prb1;          // register B value from reg file
	reg	 [4:0]  dest_ar_idx0;
	reg	 [4:0]  dest_ar_idx1;
	reg	 [6:0]  dest_pr_idx0;
	reg	 [6:0]  dest_pr_idx1;
  reg   [1:0] opa_select0;    // opA mux select from decoder
  reg   [1:0] opa_select1;    // opA mux select from decoder

  reg   [1:0] opb_select0;    // opB mux select from decoder
  reg   [1:0] opb_select1;    // opB mux select from decoder

 	reg 				valid_inst0;
	reg					valid_inst1;

	wire				ar_a_zero0;
	wire				ar_b_zero0;
	wire				ar_a_zero1;
	wire				ar_b_zero1;
	
	assign ar_a_zero0 = (rs_IR0[25:21] == `ZERO_REG);
	assign ar_b_zero0 = (rs_IR0[20:16] == `ZERO_REG);
	assign ar_a_zero1 = (rs_IR1[25:21] == `ZERO_REG);
	assign ar_b_zero1 = (rs_IR1[20:16] == `ZERO_REG);


		
		assign cdb_dest_ar_idx0 = dest_ar_idx0;
		assign cdb_dest_ar_idx1 = dest_ar_idx1;
		assign cdb_prf_dest_pr_idx0 = dest_pr_idx0;
		assign cdb_prf_dest_pr_idx1 = dest_pr_idx1;
		assign rs_alu_avail = 2'b11;
		assign  prf_write_enable0 = cdb_complete0;
		assign  prf_write_enable1 = cdb_complete1;

			
  reg    [63:0] opa_mux_out0, opa_mux_out1, opb_mux_out0, opb_mux_out1;
  wire          brcond_result0, brcond_result1;
  wire					ex_mem_branch_taken0, ex_mem_branch_taken1; 
   // set up possible immediates:
   //   mem_disp: sign-extended 16-bit immediate for memory format
   //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
   //   alu_imm: zero-extended 8-bit immediate for ALU ops
  wire [63:0] mem_disp0 = { {48{IR0[15]}}, IR0[15:0] };
  wire [63:0] br_disp0  = { {41{IR0[20]}}, IR0[20:0], 2'b00 };
  wire [63:0] alu_imm0  = { 56'b0, IR0[20:13] };
  //Second copy for the second set of instructions
  wire [63:0] mem_disp1 = { {48{IR1[15]}}, IR1[15:0] };
  wire [63:0] br_disp1  = { {41{IR1[20]}}, IR1[20:0], 2'b00 };
  wire [63:0] alu_imm1  = { 56'b0, IR1[20:13] };
   //
   // ALU opA mux
   //
								
								
	always @*
	begin
		opa_mux_out0 = pra0;
		opa_mux_out1 = pra1;
		case (opb_select0)
			`ALU_OPB_IS_REGB:			opb_mux_out0 = (ar_b_zero0) ? 64'b0 : prb0;
			`ALU_OPB_IS_ALU_IMM:	opb_mux_out0 = alu_imm0;
			default:							opb_mux_out0 = 64'b0;
		endcase
		case (opb_select1)
			`ALU_OPB_IS_REGB:			opb_mux_out1 = (ar_b_zero1) ? 64'b0 : prb1;
			`ALU_OPB_IS_ALU_IMM:	opb_mux_out1 = alu_imm1;
			default:							opb_mux_out1 = 64'b0;
		endcase
	end

	//
   // instantiate the ALU
   //
  mult mult0(clock, reset, opa_mux_out0, opb_mux_out0, valid_inst0, prf_result0, cdb_complete0);
	mult mult1(clock, reset, opa_mux_out1, opb_mux_out1, valid_inst1, prf_result1, cdb_complete1);
  
	always @(posedge clock)
	begin
		if(reset)
		begin
			NPC0 	<= 	`SD 0;
			NPC1 	<= 	`SD 0;
			IR0 	<=	`SD 0;
			IR1	 	<=	`SD 0;
			pra0	<=	`SD 0;
			pra1	<=	`SD 0;
			prb0	<=	`SD 0;
			prb1	<=	`SD 0;
			dest_ar_idx0	<=	`SD 0;
			dest_ar_idx1	<=	`SD 0;
			dest_pr_idx0	<=	`SD 0;
			dest_pr_idx1	<=	`SD 0;
			opa_select0		<=	`SD 0;
			opa_select1		<=	`SD 0;
			opb_select0		<=	`SD 0;
			opb_select1		<=	`SD 0;
			valid_inst0		<=	`SD 0;
			valid_inst1		<=	`SD 0;
		end
		else
		begin
			NPC0 	<= 	`SD rs_NPC0;
			NPC1 	<= 	`SD rs_NPC1;
			IR0 	<=	`SD rs_IR0;
			IR1	 	<=	`SD rs_IR1;
			pra0	<=	`SD prf_pra0;
			pra1	<=	`SD prf_pra1;
			prb0	<=	`SD prf_prb0;
			prb1	<=	`SD prf_prb1;
			dest_ar_idx0	<=	`SD rs_dest_ar_idx0;
			dest_ar_idx1	<=	`SD rs_dest_ar_idx1;
			dest_pr_idx0	<=	`SD rs_dest_pr_idx0;
			dest_pr_idx1	<=	`SD rs_dest_pr_idx1;
			opa_select0		<=	`SD rs_opa_select0;
			opa_select1		<=	`SD rs_opa_select1;
			opb_select0		<=	`SD rs_opb_select0;
			opb_select1		<=	`SD rs_opb_select1;
			valid_inst0		<=	`SD rs_valid_inst0;
			valid_inst1		<=	`SD rs_valid_inst1;
		end
	end
	
	
	
	
	endmodule
