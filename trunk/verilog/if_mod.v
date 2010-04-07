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
				bht_branch_taken0,
				bht_branch_taken1,
				btb_pred_addr0,
				btb_pred_addr1,
				bht_bhr0,
				bht_bhr1,
				Imem2proc_data,
				Imem_valid,
				id_dispatch_num,

				// Outputs
				id_NPC0,        // PC+4 of fetched instruction
				id_NPC1,
				id_IR0,         // fetched instruction out
				id_IR1,		//  second fetched instruction out
				proc2Imem_addr,
				id_branch_taken0,
				id_branch_taken1,
				id_pred_addr0,
				id_pred_addr1,
				id_valid_inst0,
				id_valid_inst1,  // when low, instruction is garbage,
				id_bhr0,
				id_bhr1
				);

input         clock;              // system clock
input         reset;              // system reset
// makes pipeline behave as single-cycle
input         bht_branch_taken0; // taken-branch signal
input					bht_branch_taken1;
input  [63:0] btb_pred_addr0;   // target pc: use if take_branch is TRUE
input  [63:0] btb_pred_addr1;
input [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr0;
input [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] bht_bhr1;
input  [63:0] Imem2proc_data;     // Data coming back from instruction-memory
input  			  Imem_valid;
input  [1:0]  id_dispatch_num;		//Whether RS and ROB are busy

output [63:0] proc2Imem_addr;     // Address sent to Instruction memory
output [63:0] id_NPC0;         // PC of instruction after fetched (PC+4).
output [63:0] id_NPC1;
output [31:0] id_IR0;          // fetched instruction
output [31:0] id_IR1;
output  		 id_valid_inst0;
output				id_valid_inst1;
output				id_branch_taken0;
output				id_branch_taken1;
output	[63:0]			id_pred_addr0;
output	[63:0]			id_pred_addr1;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] id_bhr0;
output [`LOG_NUM_BHT_PATTERN_ENTRIES-1:0] id_bhr1;
reg    [63:0] PC_reg;               // PC we are currently fetching

wire   [63:0] PC_plus_4;
wire	 [63:0] PC_plus_8;
wire          PC_enable0;
wire					PC_enable1;
wire          next_ready_for_valid;


reg		 [63:0]	next_PC;
reg						id_valid_inst0;
reg						id_valid_inst1;

assign id_bhr0 = bht_bhr0;
assign id_bhr1 = bht_bhr1;
//wire [1:0] busy =  2'd2 - id_dispatch_num;
assign proc2Imem_addr = {PC_reg[63:3], 3'b0};
//
// this mux is because the Imem gives us 64 bits not 32 bits
assign id_IR0 = PC_reg[2] ? Imem2proc_data[63:32] : Imem2proc_data[31:0];
assign id_IR1 = Imem2proc_data[63:32];
// default next PC value
assign PC_plus_4 = PC_reg + 4;
assign PC_plus_8 = PC_reg + 8;
// next PC is target_pc if there is a taken branch or
// the next sequential PC (PC+4) if no branch
// (halting is handled with the enable PC_enable;

//assign next_PC = id_dispatch_num[1] ? PC_plus_8: id_dispatch_num[0] ? PC_plus_4 : PC_reg;

always @*
begin
	if (Imem_valid)
	begin
		if (PC_reg[2])
		begin
			id_valid_inst0 = 1;
			id_valid_inst1 = 0;
			if (id_dispatch_num[0] | id_dispatch_num[1])
				next_PC = PC_plus_4;
			else
				next_PC = PC_reg;
		end
		else
		begin
			id_valid_inst0 = 1;
			id_valid_inst1 = 1;
			if (id_dispatch_num[1])
				next_PC = PC_plus_8;
			else if (id_dispatch_num[0])
				next_PC = PC_plus_4;
			else
				next_PC = PC_reg;
		end
	end
	else
	begin
		next_PC = PC_reg;
		id_valid_inst0 = 0;
		id_valid_inst1 = 0;
	end
end

// The take-branch signal must override stalling (otherwise it may be lost)
assign PC_enable0 = id_valid_inst0 ;//| bht_branch_taken0;
assign PC_enable1 = id_valid_inst1 ;//| bht_branch_taken1;
    // Pass PC+4 down pipeline w/instruction
	// I don't know what is going on here.......
//assign id_NPC0 = (id_dispatch_num[1] |id_dispatch_num[0]) ? PC_plus_4 : PC_reg;
//assign id_NPC1 = PC_plus_8;
assign id_NPC0 = PC_plus_4;
assign id_NPC1 = PC_plus_8;

//assign id_valid_inst0 = Imem_valid;
//assign id_valid_inst1 = Imem_valid&~PC_reg[2];



assign  id_branch_taken0 = 0;
assign  id_branch_taken1 = 0;
assign  id_pred_addr0 = 0;
assign  if_pred_addr1 = 0;


// This register holds the PC value
always @(posedge clock)
begin
	if(reset)
		PC_reg <= `SD 0;       // initial PC value is 0
	else if(PC_enable0|PC_enable1)
		PC_reg <= `SD next_PC; // transition to next PC
	end  // always

    //
endmodule  // module if_stage
