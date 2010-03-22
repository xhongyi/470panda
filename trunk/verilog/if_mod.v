/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if.v                                          //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       // 
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module if_mod(// Inputs
                clock,
                reset,
                ex_mem_take_branch0,
				ex_mem_take_branch1,
                ex_mem_target_pc0,
				ex_mem_target_pc1,
                Imem2proc_data,
                Imem_valid,
				busy,
                    
                // Outputs
                if_NPC_out,        // PC+4 of fetched instruction
                if_IR_out0,         // fetched instruction out
				if_IR_out1,		//  second fetched instruction out
                proc2Imem_addr,
                if_valid_inst_out0,
				if_valid_inst_out1  // when low, instruction is garbage
               );

  input         clock;              // system clock
  input         reset;              // system reset
                                      // makes pipeline behave as single-cycle
  input         ex_mem_take_branch0; // taken-branch signal
  input			ex_mem_take_branch1;
  input  [63:0] ex_mem_target_pc0;   // target pc: use if take_branch is TRUE
  input  [63:0] ex_mem_target_pc1;
  input  [63:0] Imem2proc_data;     // Data coming back from instruction-memory
  input  [1:0]  Imem_valid;
  input  [1:0]  busy;		//Whether RS and ROB are busy

  output [63:0] proc2Imem_addr;     // Address sent to Instruction memory
  output [63:0] if_NPC_out;         // PC of instruction after fetched (PC+4).
  output [31:0] if_IR_out0;          // fetched instruction
  output [31:0] if_IR_out1;
  output        if_valid_inst_out0;
  output		if_valid_inst_out1;

  reg    [63:0] PC_reg;               // PC we are currently fetching

  wire   [63:0] PC_plus_4;
  wire   [63:0] next_PC;
  wire          PC_enable;
  wire          next_ready_for_valid;
   
  assign proc2Imem_addr = {PC_reg[63:3], 3'b0};

    // this mux is because the Imem gives us 64 bits not 32 bits
  assign if_IR_out0 = PC_reg[2] ? Imem2proc_data[63:32] : Imem2proc_data[31:0];
  assign if_IR_out1 = Imem2proc_data[31:0];
    // default next PC value
  assign PC_plus_4 = PC_reg + 4;
  assign PC_plus_8 = PC_reg + 8;
    // next PC is target_pc if there is a taken branch or
    // the next sequential PC (PC+4) if no branch
    // (halting is handled with the enable PC_enable;
  
  assign next_PC = busy[1] ? PC_reg: busy[0] ? PC_plus_4 : PC_plus_8;

    // The take-branch signal must override stalling (otherwise it may be lost)
  assign PC_enable0 = if_valid_inst_out0 ;//| ex_mem_take_branch0;
  assign PC_enable1 = if_valid_inst_out1 ;//| ex_mem_take_branch1;
    // Pass PC+4 down pipeline w/instruction
	// I don't know what is going on here.......
  assign if_NPC_out = busy[1] ? PC_reg : busy[0] ? PC_plus_4 : PC_plus_8;

	assign    if_valid_inst_out0 =  ~busy[1];
	assign	  if_valid_inst_out1 =  ~(busy[1]|busy[0]);	
  
  // This register holds the PC value
  always @(posedge clock)
  begin
    if(reset)
      PC_reg <= `SD 0;       // initial PC value is 0
    else if(PC_enable)
      PC_reg <= `SD next_PC; // transition to next PC
  end  // always

    //
endmodule  // module if_stage
