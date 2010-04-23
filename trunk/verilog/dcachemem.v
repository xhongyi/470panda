module dcachemem(// inputs
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
											 dcache_halt,
											 Dmem_response,
                       // outputs
                       rd1_data,
                       rd1_valid,
                       rob_halt_complete
                                             
                      );

input clock, reset, wr1_en, wr0_en,dcache_halt;
input [6:0] wr1_idx, wr0_idx, rd1_idx;
input [21:0] wr1_tag, wr0_tag, rd1_tag;
input [63:0] wr1_data, wr0_data; 
input [3:0] Dmem_response;
output [63:0] rd1_data;
output rd1_valid, rob_halt_complete;

reg [63:0] data [127:0];
reg [21:0] tags [127:0]; 
reg [127:0] valids;

integer i;
reg [63:0] Dmem_addr,Dmem_data;
reg [1:0] Dmem_cmd;
reg [3:0] halt_counter;


assign rd1_data = data[rd1_idx];
assign rd1_valid = valids[rd1_idx]&&(tags[rd1_idx] == rd1_tag);


assign rob_halt_complete = (halt_counter == 1);



always @(posedge clock)
begin
  if(reset) 
  begin
  	valids <= `SD 128'b0;
		halt_counter <= `SD 0;
	end
  else 
	begin
		if(wr1_en) 
    valids[wr1_idx] <= `SD 1;
		if(wr0_en)
		valids[wr0_idx] <= `SD 1;
	end
	if(dcache_halt)
		begin
			halt_counter <= `SD  1;
		end
end

genvar j;
generate
	for (j = 0; j < 128; j=j+1)
	begin : dmem
		wire	[63:0]	DATA = data[j];
	end
endgenerate

always @(posedge clock)
begin
		if(wr1_en)
		begin
			data[wr1_idx] <= `SD wr1_data;
			tags[wr1_idx] <= `SD wr1_tag;
		end
		if(wr0_en&&~(wr1_en&&wr0_idx==wr1_idx))
		begin
			data[wr0_idx] <= `SD wr0_data;
			tags[wr0_idx] <= `SD wr0_tag;
		end
		
			

end

endmodule
