/*************************************************************
 *
 * Module: prien.v
 *
 * Desciption: priority decoder with high and low idx
 *
 * clock: 1.09
 *
 *************************************************************/
module prien_2(
				decode,

				encode_high,
				encode_low,
				valid);

input		[1:0]	decode;
output				encode_high;
output				encode_low;
output				valid;

assign valid = decode[1] | decode[0];

assign encode_high = decode[1];

assign encode_low = ~decode[0];

endmodule

module prien_4(
				decode,

				encode_high,
				encode_low,
				valid);

input		[3:0]	decode;

output	[1:0]	encode_high;
output	[1:0]	encode_low;
output				valid;

wire 		[1:0]	sub_valid;
wire		[1:0]	sub_encode_high;
wire		[1:0]	sub_encode_low;

prien_2 sub_prien [1:0] (.decode(decode),
				.encode_high(sub_encode_high),
				.encode_low(sub_encode_low),
				.valid(sub_valid));

assign	encode_high[1] = sub_valid[1];
assign	encode_high[0] = (sub_valid[1]) ? sub_encode_high[1] :
												 (sub_valid[0]) ? sub_encode_high[0] : 1'b0;

assign	encode_low[1] = ~sub_valid[0]  & sub_valid[1];
assign	encode_low[0] = (sub_valid[0]) ? sub_encode_low[0] :
												(sub_valid[1]) ? sub_encode_low[1] : 1'b0;

assign	valid = sub_valid[1] | sub_valid[0];

endmodule

module prien_8(
				decode,

				encode_high,
				encode_low,
				valid);

input		[7:0]	decode;

output	[2:0]	encode_high;
output	[2:0]	encode_low;
output				valid;

wire		[1:0]	sub_valid;
wire		[3:0]	sub_encode_high;
wire		[3:0]	sub_encode_low;

prien_4 sub_prien [1:0] (.decode(decode),
				.encode_high(sub_encode_high), 
				.encode_low(sub_encode_low),
				.valid(sub_valid));

assign encode_high[2] = sub_valid[1];
assign encode_high[1:0] = (sub_valid[1]) ? sub_encode_high[3:2] :
													(sub_valid[0]) ? sub_encode_high[1:0]	: 2'b0;

assign encode_low[2] = ~sub_valid[0] & sub_valid[1];
assign encode_low[1:0] = (sub_valid[0]) ? sub_encode_low[1:0] :
												 (sub_valid[1]) ? sub_encode_low[3:2] : 2'b00;

assign valid = sub_valid[1] | sub_valid[0];

endmodule

module prien_16(
				decode,

				encode_high,
				encode_low,
				valid);

input		[15:0]	decode;

output	[3:0]	encode_high;
output	[3:0]	encode_low;
output				valid;

wire		[1:0]	sub_valid;
wire		[5:0]	sub_encode_high;
wire		[5:0]	sub_encode_low;

prien_8 sub_prien [1:0] (.decode(decode),
				.encode_high(sub_encode_high), 
				.encode_low(sub_encode_low),
				.valid(sub_valid));

assign encode_high[3] = sub_valid[1];
assign encode_high[2:0] = (sub_valid[1]) ? sub_encode_high[5:3] :
													(sub_valid[0]) ? sub_encode_high[2:0]	: 3'b0;

assign encode_low[3] = ~sub_valid[0] & sub_valid[1];
assign encode_low[2:0] = (sub_valid[0]) ? sub_encode_low[2:0] :
												 (sub_valid[1]) ? sub_encode_low[5:3] : 3'b0;

assign valid = sub_valid[1] | sub_valid[0];

endmodule

// 32 bits
module prien(
				decode,

				encode_high,
				encode_low,
				valid);

input		[31:0]	decode;

output	[4:0]	encode_high;
output	[4:0]	encode_low;
output				valid;

wire		[1:0]	sub_valid;
wire		[7:0]	sub_encode_high;
wire		[7:0]	sub_encode_low;

prien_16 sub_prien [1:0] (.decode(decode),
				.encode_high(sub_encode_high), 
				.encode_low(sub_encode_low),
				.valid(sub_valid));

assign encode_high[4] = sub_valid[1];
assign encode_high[3:0] = (sub_valid[1]) ? sub_encode_high[7:4] :
													(sub_valid[0]) ? sub_encode_high[3:0]	: 4'b0;

assign encode_low[4] = ~sub_valid[0] & sub_valid[1];
assign encode_low[3:0] = (sub_valid[0]) ? sub_encode_low[3:0] :
												 (sub_valid[1]) ? sub_encode_low[7:4] : 4'b0;

assign valid = sub_valid[1] | sub_valid[0];

endmodule
