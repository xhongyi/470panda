module testbench;
////////////////////////////////////////////////////////////////Origin Inputs

reg         clock;               // system clock
reg         reset;               // system reset
reg  [63:0] rs_NPC0;           // incoming instruction PC+4
reg  [63:0] rs_NPC1;           // incoming instruction PC+4
reg  [31:0] rs_IR0;            // incoming instruction
reg  [31:0] rs_IR1;            // incoming instruction
reg  [63:0] prf_pra0;          // register A value from reg file   
reg  [63:0] prf_pra1;          // register A value from reg file

reg  [63:0]	prf_prb0;          // register B value from reg file
reg  [63:0]	prf_prb1;          // register B value from reg file
reg	 [4:0]	rs_dest_ar_idx0;
reg	 [4:0]	rs_dest_ar_idx1;
reg	 [6:0]	rs_dest_pr_idx0;
reg	 [6:0]	rs_dest_pr_idx1;
reg  [1:0]	rs_opa_select0;    // opA mux select from decoder
reg  [1:0]	rs_opa_select1;    // opA mux select from decoder

reg  [1:0]	rs_opb_select0;    // opB mux select from decoder
reg  [1:0]	rs_opb_select1;    // opB mux select from decoder

  
reg					rs_valid_inst0;
reg					rs_valid_inst1;

////////////////////////////////////////////////////////////////Correct Output
	
reg	[63:0]	cre_prf_result0;   // ALU result
reg	[63:0]	cre_prf_result1;   // ALU result
reg					cre_prf_write_enable0;
reg					cre_prf_write_enable1;
reg					cre_cdb_complete0;
reg					cre_cdb_complete1;
reg					cre_cdb_dest_ar_idx0;
reg					cre_cdb_dest_ar_idx1;
reg					cre_cdb_prf_dest_pr_idx0;
reg					cre_cdb_prf_dest_pr_idx1;
reg					cre_cdb_exception0;
reg					cre_cdb_exception1;
reg	[1:0]		cre_rs_alu_avail;

////////////////////////////////////////////////////////////////Device Output

wire	[63:0]	prf_result0;   // ALU result
wire	[63:0]	prf_result1;   // ALU result
wire				prf_write_enable0;
wire				prf_write_enable1;
wire				cdb_complete0;
wire				cdb_complete1;
wire				cdb_dest_ar_idx0;
wire				cdb_dest_ar_idx1;
wire				cdb_prf_dest_pr_idx0;
wire				cdb_prf_dest_pr_idx1;
wire				cdb_exception0;
wire				cdb_exception1;
wire	[1:0]	rs_alu_avail;

////////////////////////////////////////////////////////////////Correct Signal
reg 				correct;

alu_mul(				clock,
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
								prf_result0,
								prf_result1,
								prf_write_enable0,
								prf_write_enable1,
								rs_alu_avail
								);
/*
always @* begin
	if (
	prf_result0 != cre_prf_result0 ||
	prf_result1 != cre_prf_result1 ||
	prf_write_enable0 != cre_prf_write_enable0 ||
	prf_write_enable1 != cre_prf_write_enable1 ||
	cdb_complete0 != cre_cdb_complete0 ||
	cdb_complete1 != cre_cdb_complete1 ||
	cdb_dest_ar_idx0 != cre_cdb_dest_ar_idx0 ||
	cdb_dest_ar_idx1 != cre_cdb_dest_ar_idx1 ||
	cdb_prf_dest_pr_idx0 != cre_cdb_prf_dest_pr_idx0 ||
	cdb_prf_dest_pr_idx1 != cre_cdb_prf_dest_pr_idx1 ||
	cdb_exception0 != cre_cdb_exception0 ||
	cdb_exception1 != cre_cdb_exception1 ||
	rs_alu_avail != cre_rs_alu_avail) begin

		$display("prf_result0: %d	cre_prf_result0: %d\n", prf_result0, cre_prf_result0);
		$display("prf_result1: %d	cre_prf_result1: %d\n", prf_result1, cre_prf_result1);
		$display("prf_write_enable0: %d	cre_prf_write_enable0: %d\n", prf_write_enable0, cre_prf_write_enable0);
		$display("prf_write_enable1: %d	cre_prf_write_enable1: %d\n", prf_write_enable1, cre_prf_write_enable1);
		$display("cdb_complete0: %d	cre_cdb_complete0: %d\n", cdb_complete0, cre_cdb_complete0);
		$display("cdb_complete1: %d	cre_cdb_complete1: %d\n", cdb_complete1, cre_cdb_complete1);
		$display("cdb_dest_ar_idx0: %d	cre_cdb_dest_ar_idx0: %d\n", cdb_dest_ar_idx0, cre_cdb_dest_ar_idx0);
		$display("cdb_dest_ar_idx1: %d	cre_cdb_dest_ar_idx1: %d\n", cdb_dest_ar_idx1, cre_cdb_dest_ar_idx1);
		$display("cdb_prf_dest_pr_idx0: %d	cre_cdb_prf_dest_pr_idx0: %d\n", cdb_prf_dest_pr_idx0, cre_cdb_prf_dest_pr_idx0);
		$display("cdb_prf_dest_pr_idx1: %d	cre_cdb_prf_dest_pr_idx1: %d\n", cdb_prf_dest_pr_idx1, cre_cdb_prf_dest_pr_idx1);
		$display("cdb_exception0: %d	cre_cdb_exception0: %d\n", cdb_exception0, cre_cdb_exception0);
		$display("cdb_exception1: %d	cre_cdb_exception1: %d\n", cdb_exception1, cre_cdb_exception1);
		$display("rs_alu_avail: %d	cre_rs_alu_avail: %d\n"rs_alu_avail, cre_rs_alu_avail);
		correct = 0;
	end
end
*/
always @(posedge clock) begin
	#4
  if (~correct) begin
		$display("*** Incorrect at time %4.0f\n", $time);
		$finish;
	end
end

always
  begin
    #5;
    clock = ~clock;
  end


initial begin

  //$vcdpluson;
	$monitor("Time:%4.0f rs_NPC0: %d	rs_NPC1 %d\n	rs_IR0: %d	rs_IR1 %d\n	prf_pra0: %d	prf_pra1 %d\n	prf_prb0: %d	prf_prb1 %d\n	rs_dest_ar_idx0: %d	rs_dest_ar_idx1 %d\n	rs_dest_pr_idx0: %d	rs_dest_pr_idx1 %d\n	rs_opa_select0: %d	rs_opa_select1 %d\n	rs_opb_select0: %d	rs_opb_select1 %d\n	rs_valid_inst0: %d	rs_valid_inst1 %d\n	\n	Outputs	\n	cdb_complete0: %d	cdb_complete1 %d\n	cdb_dest_ar_idx0: %d	cdb_dest_ar_idx1 %d\n	cdb_prf_dest_pr_idx0: %d	cdb_prf_dest_pr_idx1 %d\n	cdb_exception0: %d	cdb_exception1 %d\n	prf_result0: %d	prf_result1 %d\n	prf_write_enable0: %d	prf_write_enable1 %d\n	rs_alu_avail", $time, rs_NPC0, rs_NPC1, rs_IR0, rs_IR1, prf_pra0, prf_pra1, prf_prb0, prf_prb1, rs_dest_ar_idx0, rs_dest_ar_idx1, rs_dest_pr_idx0, rs_dest_pr_idx1, rs_opa_select0, rs_opa_select1, rs_opb_select0, rs_opb_select1, rs_valid_inst0, rs_valid_inst1,	cdb_complete0, cdb_complete1, cdb_dest_ar_idx0, cdb_dest_ar_idx1, cdb_prf_dest_pr_idx0, cdb_prf_dest_pr_idx1, cdb_exception0, cdb_exception1, prf_result0, prf_result1, prf_write_enable0, prf_write_enable1, rs_alu_avail);

	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////first ever inputs
clock = 0;
reset = 1;
correct = 1;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Origin Inputs
rs_NPC0 = 0;           // incoming instruction PC+4
rs_NPC1 = 0;           // incoming instruction PC+4
rs_IR0 = 0;            // incoming instruction
rs_IR1 = 0;            // incoming instruction
prf_pra0 = 0;          // register A value from reg file 
prf_pra1 = 0;          // register A value from reg file

prf_prb0 = 0;          // register B value from reg file
prf_prb1 = 0;          // register B value from reg file
rs_dest_ar_idx0 = 0;
rs_dest_ar_idx1 = 0;
rs_dest_pr_idx0 = 0;
rs_dest_pr_idx1 = 0;
rs_opa_select0 = 0;    // opA mux select from decoder
rs_opa_select1 = 0;    // opA mux select from decoder

rs_opb_select0 = 0;    // opB mux select from decoder
rs_opb_select1 = 0;    // opB mux select from decoder

  
rs_valid_inst0 = 0;
rs_valid_inst1 = 0;

////////////////////////////////////////////////////////////////Correct Output
	
cre_prf_result0 = 0;   // ALU result
cre_prf_result1 = 0;   // ALU result
cre_prf_write_enable0 = 0;
cre_prf_write_enable1 = 0;
cre_cdb_complete0 = 0;
cre_cdb_complete1 = 0;
cre_cdb_dest_ar_idx0 = 0;
cre_cdb_dest_ar_idx1 = 0;
cre_cdb_prf_dest_pr_idx0 = 0;
cre_cdb_prf_dest_pr_idx1 = 0;
cre_cdb_exception0 = 0;
cre_cdb_exception1 = 0;
cre_rs_alu_avail = 0;


////////////////////////////////////////////////////////////////Set back reset bit
@(negedge clock);
reset = 0;
////////////////////////////////////////////////////////////////Start test
@(negedge clock);
rs_valid_inst0 = 1;
rs_valid_inst1 = 1;
prf_pra0 = 15;
prf_prb0 = 20;
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
@(negedge clock);
$finish;
end

endmodule
