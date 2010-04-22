/////what if jump to a odd number address?
/////Question: is there any posibility that pc1 is not pc0+4? (newpc could be resolve within one cycle??)

//currently is implemented as a direct mapped caches with 1024 entries


module btb(//inputs
					clock,
					reset,
					
					if_NPC0,
					if_NPC1,//not implemented yet
					
					recover_uncond,
					recover_NPC,
					recover_actual_addr,

//				rob_retire_jump1,
//				rob_retire_pc1,
//				rob_cre_npc1,
					
					//outputs
					if_pred_addr0,
					if_pred_addr1
					);
`ifndef NUM_BTB_ENTRIES
`define	NUM_BTB_ENTRIES	128
`endif

`ifndef	LOG_NUM_BTB_ENTRIES
`define	LOG_NUM_BTB_ENTRIES	7
`endif

input	clock;
input	reset;

input	[63:0]					if_NPC0;//current PC
input [63:0]					if_NPC1;

input									recover_uncond;//the retired instruction.
input	[63:0]					recover_NPC;
input	[63:0]					recover_actual_addr;

/*
input									rob_retire_jump1;//the retired instruction.
input	[63:0]					rob_retire_pc1;
input	[63:0]					rob_cre_npc1;
*/

output	[63:0]				if_pred_addr0;//the predictied npc
output	[63:0]				if_pred_addr1;

/*
reg	[`TAG_LENGTH-1:0]	tag							[`NUM_BTB_ENTRIES-1:0];
reg	[`TAG_LENGTH-1:0]	next_tag				[`NUM_BTB_ENTRIES-1:0];
*/
reg	[63:0]						br				[`NUM_BTB_ENTRIES-1:0];//branch displacement (I ignored the fact that branch ins may branch to a unaliased address)
reg	[63:0]						next_br		[`NUM_BTB_ENTRIES-1:0];

wire	[63:0]					if_pred_addr0;
wire	[63:0]					if_pred_addr1;

integer i;

assign if_pred_addr0 = br[if_NPC0[`LOG_NUM_BTB_ENTRIES+1:2]];
assign if_pred_addr1 = br[if_NPC1[`LOG_NUM_BTB_ENTRIES+1:2]];

always @* begin
	for(i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
//		next_tag[i] = tag[i];
		next_br[i] = br[i];
	end

//correct the BTB if there is a mispredicted branch.	
/*
	if (rob_retire_jump0 && 
			(tag[recover_NPC[`LOG_NUM_BTB_ENTRIES+1:2]] == 
			 recover_NPC[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2]))
*/
	if (recover_uncond)
		next_br[recover_NPC[`LOG_NUM_BTB_ENTRIES+1:2]] = recover_actual_addr;
/*
	if (rob_retire_jump1 && 
			(tag[rob_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2]] == 
			 rob_retire_pc1[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2]))

	if (rob_retire_jump1)
		next_br_displ[rob_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2]] = rob_cre_npc1[`LOG_ENTRIES_VALUE+1:2];


//give out the predicted target npc
//first by the first instruction is predicted as a branch
	if (tag[if_NPC0[`LOG_NUM_BTB_ENTRIES+1:2]] == if_NPC0[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2])
		if_pred_addr0 = {if_NPC0[63:`LOG_NUM_BTB_ENTRIES+2], br_displ[if_NPC0[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
	else
	if (tag[if_NPC1[`LOG_NUM_BTB_ENTRIES+1:2]] == if_NPC1[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2])
		if_pred_addr1 = {if_NPC1[`LOG_NUM_BTB_ENTRIES+2], br_displ[if_NPC1[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
*/
end

always @(posedge clock) begin
	if (reset) begin
		for (i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
			br[i] <= `SD 64'b0;
		end
	end

	else begin
		for (i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
			br[i] <= `SD next_br[i];
		end
	end
end

genvar IDX;
generate
	for(IDX=0; IDX<`NUM_BTB_ENTRIES; IDX=IDX+1)
	begin : foo
		wire [63:0] BR = br[IDX];  //64 tags, 7 bits each.
		wire [63:0] NEXT_BR = next_br[IDX];
	end
	wire [`LOG_NUM_BTB_ENTRIES-1:0] RETIRE_ENTRY0 = recover_NPC[`LOG_NUM_BTB_ENTRIES+1:2];
endgenerate

endmodule
