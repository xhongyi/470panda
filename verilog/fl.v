//The main usage of free list is to output and forword free register tags to rob and rs.
//It should act as a stack, which means the most recently freed one would be used first.
//If reset, then free_entries[0] = 32, free_entries[1] = 33,... free_entries[63] = 95.
//If 2 request and 2 retire, just forward the retires to the requests.
//If 1 request and 1 retire, just forward the retires to the requests.
//If 0 request and 0 retire, just forward the retires to the requests.
//If 2 request and 1 retire, then shift out by 1 and forward 1.
//If 2 request and 0 retire, then shift out by 2.
//If 1 request and 0 retire, then shift out by 1.
//If 1 request and 2 retire, then shift in by 1 and forward 1.
//If 0 request and 2 retire, then shift in by 2.
//If 0 request and 1 retire, then shift in by 1.

module fl (//inputs
		  clock,
		  reset,
		  id_dispatch_num,
		  rob_retire_num,
		
	  	  //outputs
	 	  rob_rs_mt_pr0, //new registers
		  rob_rs_mt_pr1
		  //debug output
  		 );

input clock, reset;
input [1:0] id_dispatch_num;
input [1:0] rob_retire_num;

output [6:0]rob_rs_mt_pr0, rob_rs_mt_pr1;

reg [6:0] head, tail;
reg [6:0] next_head, next_tail;
reg [6:0] rob_rs_mt_pr0, rob_rs_mt_pr1;

integer i;

always @* begin
  if (id_dispatch_num == 2'd2) begin
    if (tail == 7'd94) begin
      next_tail = 7'd0;
      rob_rs_mt_pr0 = tail;
      rob_rs_mt_pr1 = tail + 7'd1;
    end
    else if (tail == 7'd95) begin
      next_tail = 7'd1;
      rob_rs_mt_pr0 = tail;
      rob_rs_mt_pr1 = 7'd0;
    end
    else begin
      next_tail = tail + 7'd2;
      rob_rs_mt_pr0 = tail;
      rob_rs_mt_pr1 = tail + 7'd1;
    end
  end
  else if (id_dispatch_num == 2'd1) begin
    rob_rs_mt_pr0 = tail;
    rob_rs_mt_pr1 = 7'd0;
    if (tail == 7'd95)
      next_tail = 7'd0;
    else
      next_tail = tail + 7'd1;
  end
  else begin
    next_tail = tail;
    rob_rs_mt_pr0 = 7'd0;
    rob_rs_mt_pr1 = 7'd0;
  end


  if (rob_retire_num == 2'd2) begin
    if (head == 7'd94)
      next_head = 7'd0;
    else if (head == 7'd95)
      next_head = 7'd1;
    else
      next_head = head + 7'd2;
	end
  else if (rob_retire_num == 2'd1)
    if (head == 7'd95)
      next_head = 7'd0;
    else
      next_head = head + 7'd1;
  else
    next_head = head;

end

always @(posedge clock) begin
  if (reset) begin
    head <= 7'd95;
    tail <= 7'd32;
  end
  else begin
    head <= next_head;
    tail <= next_tail;
  end
end
endmodule
