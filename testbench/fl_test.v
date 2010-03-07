/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  fl_test.v                                           //
//                                                                     //
//  Description :  Testbench module for the free list                  //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

//


module testbench;

  // Registers and wires used in the testbench
reg clock;
reg reset;
reg [1:0] rob_dispatch_num;
reg [1:0] rob_retire_num;
reg [6:0] rob_retire_a;
reg [6:0] rob_retire_b;

wire [6:0] rob_rs_mt_a,
wire [6:0] rob_rs_mt_b,

reg [6:0] cre_a;
reg [6:0] cre_b;

reg correct;
reg done;
  // Instantiate the Pipeline
free_list    f1 (//inputs
		  clock,
		  reset,
		  rob_dispatch_num,
		  rob_retire_num,
		  rob_retire_a,
		  rob_retire_b,
		
	  	  //outputs
	 	  rob_rs_mt_a, //new registers
		  rob_rs_mt_b,
		  //debug output
  		 );

always @(posedge clock)
begin
  if(rob_dispatch_num == (rob_retire_num + 1))
    correct = (cre_a == rob_re_mt_a)|~done;
  else if (rob_dispatch_num == (rob_retire_num + 2))
    correct = (cre_a == rob_re_mt_a)&(cre_b == rob_re_mt_b)|~done;
  3# 
  if(!correct) begin 
    $display("Incorrect at time %4.0f",$time);
    $display("cres = %h result = %h",cres,result);
    $finish;
  end

  // Generate System Clock
  always
  begin
    #5;
    clock = ~clock;
  end

initial begin

  //$vcdpluson;
  $monitor("Time:%4.0f done:%h dispatch_num:%h retire_num:%h rob_retire_a:%h rob_retire_b:%h cre_a:%h cre_b:%h rob_rs_mt_a:%h rob_rs_mt_b:%h, correct",$time,done,dispatch_num,retire_num,rob_retire_a,rob_retire_b,cre_a,cre_b,rob_rs_mt_a,rob_rs_mt_b,correct);
  dispatch_num = 0;
  retire_num = 0;
  rob_retire_a = 0;
  rob_retire_b = 0;
  cre_a = 0;
  cre_b = 0;
  rob_rs_mt_a = 0;
  rob_rs_mt_b = 0;
  correct = 1;
  clock=0;
  reset = 1;
//test reset and 1 dispatch with 0 retire.
@(negedge clock);
@(negedge clock);
reset=0;
@(negedge clock);
rob_dispatch = 1;
cre_a = 32;
@(negedge clock);
done = 1;
@(negedge clock);
done = 0;
@(negedge clock);
//test 2 dispatch with 0 retire.
@(negedge clock);
rob_dispatch = 2;
cre_a = 32;
cre_b = 3
@(negedge clock);
done = 1;
@(negedge clock);
done = 0;
@(negedge clock);



@(posedge done);
@(negedge clock);
start=1;
a=-1;
@(negedge clock);
start=0;
@(posedge done);
@(negedge clock);
@(negedge clock);
start=1;
a=-20;
b=5;
@(negedge clock);
start=0;
@(posedge done);
@(negedge clock);
quit = 0;
quit <= #10000 1;
while(~quit)
begin
  start=1;
  a={$random,$random};
  b={$random,$random};
  @(negedge clock);
  start=0;
  @(posedge done);
  @(negedge clock);
end
$finish;
end

endmodule


