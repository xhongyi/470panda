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
		  rob_retire_tag_0,
		  rob_retire_tag_1,
		
			recover,
			
	  	  //outputs
	 	  rob_rs_mt_pr0, //new registers
		  rob_rs_mt_pr1
		  //debug output
  		 );

input clock, reset;
input [1:0] id_dispatch_num;
input [1:0] rob_retire_num;
input [6:0] rob_retire_tag_0, rob_retire_tag_1;

input recover;

output [6:0] rob_rs_mt_pr0, rob_rs_mt_pr1;

wire [5:0] tail_plus_one;
wire [5:0] head_plus_one;
wire [5:0] tail_plus_two;
wire [5:0] head_plus_two;

reg [5:0] head, tail;
reg [5:0] next_head, next_tail;

reg [6:0] next_pr [63:0];
reg	[6:0]	pr [63:0];

assign tail_plus_one = tail + 6'd1;
assign head_plus_one = head + 6'd1;
assign tail_plus_two = tail + 6'd2;
assign head_plus_two = head + 6'd2;

assign rob_rs_mt_pr0 = pr[tail];
assign rob_rs_mt_pr1 = pr[tail_plus_one];

integer i;

always @* begin
	next_tail = tail;
	next_head = head;
	for (i=0; i<64; i=i+1) begin
		next_pr[i] = pr[i];
	end
	
	if (recover)
		next_tail = head;
	else begin
		if (id_dispatch_num == 2'd2)
			next_tail = tail_plus_two;
		else if (id_dispatch_num == 2'd1)
			next_tail = tail_plus_one;

		if (rob_retire_num == 2'd2) begin
			next_pr[head] = rob_retire_tag_0;
			next_pr[head_plus_one] = rob_retire_tag_1;
			next_head =	head_plus_two;
		end
		else if (rob_retire_num == 2'd1) begin
			next_pr[head] = rob_retire_tag_0;
      next_head = head_plus_one;
		end
	end
end//end always

always @(posedge clock) begin
  if (reset) begin
    head <= 6'd0;
    tail <= 6'd0;
   	for (i=0; i<64; i=i+1) begin
   		pr[i] = (i+7'd32);
   	end
  end
  else begin
    head <= next_head;
    tail <= next_tail;
    for (i=0; i<64; i=i+1) begin
    	pr[i] = next_pr[i];
    end
  end
end//end always

genvar IDX;
generate
	for(IDX=0; IDX<64; IDX=IDX+1)
	begin : foo
wire	[63:0]	PR = pr[IDX];
wire	[63:0]	NEXT_PR = next_pr[IDX];
	end
endgenerate

endmodule
