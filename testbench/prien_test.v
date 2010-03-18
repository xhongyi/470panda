module testbench;

parameter	DE_SIZE = 32;
parameter	EN_SIZE = 5;
  // Registers and wires used in the testbench
reg clock;
reg reset;

reg	[DE_SIZE-1:0]	decode;
wire	[EN_SIZE-1:0]	encode_high, encode_low;
wire	valid;

reg [EN_SIZE-1:0] cre_high, cre_low;

wire	correct = (cre_high == encode_high && cre_low == encode_low);

prien	pri(
		decode,
		encode_high,
		encode_low,
		valid
  		 );

always @(posedge clock)
  #2
  if(!correct) begin 
    $display("Incorrect at time %4.0f",$time);
    $display("decode: %h, encode_low: %d, encode_high: %d, cre_low: %d, cre_high: %d", decode, encode_low, encode_high, cre_low, cre_high);
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
	$monitor("Time:%4.0f decode: %h, encode_low: %d, encode_high: %d, cre_low: %d, cre_high: %d",$time, decode, encode_low, encode_high, cre_low, cre_high);
	clock = 0;
	decode = 32'hffff_ffff;
	cre_high = 5'd31;
	cre_low = 5'd1;
//test reset and 1 dispatch with 0 retire.
@(negedge clock);
decode = 32'h0f00_0000;
cre_high = 5'd27;
cre_low = 5'd24;
@(negedge clock);
decode = 32'h0f00_00f0;
cre_high = 5'd27;
cre_low = 5'd4;


@(negedge clock);
$finish;
end

endmodule


