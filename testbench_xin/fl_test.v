/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  fl_test.v                         //
//                                                                     //
//  Description :  Testbench module for the free list//
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


module testbench;

  // Registers and wires used in the testbench
reg clock;
reg reset;
reg [1:0] rob_dispatch_num;
reg [1:0] rob_retire_num;
reg [6:0] rob_retire_a;
reg [6:0] rob_retire_b;

wire [6:0] rob_rs_mt_a;
wire [6:0] rob_rs_mt_b;

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

always @*
begin
  if(rob_dispatch_num == 1)
    correct = (cre_a == rob_rs_mt_a)|~done;
  else if (rob_dispatch_num == 2)
    correct = (cre_a == rob_rs_mt_a)&(cre_b == rob_rs_mt_b)|~done;
  else
    correct = 1;
end

always @(posedge clock)
  #3 
  if(!correct) begin 
    $display("Incorrect at time %4.0f",$time);
    $display("done:%d dispatch_num:%d retire_num:%d rob_retire_a:%d rob_retire_b:%d cre_a:%d cre_b:%d rob_rs_mt_a:%d rob_rs_mt_b:%d, correct: %d", done, rob_dispatch_num, rob_retire_num, rob_retire_a, rob_retire_b, cre_a, cre_b, rob_rs_mt_a, rob_rs_mt_b, correct);
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
  $monitor("Time:%4.0f -clock:%d done:%d dispatch_num:%d retire_num:%d rob_retire_a:%d rob_retire_b:%d cre_a:%d cre_b:%d rob_rs_mt_a:%d rob_rs_mt_b:%d, correct:%d, reset: %d",$time, clock, done, rob_dispatch_num, rob_retire_num, rob_retire_a, rob_retire_b, cre_a, cre_b, rob_rs_mt_a, rob_rs_mt_b, correct, reset);
  rob_dispatch_num = 0;
  rob_retire_num = 0;
  rob_retire_a = 0;
  rob_retire_b = 0;
  cre_a = 0;
  cre_b = 0;
  correct = 1;
  clock=0;
  done = 0;
  reset = 1;
//test reset and 1 dispatch with 0 retire.
@(negedge clock);
@(negedge clock);
reset=0;
@(posedge clock);
rob_dispatch_num = 1;
cre_a = 32;
done = 1;
@(posedge clock);
rob_dispatch_num = 0;
done = 0;
//test 2 dispatch with 0 retire.
@(posedge clock);
rob_dispatch_num = 2;
cre_a = 33;
cre_b = 34;
done = 1;
@(posedge clock);
rob_dispatch_num = 0;
done = 0;
//test 0 dispatch with 1 retire.
@(posedge clock);
rob_dispatch_num = 0;
rob_retire_num = 1;
cre_a = 5;
cre_b = 0;
rob_retire_a = 5;
@(posedge clock);
rob_retire_num = 0;
rob_dispatch_num = 1;
done = 1;
@(posedge clock);
rob_dispatch_num = 0;
done = 0;
//test 0 dispatch with 2 retire.
@(posedge clock);
rob_dispatch_num = 0;
rob_retire_num = 2;
cre_a = 6;
cre_b = 7;
rob_retire_a = 6;
rob_retire_b = 7;
@(posedge clock);
rob_retire_num = 0;
rob_dispatch_num = 2;
done = 1;
@(posedge clock);
rob_dispatch_num = 0;
done = 0;
//test 1 dispatch with 1 retire.
@(posedge clock);
rob_dispatch_num = 1;
rob_retire_num = 1;
cre_a = 8;
cre_b = 0;
rob_retire_a = 8;
rob_retire_b = 0;
done = 1;
@(posedge clock);
rob_retire_num = 0;
rob_dispatch_num = 0;
done = 0;
//test 2 dispatch with 2 retire.
@(posedge clock);
rob_dispatch_num = 2;
rob_retire_num = 2;
cre_a = 9;
cre_b = 10;
rob_retire_a = 9;
rob_retire_b = 10;
done = 1;
@(posedge clock);
rob_retire_num = 0;
rob_dispatch_num = 0;
done = 0;
//test 1 dispatch with 2 retire.
@(posedge clock);
rob_dispatch_num = 1;
rob_retire_num = 2;
cre_a = 12;
cre_b = 0;
rob_retire_a = 11;
rob_retire_b = 12;
done = 1;
@(posedge clock);
rob_retire_num = 0;
rob_dispatch_num = 0;
done = 0;
@(posedge clock);
rob_dispatch_num = 1;
cre_a = 11;
done = 1;
@(posedge clock);
rob_dispatch_num = 0;
done = 0;
//test 2 dispatch with 1 retire.
@(posedge clock);
rob_dispatch_num = 2;
rob_retire_num = 1;
cre_a = 13;
cre_b = 35;
rob_retire_a = 13;
rob_retire_b = 0;
done = 1;
@(posedge clock);
rob_retire_num = 0;
rob_dispatch_num = 0;
done = 0;
@(posedge clock);
$finish;
end

endmodule


