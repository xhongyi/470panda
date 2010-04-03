/////what if jump to a odd number address?

//currently is implemented as a direct mapped caches with 1024 entries

`timescale 1ns/100ps

module btb(//inputs
					clock,
					reset,
					
					if_pc,
					
					rob_jump_retire0,
					rob_jump_retire_pc0,
					rob_correct_npc0,

					rob_jump_retire1,
					rob_jump_retire_pc1,
					rob_correct_npc1,			
					
					//outputs
					if_pred_addr0,
					if_pred_addr1
					);
`ifndef NUM_BTB_ENTRIES
`define	NUM_BTB_ENTRIES	1024
`endif

`ifndef	LOG_NUM_BTB_ENTRIES
`define	LOG_NUM_BTB_ENTRIES	10
`endif

input	clock;
input	reset;

input	[63:0]					if_pc;//current PC

input									rob_jump_retire0;//if 0 predicted wrong
input	[63:0]					rob_jump_retire_pc0;
input	[63:0]					rob_correct_npc0;

input									rob_jump_retire1;//if 1 predicted wrong
input	[63:0]					rob_jump_retire_pc1;
input	[63:0]					rob_correct_npc1;

output	[63:0]				if_pred_addr0;//the predictied npc
output	[63:0]				if_pred_addr1;

reg	[`TAG_LENGTH-1:0]	tag							[`NUM_BTB_ENTRIES-1:0];
reg	[`TAG_LENGTH-1:0]	next_tag				[`NUM_BTB_ENTRIES-1:0];
reg	[18:0]						br_displ				[`NUM_BTB_ENTRIES-1:0];//branch displacement (I ignored the fact that branch ins may branch to a unaliased address)
reg	[18:0]						next_br_displ		[`NUM_BTB_ENTRIES-1:0];

wire	[63:0]					if_pc_plus_four;

integer i;

wire	[63:0]				if_pred_addr0;
wire	[63:0]				if_pred_addr1;

assign if_pred_addr0 = {if_pc[63:`LOG_NUM_BTB_ENTRIES+2], br_displ[if_pc[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
assign if_pred_addr1 = {if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+2], br_displ[if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
assign if_pc_plus_four = if_pc + 3'd4;

always @* begin
	for(i=0; i<NUM_BTB_ENTRIES; i=i+1) begin
		next_tag[i] = tag[i];
		next_br_displ[i] = br_displ[i];
	end

//correct the BTB if there is a mispredicted branch.	
	if (rob_jump_retire0 && 
			(tag[rob_jump_retire_pc0[`LOG_NUM_BTB_ENTRIES+1:2]] == 
			rob_jump_retire_pc0[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2]))
		next_br_displ[rob_jump_retire_pc0[`LOG_NUM_BTB_ENTRIES+1:2]] = rob_correct_npc0[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2];

	if (rob_jump_retire1 && 
			(tag[rob_jump_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2]] == 
			rob_jump_retire_pc1[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2]))
		next_br_displ[rob_jump_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2]] = rob_correct_npc1[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2];

/*	
//give out the predicted target npc
//first by the first instruction is predicted as a branch
	if (tag[if_pc[`LOG_NUM_BTB_ENTRIES+1:2]] == if_pc[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2])
		if_pred_addr0 = {if_pc[63:`LOG_NUM_BTB_ENTRIES+2], br_displ[if_pc[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
	else
	if (tag[if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+1:2]] == if_pc_plus_four[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2])
		if_pred_addr1 = {if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+2], br_displ[if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
*/

always @(posedge clock) begin
	if (reset) begin
		for (i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
			tag[i] <= 0;
			br_displ[i] <= 0;
		end
	end

	else begin
		for (i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
			tag[i] <= next_tag[i];
			br_displ[i] <= next_br_displ[i];
		end
	end
end

endmodule