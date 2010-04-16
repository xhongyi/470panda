module dcachemem128x64 (// inputs
                       clock,
                       reset, 
                       wr1_en,
                       wr1_tag,
                       wr1_idx,
                       wr1_data,
											 wr0_en,
											 wr0_tag,
											 wr0_idx,
											 wr0_data,
                       rd1_tag,
                       rd1_idx,

                       // outputs
                       rd1_data,
                       rd1_valid,
                       wr1_dirty
                       
                      );

input clock, reset, wr1_en, wr0_en;
input [6:0] wr1_idx, wr0_idx, rd1_idx;
input [21:0] wr1_tag, wr0_tag, rd1_tag;
input [63:0] wr1_data, wr0_data; 
output [63:0] rd1_data;
output rd1_valid;
output wr1_dirty;
reg [63:0] data [127:0];
reg [21:0] tags [127:0]; 
reg [127:0] valids;
reg [127:0] dirty;

assign rd1_data = data[rd1_idx];
assign rd1_valid = valids[rd1_idx]&&(tags[rd1_idx] == rd1_tag);
assign wr1_dirty = dirty[wr1_idx];
assign mem_wr_en = dirty[wr1_idx] & valids[wr1_idx] & (wr1_tag != tags[wr1_idx]);
assign mem_addr =  {tags[wr1_idx], wr1_idx};
assign mem_data =  data[wr1_idx];

always @(posedge clock)
begin
  if(reset) 
	valids <= `SD 128'b0;
  else 
	begin
		if(wr1_en) 
    valids[wr1_idx] <= `SD 1;
		if(wr0_en)
		valids[wr0_idx] <= `SD 1;
	end
end

always @(posedge clock)
begin
	if(reset) dirty <= `SD 128'b0;
	begin
		if(wr1_en)
		begin
			data[wr1_idx] <= `SD wr1_data;
			tags[wr1_idx] <= `SD wr1_tag;
			dirty[wr1_idx] <= `SD ~dirty[wr1_idx];
		end
		if(wr0_en)
		begin
			data[wr0_idx] <= `SD wr0_data;
			tags[wr0_idx] <= `SD wr0_tag;
			dirty[wr0_idx] <= `SD ~dirty[wr0_idx];
		end
	end
end

endmodule
