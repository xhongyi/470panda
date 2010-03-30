


//////////////////////////////////////////////////////////
// EECS470 Project Team Panda							//
// Re-order Buffer										//
// Min Clock Cycle: 3.2ns								//
//////////////////////////////////////////////////////////



module rob(//inputs
			reset,
			clock,
			//dispatch
			fl_pr0,
			fl_pr1,
			mt_p0told,
			mt_p1told,
			id_dispatch_num,
			id_valid_inst0,
			id_valid_inst1,
			id_halt0,
			id_halt1,
			//complete
			cdb_pr_ready,
			cdb_pr_tag_0,
			cdb_pr_tag_1,
			cdb_pr_tag_2,
			cdb_pr_tag_3,
			cdb_pr_tag_4,
			cdb_pr_tag_5,
			//outputs
			//dispatch
			id_cap,
			//retire
			fl_retire_tag_a,
			fl_retire_tag_b,
			fl_retire_num,

			retire_halt //new it is true when halt inst is retired

);
input reset;
input clock;

input [6:0] fl_pr0;
input [6:0] fl_pr1;
input [6:0] mt_p0told;
input [6:0] mt_p1told;
input  id_valid_inst0;
input  id_valid_inst1;
input [1:0] id_dispatch_num;

input [5:0] cdb_pr_ready; //Note: the bandwidth is CDB_WIDTH;
input [6:0] cdb_pr_tag_0;
input [6:0] cdb_pr_tag_1;
input [6:0] cdb_pr_tag_2;
input [6:0] cdb_pr_tag_3; 
input [6:0] cdb_pr_tag_4;
input [6:0] cdb_pr_tag_5; //Note: the bandwidth is CDB_WIDTH;

input id_halt0;
input	id_halt1;

output [1:0] id_cap;

output [6:0] fl_retire_tag_a;
output [6:0] fl_retire_tag_b;
output [1:0] fl_retire_num;
output retire_halt; 


reg [1:0] fl_retire_num;
reg [6:0] fl_retire_tag_a;
reg [6:0] fl_retire_tag_b;
reg [1:0] id_cap; 

 //wires
wire [5:0] head_plus_one;
wire [5:0] tail_plus_one;
wire [5:0] tail_plus_two;
wire [64:0] previous_pc;

 //Internal State
reg [63:0] ready;
reg [6:0] tag  [63:0];  //64 tags, 7 bits each.
reg [6:0] told [63:0];  //64 old tags, 7 bits each.
reg [5:0] head ; //head position, anywhere between 0 and 63.
reg [5:0] tail ; //tail position, anywhere between 0 and 63.
reg [63:0] halt;

//reg inputs
reg [6:0] pr0;
reg [6:0] pr1;
reg [6:0] p0told;
reg [6:0] p1told;
reg  valid_inst0;
reg  valid_inst1;
reg [1:0] dispatch_num;
reg halt0;
reg halt1;

reg retire_halt;

//Update State
reg [63:0] next_ready;
reg [6:0] next_tag  [63:0];
reg [6:0] next_told [63:0];
reg [5:0] next_head;
reg [5:0] next_tail;
reg [63:0] next_halt;

integer index, jindex, kindex;

assign full = ((tail==6'd63 && head==6'd0)|(head==tail+6'd1));
assign almost_full = ((tail==6'd62&&head==6'd0)&&(tail==6'd63&&head==6'd1)&&(head==tail+6'd2));

assign  head_plus_one = (head==6'd63) ? 6'b0 : head + 6'd1;
assign  tail_plus_one = (tail == 6'd63)? 6'd0 : tail + 6'd1;


always @*
begin
//Load Internal State
for (kindex = 0; kindex < 64; kindex = kindex + 1)
begin
	next_tag[kindex] = tag[kindex];
	next_told[kindex] = told[kindex];
	next_ready[kindex] = ready[kindex];
	next_halt[kindex] = halt [kindex];
end


    
	//Start of dispatch	
	//checklist:
	//check rs_avail:
	//update tag with fl , told with mt at tail
  $display("dispatch_num is ", dispatch_num);
  id_cap = full? 2'd0 : almost_full? 2'd1 :2'd2;
	case (dispatch_num) 
		2'b00:
		begin
		$display("did not dispatch");	
			//id_cap = 2'b0;
 			next_tail = tail;
		end
		2'b01:
		begin
			$display("dispatched one");
			next_tag[tail] = pr0;
			next_told[tail] = p0told;
			next_ready[tail] = ~valid_inst0; 
			next_halt[tail] = halt0;
			//id_cap = 2'b1;
			next_tail = (tail == 6'd63)? 6'd0 : tail + 6'b1;
		end
		2'b10,2'b11:
		begin
			$display("dispatched two");
			next_tag[tail] = pr0;
			next_told[tail] = p0told;
			next_halt[tail] = halt0;
			next_tag[tail_plus_one] = pr1;
			next_told[tail_plus_one] = p1told;
			next_halt[tail_plus_one] = halt1;
			next_ready[tail] = ~valid_inst0;
			next_ready[tail_plus_one] = ~valid_inst1;
		  //id_cap = 2'b10;
			next_tail = (tail == 6'd62) ? 6'd0 : (tail == 6'd63) ? 6'd1 : tail + 6'd2;
		end
	endcase
	$display("head is: %h tail is %h  tag[head]: %h tag[tail]: %h ready[head]: ",head, tail,  tag[head], tag[tail], ready[head]);
	$display("next_head is: %h next_tail is: %h next_tag[head] is: %h, next_tag[tail] is: %h",next_head, next_tail, next_tag[head], next_tag[tail]);
	$display("pr0 is:%h pr1 is %h p0told is %h p1told is%h dispatch_num is %h", pr0, pr1, p0told, p1told, dispatch_num);
	//end of dispatch

	//complete
	//checklist:
	//check each bit of cdb_pr_ready
	//if any bit of cdb_pr_ready == 1, search the hold file for ready bit.
	if(cre_pr_ready[0] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cdb_pr_tag_0 == tag[index]) next_ready[index] = 1;
			else next_ready[index] = 0;
		end
	end
	if(cre_pr_ready[1] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cre_pr_tag_1 == tag[index]) next_ready[index] = 1;
			else next_ready[index] = 0;
		end
	end	
	if(cre_pr_ready[2] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cre_pr_tag_2 == tag[index]) next_ready[index] = 1;
			else next_ready[index] = 0;
		end				
	end	
	if(cre_pr_ready[3] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cre_pr_tag_3 == tag[index]) next_ready[index] = 1;
			else next_ready[index] = 0;
		end				
	end	
	if(cre_pr_ready[4] ==1 )
	begin
				
		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cre_pr_tag_4 == tag[index]) next_ready[index] = 1;
			else next_ready[index] = 0;
		end				
	end	
	if(cre_pr_ready[5] ==1 )
	begin

		for (index = 0; index < 64; index = index + 1)
		begin					//Note: the two tags COULD be the same
			if(cre_pr_tag_5 == tag[index]) next_ready[index] = 1;
			else next_ready[index] = 0;
		end	
	end	
	//end of complete

	//retire
	//Note: default case here is we retire two command, this may be incorrect.
	//checklist:
	//check  if tail and tail_plus_one are ready
	//if ready, put the tag to retire
	//if retire is tail, output 
    if (ready[head] == 1 && ready[head_plus_one] ==1)
	begin
		next_head =  head + 2;
		next_ready[head] = 0;
		next_ready[head_plus_one] = 0;
		fl_retire_tag_a = tag[head];
		fl_retire_tag_b = tag[head_plus_one];
		fl_retire_num = 2'b10;
		retire_halt = halt[head] | halt[head_plus_one];
	end
	else if (ready[head] == 1)
	begin
		next_head = head + 1;
		next_ready[head] = 0;
		fl_retire_tag_a	= tag[head];
		fl_retire_tag_b = 7'h7f;
		fl_retire_num = 2'b01;
		retire_halt = halt[head];
	end
	else
	begin
		//do nothing
		next_head = head;
		fl_retire_num = 2'b00;
		fl_retire_tag_a = 7'h7f;
		fl_retire_tag_b = 7'h7f;
		retire_halt = 0;
	end
	

end // end of combinational logic

always @(posedge clock)
begin //of sequential logic
	if(reset)
	begin
		 head <= `SD 64'h0;
		 tail <= `SD 64'h0;
		 pr0 <= `SD 0;
		 pr1 <= `SD 0;
		 p0told <= `SD 0;
		 p1told <= `SD 0;
		 valid_inst0 <= `SD 0;
		 valid_inst1 <= `SD 1;
		 dispatch_num <= `SD 0;
		 halt0 <= `SD 0;
		 halt1 <= `SD 0;
		for (index = 0; index < 64; index = index + 1)
		begin
			halt [kindex] <= `SD 1'h0;
			tag[index] <= `SD 7'h0;
			told[index] <= `SD 7'h0;
			ready[index] <= `SD 1'h0;
		end
		//initialization
	end
	else
	begin
			for (kindex = 0; kindex < 64; kindex = kindex + 1)
			begin
				halt [kindex] <= `SD next_halt[kindex];
				tag[kindex] <= `SD next_tag[kindex];
				told[kindex] <= `SD next_told[kindex];
				ready[kindex] <= `SD next_ready[kindex];
			end
			
			head <= `SD next_head;
			tail <= `SD next_tail;
			pr0 <= `SD fl_pr0;
			 pr1 <= `SD fl_pr1;
			 p0told <= `SD mt_p0told;
			 p1told <= `SD mt_p1told;
			 valid_inst0 <= `SD id_valid_inst0;
			 valid_inst1 <= `SD id_valid_inst1;
			 dispatch_num <= `SD id_dispatch_num;
			 halt0 <= `SD id_halt0;
			 halt1 <= `SD id_halt1;
	end
end//of sequential logic

genvar IDX;
generate
	for(IDX=0; IDX<32; IDX=IDX+1)
	begin : foo
		wire [6:0] TAG = tag[IDX];  //64 tags, 7 bits each.
		wire [6:0] TOLD = told[IDX];
		wire [6:0] NEXT_TAG = next_tag[IDX];  //64 tags, 7 bits each.
		wire [6:0] NEXT_TOLD = next_told[IDX];
	end

endgenerate


endmodule
	
	
