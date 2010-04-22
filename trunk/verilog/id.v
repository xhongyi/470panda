/*
 * Name: id.v
 *
 * Description: decode the instructions from if stage and dispatch
 * instructions
 *
 * Min clock time: 3.5
 */


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder(// Inputs
               inst,
               valid_inst_in,  // ignore inst when low, outputs will
                               // reflect noop (except valid_inst)

               // Outputs
               opa_select,
               opb_select,
               alu_func,
               dest_reg,
               rd_mem,
               wr_mem,
               ldl_mem,
               stc_mem,
               cond_branch,
               uncond_branch,
               halt,           // non-zero on a halt
               cpuid,          // get CPUID instruction
               illegal,        // non-zero on an illegal instruction 
               valid_inst      // for counting valid instructions executed
                               // and for making the fetch stage die on halts/
                               // keeping track of when to allow the next
                               // instruction out of fetch
                               // 0 for HALT and illegal instructions (die on halt)
              );

  input [31:0] inst;
  input valid_inst_in;

  output [1:0] opa_select, opb_select, dest_reg; // mux selects
  output [4:0] alu_func;
  output rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch, halt;
  output cpuid, illegal, valid_inst;

  reg [1:0] opa_select, opb_select, dest_reg; // mux selects
  reg [4:0] alu_func;
  reg rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch;
  reg cpuid, halt, illegal;

  assign valid_inst = valid_inst_in & ~illegal;
  always @*
  begin
      // default control values:
      // - valid instructions must override these defaults as necessary.
      //   opa_select, opb_select, and alu_func should be set explicitly.
      // - invalid instructions should clear valid_inst.
      // - These defaults are equivalent to a noop
      // * see sys_defs.vh for the constants used here
    opa_select = 0;
    opb_select = 0;
    alu_func = 0;
    dest_reg = `DEST_NONE;
    rd_mem = `FALSE;
    wr_mem = `FALSE;
    ldl_mem = `FALSE;
    stc_mem = `FALSE;
    cond_branch = `FALSE;
    uncond_branch = `FALSE;
    halt = `FALSE;
    cpuid = `FALSE;
    illegal = `FALSE;
    if(valid_inst_in)
    begin
      case ({inst[31:29], 3'b0})
        6'h0:
          case (inst[31:26])
            `PAL_INST: begin
               if (inst[25:0] == `PAL_HALT)
                 halt = `TRUE;
               else if (inst[25:0] == `PAL_WHAMI) begin
                 cpuid = `TRUE;
                 dest_reg = `DEST_IS_REGA;   // get cpuid writes to r0
               end else
                 illegal = `TRUE;
              end
            default: illegal = `TRUE;
          endcase // case(inst[31:26])
         
        6'h10:
          begin
            opa_select = `ALU_OPA_IS_REGA;
            opb_select = inst[12] ? `ALU_OPB_IS_ALU_IMM : `ALU_OPB_IS_REGB;
            dest_reg = `DEST_IS_REGC;
            case (inst[31:26])
              `INTA_GRP:
                 case (inst[11:5])
                   `CMPULT_INST:  alu_func = `ALU_CMPULT;
                   `ADDQ_INST:    alu_func = `ALU_ADDQ;
                   `SUBQ_INST:    alu_func = `ALU_SUBQ;
                   `CMPEQ_INST:   alu_func = `ALU_CMPEQ;
                   `CMPULE_INST:  alu_func = `ALU_CMPULE;
                   `CMPLT_INST:   alu_func = `ALU_CMPLT;
                   `CMPLE_INST:   alu_func = `ALU_CMPLE;
                    default:      illegal = `TRUE;
                  endcase // case(inst[11:5])
              `INTL_GRP:
                case (inst[11:5])
                  `AND_INST:    alu_func = `ALU_AND;
                  `BIC_INST:    alu_func = `ALU_BIC;
                  `BIS_INST:    alu_func = `ALU_BIS;
                  `ORNOT_INST:  alu_func = `ALU_ORNOT;
                  `XOR_INST:    alu_func = `ALU_XOR;
                  `EQV_INST:    alu_func = `ALU_EQV;
                  default:      illegal = `TRUE;
                endcase // case(inst[11:5])
              `INTS_GRP:
                case (inst[11:5])
                  `SRL_INST:  alu_func = `ALU_SRL;
                  `SLL_INST:  alu_func = `ALU_SLL;
                  `SRA_INST:  alu_func = `ALU_SRA;
                  default:    illegal = `TRUE;
                endcase // case(inst[11:5])
              `INTM_GRP:
                case (inst[11:5])
                  `MULQ_INST:       alu_func = `ALU_MULQ;
                  default:          illegal = `TRUE;
                endcase // case(inst[11:5])
              `ITFP_GRP:       illegal = `TRUE;       // unimplemented
              `FLTV_GRP:       illegal = `TRUE;       // unimplemented
              `FLTI_GRP:       illegal = `TRUE;       // unimplemented
              `FLTL_GRP:       illegal = `TRUE;       // unimplemented
            endcase // case(inst[31:26])
          end
           
        6'h18:
          case (inst[31:26])
            `MISC_GRP:       illegal = `TRUE; // unimplemented
            `JSR_GRP:
               begin
                 // JMP, JSR, RET, and JSR_CO have identical semantics
                 opa_select = `ALU_OPA_IS_NOT3;
                 opb_select = `ALU_OPB_IS_REGB;
                 alu_func = `ALU_AND; // clear low 2 bits (word-align)
                 dest_reg = `DEST_IS_REGA;
                 uncond_branch = `TRUE;
               end
            `FTPI_GRP:       illegal = `TRUE;       // unimplemented
           endcase // case(inst[31:26])
           
        6'h08, 6'h20, 6'h28:
          begin
            opa_select = `ALU_OPA_IS_MEM_DISP;
            opb_select = `ALU_OPB_IS_REGB;
            alu_func = `ALU_ADDQ;
            dest_reg = `DEST_IS_REGA;
            case (inst[31:26])
              `LDA_INST:  /* defaults are OK */;
              `LDQ_INST:
                begin
                  rd_mem = `TRUE;
                  dest_reg = `DEST_IS_REGA;
                end // case: `LDQ_INST
              `LDQ_L_INST:
                begin
                  rd_mem = `TRUE;
                  ldl_mem = `TRUE;
                  dest_reg = `DEST_IS_REGA;
                end // case: `LDQ_L_INST
              `STQ_INST:
                begin
                	opa_select = `ALU_OPA_IS_REGA;
                  wr_mem = `TRUE;
                  dest_reg = `DEST_NONE;
                end // case: `STQ_INST
              `STQ_C_INST:
                begin
	                opa_select = `ALU_OPA_IS_REGA;
                  wr_mem = `TRUE;
                  stc_mem = `TRUE;
                  dest_reg = `DEST_IS_REGA;
                end // case: `STQ_INST
              default:       illegal = `TRUE;
            endcase // case(inst[31:26])
          end
           
        6'h30, 6'h38:
          begin
            opa_select = `ALU_OPA_IS_NPC;
            opb_select = `ALU_OPB_IS_BR_DISP;
            alu_func = `ALU_ADDQ;
            case (inst[31:26])
              `FBEQ_INST, `FBLT_INST, `FBLE_INST,
              `FBNE_INST, `FBGE_INST, `FBGT_INST:
                begin
                  // FP conditionals not implemented
                  illegal = `TRUE;
                end
                 
              `BR_INST, `BSR_INST:
                begin
                  dest_reg = `DEST_IS_REGA;
                  uncond_branch = `TRUE;
                end
  
              default:
              begin
              	opa_select = `ALU_OPA_IS_REGA;
                cond_branch = `TRUE; // all others are conditional
              end
            endcase // case(inst[31:26])
          end
      endcase // case(inst[31:29] << 3)
    end // if(~valid_inst_in)
  end // always
   
endmodule // decoder


/*module id_kernel(
              // Inputs
              clock,
              reset,
              if_IR,
              if_valid_inst,

              // Outputs
              id_ra_idx_out,
              id_rb_idx_out,
							id_rb_idx_out,
              id_opa_select_out,
              id_opb_select_out,
              id_dest_reg_idx_out,
              id_alu_func_out,
              id_rd_mem_out,
              id_wr_mem_out,
              id_ldl_mem_out,
              id_stc_mem_out,
              id_cond_branch_out,
              id_uncond_branch_out,
              id_halt_out,
              id_cpuid_out,
              id_illegal_out,
              id_valid_inst_out
              );


  input         reset;                // system reset
  input  [31:0] if_IR;             // incoming instruction
  input         if_valid_inst;

  output 	[4:0] id_ra_idx_out;      // reg A index
  output 	[4:0] id_rb_idx_out;      // reg B index
	output	[4:0]	id_rc_idx_out;			// reg C index

  output  [1:0] id_opa_select_out;    // ALU opa mux select (ALU_OPA_xxx *)
  output  [1:0] id_opb_select_out;    // ALU opb mux select (ALU_OPB_xxx *)
  output  [4:0] id_dest_reg_idx_out;  // destination (writeback) register index
                                      // (ZERO_REG if no writeback)
  output  [4:0] id_alu_func_out;      // ALU function select (ALU_xxx *)
  output        id_rd_mem_out;        // does inst read memory?
  output        id_wr_mem_out;        // does inst write memory?
  output        id_ldl_mem_out;       // load-lock inst?
  output        id_stc_mem_out;       // store-conditional inst?
  output        id_cond_branch_out;   // is inst a conditional branch?
  output        id_uncond_branch_out; // is inst an unconditional branch 
                                      // or jump?
  output        id_halt_out;
  output        id_cpuid_out;         // get CPUID inst?
  output        id_illegal_out;
  output        id_valid_inst_out;    // is inst a valid instruction to be 
                                      // counted for CPI calculations?
   
  wire    [1:0] dest_reg_select;
  reg     [4:0] id_dest_reg_idx_out;     // not state: behavioral mux output
   
    // instruction fields read from IF/ID pipeline register
  wire    [4:0] ra_idx = if_IR[25:21];   // inst operand A register index
  wire    [4:0] rb_idx = if_IR[20:16];   // inst operand B register index
  wire    [4:0] rc_idx = if_IR[4:0];     // inst operand C register index

    // instantiate the instruction decoder
  decoder decoder_0 (// Input
                     .inst(if_id_IR),
                     .valid_inst_in(if_id_valid_inst),

                     // Outputs
                     .opa_select(id_opa_select_out),
                     .opb_select(id_opb_select_out),
                     .alu_func(id_alu_func_out),
                     .dest_reg(dest_reg_select),
                     .rd_mem(id_rd_mem_out),
                     .wr_mem(id_wr_mem_out),
                     .ldl_mem(id_ldl_mem_out),
                     .stc_mem(id_stc_mem_out),
                     .cond_branch(id_cond_branch_out),
                     .uncond_branch(id_uncond_branch_out),
                     .halt(id_halt_out),
                     .cpuid(id_cpuid_out),
                     .illegal(id_illegal_out),
                     .valid_inst(id_valid_inst_out)
                    );

     // mux to generate dest_reg_idx based on
     // the dest_reg_select output from decoder
  always @*
    begin
      case (dest_reg_select)
        `DEST_IS_REGC: id_dest_reg_idx_out = rc_idx;
        `DEST_IS_REGA: id_dest_reg_idx_out = ra_idx;
        `DEST_NONE:    id_dest_reg_idx_out = `ZERO_REG;
        default:       id_dest_reg_idx_out = `ZERO_REG; 
      endcase
    end
   
endmodule // module id_kernel*/

module id (
				//Inputs
				clock,
				reset,
				if_IR0,
				if_IR1,
				if_valid_inst0,
				if_valid_inst1,
				if_NPC0,
				if_NPC1,
				bht_bhr0,
				bht_bhr1,
				if_branch_taken0,
				if_branch_taken1,
				if_pred_addr0,
				if_pred_addr1,

				rob_cap, // rob capacity
				rs_cap, // rs capacity
				lsq_cap,

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
				
				rob_bhr0,//new
				rob_bhr1,//new

				rs_rob_mt_illegal_inst0,
				rs_rob_mt_illegal_inst1,
				rs_rob_mt_valid_inst0,
				rs_rob_mt_valid_inst1,

				rs_rob_mt_dispatch_num,
				if_inst_need_num
				);

input					clock;
input					reset;
input	 [31:0]	if_IR0;
input	 [31:0] if_IR1;
input					if_valid_inst0;
input					if_valid_inst1;
input	 [63:0] if_NPC0;
input	 [63:0]	if_NPC1;
input [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr0;
input [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr1;
input					if_branch_taken0;
input 				if_branch_taken1;
input	 [63:0]	if_pred_addr0;
input	 [63:0]	if_pred_addr1;

input		[1:0]	rob_cap; // rob capacity
input		[1:0]	rs_cap; // rs capacity
input		[1:0]	lsq_cap;

output [63:0]	rs_NPC0;
output [63:0]	rs_NPC1;
output [31:0]	rs_IR0;
output [31:0]	rs_IR1;

output					rs_branch_taken0;
output 					rs_branch_taken1;
output	 [63:0]	rs_pred_addr0;
output	 [63:0]	rs_pred_addr1;

output	[4:0]	rs_mt_ra_idx0;
output	[4:0]	rs_mt_ra_idx1;
output	[4:0]	rs_mt_rb_idx0;
output	[4:0]	rs_mt_rb_idx1;
output	[4:0]	rs_mt_rc_idx0;
output	[4:0]	rs_mt_rc_idx1;

output	[1:0]	rs_mt_opa_select0;
output	[1:0]	rs_mt_opa_select1;
output	[1:0]	rs_mt_opb_select0;
output	[1:0]	rs_mt_opb_select1;

output	[4:0]	rs_mt_dest_idx0;
output	[4:0]	rs_mt_dest_idx1;
output	[4:0]	rs_alu_func0;
output	[4:0]	rs_alu_func1;

output				rs_rd_mem0;
output				rs_rd_mem1;
output				rs_wr_mem0;
output				rs_wr_mem1;

output				rs_ldl_mem0;
output				rs_ldl_mem1;
output				rs_stc_mem0;
output				rs_stc_mem1;

output				rs_cond_branch0;
output				rs_cond_branch1;
output				rs_uncond_branch0;
output				rs_uncond_branch1;
output				rs_halt0;
output				rs_halt1;

output				rs_rob_mt_illegal_inst0;
output				rs_rob_mt_illegal_inst1;
output				rs_rob_mt_valid_inst0;
output				rs_rob_mt_valid_inst1;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] rob_bhr0;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] rob_bhr1;

output	[1:0]	rs_rob_mt_dispatch_num;
output	[1:0]	if_inst_need_num;

// Internal states

reg	 [63:0]	npc0;
reg	 [31:0]	ir0;
reg		[4:0]	ra_idx0;
reg		[4:0]	rb_idx0;
reg		[4:0]	rc_idx0;
reg					branch_taken0;
reg	 [63:0]	pred_addr0;
reg		[1:0]	opa_select0;
reg		[1:0]	opb_select0;
reg		[4:0]	dest_idx0;
reg		[4:0]	alu_func0;
reg					rd_mem0;
reg					wr_mem0;
reg					ldl_mem0;
reg					stc_mem0;
reg					cond_branch0;
reg					uncond_branch0;
reg					halt0;
reg					illegal_inst0;
reg					valid_inst0;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bhr0;//new

reg	 [63:0]	npc1;
reg	 [31:0]	ir1;
reg		[4:0]	ra_idx1;
reg		[4:0]	rb_idx1;
reg		[4:0]	rc_idx1;
reg					branch_taken1;
reg	 [63:0]	pred_addr1;
reg		[1:0]	opa_select1;
reg		[1:0]	opb_select1;
reg		[4:0]	dest_idx1;
reg		[4:0]	alu_func1;
reg					rd_mem1;
reg					wr_mem1;
reg					ldl_mem1;
reg					stc_mem1;
reg					cond_branch1;
reg					uncond_branch1;
reg					halt1;
reg					illegal_inst1;
reg					valid_inst1;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bhr1;//new

wire	[4:0]	next_ra_idx0;
wire	[4:0]	next_rb_idx0;
wire	[4:0]	next_rc_idx0;
wire	[1:0]	next_opa_select0;
wire	[1:0]	next_opb_select0;
reg		[4:0]	next_dest_idx0;
wire	[4:0]	next_alu_func0;
wire				next_rd_mem0;
wire				next_wr_mem0;
wire				next_ldl_mem0;
wire				next_stc_mem0;
wire				next_cond_branch0;
wire				next_uncond_branch0;
wire				next_halt0;
wire				next_illegal_inst0;
wire				next_valid_inst0;

wire	[4:0]	next_ra_idx1;
wire	[4:0]	next_rb_idx1;
wire	[4:0]	next_rc_idx1;
wire	[1:0]	next_opa_select1;
wire	[1:0]	next_opb_select1;
reg		[4:0]	next_dest_idx1;
wire	[4:0]	next_alu_func1;
wire				next_rd_mem1;
wire				next_wr_mem1;
wire				next_ldl_mem1;
wire				next_stc_mem1;
wire				next_cond_branch1;
wire				next_uncond_branch1;
wire				next_halt1;
wire				next_illegal_inst1;
wire				next_valid_inst1;

/*
 * Decode Stage
 */

wire	[1:0]	dest_reg_select0;
wire	[1:0]	dest_reg_select1;
wire				cpuid0;
wire				cpuid1;

decoder decoder0 (// Inputs
									.inst(if_IR0),
									.valid_inst_in(if_valid_inst0),

									// Outputs
									.opa_select(next_opa_select0),
									.opb_select(next_opb_select0),
									.alu_func(next_alu_func0),
									.dest_reg(dest_reg_select0),
									.rd_mem(next_rd_mem0),
									.wr_mem(next_wr_mem0),
									.ldl_mem(next_ldl_mem0),
									.stc_mem(next_stc_mem0),
									.cond_branch(next_cond_branch0),
									.uncond_branch(next_uncond_branch0),
									.halt(next_halt0),
									.cpuid(cpuid0),
									.illegal(next_illegal_inst0),
									.valid_inst(next_valid_inst0)
				);

decoder decoder1 (// Inputs
									.inst(if_IR1),
									.valid_inst_in(if_valid_inst1),

									// Outputs
									.opa_select(next_opa_select1),
									.opb_select(next_opb_select1),
									.alu_func(next_alu_func1),
									.dest_reg(dest_reg_select1),
									.rd_mem(next_rd_mem1),
									.wr_mem(next_wr_mem1),
									.ldl_mem(next_ldl_mem1),
									.stc_mem(next_stc_mem1),
									.cond_branch(next_cond_branch1),
									.uncond_branch(next_uncond_branch1),
									.halt(next_halt1),
									.cpuid(cpuid1),
									.illegal(next_illegal_inst1),
									.valid_inst(next_valid_inst1)
				);

assign next_ra_idx0 = if_IR0[25:21];   // inst operand A register index
assign next_rb_idx0 = if_IR0[20:16];   // inst operand B register index
assign next_rc_idx0 = if_IR0[4:0];     // inst operand C register index

assign next_ra_idx1 = if_IR1[25:21];   // inst operand A register index
assign next_rb_idx1 = if_IR1[20:16];   // inst operand B register index
assign next_rc_idx1 = if_IR1[4:0];     // inst operand C register index

always @*
begin
	case (dest_reg_select0)
		`DEST_IS_REGC: next_dest_idx0 = next_rc_idx0;
		`DEST_IS_REGA: next_dest_idx0 = next_ra_idx0;
		`DEST_NONE:    next_dest_idx0 = `ZERO_REG;
		default:       next_dest_idx0 = `ZERO_REG; 
	endcase
	case (dest_reg_select1)
		`DEST_IS_REGC: next_dest_idx1 = next_rc_idx1;
		`DEST_IS_REGA: next_dest_idx1 = next_ra_idx1;
		`DEST_NONE:    next_dest_idx1 = `ZERO_REG;
		default:       next_dest_idx1 = `ZERO_REG; 
	endcase
end

/*
 * Dispatch Stage
 */

reg		[1:0]	dispatch_num;
reg		[1:0] inst_need_num;

always @*
begin
	if (rob_cap == 2'b10 && rs_cap == 2'b10 && lsq_cap == 2'b10 && valid_inst0 && valid_inst1)
		dispatch_num = 2'b10;
	else if (rob_cap == 2'b0 || rs_cap == 2'b0 || lsq_cap == 2'b0)
		dispatch_num = 2'b00;
	else if (valid_inst0)
		dispatch_num = 2'b01;
	else
		dispatch_num = 2'b00;
end

always @*
begin
	if (rob_cap == 2'b10 && rs_cap == 2'b10 && lsq_cap == 2'b10)
		inst_need_num = 2'b10;
	else if (rob_cap == 2'b0 || rs_cap == 2'b0 || lsq_cap == 2'b0)
	begin
		if (~valid_inst0)
			inst_need_num = 2'b10;
		else if (valid_inst0 && ~valid_inst1)
			inst_need_num = 2'b01;
		else
			inst_need_num = 2'b00;
	end
	else
	begin
		if (valid_inst1)
			inst_need_num = 2'b01;
		else
			inst_need_num = 2'b10;
	end
end

assign rs_rob_mt_dispatch_num = dispatch_num;
assign if_inst_need_num		=	inst_need_num;

assign rs_NPC0						= npc0;
assign rs_IR0							= ir0;

assign rs_mt_ra_idx0			= ra_idx0;
assign rs_mt_rb_idx0			= rb_idx0;
assign rs_mt_rc_idx0			= rc_idx0;

assign rs_branch_taken0		= branch_taken0;
assign rs_pred_addr0			= pred_addr0;

assign rs_mt_opa_select0 	= opa_select0;
assign rs_mt_opb_select0	= opb_select0;

assign rs_mt_dest_idx0		= dest_idx0;
assign rs_alu_func0				= alu_func0;

assign rs_rd_mem0					= rd_mem0;
assign rs_wr_mem0					= wr_mem0;

assign rs_ldl_mem0				= ldl_mem0;
assign rs_stc_mem0				= stc_mem0;

assign rs_cond_branch0		= cond_branch0;
assign rs_uncond_branch0	= uncond_branch0;
assign rs_halt0						= halt0;

assign rob_bhr0 = bhr0;//new

assign rs_rob_mt_illegal_inst0 	= illegal_inst0;
assign rs_rob_mt_valid_inst0		= (dispatch_num[1] | dispatch_num[0]) ? valid_inst0 : 1'b0;

assign rs_NPC1						= npc1;
assign rs_IR1							= ir1;

assign rs_mt_ra_idx1			= ra_idx1;
assign rs_mt_rb_idx1			= rb_idx1;
assign rs_mt_rc_idx1			= rc_idx1;

assign rs_branch_taken1		= branch_taken1;
assign rs_pred_addr1			= pred_addr1;

assign rs_mt_opa_select1 	= opa_select1;
assign rs_mt_opb_select1	= opb_select1;

assign rs_mt_dest_idx1		= dest_idx1;
assign rs_alu_func1				= alu_func1;

assign rs_rd_mem1					= rd_mem1;
assign rs_wr_mem1					= wr_mem1;

assign rs_ldl_mem1				= ldl_mem1;
assign rs_stc_mem1				= stc_mem1;

assign rs_cond_branch1		= cond_branch1;
assign rs_uncond_branch1	= uncond_branch1;
assign rs_halt1						= halt1;

assign rob_bhr1 = bhr1;//new

assign rs_rob_mt_illegal_inst1 	= illegal_inst1;
assign rs_rob_mt_valid_inst1		= (dispatch_num[1]) ? valid_inst1 : 1'b0;


/*
 * Update states
 */

always @(posedge clock)
begin
	if (reset)
	begin
		npc0						<= `SD 0;
		ir0							<= `SD `NOOP_INST;
		ra_idx0					<= `SD `ZERO_REG;
		rb_idx0					<= `SD `ZERO_REG;
		rc_idx0					<= `SD `ZERO_REG;
		branch_taken0		<= `SD 0;
		pred_addr0			<= `SD 0;
		opa_select0			<= `SD 0;
		opb_select0			<= `SD 0;
		dest_idx0				<= `SD `ZERO_REG;
		alu_func0				<= `SD 0;
		rd_mem0					<= `SD 0;
		wr_mem0					<= `SD 0;
		cond_branch0		<= `SD 0;
		uncond_branch0	<= `SD 0;
		halt0						<= `SD 0;
		illegal_inst0 	<= `SD 0;
		valid_inst0			<= `SD 0;
		bhr0						<= `SD 0;

		npc1						<= `SD 0;
		ir1							<= `SD `NOOP_INST;
		ra_idx1					<= `SD `ZERO_REG;
		rb_idx1					<= `SD `ZERO_REG;
		rc_idx1					<= `SD `ZERO_REG;
		branch_taken1		<= `SD 0;
		pred_addr1			<= `SD 0;
		opa_select1			<= `SD 0;
		opb_select1			<= `SD 0;
		dest_idx1				<= `SD `ZERO_REG;
		alu_func1				<= `SD 0;
		rd_mem1					<= `SD 0;
		wr_mem1					<= `SD 0;
		cond_branch1		<= `SD 0;
		uncond_branch1	<= `SD 0;
		halt1						<= `SD 0;
		illegal_inst1 	<= `SD 0;
		valid_inst1			<= `SD 0;
		bhr1						<= `SD 0;
	end
	else if (dispatch_num[1] || (dispatch_num[0] && ~valid_inst1) || (~valid_inst1 && ~valid_inst0)) // Two instructions are dispatched
	begin
		npc0 						<= `SD if_NPC0;
		ir0 						<= `SD if_IR0;
		ra_idx0					<= `SD next_ra_idx0;
		rb_idx0 				<= `SD next_rb_idx0;
		rc_idx0 				<= `SD next_rc_idx0;
		branch_taken0		<= `SD if_branch_taken0;
		pred_addr0			<= `SD if_pred_addr0;
		opa_select0 		<= `SD next_opa_select0;
		opb_select0 		<= `SD next_opb_select0;
		dest_idx0 			<= `SD next_dest_idx0;
		alu_func0 			<= `SD next_alu_func0;
		rd_mem0 				<= `SD next_rd_mem0;
		wr_mem0 				<= `SD next_wr_mem0;
		ldl_mem0 				<= `SD next_ldl_mem0;
		stc_mem0 				<= `SD next_stc_mem0;
		cond_branch0 		<= `SD next_cond_branch0;
		uncond_branch0 	<= `SD next_uncond_branch0;
		halt0 					<= `SD next_halt0;
		illegal_inst0 	<= `SD next_illegal_inst0;
		valid_inst0 		<= `SD next_valid_inst0;
		bhr0						<= `SD bht_bhr0;

		npc1 						<= `SD if_NPC1;
		ir1 						<= `SD if_IR1;
		ra_idx1					<= `SD next_ra_idx1;
		rb_idx1 				<= `SD next_rb_idx1;
		rc_idx1 				<= `SD next_rc_idx1;
		branch_taken1		<= `SD if_branch_taken1;
		pred_addr1			<= `SD if_pred_addr1;
		opa_select1 		<= `SD next_opa_select1;
		opb_select1 		<= `SD next_opb_select1;
		dest_idx1 			<= `SD next_dest_idx1;
		alu_func1 			<= `SD next_alu_func1;
		rd_mem1 				<= `SD next_rd_mem1;
		wr_mem1 				<= `SD next_wr_mem1;
		ldl_mem1 				<= `SD next_ldl_mem1;
		stc_mem1 				<= `SD next_stc_mem1;
		cond_branch1 		<= `SD next_cond_branch1;
		uncond_branch1 	<= `SD next_uncond_branch1;
		halt1 					<= `SD next_halt1;
		illegal_inst1 	<= `SD next_illegal_inst1;
		valid_inst1 		<= `SD next_valid_inst1;
		bhr1						<= `SD bht_bhr1;
		end
	else if (dispatch_num[0] && valid_inst1) // One instructions are dispatched
		begin
		npc0 						<= `SD npc1;
		ir0 						<= `SD ir1;
		ra_idx0 				<= `SD ra_idx1;
		rb_idx0 				<= `SD rb_idx1;
		rc_idx0 				<= `SD rc_idx1;
		branch_taken0		<= `SD branch_taken1;
		pred_addr0			<= `SD pred_addr1;
		opa_select0 		<= `SD opa_select1;
		opb_select0	 		<= `SD opb_select1;
		dest_idx0 			<= `SD dest_idx1;
		alu_func0 			<= `SD alu_func1;
		rd_mem0 				<= `SD rd_mem1;
		wr_mem0 				<= `SD wr_mem1;
		ldl_mem0 				<= `SD ldl_mem1;
		stc_mem0		 		<= `SD stc_mem1;
		cond_branch0 		<= `SD cond_branch1;
		uncond_branch0 	<= `SD uncond_branch1;
		halt0 					<= `SD halt1;
		illegal_inst0 	<= `SD illegal_inst1;
		valid_inst0 		<= `SD valid_inst1;
		bhr0						<= `SD bhr1;

		npc1 						<= `SD if_NPC0;
		ir1 						<= `SD if_IR0;
		ra_idx1					<= `SD next_ra_idx0;
		rb_idx1 				<= `SD next_rb_idx0;
		rc_idx1 				<= `SD next_rc_idx0;
		branch_taken1		<= `SD if_branch_taken0;
		pred_addr1			<= `SD if_pred_addr0;
		opa_select1 		<= `SD next_opa_select0;
		opb_select1 		<= `SD next_opb_select0;
		dest_idx1 			<= `SD next_dest_idx0;
		alu_func1 			<= `SD next_alu_func0;
		rd_mem1 				<= `SD next_rd_mem0;
		wr_mem1 				<= `SD next_wr_mem0;
		ldl_mem1 				<= `SD next_ldl_mem0;
		stc_mem1 				<= `SD next_stc_mem0;
		cond_branch1 		<= `SD next_cond_branch0;
		uncond_branch1 	<= `SD next_uncond_branch0;
		halt1 					<= `SD next_halt0;
		illegal_inst1 	<= `SD next_illegal_inst0;
		valid_inst1 		<= `SD next_valid_inst0;
		bhr1						<= `SD bht_bhr0;
		end
	else if (dispatch_num == 2'b0 && valid_inst0 && ~valid_inst1)
	begin
		npc1 						<= `SD if_NPC0;
		ir1 						<= `SD if_IR0;
		ra_idx1					<= `SD next_ra_idx0;
		rb_idx1 				<= `SD next_rb_idx0;
		rc_idx1 				<= `SD next_rc_idx0;
		branch_taken1		<= `SD if_branch_taken0;
		pred_addr1			<= `SD if_pred_addr0;
		opa_select1 		<= `SD next_opa_select0;
		opb_select1 		<= `SD next_opb_select0;
		dest_idx1 			<= `SD next_dest_idx0;
		alu_func1 			<= `SD next_alu_func0;
		rd_mem1 				<= `SD next_rd_mem0;
		wr_mem1 				<= `SD next_wr_mem0;
		ldl_mem1 				<= `SD next_ldl_mem0;
		stc_mem1 				<= `SD next_stc_mem0;
		cond_branch1 		<= `SD next_cond_branch0;
		uncond_branch1 	<= `SD next_uncond_branch0;
		halt1 					<= `SD next_halt0;
		illegal_inst1 	<= `SD next_illegal_inst0;
		valid_inst1 		<= `SD next_valid_inst0;
		bhr1						<= `SD bht_bhr0;
	end
end

endmodule
