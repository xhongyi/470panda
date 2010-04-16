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
      `ALU_CMPULE: result = { 63'd0, (opa == opb) };
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
      2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) = 0)
    endcase
  
     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond


module alu_sim(// Inputs
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
								rs_alu_func0,
								rs_alu_func1,
								rs_cond_branch0,
								rs_cond_branch1,
								rs_uncond_branch0,
								rs_uncond_branch1,
								rs_branch_taken0,
								rs_branch_taken1,
								rs_pred_addr0,
								rs_pred_addr1,
								rs_valid_inst0,
								rs_valid_inst1,
								// Outputs
								cdb_complete0,
								cdb_complete1,
								cdb_dest_ar_idx0,
								cdb_dest_ar_idx1,
								cdb_prf_dest_pr_idx0,
								cdb_prf_dest_pr_idx1,
								cdb_exception0,
								cdb_exception1,
								
								cdb_actual_addr0,//new
								cdb_actual_taken0,//new
								cdb_actual_addr1,//new
								cdb_actual_taken1,//new
								
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

  input   [4:0] rs_alu_func0;      // ALU function select from decoder
  input   [4:0] rs_alu_func1;      // ALU function select from decoder

  input         rs_cond_branch0;   // is this a cond br? from decoder
  input         rs_cond_branch1;   // is this a cond br? from decoder
  
  input         rs_uncond_branch0; // is this an uncond br? from decoder
  input         rs_uncond_branch1; // is this an uncond br? from decoder
	input					rs_branch_taken0;
	input					rs_branch_taken1;
	input	[63:0]	rs_pred_addr0;
	input	[63:0]	rs_pred_addr1;
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
	output				cdb_exception0;
	output			  cdb_exception1;
	output	[63:0]	cdb_actual_addr0;//new
	output	[63:0]	cdb_actual_addr1;//new
	output					cdb_actual_taken0;//new
	output					cdb_actual_taken1;//new
  output [1:0]	rs_alu_avail;
	
	//Output Registers
	reg [63:0] prf_result0;   // ALU result
	reg [63:0] prf_result1;   // ALU result
	reg 				prf_write_enable0;
	reg				prf_write_enable1;
	reg				cdb_complete0;
	reg				cdb_complete1;
	reg		[4:0]	cdb_dest_ar_idx0;
	reg		[4:0]	cdb_dest_ar_idx1;
	reg		[6:0]	cdb_prf_dest_pr_idx0;
	reg		[6:0]	cdb_prf_dest_pr_idx1;
	reg				cdb_exception0;
	reg			  cdb_exception1;
	reg		[63:0]	cdb_actual_addr0;
	reg		[63:0]	cdb_actual_addr1;
	reg						cdb_actual_taken0;
	reg						cdb_actual_taken1;
  reg [1:0]		rs_alu_avail;
	
	//Update registers
	reg [63:0] next_prf_result0;
	reg [63:0] next_prf_result1;
	reg 			next_prf_write_enable0;
	reg				next_prf_write_enable1;
	reg				next_cdb_complete0;
	reg				next_cdb_complete1;
	reg	[4:0]	next_cdb_dest_ar_idx0;
	reg	[4:0]	next_cdb_dest_ar_idx1;
	reg	[6:0]	next_cdb_prf_dest_pr_idx0;
	reg	[6:0]	next_cdb_prf_dest_pr_idx1;
	reg	    	next_cdb_exception0;
	reg			  next_cdb_exception1;
  reg [1:0]	next_rs_alu_avail;
  reg	[63:0]	next_cdb_actual_addr0;
  reg	[63:0]	next_cdb_actual_addr1;
  reg					next_cdb_actual_taken0;
  reg					next_cdb_actual_taken1;
	
	wire [63:0] alu_result0;//new
	wire [63:0] alu_result1;//new
	
	
	

  reg    [63:0] opa_mux_out0, opa_mux_out1, opb_mux_out0, opb_mux_out1;
  wire          brcond_result0, brcond_result1;
  wire					ex_take_branch_out0, ex_take_branch_out1; //modified
   // set up possible immediates:
   //   mem_disp: sign-extended 16-bit immediate for memory format
   //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
   //   alu_imm: zero-extended 8-bit immediate for ALU ops
  wire [63:0] mem_disp0 = { {48{rs_IR0[15]}}, rs_IR0[15:0] };
  wire [63:0] br_disp0  = { {41{rs_IR0[20]}}, rs_IR0[20:0], 2'b00 };
  wire [63:0] alu_imm0  = { 56'b0, rs_IR0[20:13] };
  //Second copy for the second set of instructions
  wire [63:0] mem_disp1 = { {48{rs_IR1[15]}}, rs_IR1[15:0] };
  wire [63:0] br_disp1  = { {41{rs_IR1[20]}}, rs_IR1[20:0], 2'b00 };
  wire [63:0] alu_imm1  = { 56'b0, rs_IR1[20:13] };
   //
   // ALU opA mux
   //
	always @*
	begin
		next_cdb_complete0 = 1;
		next_cdb_complete1 = 1;
		next_cdb_dest_ar_idx0 = rs_dest_ar_idx0;
		next_cdb_dest_ar_idx1 = rs_dest_ar_idx1;
		next_cdb_prf_dest_pr_idx0 = rs_dest_pr_idx0;
		next_cdb_prf_dest_pr_idx1 = rs_dest_pr_idx1;
		next_rs_alu_avail = 2'b11;
		next_cdb_complete0 = rs_valid_inst0;
		next_cdb_complete1 = rs_valid_inst1;
		next_cdb_actual_addr0 = alu_result0;
		next_cdb_actual_addr1 = alu_result1;
		next_cdb_actual_taken0 = ex_take_branch_out0;
		next_cdb_actual_taken1 = ex_take_branch_out1;
		next_prf_write_enable0 = rs_valid_inst0;
		next_prf_write_enable1 = rs_valid_inst1;
		if (rs_dest_ar_idx0 == `ZERO_REG)
			next_prf_result0 = 64'd0;
		else if (ex_take_branch_out0)
			next_prf_result0 = rs_NPC0;
		else
			next_prf_result0 = alu_result0;
		if (rs_dest_ar_idx1 == `ZERO_REG)
			next_prf_result1 = 64'd0;
		else if (ex_take_branch_out1)
			next_prf_result1 = rs_NPC0;
		else
			next_prf_result1 = alu_result1;
  end
  always @*
  begin
    case (rs_opa_select0)
      `ALU_OPA_IS_REGA:
											      begin
											     		if (rs_cond_branch0)
											     			opa_mux_out0 = rs_NPC0;
											     		else
											     			opa_mux_out0 = prf_pra0;
											     	end
      `ALU_OPA_IS_MEM_DISP: opa_mux_out0 = mem_disp0;
      `ALU_OPA_IS_NPC:      opa_mux_out0 = rs_NPC0;
      `ALU_OPA_IS_NOT3:     opa_mux_out0 = ~64'h3;
    endcase
		case (rs_opa_select1)
      `ALU_OPA_IS_REGA:
     									      begin
											     		if (rs_cond_branch1)
											     			opa_mux_out1 = rs_NPC1;
											     		else
											     			opa_mux_out1 = prf_pra1;
											     	end
      `ALU_OPA_IS_MEM_DISP: opa_mux_out1 = mem_disp1;
      `ALU_OPA_IS_NPC:      opa_mux_out1 = rs_NPC1;
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
    case (rs_opb_select0)
      `ALU_OPB_IS_REGB:    opb_mux_out0 = prf_prb0;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out0 = alu_imm0;
      `ALU_OPB_IS_BR_DISP: opb_mux_out0 = br_disp0;
    endcase 
	case (rs_opb_select1)
      `ALU_OPB_IS_REGB:    opb_mux_out1 = prf_prb1;
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
             .func(rs_alu_func0),

             // Output
             .result(alu_result0)
            );
  alu alu_1 (// Inputs
             .opa(opa_mux_out1),
             .opb(opb_mux_out1),
             .func(rs_alu_func1),

             // Output
             .result(alu_result1)
            );
   //
   // instantiate the branch condition tester
   //
  brcond brcond0 (// Inputs
                .opa(prf_pra0),       // always check regA value
                .func(rs_IR0[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result0)
               );
  brcond brcond1 (// Inputs
                .opa(prf_pra1),       // always check regA value
                .func(rs_IR1[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result1)
               );

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign ex_take_branch_out0 = rs_uncond_branch0
                          | (rs_cond_branch0 & brcond_result0);
  assign ex_take_branch_out1 = rs_uncond_branch1
                          | (rs_cond_branch1 & brcond_result1);
	
	//deal with branch exception:												
always @*
begin
next_cdb_exception0 = 1'd0;
next_cdb_exception1 = 1'd0;
	if (rs_cond_branch0)
	begin
		if (rs_branch_taken0 ^ ex_take_branch_out0)
			next_cdb_exception0 = 1'd1;
	end
	if (rs_cond_branch1)
	begin
		if (rs_branch_taken1 ^ ex_take_branch_out1)
			next_cdb_exception1 = 1'd1;
	end
	if (rs_uncond_branch0)
	begin
		if (rs_pred_addr0 != alu_result0)
			next_cdb_exception0 = 1'd1;
	end
	if (rs_uncond_branch1)
	begin
		if (rs_pred_addr1 != alu_result1)
			next_cdb_exception1 = 1'd1;
	end
end//end always
												
always @* //Sequential logic
begin
	cdb_complete0 = 0;
	cdb_complete1 = 0;
	cdb_dest_ar_idx0 = 0;
	cdb_dest_ar_idx1 = 0;
	cdb_prf_dest_pr_idx0 = 0;
	cdb_prf_dest_pr_idx1 =0;
	cdb_exception0 = 0;
	cdb_exception1 = 0;
	prf_result0 = 0;
	prf_result1 = 0;
	prf_write_enable0 = 0;
	prf_write_enable1 = 0;
	rs_alu_avail = 0;
	cdb_actual_addr0 = 0;
	cdb_actual_addr1 = 0;
	cdb_actual_taken0 = 0;
	cdb_actual_taken1 = 0;

	rs_alu_avail = next_rs_alu_avail;
	if(rs_valid_inst0)
	begin
		cdb_complete0 = next_cdb_complete0;
		cdb_dest_ar_idx0 = next_cdb_dest_ar_idx0;
		cdb_prf_dest_pr_idx0 = next_cdb_prf_dest_pr_idx0;
		cdb_exception0 = next_cdb_exception0;
		prf_result0 = next_prf_result0;
		prf_write_enable0 = next_prf_write_enable0;
		cdb_actual_addr0 = next_cdb_actual_addr0;
		cdb_actual_taken0 = next_cdb_actual_taken0;
	end
	if(rs_valid_inst1)
	begin
			cdb_complete1 = next_cdb_complete1;
			cdb_dest_ar_idx1 = next_cdb_dest_ar_idx1;
			cdb_prf_dest_pr_idx1 = next_cdb_prf_dest_pr_idx1;
			cdb_exception1 = next_cdb_exception1;
			prf_result1 = next_prf_result1;
			prf_write_enable1 = next_prf_write_enable1;
			cdb_actual_addr1 = next_cdb_actual_addr1;
			cdb_actual_taken1 = next_cdb_actual_taken1;
	end
end

endmodule // module ex_stage

