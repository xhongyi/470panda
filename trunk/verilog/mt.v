/*
 * Module name: mt.v
 * Description: module design of map table
 * 03-15-10 wangyef: Modified I/O port, expanded CDB width
 */

`timescale 1ns/100ps

module mt (// Inputs
					 clock,
					 reset,
					 id_dispatch_num,
					 fl_pr0,
					 fl_pr1,
					
					id_valid_inst0,
					id_valid_inst1,
					id_opa_select0,
					id_opa_select1,
					id_opb_select0,
					id_opb_select1,

					id_ra_idx0,
					id_ra_idx1,
					id_rb_idx0,
					id_rb_idx1,
					id_dest_idx0,
					id_dest_idx1,
					

					 cdb_broadcast,
					 cdb_pr_tag0,
					 cdb_pr_tag1,
					 cdb_pr_tag2,
					 cdb_pr_tag3,
					 cdb_pr_tag4,
					 cdb_pr_tag5,
					 cdb_ar_tag0,
					 cdb_ar_tag1,
					 cdb_ar_tag2,
					 cdb_ar_tag3,
					 cdb_ar_tag4,
					 cdb_ar_tag5,

					 //Outputs
					 rob_p0told,
					 rob_p1told,
					 rs_pr_a1,
					 rs_pr_a2,
					 rs_pr_b1,
					 rs_pr_b2,

					 rs_pr_a1_ready,
					 rs_pr_a2_ready,
					 rs_pr_b1_ready,
					 rs_pr_b2_ready
					 );
	
	`ifndef CDB_WIDTH
	`define CDB_WIDTH 6
	`endif

	input 				clock;
	input					reset;
	input 	[1:0]	id_dispatch_num;
	input 	[6:0]	fl_pr0;
	input 	[6:0]	fl_pr1;

	// If a2 or b2 is not valid, the default value for pr is 0
	input 				id_valid_inst0;
	input 				id_valid_inst1;
	input 	[1:0]	id_opa_select0;
	input 	[1:0]	id_opa_select1;
	input 	[1:0]	id_opb_select0;
	input 	[1:0]	id_opb_select1;
	
	input	[4:0]	id_ra_idx0;
	input	[4:0]	id_ra_idx1;
	input	[4:0]	id_rb_idx0;
	input	[4:0]	id_rb_idx1;
	input 	[4:0]	id_dest_idx0;
	input	[4:0]	id_dest_idx1;

	

	input	[5:0]	cdb_broadcast;
	input	[6:0]	cdb_pr_tag0;
	input	[6:0]	cdb_pr_tag1;
	input	[6:0]	cdb_pr_tag2;
	input	[6:0]	cdb_pr_tag3;
	input	[6:0]   cdb_pr_tag4;
	input	[6:0]	cdb_pr_tag5;
	input	[4:0]	cdb_ar_tag0;
	input	[4:0]	cdb_ar_tag1;
	input	[4:0]	cdb_ar_tag2;
	input	[4:0]	cdb_ar_tag3;
	input	[4:0]	cdb_ar_tag4;
	input	[4:0]	cdb_ar_tag5;


	output	[6:0]	rob_p0told;
	output	[6:0]	rob_p1told;
	output	[6:0]	rs_pr_a1;
	output	[6:0]	rs_pr_a2;
	output	[6:0]	rs_pr_b1;
	output	[6:0]	rs_pr_b2;

	output				rs_pr_a1_ready;
	output				rs_pr_a2_ready;
	output				rs_pr_b1_ready;
	output				rs_pr_b2_ready;

	reg		[6:0]	pr_tags[31:0];
	reg		[31:0]	ready_bits;

	reg		[31:0]	next_ready_bits;
	wire 	rob_ar_a_valid = id_valid_inst0;
	wire	rob_ar_b_valid = id_valid_inst1;
	wire	rob_ar_a1_valid = (id_valid_inst0) & (id_opa_select0 == `ALU_OPA_IS_REGA);
	wire	rob_ar_a2_valid = (id_valid_inst0) & (id_opb_select0 == `ALU_OPB_IS_REGB);
	wire	rob_ar_b1_valid = (id_valid_inst1) & (id_opa_select1 == `ALU_OPA_IS_REGA);
	wire	rob_ar_b2_valid = (id_valid_inst1) & (id_opb_select1 == `ALU_OPB_IS_REGB);
	

	wire	[6:0]	pr_tags_next0 = 
								(id_dispatch_num == 2'd0 || ~rob_ar_a_valid) ? pr_tags[id_dest_idx0] : 
								(id_dispatch_num == 2'd2 && rob_ar_b_valid && (id_dest_idx0 == id_dest_idx1)) ? fl_pr1 : fl_pr0;
	wire 	[6:0]	pr_tags_next1 = 
								(id_dispatch_num == 2'd2 && rob_ar_b_valid) ? fl_pr1 : 
																															 pr_tags[id_dest_idx1];
	wire 	[4:0]	pr_tags_idx_next0 = id_dest_idx0;
	wire 	[4:0]	pr_tags_idx_next1 = id_dest_idx1;

	always @*
	begin
		next_ready_bits = ready_bits;

		// Assume CDB_WIDTH is 6
		if (cdb_broadcast[0] && pr_tags[cdb_ar_tag0] == cdb_pr_tag0)
			next_ready_bits[cdb_ar_tag0] = 1'b1;
		if (cdb_broadcast[1] && pr_tags[cdb_ar_tag1] == cdb_pr_tag1)
			next_ready_bits[cdb_ar_tag1] = 1'b1;
		if (cdb_broadcast[2] && pr_tags[cdb_ar_tag2] == cdb_pr_tag2)
			next_ready_bits[cdb_ar_tag2] = 1'b1;
		if (cdb_broadcast[3] && pr_tags[cdb_ar_tag3] == cdb_pr_tag3)
			next_ready_bits[cdb_ar_tag3] = 1'b1;
		if (cdb_broadcast[4] && pr_tags[cdb_ar_tag4] == cdb_pr_tag4)
			next_ready_bits[cdb_ar_tag4] = 1'b1;
		if (cdb_broadcast[5] && pr_tags[cdb_ar_tag5] == cdb_pr_tag5)
			next_ready_bits[cdb_ar_tag5] = 1'b1;
		if (id_dispatch_num > 0 && rob_ar_a_valid)
			next_ready_bits[id_dest_idx0] = 1'b0;
		if (id_dispatch_num > 1 && rob_ar_b_valid)
			next_ready_bits[id_dest_idx1] = 1'b0;
	end

	assign rob_p0told = pr_tags[id_dest_idx0];
	assign rob_p1told = (rob_ar_a_valid && id_dest_idx1 == id_dest_idx0) ? fl_pr0: pr_tags[id_dest_idx1];

	assign rs_pr_a1 = pr_tags[id_ra_idx0];
	assign rs_pr_a2 = pr_tags[id_rb_idx0];
	assign rs_pr_a1_ready = ready_bits[id_ra_idx0];
	assign rs_pr_a2_ready = ready_bits[id_rb_idx0];

	assign rs_pr_b1 = (rob_ar_a_valid && id_ra_idx1 == id_dest_idx0)? fl_pr0: 
																															 pr_tags[id_ra_idx1];
	assign rs_pr_b2 = (rob_ar_a_valid && id_rb_idx1 == id_dest_idx0)? fl_pr0: 
																												  		 pr_tags[id_rb_idx1];
	assign rs_pr_b1_ready = (rob_ar_a_valid && id_ra_idx1 == id_dest_idx0)? 1'b0: 
																															 ready_bits[id_ra_idx1];
	assign rs_pr_b2_ready = (rob_ar_a_valid && id_rb_idx1 == id_dest_idx0)? 1'b0: 
																															 ready_bits[id_rb_idx1];

	genvar i;
	generate
	for (i = 0; i < 32; i = i+1)
	begin : foo
		wire [6:0]	tmp_pr_tag = pr_tags[i];
	end
	endgenerate

	always @(posedge clock)
	begin
		if (reset) begin
			pr_tags[0] <= `SD 7'd0;
			pr_tags[1] <= `SD 7'd1;
			pr_tags[2] <= `SD 7'd2;
			pr_tags[3] <= `SD 7'd3;
			pr_tags[4] <= `SD 7'd4;
			pr_tags[5] <= `SD 7'd5;
			pr_tags[6] <= `SD 7'd6;
			pr_tags[7] <= `SD 7'd7;
			pr_tags[8] <= `SD 7'd8;
			pr_tags[9] <= `SD 7'd9;
			pr_tags[10] <= `SD 7'd10;
			pr_tags[11] <= `SD 7'd11;
			pr_tags[12] <= `SD 7'd12;
			pr_tags[13] <= `SD 7'd13;
			pr_tags[14] <= `SD 7'd14;
			pr_tags[15] <= `SD 7'd15;
			pr_tags[16] <= `SD 7'd16;
			pr_tags[17] <= `SD 7'd17;
			pr_tags[18] <= `SD 7'd18;
			pr_tags[19] <= `SD 7'd19;
			pr_tags[20] <= `SD 7'd20;
			pr_tags[21] <= `SD 7'd21;
			pr_tags[22] <= `SD 7'd22;
			pr_tags[23] <= `SD 7'd23;
			pr_tags[24] <= `SD 7'd24;
			pr_tags[25] <= `SD 7'd25;
			pr_tags[26] <= `SD 7'd26;
			pr_tags[27] <= `SD 7'd27;
			pr_tags[28] <= `SD 7'd28;
			pr_tags[29] <= `SD 7'd29;
			pr_tags[30] <= `SD 7'd30;
			pr_tags[31] <= `SD 7'd31;

			ready_bits <= `SD 32'hffffffff;
		end else begin
			ready_bits <= `SD next_ready_bits;
			pr_tags[id_dest_idx0] <= `SD pr_tags_next0;
			pr_tags[id_dest_idx1] <= `SD pr_tags_next1;
		end
	end

endmodule
