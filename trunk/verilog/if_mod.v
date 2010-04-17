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


module if_mod(// Inputs
				clock,
				reset,
				bht_branch_taken0,
				bht_branch_taken1,
				btb_pred_addr0,
				btb_pred_addr1,
				Imem2proc_data,
				Imem_valid,
				id_dispatch_num,
				
				recover,
				recover_addr,

				// Outputs
				id_bht_NPC0,        // PC+4 of fetched instruction
				id_bht_NPC1,
				id_IR0,         // fetched instruction out
				id_IR1,		//  second fetched instruction out
				proc2Imem_addr,
				id_branch_taken0,
				id_branch_taken1,
				id_pred_addr0,
				id_pred_addr1,
				id_valid_inst0,
				id_valid_inst1,  // when low, instruction is garbage,
				bht_valid_cond0,//new
				bht_valid_cond1//new
				);

input																			clock;              // system clock
input																			reset;              // system reset
// makes pipeline behave as single-cycle
input																			bht_branch_taken0; // taken-branch signal
input																			bht_branch_taken1;
input	[63:0]															btb_pred_addr0;   // target pc: use if take_branch is TRUE
input	[63:0]															btb_pred_addr1;
input	[63:0]															Imem2proc_data;     // Data coming back from instruction-memory
input																			Imem_valid;
input	[1:0]																id_dispatch_num;		//Whether RS and ROB are busy

input																			recover;			//new
input	[63:0]															recover_addr;		//new

output	[63:0]														proc2Imem_addr;     // Address sent to Instruction memory
output	[63:0]														id_bht_NPC0;         // PC of instruction after fetched (PC+4).
output	[63:0]														id_bht_NPC1;
output	[31:0]														id_IR0;          // fetched instruction
output	[31:0]														id_IR1;
output																		id_valid_inst0;
output																		id_valid_inst1;
output																		id_branch_taken0;
output																		id_branch_taken1;
output	[63:0]														id_pred_addr0;
output	[63:0]														id_pred_addr1;
output																		bht_valid_cond0;	//new
output																		bht_valid_cond1;	//new

reg	[63:0]																PC_reg;               // PC we are currently fetching

wire																			id_branch_taken0;
wire																			id_branch_taken1;
wire	[63:0]															id_pred_addr0;
wire	[63:0]															id_pred_addr1;

wire	[63:0]															PC_plus_4;
wire	[63:0]															PC_plus_8;
wire																			PC_enable0;
wire																			PC_enable1;
wire																			next_ready_for_valid;

wire																			IR0_jump;
wire																			IR1_jump;
wire																			IR0_uncond;
wire																			IR1_uncond;
wire																			IR0_cond;
wire																			IR1_cond;

wire	[63:0]															branch_pred0;
wire	[63:0]															branch_pred1;

reg																				valid_jump0;	//new
reg																				valid_jump1;	//new

reg																				bht_valid_cond0;//new
reg																				bht_valid_cond1;//new

reg	[63:0]																next_PC;
reg																				id_valid_inst0;
reg																				id_valid_inst1;

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

assign id_bht_NPC0 = PC_plus_4;
assign id_bht_NPC1 = PC_plus_8;
assign	IR0_uncond = ((id_IR0[31:26] == `BR_INST) | (id_IR0[31:26] == `BSR_INST));
assign	IR1_uncond = ((id_IR1[31:26] == `BR_INST) | (id_IR1[31:26] == `BSR_INST));
assign	IR0_cond = (((id_IR0[31:29] == 3'd6) | (id_IR0[31:29] == 3'd7)) & ~IR0_uncond)? 1'd1 : 1'd0;
assign	IR1_cond = (((id_IR1[31:29] == 3'd6) | (id_IR1[31:29] == 3'd7)) & ~IR1_uncond)? 1'd1 : 1'd0;
assign	IR0_jump = (id_IR0[31:26] == `JSR_GRP);
assign	IR1_jump = (id_IR1[31:26] == `JSR_GRP);

assign	branch_pred0 = id_bht_NPC0 + {{41{id_IR0[20]}},id_IR0[20:0],2'b00};
assign	branch_pred1 = id_bht_NPC1 + {{41{id_IR1[20]}},id_IR1[20:0],2'b00};

assign	id_branch_taken0 = bht_branch_taken0;
assign	id_branch_taken1 = bht_branch_taken1;
assign	id_pred_addr0 = (valid_jump0)? btb_pred_addr0 : branch_pred0;
assign	id_pred_addr1 = (valid_jump1)? btb_pred_addr1 : branch_pred1;

always @*
begin
//default: ID need none
	bht_valid_cond0 = 0;//new
	bht_valid_cond1 = 0;//new
	valid_jump0 = 0;//new
	valid_jump1 = 0;//new
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	next_PC = PC_reg;
	if (Imem_valid)
	begin
		if (PC_reg[2])//current PC is a odd number
		begin
			if (id_dispatch_num[0] | id_dispatch_num[1]) begin//id needs either one or two
				id_valid_inst0 = 1'b1;
				
				if (IR0_uncond) begin//IR0 is uncond branch
					next_PC = branch_pred0;
				end
				else if (IR0_cond) begin//IR0 is cond branch
					bht_valid_cond0 = 1'b1;
					if (bht_branch_taken0)//branch0 taken
						next_PC = branch_pred0;
					else//branch0 not taken
						next_PC = PC_plus_4;
				end
				else if (IR0_jump) begin//IR0 is jump
					valid_jump0 = 1'b1;
					next_PC = btb_pred_addr0;
				end
				else//IR0 is neither jump nor branch(cond or uncond)
					next_PC = PC_plus_4;
			end
		end
		
		else//current PC is a even number
		begin
			if (id_dispatch_num[1]) begin//id needs two
				id_valid_inst0 = 1'b1;
				
				if(IR0_uncond) begin//IR0 is uncond branch
					next_PC = branch_pred0;
				end
				
				else if (IR0_cond) begin//IR0 is cond branch
					bht_valid_cond0 = 1'b1;
					
					if (bht_branch_taken0)//branch0 is taken
						next_PC = branch_pred0;
					else begin//branch0 is not taken
						id_valid_inst1 = 1'b1;
						
						if (IR1_uncond) begin//IR1 is uncond branch
							next_PC = branch_pred1;
						end
						else if (IR1_cond) begin//IR1 is cond branch
							bht_valid_cond1 = 1'b1;
							
							if (bht_branch_taken1)//branch1 is taken
								next_PC = branch_pred1;
							else//branch1 is not taken
								next_PC = PC_plus_8;
						end
						else if (IR1_jump) begin//IR1 is jump
							valid_jump1 = 1'b1;
							next_PC = btb_pred_addr1;
						end
						else//IR1 is neither jump nor branch(cond or uncond)
						next_PC = PC_plus_8;
					end
				end
				
				else if (IR0_jump) begin//IR0 is jump
					valid_jump0 = 1'b1;
					next_PC = btb_pred_addr0;
				end
				
				else begin//IR0 neither branch nor jump
					id_valid_inst1 = 1'b1;
					
					if (IR1_uncond) begin//IR1 is uncond branch
						next_PC = branch_pred1;
					end
					else if (IR1_cond) begin//IR1 is cond branch
						bht_valid_cond1 = 1'b1;
						
						if(bht_branch_taken1)//branch1 is taken
							next_PC = branch_pred1;
						else// branch1 is not taken
							next_PC = PC_plus_8;
					end
					else if (IR1_jump) begin//IR1 is jump
						valid_jump1 = 1'b1;
						next_PC = btb_pred_addr1;
					end
					else//IR1 is neither branch nor jump
						next_PC = PC_plus_8;
				end
			end
			else if (id_dispatch_num[0]) begin//id needs one
				id_valid_inst0 = 1'b1;
				
				if (IR0_cond) begin
					bht_valid_cond0 = 1'b1;
					
					if (bht_branch_taken0)
						next_PC = branch_pred0;
					else
						next_PC = PC_plus_4;
				end
				else if (IR0_jump) begin
					valid_jump0 = 1'b1;
					next_PC = btb_pred_addr0;
				end
				else
					next_PC = PC_plus_4;
			end
		end
	end
end//end always @*

// The take-branch signal must override stalling (otherwise it may be lost)
assign PC_enable0 = id_valid_inst0 ;//| bht_branch_taken0;
assign PC_enable1 = id_valid_inst1 ;//| bht_branch_taken1;
    // Pass PC+4 down pipeline w/instruction
	// I don't know what is going on here.......
//assign id_bht_NPC0 = (id_dispatch_num[1] |id_dispatch_num[0]) ? PC_plus_4 : PC_reg;
//assign id_bht_NPC1 = PC_plus_8;

//assign id_valid_inst0 = Imem_valid;
//assign id_valid_inst1 = Imem_valid&~PC_reg[2];

// This register holds the PC value
always @(posedge clock)
begin
	if(reset)
		PC_reg <= `SD 0;       // initial PC value is 0
	else if(recover)
		PC_reg <= `SD recover_addr;
	else
		PC_reg <= `SD next_PC; // transition to next PC
end  // always

endmodule  // module if_stage
