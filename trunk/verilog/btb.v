/////what if jump to a odd number address?
/////Question: is there any posibility that pc1 is not pc0+4? (newpc could be resolve within one cycle??)

//currently is implemented as a direct mapped caches with 1024 entries

`timescale 1ns/100ps

module btb(//inputs
					clock,
					reset,
					
					if_pc0,
					if_pc_plus_four,//not implemented yet
					
					rob_retire_jump0,
					rob_retire_pc0,
					rob_cre_npc0,

					rob_retire_jump1,
					rob_retire_pc1,
					rob_cre_npc1,
					
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

`ifndef	LOG_ENTRIES_VALUE
`define	LOG_ENTRIES_VALUE	30
`endif

input	clock;
input	reset;

input	[63:0]					if_pc;//current PC
input [63:0]					if_pc_plus_four;

input									rob_retire_jump0;//the retired instruction.
input	[63:0]					rob_retire_pc0;
input	[63:0]					rob_cre_npc0;

input									rob_retire_jump1;//the retired instruction.
input	[63:0]					rob_retire_pc1;
input	[63:0]					rob_cre_npc1;

output	[63:0]				if_pred_addr0;//the predictied npc
output	[63:0]				if_pred_addr1;

/*
reg	[`TAG_LENGTH-1:0]	tag							[`NUM_BTB_ENTRIES-1:0];
reg	[`TAG_LENGTH-1:0]	next_tag				[`NUM_BTB_ENTRIES-1:0];
*/
reg	[18:0]						br_displ				[`LOG_ENTRIES_VALUE-1:0];//branch displacement (I ignored the fact that branch ins may branch to a unaliased address)
reg	[18:0]						next_br_displ		[`LOG_ENTRIES_VALUE-1:0];

wire	[63:0]					if_pred_addr0;
wire	[63:0]					if_pred_addr1;

integer i;

assign if_pred_addr0 = {32'b0, next_br_displ[if_pc[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
assign if_pred_addr1 = {32'b0, next_br_displ[if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};

always @* begin
	for(i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
//		next_tag[i] = tag[i];
		next_br_displ[i] = br_displ[i];
	end

//correct the BTB if there is a mispredicted branch.	
/*
	if (rob_retire_jump0 && 
			(tag[rob_retire_pc0[`LOG_NUM_BTB_ENTRIES+1:2]] == 
			 rob_retire_pc0[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2]))
*/
	if (rob_retire_jump0)
		next_br_displ[rob_retire_pc0[`LOG_NUM_BTB_ENTRIES+1:2]] = rob_cre_npc0[`LOG_ENTRIES_VALUE+1:2];
/*
	if (rob_retire_jump1 && 
			(tag[rob_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2]] == 
			 rob_retire_pc1[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2]))
*/
	if (rob_retire_jump1)
		next_br_displ[rob_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2]] = rob_cre_npc1[`LOG_ENTRIES_VALUE+1:2];

/*	
//give out the predicted target npc
//first by the first instruction is predicted as a branch
	if (tag[if_pc[`LOG_NUM_BTB_ENTRIES+1:2]] == if_pc[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2])
		if_pred_addr0 = {if_pc[63:`LOG_NUM_BTB_ENTRIES+2], br_displ[if_pc[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
	else
	if (tag[if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+1:2]] == if_pc_plus_four[`TAG_LENGTH+`LOG_NUM_BTB_ENTRIES+1:`LOG_NUM_BTB_ENTRIES+2])
		if_pred_addr1 = {if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+2], br_displ[if_pc_plus_four[`LOG_NUM_BTB_ENTRIES+1:2]], 2'b0};
*/
end

always @(posedge clock) begin
	if (reset) begin
		for (i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
//		tag[i] <= 0;
			br_displ[i] <= `SD 0;
		end
	end

	else begin
		for (i=0; i<`NUM_BTB_ENTRIES; i=i+1) begin
//		tag[i] <= next_tag[i];
			br_displ[i] <= `SD next_br_displ[i];
		end
	end
end

genvar IDX;
generate
	for(IDX=0; IDX<`NUM_BTB_ENTRIES; IDX=IDX+1)
	begin : foo
		wire [29:0] BR_DISPL = br_displ[IDX];  //64 tags, 7 bits each.
		wire [29:0] NEXT_BR_DISPL = next_br_displ[IDX];
	end
	wire [`LOG_NUM_BTB_ENTRIES-1:0] RETIRE_ENTRY0 = rob_retire_pc0[`LOG_NUM_BTB_ENTRIES+1:2];
	wire [`LOG_NUM_BTB_ENTRIES-1:0] RETIRE_RETRY1 = rob_retire_pc1[`LOG_NUM_BTB_ENTRIES+1:2];
endgenerate

endmodule
