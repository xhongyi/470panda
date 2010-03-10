////////////////////////////////////////////////////////////////////

//Function Units:

module rs(
          //dispatch inputs
  	  rob_opcode_a,
	  fl_a,
	  mt_a1,
	  mt_a2,
	  rob_immediate_a,
	  rob_ar_a,

	  rob_opcode_b,
	  fl_b,
	  mt_b1,
	  mt_b2,
	  rob_immediate_b,
	  rob_ar_b,

	  //issue inputs
	  ALU_1_avail,
	  ALU_2_avail,
	  MULT_1_avail,
	  MULT_2_avail,
	  BR_ALU_1_avail,
	  BR_ALU_2_avail,

	  //dispatch outputs
	  rob_avail,

	  //issue outputs
	  ALU_2_valid,
	  MULT_1_valid,
	  MULT_2_valid,
	  BR_ALU_1_valid,
	  BR_ALU_2_valid,

	  ALU_2_select,
	  MULT_1_select,
	  MULT_2_select,
	  BR_ALU_1_select,
	  BR_ALU_2_select,

	  ALU_1_a,
	  ALU_2_op_a1,
	  fu_op_a2,
	  fu_dest_ar_a,

	  fu_op_b,
	  fu_op_b1,
	  fu_op_b2,
	  fu_dest_ar_b
	 );

//dispatch inputs
input[] rob_opcode_a;
input fl_a;
input mt_a1;
input mt_a2;
input rob_immediate_a;
input rob_ar_a;

input rob_opcodeb;
input fl_b;
input mt_b1;
input mt_b2;
input rob_immediate_b;
input rob_ar_b;

//issue inputs
input ALU_1_avail;
input ALU_2_avail;
input MULT_1_avail;
input MULT_2_avail;
input BR_ALU_1_avail;
input BR_ALU_2_avail;

//dispatch outputs
output rob_avail;

//issue outputs
output ALU_2_valid;
output MULT_1_valid;
output MULT_2_valid;
output BR_ALU_1_valid;
output BR_ALU_2_valid;

output ALU_2_select;
output MULT_1_select;
output MULT_2_select;
output BR_ALU_1_select;
output BR_ALU_2_select;

output fu_op_a;
output fu_op_a1;
output fu_op_a2;
output fu_dest_ar_a;

output fu_op_b;
output fu_op_b1;
output fu_op_b2;
output fu_dest_ar_b;

reg entry_valid[15:0];
reg 
