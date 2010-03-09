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

module free_list (//inputs
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

input clock, reset;
input [1:0] rob_dispatch_num;
input [1:0] rob_retire_num;
input [6:0] rob_retire_a, rob_retire_b;

output [6:0]rob_rs_mt_a, rob_rs_mt_b;

reg [6:0] free_entries [63:0];
reg [6:0] rob_rs_mt_a, rob_rs_mt_b;
reg [2:0] shift;		//0:no shift; 1:1-in-shift; 2:2-in-shift; 3:1-out-shift; 4:2-out-shift
integer i;

always @* begin
    shift = 3'd0;
    rob_rs_mt_a = 7'd0;
    rob_rs_mt_b = 7'd0;
  if (rob_dispatch_num == 2'd1 && rob_retire_num  == 2'd1)
  begin
    shift = 3'd0;
    rob_rs_mt_a = rob_retire_a;
  end
  else if (rob_dispatch_num == 2'd2 && rob_retire_num == 2'd2)
  begin
    shift = 3'd0;
    rob_rs_mt_a = rob_retire_a;
    rob_rs_mt_b = rob_retire_b;
  end
  else if (rob_dispatch_num == 2'd0 && rob_retire_num == 2'd1)
  begin
    shift = 3'd1;
  end
  else if (rob_dispatch_num == 2'd0 && rob_retire_num == 2'd2)
  begin
    shift = 3'd2;
  end
  else if (rob_dispatch_num == 2'd1 && rob_retire_num == 2'd0)
  begin
    shift = 3'd3;
    rob_rs_mt_a = free_entries[0];
  end
  else if ((rob_dispatch_num == 2'd2) && (rob_retire_num == 2'd0))
  begin
    shift = 3'd4;
    rob_rs_mt_a = free_entries[0];
    rob_rs_mt_b = free_entries[1];
  end
  else if (rob_dispatch_num == 2'd1 && rob_retire_num == 2'd2)
  begin
    shift = 3'd1;
    rob_rs_mt_a = rob_retire_b;
  end
  else if (rob_dispatch_num == 2'd2 && rob_retire_num == 2'd1)
  begin
    shift = 3'd3;
    rob_rs_mt_a = rob_retire_a;
    rob_rs_mt_b = free_entries[0];
  end
end

always @(posedge clock) begin
  if (reset) begin
    for (i=95; i>=32; i = i-1) begin
      free_entries[i-32] <= i;
    end
  end
  else begin
    if (shift == 3'd1) begin
      free_entries[0] <= rob_retire_a;
      for (i=1; i<=31; i=i+1) begin
        free_entries[i] <= free_entries[i-1];
      end
    end
    else if (shift == 3'd2) begin
      free_entries[0] <= rob_retire_a;
      free_entries[1] <= rob_retire_b;
      for (i=2; i<=31; i=i+1) begin
        free_entries[i] <= free_entries[i-2];
      end
    end
    else if (shift == 3'd3) begin 
      free_entries[63] <= 7'd0;
      for (i=0; i<=30; i=i+1) begin
        free_entries[i] <= free_entries[i+1];
      end
    end
    else if (shift == 3'd4) begin
      free_entries[63] <= 7'd0;
      free_entries[62] <= 7'd0;
      for (i=0; i<=29; i=i+1) begin
        free_entries[i] <= free_entries[i+2];
      end
    end
  end
end
endmodule
