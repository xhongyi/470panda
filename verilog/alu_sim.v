//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  ex_stage.v                                           //
//                                                                      //
//  Description :  instruction execute (EX) stage of the pipeline;      //
//                 given the instruction command code CMD, select the   //
//                 proper input A and B for the ALU, compute the result,// 
//                 and compute the condition for branches, and pass all //
//                 the results down the pipeline.                       // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

//
// The ALU
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is purely combinational
//
module alu(//Inputs
           opa,
           opb,
           func,
           
           // Output
           result
          );

  input  [63:0] opa;
  input  [63:0] opb;
  input   [4:0] func;
  output [63:0] result;

  reg    [63:0] result;

    // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;
    
    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always @*
  begin
    case (func)
      `ALU_ADDQ:   result = opa + opb;
      `ALU_SUBQ:   result = opa - opb;
      `ALU_AND:    result = opa & opb;
      `ALU_BIC:    result = opa & ~opb;
      `ALU_BIS:    result = opa | opb;
      `ALU_ORNOT:  result = opa | ~opb;
      `ALU_XOR:    result = opa ^ opb;
      `ALU_EQV:    result = opa ^ ~opb;
      `ALU_SRL:    result = opa >> opb[5:0];
      `ALU_SLL:    result = opa << opb[5:0];
      `ALU_SRA:    result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                             opb[5:0])); // arithmetic from logical shift
     // `ALU_MULQ:   result = opa * opb;
      `ALU_CMPULT: result = { 63'd0, (opa < opb) };
      `ALU_CMPEQ:  result = { 63'd0, (opa == opb) };
      `ALU_CMPULE: result = { 63'd0, (opa <= opb) };
      `ALU_CMPLT:  result = { 63'd0, signed_lt(opa, opb) };
      `ALU_CMPLE:  result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:     result = 64'hdeadbeefbaadbeef; // here only to force
                                                  // a combinational solution
                                                  // a casex would be better
    endcase
  end
endmodule // alu

//
// BrCond module
//
// Given the instruction code, compute the proper condition for the
// instruction; for branches this condition will indicate whether the
// target is taken.
//
// This module is purely combinational
//
module brcond(// Inputs
              opa,        // Value to check against condition
              func,       // Specifies which condition to check

              // Output
              cond        // 0/1 condition result (False/True)
             );

  input   [2:0] func;
  input  [63:0] opa;
  output        cond;
  
  reg           cond;

  always @*
  begin
    case (func[1:0]) // 'full-case'  All cases covered, no need for a default
      2'b00: cond = (opa[0] == 0);  // LBC: (lsb(opa) == 0) ?
      2'b01: cond = (opa == 0);     // EQ: (opa == 0) ?
      2'b10: cond = (opa[63] == 1); // LT: (signed(opa) < 0) : check sign bit
      2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) <= 0)
    endcase
  
     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond


module sim(// Inputs
                clock,
                reset,
                rs_sim_NPC0,
				rs_sim_NPC1,
                rs_sim_IR0,
				rs_sim_IR1,
                rs_sim_pra0,
				rs_sim_pra1,
                rs_sim_prb0,
				rs_sim_prb1,
                rs_sim_opa_select0,
				rs_sim_opa_select1,
                rs_sim_opb_select0,
				rs_sim_opb_select1,
                rs_sim_alu_func0,
				rs_sim_alu_func1,
                rs_sim_cond_branch0,
				rs_sim_cond_branch1,
                rs_sim_uncond_branch0,
				rs_sim_uncond_branch1,
                
                // Outputs
                sim_alu_result_out0,
				sim_alu_result_out1,
                sim_take_branch_out0,
				sim_take_branch_out1
               );

  input         clock;               // system clock
  input         reset;               // system reset
  input  [63:0] rs_sim_NPC0;           // incoming instruction PC+4
  input  [63:0] rs_sim_NPC1;           // incoming instruction PC+4
  input  [31:0] rs_sim_IR0;            // incoming instruction
  input  [31:0] rs_sim_IR1;            // incoming instruction
  input  [63:0] rs_sim_pra0;          // register A value from reg file   
  input  [63:0] rs_sim_pra1;          // register A value from reg file

  input  [63:0] rs_sim_prb0;          // register B value from reg file
  input  [63:0] rs_sim_prb1;          // register B value from reg file

  input   [1:0] rs_sim_opa_select0;    // opA mux select from decoder
  input   [1:0] rs_sim_opa_select1;    // opA mux select from decoder

  input   [1:0] rs_sim_opb_select0;    // opB mux select from decoder
  input   [1:0] rs_sim_opb_select1;    // opB mux select from decoder

  input   [4:0] rs_sim_alu_func0;      // ALU function select from decoder
  input   [4:0] rs_sim_alu_func1;      // ALU function select from decoder

  input         rs_sim_cond_branch0;   // is this a cond br? from decoder
  input         rs_sim_cond_branch1;   // is this a cond br? from decoder
  
  input         rs_sim_uncond_branch0; // is this an uncond br? from decoder
  input         rs_sim_uncond_branch1; // is this an uncond br? from decoder


  output [63:0] sim_alu_result_out0;   // ALU result
  output [63:0] sim_alu_result_out1;   // ALU result

  output        sim_take_branch_out0;  // is this a taken branch?
  output        sim_take_branch_out1;  // is this a taken branch?
  //output [1:0]		rs_alu_ready;

  reg    [63:0] opa_mux_out0, opa_mux_out1, opb_mux_out0, opb_mux_out1;
  wire          brcond_result0, brcond_result1;
   
   // set up possible immediates:
   //   mem_disp: sign-extended 16-bit immediate for memory format
   //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
   //   alu_imm: zero-extended 8-bit immediate for ALU ops
  wire [63:0] mem_disp0 = { {48{rs_sim_IR0[15]}}, rs_sim_IR0[15:0] };
  wire [63:0] br_disp0  = { {41{rs_sim_IR0[20]}}, rs_sim_IR0[20:0], 2'b00 };
  wire [63:0] alu_imm0  = { 56'b0, rs_sim_IR0[20:13] };
  //Second copy for the second set of instructions
  wire [63:0] mem_disp1 = { {48{rs_sim_IR1[15]}}, rs_sim_IR1[15:0] };
  wire [63:0] br_disp1  = { {41{rs_sim_IR1[20]}}, rs_sim_IR1[20:0], 2'b00 };
  wire [63:0] alu_imm1  = { 56'b0, rs_sim_IR1[20:13] };
   //
   // ALU opA mux
   //
  always @*
  begin
    case (rs_sim_opa_select0)
      `ALU_OPA_IS_REGA:     opa_mux_out0 = rs_sim_pra0;
      `ALU_OPA_IS_MEM_DISP: opa_mux_out0 = mem_disp0;
      `ALU_OPA_IS_NPC:      opa_mux_out0 = rs_sim_NPC0;
      `ALU_OPA_IS_NOT3:     opa_mux_out0 = ~64'h3;
    endcase
	case (rs_sim_opa_select1)
      `ALU_OPA_IS_REGA:     opa_mux_out1 = rs_sim_pra1;
      `ALU_OPA_IS_MEM_DISP: opa_mux_out1 = mem_disp1;
      `ALU_OPA_IS_NPC:      opa_mux_out1 = rs_sim_NPC1;
      `ALU_OPA_IS_NOT3:     opa_mux_out1 = ~64'h3;
    endcase
  end

   //
   // ALU opB mux select
   //
  always @*
  begin
     // Default value, Set only because the case isnt full.  If you see this
     // value on the output of the mux you have an invalid opb_select
    opb_mux_out0 = 64'hbaadbeefdeadbeef;
	opb_mux_out1 = 64'hbaadbeefdeadbeef;
    case (rs_sim_opb_select0)
      `ALU_OPB_IS_REGB:    opb_mux_out0 = rs_sim_prb0;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out0 = alu_imm0;
      `ALU_OPB_IS_BR_DISP: opb_mux_out0 = br_disp0;
    endcase 
	case (rs_sim_opb_select1)
      `ALU_OPB_IS_REGB:    opb_mux_out1 = rs_sim_prb1;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out1 = alu_imm1;
      `ALU_OPB_IS_BR_DISP: opb_mux_out1 = br_disp1;
    endcase
  end

   //
   // instantiate the ALU
   //
  alu alu_0 (// Inputs
             .opa(opa_mux_out0),
             .opb(opb_mux_out0),
             .func(rs_sim_alu_func0),

             // Output
             .result(sim_alu_result_out0)
            );
  alu alu_1 (// Inputs
             .opa(opa_mux_out1),
             .opb(opb_mux_out1),
             .func(rs_sim_alu_func1),

             // Output
             .result(sim_alu_result_out1)
            );
   //
   // instantiate the branch condition tester
   //
  brcond brcond0 (// Inputs
                .opa(rs_sim_pra0),       // always check regA value
                .func(rs_sim_IR0[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result0)
               );
  brcond brcond1 (// Inputs
                .opa(rs_sim_pra1),       // always check regA value
                .func(rs_sim_IR1[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result1)
               );

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign ex_take_branch_out0 = rs_sim_uncond_branch0
                          | (rs_sim_cond_branch0 & brcond_result0);
  assign ex_take_branch_out1 = rs_sim_uncond_branch1
                          | (rs_sim_cond_branch1 & brcond_result1);

endmodule // module ex_stage

