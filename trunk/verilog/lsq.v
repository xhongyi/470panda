`timescale 1ns/100ps

module lsq (// Inputs
						clock,
						reset,
						// Give the age of each ld
						id_rd_mem0,
						id_rd_mem1,

						// Put the store in the queue at dispatch
						id_wr_mem0,
						id_wr_mem1,
						
						// At the issue stage, pass the ready load and store 
						// from rs to lsq
						rs_IR0,
						prf_pra_value0,
						prf_prb_value0,
						rs_issue_age0,
						rs_issue_old0,
						rs_dest_ar_idx0,
						rs_dest_pr_idx0,
						rs_rd_mem0,
						rs_wr_mem0,
						rs_valid_inst0,

						rs_IR1,
						prf_pra_value1,
						prf_prb_value1,
						rs_issue_age1,
						rs_issue_old1,
						rs_dest_ar_idx1,
						rs_dest_pr_idx1,
						rs_rd_mem1,
						rs_wr_mem1,
						rs_valid_inst1,

						rs_wr_mem0_peer,
						rs_wr_mem1_peer,

						id_dispatch_num,

						// Retire the stores
						rob_retire_num,
						rob_retire_wr_mem0,
						rob_retire_wr_mem1,

						Dcache_avail,

						// Outputs
						// Give back the age of ld at dispatch
						rs_disp_age0,
						rs_disp_old0,
						rs_disp_age1,
						rs_disp_old1,

						// How many ld lsq can eat
						rs_avail,

						// If the value of load is found if the previous store
						// complete the inst and write the value
						// Also complete the ready store
						cdb_complete,
						cdb_prf_pr_idx,
						cdb_ar_idx,
						prf_pr_wr_enable,
						prf_pr_value,

						// The load value of the address is not found,
						// throw the load to cache
	
						// When Dcache commit the ld, it will write the value to 
						// the second interface for alu_mem of prf
						Dcache_rd_mem,
						Dcache_wr_mem,
						Dcache_addr,
						Dcache_pr_idx,
						Dcache_ar_idx,

						// For the retired store value
						Dcache_st_value,

						Dcache_st_addr
						);

`ifndef LEN_STQ
`define LEN_STQ 64
`endif

`ifndef BIT_STQ
`define BIT_STQ 6
`endif

// LEN_LDQ must be larger than 1
`ifndef	LEN_LDQ
`define	LEN_LDQ 4
`endif

`ifndef	BIT_LDQ
`define	BIT_LDQ 2
`endif

input					clock;
input					reset;
input					id_rd_mem0;
input					id_wr_mem0;
input					id_rd_mem1;
input					id_wr_mem1;

input  [31:0]	rs_IR0;
input	 [63:0]	prf_pra_value0;
input	 [63:0]	prf_prb_value0;
input		[4:0]	rs_dest_ar_idx0;
input		[6:0]	rs_dest_pr_idx0;
input					rs_rd_mem0;
input					rs_wr_mem0;
input					rs_valid_inst0;

input  [31:0]	rs_IR1;
input	 [63:0]	prf_pra_value1;
input	 [63:0]	prf_prb_value1;
input		[4:0]	rs_dest_ar_idx1;
input		[6:0]	rs_dest_pr_idx1;
input					rs_rd_mem1;
input					rs_wr_mem1;
input					rs_valid_inst1;

input		[1:0]	rob_retire_num;
input					rob_retire_wr_mem0;
input					rob_retire_wr_mem1;

input					rs_wr_mem0_peer;
input					rs_wr_mem1_peer;

input		[1:0]	id_dispatch_num;

input					Dcache_avail;

input		[`BIT_STQ-1:0]	rs_issue_age0;
input		[`BIT_STQ-1:0]	rs_issue_age1;
input										rs_issue_old0;
input										rs_issue_old1;
output	[`BIT_STQ-1:0]	rs_disp_age0;
output	[`BIT_STQ-1:0]	rs_disp_age1;
output									rs_disp_old0;
output									rs_disp_old1;

output	[1:0]	rs_avail;

output				cdb_complete;
output	[6:0]	cdb_prf_pr_idx;
output	[4:0]	cdb_ar_idx;
output				prf_pr_wr_enable;
output [63:0]	prf_pr_value;

output				Dcache_rd_mem;
output				Dcache_wr_mem;
output [63:0]	Dcache_addr;
output	[6:0]	Dcache_pr_idx;
output	[4:0]	Dcache_ar_idx;

output [63:0]	Dcache_st_value;
output [63:0]	Dcache_st_addr;

reg						cdb_complete;
reg			[6:0]	cdb_prf_pr_idx;
reg			[4:0]	cdb_ar_idx;
reg						prf_pr_wr_enable;
reg		 [63:0]	prf_pr_value;

reg						Dcache_rd_mem;
reg						Dcache_wr_mem;
reg		 [63:0]	Dcache_addr;
reg			[6:0]	Dcache_pr_idx;
reg			[4:0]	Dcache_ar_idx;

reg			[1:0]	rs_avail;

reg		 				 [63:0]	st_addr	[`LEN_STQ-1:0];
reg						 [63:0]	st_value[`LEN_STQ-1:0];
reg		 [`LEN_STQ-1:0]	st_ready;

reg		 [`BIT_STQ-1:0] st_head;
reg		 [`BIT_STQ-1:0] st_tail;
reg										st_empty;

reg						 [63:0] ld_addr				[`LEN_LDQ-1:0];
reg							[6:0]	ld_pr					[`LEN_LDQ-1:0];
reg							[4:0]	ld_ar					[`LEN_LDQ-1:0];
reg		 [`BIT_STQ-1:0]	ld_age				[`LEN_LDQ-1:0];
reg		 [`BIT_STQ-1:0]	ld_match_idx	[`LEN_LDQ-1:0];
reg		 [`LEN_LDQ-1:0] ld_old;

reg		 [`LEN_LDQ-1:0] ld_avail;
reg		 [`LEN_LDQ-1:0] ld_taken;
reg		 [`LEN_LDQ-1:0] ld_ready;
reg		 [`LEN_LDQ-1:0] ld_match; //Match the address of the previus store

reg		 				[63:0]	next_st_addr	[`LEN_STQ-1:0];
reg					 	[63:0]	next_st_value	[`LEN_STQ-1:0];
reg		 [`LEN_STQ-1:0]	next_st_ready;

reg		 	 [`BIT_STQ:0]	next_st_head;
reg		 	 [`BIT_STQ:0] next_st_tail;
reg										next_st_empty;

reg						 [63:0] next_ld_addr			[`LEN_LDQ-1:0];
reg						  [6:0]	next_ld_pr				[`LEN_LDQ-1:0];
reg						  [4:0]	next_ld_ar				[`LEN_LDQ-1:0];
reg		 [`BIT_STQ-1:0]	next_ld_age				[`LEN_LDQ-1:0];
reg		 [`BIT_STQ-1:0]	next_ld_match_idx	[`LEN_LDQ-1:0];
reg		 [`LEN_LDQ-1:0] next_ld_old;

reg		 [`LEN_LDQ-1:0] next_ld_avail;
reg		 [`LEN_LDQ-1:0] next_ld_taken;
reg		 [`LEN_LDQ-1:0] next_ld_ready;
reg		 [`LEN_LDQ-1:0] next_ld_match;

wire									ldq_avail;
wire	 [`BIT_LDQ-1:0]	ldq_high_idx;
wire	 [`BIT_LDQ-1:0] ldq_low_idx;
wire									ldq_ready;
wire	 [`BIT_LDQ-1:0]	ldq_ready_high;
wire	 [`BIT_LDQ-1:0] ldq_ready_low;


reg			 [`BIT_STQ:0] st_head_ext;
reg			 [`BIT_STQ:0] st_tail_ext;

reg		 	 [`BIT_STQ:0]	ld_age_ext		[`LEN_LDQ-1:0];

wire		 [63:0]	rs_mem_addr0;
wire		 [63:0]	rs_mem_addr1;

wire						ld_cdb_wait;

wire						ar_a_zero0;
wire						ar_a_zero1;
wire						ar_b_zero0;
wire						ar_b_zero1;

assign ar_a_zero0 = (rs_IR0[25:21] == `ZERO_REG);
assign ar_a_zero1 = (rs_IR1[25:21] == `ZERO_REG);
assign ar_b_zero0 = (rs_IR0[20:16] == `ZERO_REG);
assign ar_b_zero1 = (rs_IR1[20:16] == `ZERO_REG);

assign rs_mem_addr0 = ((ar_b_zero0)? 64'b0 : prf_prb_value0) + {{48{rs_IR0[15]}}, rs_IR0[15:0]};
assign rs_mem_addr1 = ((ar_b_zero1)? 64'b0 : prf_prb_value1) + {{48{rs_IR1[15]}}, rs_IR1[15:0]};

assign ld_cdb_wait = (rs_valid_inst0 & rs_wr_mem0) | 
										 (rs_valid_inst1 & rs_wr_mem1);

integer i, j;

// load properties in the load stage
assign rs_disp_age0 = st_tail;
assign rs_disp_old0 = st_empty;
assign rs_disp_age1 = (id_wr_mem0)? st_tail + 1: st_tail;
assign rs_disp_old1 = (id_wr_mem0)? 0: st_empty;

assign Dcache_st_value 	= st_value[st_head];
assign Dcache_st_addr		= st_addr[st_head];

prien_4 prien_ldq_avail(.decode(ld_avail),
												.encode_high(ldq_high_idx),
												.encode_low(ldq_low_idx),
												.valid(ldq_avail));

prien_4 prien_ldq_ready(.decode(next_ld_ready),
												.encode_high(ldq_ready_high),
												.encode_low(ldq_ready_low),
												.valid(ldq_ready));
genvar idx;
generate
	for (idx = 0; idx < `LEN_LDQ; idx = idx + 1)
	begin: foo
		wire	[`BIT_STQ-1:0] 	NEXT_LD_AGE 	= next_ld_age[idx];
		wire	[`BIT_STQ-1:0] 	LD_AGE			 	= ld_age[idx];
		wire	[`BIT_STQ-1:0] 	NEXT_LD_READY	= next_ld_ready[idx];
		wire	[`BIT_STQ-1:0] 	LD_READY			= ld_ready[idx];
		wire									NEXT_LD_MATCH	= next_ld_match[idx];
		wire									LD_MATCH			= ld_match[idx];
		wire									NEXT_ST_READY	= next_st_ready[idx];
		wire									ST_READY			= st_ready[idx];
		wire					[63:0]	NEXT_ST_ADDR	= next_st_addr[idx];
		wire					[63:0]	ST_ADDR				= st_addr[idx];
		wire					[63:0]	NEXT_ST_VALUE	= next_st_value[idx];
		wire					[63:0]	ST_VALUE			= st_value[idx];
		wire	[`BIT_STQ:0]		LD_AGE_EXT		= ld_age_ext[idx];
	end
endgenerate

always @*
begin
	if (~ldq_avail)
	begin
		if (rs_wr_mem0_peer | rs_wr_mem1_peer) rs_avail = 2'b01;
		else	rs_avail	= 2'b00;
	end
	else if (ldq_high_idx == ldq_low_idx)
	begin
		if (rs_wr_mem0_peer | rs_wr_mem1_peer) rs_avail	= 2'b11;
		else rs_avail = 2'b01;
	end
	else
	begin
		// If two st come and they can't be completed at the same time
		// *Peering* is used since wr and rd mem don't depend on lsq avail
		// This could be improved by adding another complete store queue
		if (rs_wr_mem0_peer & rs_wr_mem1_peer)
			rs_avail	= 2'b01;
		else
			rs_avail	= 2'b11;
	end

	// Store the new ld to ldq
	
	// Initialize
	for (i = 0; i < `LEN_LDQ; i = i+1)
	begin
		next_ld_addr[i]	= ld_addr[i];
		next_ld_pr[i]		= ld_pr[i];
		next_ld_ar[i]		= ld_ar[i];
		next_ld_age[i]	= ld_age[i];
		next_ld_match_idx[i] = 0;
	end
	next_ld_avail	= ld_avail;
	next_ld_taken = ld_taken;
	next_ld_ready = ld_ready;
	next_ld_match	= ld_match;
	next_ld_old		= 0;

	// Put the new loads into the load waiting queue
	if (ldq_avail)
	begin
		if (rs_rd_mem0 & rs_valid_inst0)
		begin	
			next_ld_addr[ldq_high_idx]	= rs_mem_addr0;
			next_ld_pr[ldq_high_idx]		= rs_dest_pr_idx0;
			next_ld_ar[ldq_high_idx]		= rs_dest_ar_idx0;
			next_ld_age[ldq_high_idx]		= rs_issue_age0;
			next_ld_old[ldq_high_idx]		= rs_issue_old0;
			next_ld_avail[ldq_high_idx]	= 0;
			next_ld_taken[ldq_high_idx]	= 1;
			next_ld_ready[ldq_high_idx]	= 1;
			next_ld_match[ldq_high_idx]	= 0;
			next_ld_match_idx[ldq_high_idx] = 0;
		end
		if (rs_rd_mem1 & rs_valid_inst1)
		begin
			next_ld_addr[ldq_low_idx]		= rs_mem_addr1;
			next_ld_pr[ldq_low_idx]			= rs_dest_pr_idx1;
			next_ld_ar[ldq_low_idx]			= rs_dest_ar_idx1;
			next_ld_age[ldq_low_idx]		= rs_issue_age1;
			next_ld_old[ldq_low_idx]		= rs_issue_old1;
			next_ld_avail[ldq_low_idx]	= 0;
			next_ld_taken[ldq_low_idx]	= 1;	
			next_ld_ready[ldq_low_idx]	= 1;
			next_ld_match[ldq_low_idx]	= 0;
			next_ld_match_idx[ldq_low_idx] = 0;
		end
	end

	// Check whether the loads are ready in the load queue
	for (i = 0; i < `LEN_LDQ; i = i+1)
	begin
		ld_age_ext[i] = {1'b0, next_ld_age[i]};
		next_ld_ready[i] = 1;
		if (next_ld_avail[i])
			next_ld_ready[i] = 0;
		else if (next_ld_old[i])
			next_ld_match[i] = 0;
		else
		begin
			//if (next_ld_age[i] == st_head)
			//	next_ld_ready[i] = 1;
			if (next_ld_age[i] < st_head)
				ld_age_ext[i] = {1'b0, next_ld_age[i]} + `LEN_STQ;
			for (j = 0; j < `LEN_STQ * 2; j = j+1)
			begin
				if (st_head_ext + j < ld_age_ext[i])
				begin
					// check whehter the ld is ready
					if (~st_ready[st_head+j])
						next_ld_ready[i] = 0;
					// Check whether there is a match
					if (st_ready[st_head+j] && st_addr[st_head+j] == next_ld_addr[i])
					begin
						next_ld_match[i] = 1;
						next_ld_match_idx[i] = st_head + j;
					end
				end
			end
		end
	end



	// Store part
	
	st_head_ext = {1'b0, st_head};
	st_tail_ext = {1'b0, st_tail};
	if (st_tail < st_head | (~st_empty && st_tail == st_head))
		st_tail_ext = {1'b0, st_tail} + `LEN_STQ;

	for (i = 0; i < `LEN_STQ; i = i + 1)
	begin
		next_st_addr[i]		= st_addr[i];
		next_st_value[i]	= st_value[i];
	end
	next_st_ready	= st_ready;

	// Extend the stq at dispatch
	if (id_dispatch_num[1])//if 2 dispatch
	begin
		if (id_wr_mem0 & id_wr_mem1)//if both are stores
		begin
			next_st_ready[st_tail]		= 0;
			next_st_ready[st_tail+1]	= 0;
			next_st_tail 							= st_tail_ext + 2;
		end
		else if (id_wr_mem0 | id_wr_mem1)//if only one store is ready
		begin
			next_st_ready[st_tail]		= 0;
			next_st_tail 							= st_tail_ext + 1;
		end
		else
			next_st_tail	= st_tail_ext;
	end
	else if (id_dispatch_num[0])//if only one store
	begin
		if (id_wr_mem0)
		begin
			next_st_ready[st_tail]		= 0;
			next_st_tail							= st_tail_ext + 1;
		end
		else
			next_st_tail = st_tail_ext;
	end
	else
		next_st_tail = st_tail_ext;
	
	// Shrink the stq at retire
	if (rob_retire_num[1])//if retire 2
	begin
		if (rob_retire_wr_mem0 & rob_retire_wr_mem1)//if both are store
			next_st_head	= st_head_ext + 2;
		else if (rob_retire_wr_mem0 | rob_retire_wr_mem1)//if only one is store
			next_st_head	= st_head_ext + 1;
		else
			next_st_head 	= st_head_ext;
	end
	else if (rob_retire_num[0] & rob_retire_wr_mem0)
		next_st_head	= st_head_ext + 1;
	else
		next_st_head	= st_head_ext;

	// Check whether the new stq is empty
	if (next_st_head == next_st_tail)
		next_st_empty	= 1;
	else
		next_st_empty	= 0;

	// Stq eat the ready stq address and value at issue
	if (rs_wr_mem0 & rs_valid_inst0)
	begin
		next_st_addr[rs_issue_age0]		= rs_mem_addr0;
		next_st_value[rs_issue_age0]	= (ar_a_zero0) ? 64'b0 : prf_pra_value0;
		next_st_ready[rs_issue_age0]	= 1;
	end
	if (rs_wr_mem1 & rs_valid_inst1)
	begin
		next_st_addr[rs_issue_age1]		= rs_mem_addr1;
		next_st_value[rs_issue_age1]	= (ar_a_zero1) ? 64'b0 : prf_pra_value1;
		next_st_ready[rs_issue_age1]	= 1;
	end



	// Send ld either to the cdb or Dcache
	// There are potential latches
	cdb_complete			= 0;
	cdb_prf_pr_idx		= 0;
	cdb_ar_idx				= 0;
	prf_pr_wr_enable	= 0;
	prf_pr_value			= 64'b0;

	if (rs_wr_mem0 & rs_valid_inst0)
	begin
		cdb_complete			= 1;
		cdb_prf_pr_idx		= rs_dest_pr_idx0;
		cdb_ar_idx				= rs_dest_ar_idx0;
		prf_pr_wr_enable	= 1; // This solve the ZERO_REG problem. Right?
		prf_pr_value			= 64'b0;
	end
	else if (rs_wr_mem1 & rs_valid_inst1)
	begin
		cdb_complete			= 1;
		cdb_prf_pr_idx		= rs_dest_pr_idx1;
		cdb_ar_idx				= rs_dest_ar_idx1;
		prf_pr_wr_enable	= 1; // This solve the ZERO_REG problem. Right?
		prf_pr_value			= 64'b0;
	end

	Dcache_rd_mem		= 0;
	Dcache_wr_mem		= 0;
	Dcache_addr			= 64'b0;
	Dcache_pr_idx		= 0;
	Dcache_ar_idx		= 0;
	if (ldq_ready & ~ld_cdb_wait)
	begin
		if (next_ld_match[ldq_ready_high] | next_ld_match[ldq_ready_low])
			cdb_complete = 1;
	/*	else
		begin
			cdb_complete 			= 0;
			cdb_prf_pr_idx		= 0;
			cdb_ar_idx				= 0;
			prf_pr_wr_enable	= 0;
			rf_pr_value			= 0;
		end*/

		if (next_ld_match[ldq_ready_high] & ~ld_cdb_wait)
		begin
			cdb_complete		= 1;
			cdb_prf_pr_idx	= next_ld_pr[ldq_ready_high];
			cdb_ar_idx			= next_ld_ar[ldq_ready_high];
			prf_pr_wr_enable= 1;
			prf_pr_value		= st_value[next_ld_match_idx[ldq_ready_high]];

			next_ld_avail[ldq_ready_high]	= 1;
			next_ld_taken[ldq_ready_high] = 0;
		end
		else if (Dcache_avail)
		begin
			Dcache_rd_mem		= 1;
			Dcache_wr_mem		= 0;
			Dcache_addr			= next_ld_addr[ldq_ready_high];
			Dcache_pr_idx		= next_ld_pr[ldq_ready_high];
			Dcache_ar_idx		= next_ld_ar[ldq_ready_high];

			next_ld_avail[ldq_ready_high]	= 1;
			next_ld_taken[ldq_ready_high] = 0;
		end
		if (ldq_ready_high != ldq_ready_low)
		begin	
			if (next_ld_match[ldq_ready_low] & ~next_ld_match[ldq_ready_high] &
					~ld_cdb_wait)
			begin
				cdb_complete		= 1;
				cdb_prf_pr_idx	= next_ld_pr[ldq_ready_low];
				cdb_ar_idx			= next_ld_ar[ldq_ready_low];
				prf_pr_wr_enable= 1;
				prf_pr_value		= st_value[next_ld_match_idx[ldq_ready_low]];

				next_ld_avail[ldq_ready_low]	= 1;
				next_ld_taken[ldq_ready_low] = 0;
			end if (Dcache_avail & ~(next_ld_ready[ldq_ready_high] & ~next_ld_match[ldq_ready_high]))
			begin
				Dcache_rd_mem		= 1;
				Dcache_wr_mem		= 0;
				Dcache_addr			= next_ld_addr[ldq_ready_low];
				Dcache_pr_idx		= next_ld_pr[ldq_ready_low];
				Dcache_ar_idx		= next_ld_ar[ldq_ready_low];

				next_ld_avail[ldq_ready_low]	= 1;
				next_ld_taken[ldq_ready_low] = 0;
			end
		end
	end


end

always @ (posedge clock)
begin
	if (reset)
	begin
		for (i = 0; i < `LEN_STQ; i = i + 1)
		begin
			st_addr[i]	<= `SD 64'h0;
			st_value[i]	<= `SD 64'h0;
		end
		st_ready	<= `SD `LEN_STQ'h0;
		st_head		<= `SD 0;
		st_tail		<= `SD 0;
		st_empty	<= `SD 1;
		for (i = 0; i < `LEN_LDQ; i = i + 1)
		begin
			ld_addr[i]	<= `SD 64'b0;
			ld_pr[i]		<= `SD 0;
			ld_ar[i]		<= `SD 0;
			ld_age[i]		<= `SD 0;
			ld_match_idx[i]	<= `SD 0;
		end

		ld_avail	<= `SD -1;
		ld_taken	<= `SD 0;
		ld_old		<= `SD 0;
		ld_ready	<= `SD 0;
		ld_match	<= `SD 0;
	end
	else
	begin
		for (i = 0; i < `LEN_STQ; i = i + 1)
		begin
			st_addr[i]	<= `SD next_st_addr[i];
			st_value[i]	<= `SD next_st_value[i];
		end
		st_ready	<= `SD next_st_ready;
		st_head		<= `SD next_st_head[`BIT_STQ-1:0];
		st_tail		<= `SD next_st_tail[`BIT_STQ-1:0];
		st_empty	<= `SD next_st_empty;

		for (i = 0; i < `LEN_LDQ; i = i + 1)
		begin
			ld_addr[i]	<= `SD next_ld_addr[i];
			ld_pr[i]		<= `SD next_ld_pr[i];
			ld_ar[i]		<= `SD next_ld_ar[i];
			ld_age[i]		<= `SD next_ld_age[i];
			ld_match_idx[i]	<= `SD next_ld_match_idx[i];
		end

		ld_avail	<= `SD next_ld_avail;
		ld_taken	<= `SD next_ld_taken;
		ld_old		<= `SD next_ld_old;
		ld_ready	<= `SD next_ld_ready;
		ld_match	<= `SD next_ld_match;
	end

end

endmodule
