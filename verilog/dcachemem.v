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
											 dcache_halt,
											 Dmem_response,
                       // outputs
                       rd1_data,
                       rd1_valid,
                       wr1_dirty,
                       wr1_dirty_data,
                       rob_halt_complete,
                       Dmem_data,
                       Dmem_addr,
                       Dmem_cmd
                       
                      );

input clock, reset, wr1_en, wr0_en,dcache_halt;
input [6:0] wr1_idx, wr0_idx, rd1_idx;
input [21:0] wr1_tag, wr0_tag, rd1_tag;
input [63:0] wr1_data, wr0_data; 
input [3:0] Dmem_response;
output [63:0] rd1_data,Dmem_data, Dmem_addr,wr1_dirty_data;
output [1:0] Dmem_cmd;
output rd1_valid, rob_halt_complete;
output wr1_dirty;

reg				 has_dirty;
reg [63:0] data [127:0];
reg [21:0] tags [127:0]; 
reg [127:0] valids;
reg [127:0] dirty;
reg [127:0] next_dirty;
integer i;
reg [63:0] Dmem_addr,Dmem_data;
reg [1:0] Dmem_cmd;
reg rob_halt_complete;


assign rd1_data = data[rd1_idx];
assign rd1_valid = valids[rd1_idx]&&(tags[rd1_idx] == rd1_tag);
assign wr1_dirty = dirty[wr1_idx];
assign wr1_data  = data[wr1_idx];
assign mem_wr_en = dirty[wr1_idx] & valids[wr1_idx] & (wr1_tag != tags[wr1_idx]);
assign mem_addr =  {tags[wr1_idx], wr1_idx};
assign mem_data =  data[wr1_idx];

always @*
begin
	
	if(dcache_halt)
		begin
			//proc2Dmem_command = `BUS_STORE
			rob_halt_complete = 0;
			has_dirty = 0;
			for(i = 0; i<128; i = i+ 1)
				next_dirty[i] = dirty[i];
		
			for(i = 0; i<128; i = i + 1)
			begin			
				if(dirty[i]&!has_dirty)
				begin
					Dmem_addr =  {32'b0,tags[i],10'b0}+(i<<3);	
					Dmem_data = data[i];
					Dmem_cmd  = `BUS_STORE;
					next_dirty[i] = (Dmem_response==0)?1:0;
					has_dirty = 1;
				end
			end
			if(has_dirty == 0) rob_halt_complete = 1;
		end
end
				



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
		if(dcache_halt)
		begin
			for(i = 0; i<128; i=i+1)
			dirty[i] <= `SD next_dirty[i];
		end
	else 
		begin
		if(wr1_en)
		begin
			data[wr1_idx] <= `SD wr1_data;
			tags[wr1_idx] <= `SD wr1_tag;
			dirty[wr1_idx] <= `SD 1;
		end
		if(wr0_en&&~(wr1_en&&wr0_idx==wr1_idx))
		begin
			data[wr0_idx] <= `SD wr0_data;
			tags[wr0_idx] <= `SD wr0_tag;
			dirty[wr0_idx] <= `SD 0;
		end
	end
	end
end

endmodule
