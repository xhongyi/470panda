/////////////////////////////////////////////////////////////////////////
//   EECS470 Project Team Panda                                        //
//                                                                     //
//  ROB Testcases									                   									 //
/////////////////////////////////////////////////////////////////////////

//

module testbench;

  // Registers and wires used in the testbench
reg reset;
reg clock;

reg [6:0]		fl_pr0;
reg [6:0]		fl_pr1;
reg [6:0]		mt_p0told;
reg [6:0]		mt_p1told;
reg	[63:0]	id_NPC0;
reg	[63:0]	id_NPC1;
reg	[4:0]		id_dest_idx0;
reg	[4:0]		id_dest_idx1;
reg [1:0]		id_dispatch_num;
reg 	  		id_valid_inst0;
reg		  		id_valid_inst1;
reg					id_cond_branch0;
reg					id_cond_branch1;
reg					id_uncond_branch0;
reg					id_uncond_branch1;
reg					id_halt0;
reg					id_halt1;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr0;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	id_bhr1;

reg [5:0]		cdb_pr_ready; //Note: the bandwidth is CDB_WIDTH;
reg [6:0]		cdb_pr_tag_0;  //Note: the bandwidth is CDB_WIDTH;
reg [6:0]		cdb_pr_tag_1;
reg [6:0]		cdb_pr_tag_2;
reg [6:0]		cdb_pr_tag_3;
reg [6:0]		cdb_pr_tag_4;
reg [6:0]		cdb_pr_tag_5;
reg					cdb_exception0;
reg					cdb_exception1;
reg					cdb_exception2;
reg					cdb_exception3;
reg					cdb_exception4;
reg					cdb_exception5;

reg	[63:0]	cdb_actual_addr0;
reg					cdb_actual_taken0;

reg	[63:0]	cdb_actual_addr1;
reg					cdb_actual_taken1;


wire [1:0]		id_cap;

wire	[4:0]		mt_retire_ar_a;
wire	[4:0]		mt_retire_ar_b;	
wire	[6:0]		mt_fl_retire_tag_a;
wire	[6:0]		mt_fl_retire_tag_b;
wire	[1:0]		mt_fl_bht_recover_retire_num;

wire					bht_recover_cond_branch0;
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_retire_bhr0;
wire	[63:0]	bht_recover_NPC0;
wire					bht_actual_taken0;
wire					recover_uncond_branch0;
wire	[63:0]	recover_actual_addr0;

wire					bht_recover_cond_branch1;
wire	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	bht_retire_bhr1;
wire	[63:0]	bht_recover_NPC1;
wire					bht_actual_taken1;
wire					recover_uncond_branch1;
wire	[63:0]	recover_actual_addr1;			

wire					recover_exception;
wire					retire_halt;

reg [1:0]		cre_id_cap;

reg	[4:0]		cre_mt_retire_ar_a;
reg	[4:0]		cre_mt_retire_ar_b;	
reg	[6:0]		cre_mt_fl_retire_tag_a;
reg	[6:0]		cre_mt_fl_retire_tag_b;
reg	[1:0]		cre_mt_fl_bht_recover_retire_num;

reg					cre_bht_recover_cond_branch0;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	cre_bht_retire_bhr0;
reg	[63:0]	cre_bht_recover_NPC0;
reg					cre_bht_actual_taken0;
reg					cre_recover_uncond_branch0;
reg	[63:0]	cre_recover_actual_addr0;

reg					cre_bht_recover_cond_branch1;
reg	[`LOG_NUM_BHT_PATTERN_ENTRIES-1:0]	cre_bht_retire_bhr1;
reg	[63:0]	cre_bht_recover_NPC1;
reg					cre_bht_actual_taken1;
reg					cre_recover_uncond_branch1;
reg	[63:0]	cre_recover_actual_addr1;			

reg					cre_recover_exception;
reg					cre_retire_halt;

reg 				correct;

rob testee(//inputs
						reset,
						clock,
						//dispatch
						fl_pr0,
						fl_pr1,
						mt_p0told,
						mt_p1told,
						id_NPC0,//new
						id_NPC1,//new
						id_dest_idx0,//new
						id_dest_idx1,//new
						id_dispatch_num,
						id_valid_inst0,
						id_valid_inst1,
						id_cond_branch0,//new
						id_cond_branch1,//new
						id_uncond_branch0,//new
						id_uncond_branch1,//new
						id_halt0,
						id_halt1,
						id_bhr0,//new
						id_bhr1,//new
						//complete
						cdb_pr_ready,
						cdb_pr_tag_0,
						cdb_pr_tag_1,
						cdb_pr_tag_2,
						cdb_pr_tag_3,
						cdb_pr_tag_4,
						cdb_pr_tag_5,
						cdb_exception0,
						cdb_exception1,
						cdb_exception2,
						cdb_exception3,
						cdb_exception4,
						cdb_exception5,

						cdb_actual_addr0,//new
						cdb_actual_taken0,//new
						cdb_actual_addr1,//new
						cdb_actual_taken1,//new
						//outputs
						//dispatch
						id_cap,
						//retire
						mt_retire_ar_a,//new
						mt_retire_ar_b,//new
						mt_fl_retire_tag_a,//modified
						mt_fl_retire_tag_b,//modified
						mt_fl_bht_recover_retire_num,//modified
						
						bht_recover_cond_branch0,//new
						bht_retire_bhr0,//new
						bht_recover_NPC0,//new
						bht_actual_taken0,//new
						recover_uncond_branch0,//new
						recover_actual_addr0,//new

						bht_recover_cond_branch1,//new
						bht_retire_bhr1,//new
						bht_recover_NPC1,//new
						bht_actual_taken1,//new
						recover_uncond_branch1,//new
						recover_actual_addr1,//new

						recover_exception,//new
						retire_halt //new it is true when halt inst is retired
					);
					
integer i;
  // Instantiate the Pipeline

	
// Compare the results with the correct ones
	always @(posedge clock)
	begin
		#3;
		correct = 1;
		if (id_cap != cre_id_cap) begin
			$display("*** incorrect id_cap: %d, predicted: %d ***", id_cap, cre_id_cap);
			correct = 0;
		end
		if (cre_mt_fl_bht_recover_retire_num != mt_fl_bht_recover_retire_num) begin
			$display("*** incorrect mt_fl_bht_recover_retire_num: %d, predicted; %d ***", mt_fl_bht_recover_retire_num, cre_mt_fl_bht_recover_retire_num);
			correct = 0;
		end
		
		if (cre_mt_fl_bht_recover_retire_num != 0) begin
			if (mt_retire_ar_a != cre_mt_retire_ar_a) begin //ar
				$display("*** incorrect mt_retire_ar_a: %d, predicted; %d ***", mt_retire_ar_a, cre_mt_retire_ar_a);
				correct = 0;
			end
			if (mt_fl_retire_tag_a != cre_mt_fl_retire_tag_a) begin//mt_fl_retire_tag_a
				$display("*** incorrect mt_fl_retire_tag_a: %d, predicted; %d ***", mt_fl_retire_tag_a, cre_mt_fl_retire_tag_a);
				correct = 0;
			end
			if (bht_recover_cond_branch0 != cre_bht_recover_cond_branch0) begin//bht_recover_cond_branch
				$display("*** incorrect bht_recover_cond_branch0: %d, predicted; %d ***", bht_recover_cond_branch0, cre_bht_recover_cond_branch0);
				correct = 0;
			end
			if (bht_retire_bhr0 != cre_bht_retire_bhr0) begin//bht_retire_bhr
				$display("*** incorrect bht_retire_bhr0: %d, predicted; %d ***", bht_retire_bhr0, cre_bht_retire_bhr0);
				correct = 0;
			end
			if (bht_recover_NPC0 != cre_bht_recover_NPC0) begin//bht_recover_NPC0
				$display("*** incorrect bht_recover_NPC0: %d, predicted; %d ***", bht_recover_NPC0, cre_bht_recover_NPC0);
				correct = 0;
			end
			if (bht_actual_taken0 != cre_bht_actual_taken0) begin//bht_actual_taken0
				$display("*** incorrect bht_actual_taken0: %d, predicted; %d ***", bht_actual_taken0, cre_bht_actual_taken0);
				correct = 0;
			end
			if (recover_uncond_branch0 != cre_recover_uncond_branch0) begin//recover_uncond_branch0
				$display("*** incorrect recover_uncond_branch0: %d, predicted; %d ***", recover_uncond_branch0, cre_recover_uncond_branch0);
				correct = 0;
			end
			if (recover_actual_addr0 != cre_recover_actual_addr0) begin//recover_actual_addr0
				$display("*** incorrect recover_actual_addr0: %d, predicted; %d ***", recover_actual_addr0, cre_recover_actual_addr0);
				correct = 0;
			end
		end
		
		if (cre_mt_fl_bht_recover_retire_num == 2) begin
			if (mt_retire_ar_b != cre_mt_retire_ar_b) begin //ar
				$display("*** incorrect mt_retire_ar_b: %d, predicted; %d ***", mt_retire_ar_b, cre_mt_retire_ar_b);
				correct = 0;
			end
			if (mt_fl_retire_tag_b != cre_mt_fl_retire_tag_b) begin//mt_fl_retire_tag_b
				$display("*** incorrect mt_fl_retire_tag_b: %d, predicted; %d ***", mt_fl_retire_tag_b, cre_mt_fl_retire_tag_b);
				correct = 0;
			end
			if (bht_recover_cond_branch1 != cre_bht_recover_cond_branch1) begin//bht_recover_cond_branch
				$display("*** incorrect bht_recover_cond_branch1: %d, predicted; %d ***", bht_recover_cond_branch1, cre_bht_recover_cond_branch1);
				correct = 0;
			end
			if (bht_retire_bhr1 != cre_bht_retire_bhr1) begin//bht_retire_bhr
				$display("*** incorrect bht_retire_bhr1: %d, predicted; %d ***", bht_retire_bhr1, cre_bht_retire_bhr1);
				correct = 0;
			end
			if (bht_recover_NPC1 != cre_bht_recover_NPC1) begin//bht_recover_NPC1
				$display("*** incorrect bht_recover_NPC1: %d, predicted; %d ***", bht_recover_NPC1, cre_bht_recover_NPC1);
				correct = 0;
			end
			if (bht_actual_taken1 != cre_bht_actual_taken1) begin//bht_actual_taken1
				$display("*** incorrect bht_actual_taken1: %d, predicted; %d ***", bht_actual_taken1, cre_bht_actual_taken1);
				correct = 0;
			end
			if (recover_uncond_branch1 != cre_recover_uncond_branch1) begin//recover_uncond_branch1
				$display("*** incorrect recover_uncond_branch1: %d, predicted; %d ***", recover_uncond_branch1, cre_recover_uncond_branch1);
				correct = 0;
			end
			if (recover_actual_addr1 != cre_recover_actual_addr1) begin//recover_actual_addr1
				$display("*** incorrect recover_actual_addr1: %d, predicted; %d ***", recover_actual_addr1, cre_recover_actual_addr1);
				correct = 0;
			end
		end
		
		if (cre_recover_exception != recover_exception) begin//exception
			$display("*** incorrect recover_exception: %d, predicted; %d ***", recover_exception, cre_recover_exception);
			correct = 0;
		end
		
		if (cre_retire_halt != retire_halt) begin//halt
			$display("*** incorrect retire_halt: %d, predicted; %d ***", retire_halt, cre_retire_halt);
			correct = 0;
		end

		if (~correct) begin
			$display("*** Incorrect at time %4.0f\n", $time);
			$finish;
		end
	end
  // Generate System Clock
  always
  begin
    #5;
    clock = ~clock;
  end

initial begin

  //$vcdpluson;
  $monitor("Time:%4.0f mt_retire_ar_a: %d\t mt_retire_ar_b: %d\n mt_fl_retire_tag_a: %d\t mt_fl_retire_tag_b: %d\n mt_fl_bht_recover_retire_num: %d\n bht_recover_cond_branch0: %d\t bht_recover_cond_branch1: %d\n bht_retire_bhr0: %d\t bht_retire_bhr1: %d\n bht_recovber_NPC0: %d\t bht_recover_NPC1: %d\n bht_actual_taken0: %d\t bht_actual_taken1: %d\n recover_uncond_branch0: %d\t recover_uncond_branch1: %d\n recover_actual_addr0: %d\t recover_actual_addr1: %d\n recover_exception: %d\n retire_halt: %d\n",$time, mt_retire_ar_a, mt_retire_ar_b, mt_fl_retire_tag_a, mt_fl_retire_tag_b, mt_fl_bht_recover_retire_num, bht_recover_cond_branch0, bht_recover_cond_branch1, bht_retire_bhr0, bht_retire_bhr1, bht_recover_NPC0, bht_recover_NPC1, bht_actual_taken0, bht_actual_taken1, recover_uncond_branch0, recover_uncond_branch1, recover_actual_addr0, recover_actual_addr1, recover_exception, retire_halt);

 reset = 1;
 clock = 0;
 
 fl_pr0 = 0;
 fl_pr1 = 0;
 mt_p0told = 0;
 mt_p1told = 0;
 id_dest_idx0 = 0;
 id_dest_idx1 = 0;
 id_NPC0 = 0;//new
 id_NPC1 = 0;//new
 id_dispatch_num = 0;
 id_valid_inst0 = 0;
 id_valid_inst1 = 0;
 id_cond_branch0 = 0;
 id_cond_branch1 = 0;
 id_uncond_branch0 = 0;
 id_uncond_branch1 = 0;
 id_halt0 = 0;
 id_halt1 = 0;
 id_bhr0 = 0;
 id_bhr1 = 0;
 
 cdb_pr_ready = 0;
 cdb_pr_tag_0 = 0;
 cdb_pr_tag_1 = 0;
 cdb_pr_tag_2 = 0;
 cdb_pr_tag_3 = 0;
 cdb_pr_tag_4 = 0;
 cdb_pr_tag_5 = 0;
 cdb_exception0 = 0;
 cdb_exception1 = 0;
 cdb_exception2 = 0;
 cdb_exception3 = 0;
 cdb_exception4 = 0;
 cdb_exception5 = 0;

 cdb_actual_addr0 = 0;
 cdb_actual_taken0 = 0;
 cdb_actual_addr1 = 0;
 cdb_actual_taken1 = 0;
 cre_retire_halt = 0;
//test reset and 1 dispatch with 0 retire.
@(negedge clock);
//scenario
fl_pr0 = 32;
fl_pr1 = 33;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 4;
mt_p1told = 5;
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
@(negedge clock);
reset=0;
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0; 
mt_p0told = 0;
mt_p1told = 0;
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
clock = 0;
cre_retire_halt = 0;
//Halt test #1, insert an halt instruction
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 1;
mt_p0told = 0;
mt_p1told = 1;
id_NPC0 = 0;//new
id_NPC1 = 4;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 1;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 1;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
id_halt0 = 0;
id_halt1 = 1;
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_retire_halt = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Halt test #2, validate the 2 instrcutions.
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 1;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 1;
cre_mt_fl_bht_recover_retire_num = 2;
cre_retire_halt = 1;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 1;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;//new
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 1;//new
cre_bht_recover_NPC1 = 4;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Halt test #3, halt!
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
id_halt0 = 0;
id_halt1 = 0;
cdb_pr_ready = 6'b000000;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_retire_halt = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Basic test #1, insert ins0 and ins1
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 1;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 0;
mt_p1told = 1;
id_NPC0 = 0;//new
id_NPC1 = 4;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 1;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 1;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_retire_halt = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Basic test #2, insert ins2
@(negedge clock);
fl_pr0 = 2;
fl_pr1 = 0;
id_dispatch_num = 1;
id_valid_inst0  = 1;
id_valid_inst1 = 0;
mt_p0told = 2;
mt_p1told = 0;
id_NPC0 = 8;//new
id_NPC1 = 0;//new
id_dest_idx0 = 2;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 2;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Basic test #3, ready ins0 and ins1 and they shall be reatired
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 1;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 1;
cre_mt_fl_bht_recover_retire_num = 2;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 1;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 1;//new
cre_bht_recover_NPC1 = 4;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Basic test #5, ready ins2 and it shall be retired
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 6'b000001;
cdb_pr_tag_0 = 2;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 2;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 1;
cre_mt_retire_ar_a = 2;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 2;//new
cre_bht_recover_NPC0 = 8;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Advanced test #1, ins3 and ins4 is inserted
@(negedge clock);
fl_pr0 = 3;
fl_pr1 = 4;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 3;
mt_p1told = 4;
id_NPC0 = 12;//new
id_NPC1 = 16;//new
id_dest_idx0 = 3;//new
id_dest_idx1 = 4;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 3;//new
id_bhr1 = 4;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Advanced test #2, ins4 shall be valid. And there shall be no retire
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 6'b000001;
cdb_pr_tag_0 = 4;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Advanced test #3, ins3 shall be valid and ins3 and ins4 shall all be retired
@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0  = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 6'b000001;
cdb_pr_tag_0 = 3;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 3;
cre_mt_fl_retire_tag_b = 4;
cre_mt_fl_bht_recover_retire_num = 2;
cre_mt_retire_ar_a = 3;//new
cre_mt_retire_ar_b = 4;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 3;//new
cre_bht_recover_NPC0 = 12;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 4;//new
cre_bht_recover_NPC1 = 16;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new
//Iteration test
for(i=0; i<63; i=i+2) begin
	@(negedge clock);
	fl_pr0 = i+4;
	fl_pr1 = i+5;
	id_dispatch_num = 2;
	id_valid_inst0 = 1;
	id_valid_inst1 = 1;
	mt_p0told = i+4;
	mt_p1told = i+5;
	id_NPC0 = 16+(i*4);//new
	id_NPC1 = 20+(i*4);//new
	id_dest_idx0 = i+4;//new
	id_dest_idx1 = i+5;//new
	id_cond_branch0 = 0;//new
	id_cond_branch1 = 0;//new
	id_uncond_branch0 = 0;//new
	id_uncond_branch1 = 0;//new
	id_bhr0 = i+4;//new
	id_bhr1 = i+5;//new
	cdb_exception0 = 0;//new
	cdb_exception1 = 0;//new
	cdb_exception2 = 0;//new
	cdb_exception3 = 0;//new
	cdb_exception4 = 0;//new
	cdb_exception5 = 0;//new
	cdb_actual_addr0 = 0;//new
	cdb_actual_taken0 = 0;//new
	cdb_actual_addr1 = 0;//new
	cdb_actual_taken1 = 0;//new
	cdb_pr_ready = 0;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	if(i < 62)
		cre_id_cap = 2;
	else
		cre_id_cap = 62-i;
	cre_mt_fl_retire_tag_a = 0;
	cre_mt_fl_retire_tag_b = 0;
	cre_mt_fl_bht_recover_retire_num = 0;
	cre_mt_retire_ar_a = 0;//new
	cre_mt_retire_ar_b = 0;//new

	cre_bht_recover_cond_branch0 = 0;//new
	cre_bht_retire_bhr0 = 0;//new
	cre_bht_recover_NPC0 = 0;
	cre_bht_actual_taken0 = 0;//new
	cre_recover_uncond_branch0 = 0;//new
	cre_recover_actual_addr0 = 0;//new

	cre_bht_recover_cond_branch1 = 0;//new
	cre_bht_retire_bhr1 = 0;//new
	cre_bht_recover_NPC1 = 0;//new
	cre_bht_actual_taken1 = 0;//new
	cre_recover_uncond_branch1 = 0;//new
	cre_recover_actual_addr1 = 0;//new

	cre_recover_exception = 0;//new
end

for(i=63; i>3; i=i-6) begin
@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	id_NPC0 = 0;//new
	id_NPC1 = 0;//new
	id_dest_idx0 = 0;//new
	id_dest_idx1 = 0;//new
	id_cond_branch0 = 0;//new
	id_cond_branch1 = 0;//new
	id_uncond_branch0 = 0;//new
	id_uncond_branch1 = 0;//new
	id_bhr0 = 0;//new
	id_bhr1 = 0;//new
	cdb_exception0 = 0;//new
	cdb_exception1 = 0;//new
	cdb_exception2 = 0;//new
	cdb_exception3 = 0;//new
	cdb_exception4 = 0;//new
	cdb_exception5 = 0;//new
	cdb_actual_addr0 = 0;//new
	cdb_actual_taken0 = 0;//new
	cdb_actual_addr1 = 0;//new
	cdb_actual_taken1 = 0;//new
	cdb_pr_ready = 6'b111111;
	cdb_pr_tag_0 = i+4;
	cdb_pr_tag_1 = i+3;
	cdb_pr_tag_2 = i+2;
	cdb_pr_tag_3 = i+1;
	cdb_pr_tag_4 = i;
	cdb_pr_tag_5 = i-1;
	//prediction
	cre_id_cap = 0;
	cre_mt_fl_retire_tag_a = 0;
	cre_mt_fl_retire_tag_b = 0;
	cre_mt_fl_bht_recover_retire_num = 0;
	cre_mt_retire_ar_a = 0;//new
	cre_mt_retire_ar_b = 0;//new

	cre_bht_recover_cond_branch0 = 0;//new
	cre_bht_retire_bhr0 = 0;//new
	cre_bht_recover_NPC0 = 0;
	cre_bht_actual_taken0 = 0;//new
	cre_recover_uncond_branch0 = 0;//new
	cre_recover_actual_addr0 = 0;//new

	cre_bht_recover_cond_branch1 = 0;//new
	cre_bht_retire_bhr1 = 0;//new
	cre_bht_recover_NPC1 = 0;//new
	cre_bht_actual_taken1 = 0;//new
	cre_recover_uncond_branch1 = 0;//new
	cre_recover_actual_addr1 = 0;//new

	cre_recover_exception = 0;//new
end

@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 6'b001111;
cdb_pr_tag_0 = 4;
cdb_pr_tag_1 = 5;
cdb_pr_tag_2 = 6;
cdb_pr_tag_3 = 7;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 0;
cre_mt_fl_retire_tag_a = 4;
cre_mt_fl_retire_tag_b = 5;
cre_mt_fl_bht_recover_retire_num = 2;
cre_mt_retire_ar_a = 4;//new
cre_mt_retire_ar_b = 5;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 4;//new
cre_bht_recover_NPC0 = 16;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 5;//new
cre_bht_recover_NPC1 = 20;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new

for(i=2; i<64; i=i+2) begin
@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	id_NPC0 = 0;//new
	id_NPC1 = 0;//new
	id_dest_idx0 = 0;//new
	id_dest_idx1 = 0;//new
	id_cond_branch0 = 0;//new
	id_cond_branch1 = 0;//new
	id_uncond_branch0 = 0;//new
	id_uncond_branch1 = 0;//new
	id_bhr0 = 0;//new
	id_bhr1 = 0;//new
	cdb_exception0 = 0;//new
	cdb_exception1 = 0;//new
	cdb_exception2 = 0;//new
	cdb_exception3 = 0;//new
	cdb_exception4 = 0;//new
	cdb_exception5 = 0;//new
	cdb_actual_addr0 = 0;//new
	cdb_actual_taken0 = 0;//new
	cdb_actual_addr1 = 0;//new
	cdb_actual_taken1 = 0;//new
	cdb_pr_ready = 6'b000000;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	cre_id_cap = 2;
	cre_mt_fl_retire_tag_a = i+4;
	cre_mt_fl_retire_tag_b = i+5;
	cre_mt_fl_bht_recover_retire_num = 2;
	cre_mt_retire_ar_a = i+4;//new
	cre_mt_retire_ar_b = i+5;//new

	cre_bht_recover_cond_branch0 = 0;//new
	cre_bht_retire_bhr0 = i+4;//new
	cre_bht_recover_NPC0 = 16+(i*4);
	cre_bht_actual_taken0 = 0;//new
	cre_recover_uncond_branch0 = 0;//new
	cre_recover_actual_addr0 = 0;//new

	cre_bht_recover_cond_branch1 = 0;//new
	cre_bht_retire_bhr1 = i+5;//new
	cre_bht_recover_NPC1 = 20+(i*4);//new
	cre_bht_actual_taken1 = 0;//new
	cre_recover_uncond_branch1 = 0;//new
	cre_recover_actual_addr1 = 0;//new

	cre_recover_exception = 0;//new
end

//now test cond_branch & uncond_branch
for(i=0; i<62; i=i+2) begin
	@(negedge clock);
	fl_pr0 = i+4;
	fl_pr1 = i+5;
	id_dispatch_num = 2;
	id_valid_inst0 = 1;
	id_valid_inst1 = 1;
	mt_p0told = i+4;
	mt_p1told = i+5;
	id_NPC0 = 16+(i*4);//new
	id_NPC1 = 20+(i*4);//new
	id_dest_idx0 = i+4;//new
	id_dest_idx1 = i+5;//new
	id_cond_branch0 = 1;//new
	id_cond_branch1 = 1;//new
	id_uncond_branch0 = 1;//new
	id_uncond_branch1 = 1;//new
	id_bhr0 = i+4;//new
	id_bhr1 = i+5;//new
	cdb_exception0 = 0;//new
	cdb_exception1 = 0;//new
	cdb_exception2 = 0;//new
	cdb_exception3 = 0;//new
	cdb_exception4 = 0;//new
	cdb_exception5 = 0;//new
	cdb_actual_addr0 = 0;//new
	cdb_actual_taken0 = 0;//new
	cdb_actual_addr1 = 0;//new
	cdb_actual_taken1 = 0;//new
	cdb_pr_ready = 0;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	if(i < 62)
		cre_id_cap = 2;
	else
		cre_id_cap = 62-i;
	cre_mt_fl_retire_tag_a = 0;
	cre_mt_fl_retire_tag_b = 0;
	cre_mt_fl_bht_recover_retire_num = 0;
	cre_mt_retire_ar_a = 0;//new
	cre_mt_retire_ar_b = 0;//new

	cre_bht_recover_cond_branch0 = 0;//new
	cre_bht_retire_bhr0 = 0;//new
	cre_bht_recover_NPC0 = 0;
	cre_bht_actual_taken0 = 0;//new
	cre_recover_uncond_branch0 = 0;//new
	cre_recover_actual_addr0 = 0;//new

	cre_bht_recover_cond_branch1 = 0;//new
	cre_bht_retire_bhr1 = 0;//new
	cre_bht_recover_NPC1 = 0;//new
	cre_bht_actual_taken1 = 0;//new
	cre_recover_uncond_branch1 = 0;//new
	cre_recover_actual_addr1 = 0;//new

	cre_recover_exception = 0;//new
end

@(negedge clock);//dispatch 62
fl_pr0 = 62+4;
fl_pr1 = 0;
id_dispatch_num = 1;
id_valid_inst0 = 1;
id_valid_inst1 = 0;
mt_p0told = 62+4;
mt_p1told = 0;
id_NPC0 = 16+(62*4);//new
id_NPC1 = 0;//new
id_dest_idx0 = 62+4;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 1;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 1;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 62+4;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 1;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new

@(negedge clock);//dispatch 63
fl_pr0 = 63+4;
fl_pr1 = 0;
id_dispatch_num = 1;
id_valid_inst0 = 1;
id_valid_inst1 = 0;
mt_p0told = 63+4;
mt_p1told = 0;
id_NPC0 = 16+(63*4);//new
id_NPC1 = 0;//new
id_dest_idx0 = 63+4;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 1;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 1;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 63+4;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 0;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new

for(i=63; i>1; i=i-2) begin//ready those entries one by one
@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	id_NPC0 = 0;//new
	id_NPC1 = 0;//new
	id_dest_idx0 = 0;//new
	id_dest_idx1 = 0;//new
	id_cond_branch0 = 0;//new
	id_cond_branch1 = 0;//new
	id_uncond_branch0 = 0;//new
	id_uncond_branch1 = 0;//new
	id_bhr0 = 0;//new
	id_bhr1 = 0;//new
	cdb_exception0 = 0;//new
	cdb_exception1 = 0;//new
	cdb_exception2 = 0;//new
	cdb_exception3 = 0;//new
	cdb_exception4 = 0;//new
	cdb_exception5 = 0;//new
	cdb_actual_addr0 = (i+4)*4;//new
	cdb_actual_taken0 = 1;//new
	cdb_actual_addr1 = (i+3)*4;//new
	cdb_actual_taken1 = 1;//new
	cdb_pr_ready = 6'b000011;
	cdb_pr_tag_0 = i+4;
	cdb_pr_tag_1 = i+3;
	cdb_pr_tag_2 = i+2;
	cdb_pr_tag_3 = i+1;
	cdb_pr_tag_4 = i;
	cdb_pr_tag_5 = i-1;
	//prediction
	cre_id_cap = 0;
	cre_mt_fl_retire_tag_a = 0;
	cre_mt_fl_retire_tag_b = 0;
	cre_mt_fl_bht_recover_retire_num = 0;
	cre_mt_retire_ar_a = 0;//new
	cre_mt_retire_ar_b = 0;//new

	cre_bht_recover_cond_branch0 = 0;//new
	cre_bht_retire_bhr0 = 0;//new
	cre_bht_recover_NPC0 = 0;
	cre_bht_actual_taken0 = 0;//new
	cre_recover_uncond_branch0 = 0;//new
	cre_recover_actual_addr0 = 0;//new

	cre_bht_recover_cond_branch1 = 0;//new
	cre_bht_retire_bhr1 = 0;//new
	cre_bht_recover_NPC1 = 0;//new
	cre_bht_actual_taken1 = 0;//new
	cre_recover_uncond_branch1 = 0;//new
	cre_recover_actual_addr1 = 0;//new

	cre_recover_exception = 0;//new
end

@(negedge clock);
fl_pr0 = 0;
fl_pr1 = 0;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 0;
mt_p1told = 0;
id_NPC0 = 0;//new
id_NPC1 = 0;//new
id_dest_idx0 = 0;//new
id_dest_idx1 = 0;//new
id_cond_branch0 = 0;//new
id_cond_branch1 = 0;//new
id_uncond_branch0 = 0;//new
id_uncond_branch1 = 0;//new
id_bhr0 = 0;//new
id_bhr1 = 0;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 4*4;//new
cdb_actual_taken0 = 1;//new
cdb_actual_addr1 = 5*4;//new
cdb_actual_taken1 = 1;//new
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 4;
cdb_pr_tag_1 = 5;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 0;
cre_mt_fl_retire_tag_a = 4;
cre_mt_fl_retire_tag_b = 5;
cre_mt_fl_bht_recover_retire_num = 2;
cre_mt_retire_ar_a = 4;//new
cre_mt_retire_ar_b = 5;//new

cre_bht_recover_cond_branch0 = 1;//new
cre_bht_retire_bhr0 = 4;//new
cre_bht_recover_NPC0 = 16;
cre_bht_actual_taken0 = 1;//new
cre_recover_uncond_branch0 = 1;//new
cre_recover_actual_addr0 = 16;//new

cre_bht_recover_cond_branch1 = 1;//new
cre_bht_retire_bhr1 = 5;//new
cre_bht_recover_NPC1 = 20;//new
cre_bht_actual_taken1 = 1;//new
cre_recover_uncond_branch1 = 1;//new
cre_recover_actual_addr1 = 20;//new

cre_recover_exception = 0;//new

for(i=2; i<64; i=i+2) begin
@(negedge clock);
	fl_pr0 = 0;
	fl_pr1 = 0;
	id_dispatch_num = 0;
	id_valid_inst0 = 0;
	id_valid_inst1 = 0;
	mt_p0told = 0;
	mt_p1told = 0;
	id_NPC0 = 0;//new
	id_NPC1 = 0;//new
	id_dest_idx0 = 0;//new
	id_dest_idx1 = 0;//new
	id_cond_branch0 = 0;//new
	id_cond_branch1 = 0;//new
	id_uncond_branch0 = 0;//new
	id_uncond_branch1 = 0;//new
	id_bhr0 = 0;//new
	id_bhr1 = 0;//new
	cdb_exception0 = 0;//new
	cdb_exception1 = 0;//new
	cdb_exception2 = 0;//new
	cdb_exception3 = 0;//new
	cdb_exception4 = 0;//new
	cdb_exception5 = 0;//new
	cdb_actual_addr0 = 0;//new
	cdb_actual_taken0 = 0;//new
	cdb_actual_addr1 = 0;//new
	cdb_actual_taken1 = 0;//new
	cdb_pr_ready = 6'b000000;
	cdb_pr_tag_0 = 0;
	cdb_pr_tag_1 = 0;
	cdb_pr_tag_2 = 0;
	cdb_pr_tag_3 = 0;
	cdb_pr_tag_4 = 0;
	cdb_pr_tag_5 = 0;
	//prediction
	cre_id_cap = 2;
	cre_mt_fl_retire_tag_a = i+4;
	cre_mt_fl_retire_tag_b = i+5;
	cre_mt_fl_bht_recover_retire_num = 2;
	cre_mt_retire_ar_a = i+4;//new
	cre_mt_retire_ar_b = i+5;//new

	cre_bht_recover_cond_branch0 = 1;//new
	cre_bht_retire_bhr0 = i+4;//new
	cre_bht_recover_NPC0 = 16+(i*4);
	cre_bht_actual_taken0 = 1;//new
	cre_recover_uncond_branch0 = 1;//new
	cre_recover_actual_addr0 = 16+(i*4);//new

	cre_bht_recover_cond_branch1 = 1;//new
	cre_bht_retire_bhr1 = i+5;//new
	cre_bht_recover_NPC1 = 20+(i*4);//new
	cre_bht_actual_taken1 = 1;//new
	cre_recover_uncond_branch1 = 1;//new
	cre_recover_actual_addr1 = 20+(i*4);//new

	cre_recover_exception = 0;//new
end
//now test exception
@(negedge clock);//insert two instructions
fl_pr0 = 1;
fl_pr1 = 2;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 1;
mt_p1told = 2;
id_NPC0 = 4;//new
id_NPC1 = 8;//new
id_dest_idx0 = 1;//new
id_dest_idx1 = 2;//new
id_cond_branch0 = 1;//new
id_cond_branch1 = 1;//new
id_uncond_branch0 = 1;//new
id_uncond_branch1 = 1;//new
id_bhr0 = 1;//new
id_bhr1 = 2;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new

@(negedge clock);//cdb broadcast with the second one being exception.
fl_pr0 = 1;
fl_pr1 = 2;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 1;
mt_p1told = 2;
id_NPC0 = 4;//new
id_NPC1 = 8;//new
id_dest_idx0 = 1;//new
id_dest_idx1 = 2;//new
id_cond_branch0 = 1;//new
id_cond_branch1 = 1;//new
id_uncond_branch0 = 1;//new
id_uncond_branch1 = 1;//new
id_bhr0 = 1;//new
id_bhr1 = 2;//new
cdb_exception0 = 0;//new
cdb_exception1 = 1;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 4;//new
cdb_actual_taken0 = 1;//new
cdb_actual_addr1 = 8;//new
cdb_actual_taken1 = 1;//new
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 1;
cdb_pr_tag_1 = 2;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 1;
cre_mt_fl_retire_tag_b = 2;
cre_mt_fl_bht_recover_retire_num = 2;
cre_mt_retire_ar_a = 1;//new
cre_mt_retire_ar_b = 2;//new

cre_bht_recover_cond_branch0 = 1;//new
cre_bht_retire_bhr0 = 1;//new
cre_bht_recover_NPC0 = 4;
cre_bht_actual_taken0 = 1;//new
cre_recover_uncond_branch0 = 1;//new
cre_recover_actual_addr0 = 4;//new

cre_bht_recover_cond_branch1 = 1;//new
cre_bht_retire_bhr1 = 2;//new
cre_bht_recover_NPC1 = 8;//new
cre_bht_actual_taken1 = 1;//new
cre_recover_uncond_branch1 = 1;//new
cre_recover_actual_addr1 = 8;//new

cre_recover_exception = 1;//new

@(negedge clock);//insert two instructions
fl_pr0 = 1;
fl_pr1 = 2;
id_dispatch_num = 2;
id_valid_inst0 = 1;
id_valid_inst1 = 1;
mt_p0told = 1;
mt_p1told = 2;
id_NPC0 = 4;//new
id_NPC1 = 8;//new
id_dest_idx0 = 1;//new
id_dest_idx1 = 2;//new
id_cond_branch0 = 1;//new
id_cond_branch1 = 1;//new
id_uncond_branch0 = 1;//new
id_uncond_branch1 = 1;//new
id_bhr0 = 1;//new
id_bhr1 = 2;//new
cdb_exception0 = 0;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 0;//new
cdb_actual_taken0 = 0;//new
cdb_actual_addr1 = 0;//new
cdb_actual_taken1 = 0;//new
cdb_pr_ready = 0;
cdb_pr_tag_0 = 0;
cdb_pr_tag_1 = 0;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 0;
cre_mt_fl_retire_tag_b = 0;
cre_mt_fl_bht_recover_retire_num = 0;
cre_mt_retire_ar_a = 0;//new
cre_mt_retire_ar_b = 0;//new

cre_bht_recover_cond_branch0 = 0;//new
cre_bht_retire_bhr0 = 0;//new
cre_bht_recover_NPC0 = 0;
cre_bht_actual_taken0 = 0;//new
cre_recover_uncond_branch0 = 0;//new
cre_recover_actual_addr0 = 0;//new

cre_bht_recover_cond_branch1 = 0;//new
cre_bht_retire_bhr1 = 0;//new
cre_bht_recover_NPC1 = 0;//new
cre_bht_actual_taken1 = 0;//new
cre_recover_uncond_branch1 = 0;//new
cre_recover_actual_addr1 = 0;//new

cre_recover_exception = 0;//new

@(negedge clock);//cdb broadcast with the first one being exception.
fl_pr0 = 1;
fl_pr1 = 2;
id_dispatch_num = 0;
id_valid_inst0 = 0;
id_valid_inst1 = 0;
mt_p0told = 1;
mt_p1told = 2;
id_NPC0 = 4;//new
id_NPC1 = 8;//new
id_dest_idx0 = 1;//new
id_dest_idx1 = 2;//new
id_cond_branch0 = 1;//new
id_cond_branch1 = 1;//new
id_uncond_branch0 = 1;//new
id_uncond_branch1 = 1;//new
id_bhr0 = 1;//new
id_bhr1 = 2;//new
cdb_exception0 = 1;//new
cdb_exception1 = 0;//new
cdb_exception2 = 0;//new
cdb_exception3 = 0;//new
cdb_exception4 = 0;//new
cdb_exception5 = 0;//new
cdb_actual_addr0 = 4;//new
cdb_actual_taken0 = 1;//new
cdb_actual_addr1 = 8;//new
cdb_actual_taken1 = 1;//new
cdb_pr_ready = 6'b000011;
cdb_pr_tag_0 = 1;
cdb_pr_tag_1 = 2;
cdb_pr_tag_2 = 0;
cdb_pr_tag_3 = 0;
cdb_pr_tag_4 = 0;
cdb_pr_tag_5 = 0;
//prediction
cre_id_cap = 2;
cre_mt_fl_retire_tag_a = 1;
cre_mt_fl_retire_tag_b = 2;
cre_mt_fl_bht_recover_retire_num = 1;
cre_mt_retire_ar_a = 1;//new
cre_mt_retire_ar_b = 2;//new

cre_bht_recover_cond_branch0 = 1;//new
cre_bht_retire_bhr0 = 1;//new
cre_bht_recover_NPC0 = 4;
cre_bht_actual_taken0 = 1;//new
cre_recover_uncond_branch0 = 1;//new
cre_recover_actual_addr0 = 4;//new

cre_bht_recover_cond_branch1 = 1;//new
cre_bht_retire_bhr1 = 2;//new
cre_bht_recover_NPC1 = 8;//new
cre_bht_actual_taken1 = 1;//new
cre_recover_uncond_branch1 = 1;//new
cre_recover_actual_addr1 = 8;//new

cre_recover_exception = 1;//new
@(negedge clock);
$finish;
end

endmodule


