/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  testbench.v                                         //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline;       //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

extern void print_header(string str);
extern void print_cycles();
/*
extern void print_stage(string div, int inst, int npc, int valid_inst);*/
extern void print_reg(int wb_reg_wr_data_out_hi, int wb_reg_wr_data_out_lo,
                      int wb_reg_wr_idx_out, int wb_reg_wr_en_out);
											
extern void print_membus(int proc2mem_command, int mem2proc_response,
                         int proc2mem_addr_hi, int proc2mem_addr_lo,
                         int proc2mem_data_hi, int proc2mem_data_lo);
extern void print_close();


module testbench;

  // Registers and wires used in the testbench
  reg        clock;
  reg        reset;
  reg [31:0] clock_count;
  reg [31:0] instr_count;
  integer    wb_fileno;

  wire [1:0]  proc2mem_command;
  wire [63:0] proc2mem_addr;
  wire [63:0] proc2mem_data;
  wire [3:0]  mem2proc_response;
  wire [63:0] mem2proc_data;
  wire [3:0]  mem2proc_tag;

  wire [3:0]  pipeline_completed_insts;
  wire [3:0]  pipeline_error_status;
  wire [4:0]  pipeline_commit_wr_idx;
  wire [63:0] pipeline_commit_wr_data;
  wire        pipeline_commit_wr_en;
  wire [63:0] pipeline_commit_NPC;


  wire [63:0] if_NPC0;
	wire [63:0] if_NPC1;
  wire [31:0] if_IR0;
	wire [31:0] if_IR1;
  wire        if_valid_inst0;
  wire        if_valid_inst1;
  wire [63:0] id_NPC0;
  wire [63:0] id_NPC1;
  wire [31:0] id_IR0;
  wire [31:0] id_IR1;
  wire        id_valid_inst0;
  wire        id_valid_inst1;

	wire [63:0] rs_sim_NPC0;
  wire [63:0] rs_sim_NPC1;
  wire [31:0] rs_sim_IR0;
  wire [31:0] rs_sim_IR1;
  wire        rs_sim_valid_inst0;
  wire        rs_sim_valid_inst1;
	wire [63:0] rs_mul_NPC0;
  wire [63:0] rs_mul_NPC1;
  wire [31:0] rs_mul_IR0;
  wire [31:0] rs_mul_IR1;
  wire        rs_mul_valid_inst0;
  wire        rs_mul_valid_inst1;
	wire [63:0] rs_mem_NPC0;
  wire [63:0] rs_mem_NPC1;
  wire [31:0] rs_mem_IR0;
  wire [31:0] rs_mem_IR1;
  wire        rs_mem_valid_inst0;
  wire        rs_mem_valid_inst1;
	wire	[5:0]	cdb_broadcast;
	wire	[6:0] cdb_pr_tag0;
	wire	[6:0] cdb_pr_tag1;
	wire	[6:0] cdb_pr_tag2;
	wire	[6:0] cdb_pr_tag3;
	wire	[6:0] cdb_pr_tag4;
	wire	[6:0] cdb_pr_tag5;
	wire  [1:0] rob_retire_num;
	wire  [6:0] rob_retire_tag_a;
	wire	[6:0] rob_retire_tag_b;
	
	
  // Strings to hold instruction opcode
  reg  [8*7:0] if_instr0_str;
	reg	 [8*7:0] if_instr1_str;
	reg  [8*7:0] id_instr0_str;
	reg	 [8*7:0] id_instr1_str;

	reg  [8*7:0] rs_sim_instr0_str;
	reg	 [8*7:0] rs_sim_instr1_str;
	reg  [8*7:0] rs_mul_instr0_str;
	reg	 [8*7:0] rs_mul_instr1_str;
	reg  [8*7:0] rs_mem_instr0_str;
	reg	 [8*7:0] rs_mem_instr1_str;
  


  // Instantiate the Pipeline
 pipeline testee (// Inputs
                 clock,
                 reset,
                 mem2proc_response,
                 mem2proc_data,
                 mem2proc_tag,
                 
                 // Outputs
                 proc2mem_command,
                 proc2mem_addr,
                 proc2mem_data,

                 pipeline_completed_insts,
                 pipeline_error_status,
                 pipeline_commit_wr_data,
                 pipeline_commit_wr_idx,
                 pipeline_commit_wr_en,
                 pipeline_commit_NPC,


                 // testing hooks (these must be exported so we can test
                 // the synthesized version) data is tested by looking at
                 // the final values in memory
								 if_NPC0,
								 if_IR0,
								 if_valid_inst0,
								 id_NPC0,
								 id_IR0,
								 id_valid_inst0,
								 rs_sim_NPC0,
								 rs_sim_IR0,
								 rs_sim_valid_inst0,
								 rs_mul_NPC0,
								 rs_mul_IR0,
								 rs_mul_valid_inst0,
								 rs_mem_NPC0,
								 rs_mem_IR0,
								 rs_mem_valid_inst0,

								 if_NPC1,
								 if_IR1,
								 if_valid_inst1,
								 id_NPC1,
								 id_IR1,
								 id_valid_inst1,
								 rs_sim_NPC1,
								 rs_sim_IR1,
								 rs_sim_valid_inst1,
								 rs_mul_NPC1,
								 rs_mul_IR1,
								 rs_mul_valid_inst1,
								 rs_mem_NPC1,
								 rs_mem_IR1,
								 rs_mem_valid_inst1,

								 cdb_broadcast,
								 cdb_pr_tag0,
								 cdb_pr_tag1,
								 cdb_pr_tag2,
								 cdb_pr_tag3,
								 cdb_pr_tag4,
								 cdb_pr_tag5,
								 rob_retire_num,
								 rob_retire_tag_a,
								 rob_retire_tag_b

                );


  // Instantiate the Data Memory
  mem memory (// Inputs
            .clk               (clock),
            .proc2mem_command  (proc2mem_command),
            .proc2mem_addr     (proc2mem_addr),
            .proc2mem_data     (proc2mem_data),

             // Outputs

            .mem2proc_response (mem2proc_response),
            .mem2proc_data     (mem2proc_data),
            .mem2proc_tag      (mem2proc_tag)
           );

  // Generate System Clock
  always
  begin
    #(`VERILOG_CLOCK_PERIOD/2.0);
    clock = ~clock;
  end

  // Task to display # of elapsed clock edges
  task show_clk_count;
        real cpi;

        begin
     cpi = (clock_count + 1.0) / instr_count;
     $display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
        clock_count+1, instr_count, cpi);
           $display("@@  %4.2f ns total time to execute\n@@\n",
                    clock_count*`VIRTUAL_CLOCK_PERIOD);
        end
        
  endtask  // task show_clk_count 

  // Show contents of a range of Unified Memory, in both hex and decimal
  task show_mem_with_decimal;
   input [31:0] start_addr;
   input [31:0] end_addr;
   integer k;
   integer showing_data;
   begin
    $display("@@@");
    showing_data=0;
    for(k=start_addr;k<=end_addr; k=k+1)
      if (memory.unified_memory[k] != 0)
      begin
        $display("@@@ mem[%5d] = %x : %0d", k*8, memory.unified_memory[k], 
                                                 memory.unified_memory[k]);
        showing_data=1;
      end
      else if(showing_data!=0)
      begin
        $display("@@@");
        showing_data=0;
      end
    $display("@@@");
   end
  endtask  // task show_mem_with_decimal

  initial
  begin
    `ifdef DUMP
      $vcdplusdeltacycleon;
      $vcdpluson();
      $vcdplusmemon(memory.unified_memory);
    `endif
      
    clock = 1'b0;
    reset = 1'b0;
		$monitor("Time: %4.0f\n\nreset: %h\n mem2proc_response: %h\n mem2proc_data: %h\n mem2proc_tag: %h\n proc2mem_command: %h\n proc2mem_addr: %h\n proc2mem_data: %h\n pipeline_completed_insts: %h\n pipeline_error_status: %h\n pipeline_commit_wr_data: %h\n pipeline_commit_wr_idx: %h\n pipeline_commit_wr_en: %h\n pipeline_commit_NPC: %h\n if_NPC0: %h\n if_IR0: %h\n if_valid_inst0: %h\n id_NPC0: %h\n id_IR0: %h\n id_valid_inst0: %h\n rs_sim_NPC0: %h\n rs_sim_IR0: %h\n rs_sim_valid_inst0: %h\n rs_mul_NPC0: %h\n rs_mul_IR0: %h\n rs_mul_valid_inst0: %h\n rs_mem_NPC0: %h\n rs_mem_IR0: %h\n rs_mem_valid_inst0: %h\n if_NPC1: %h\n if_IR1: %h\n if_valid_inst1: %h\n id_NPC1: %h\n id_IR1: %h\n id_valid_inst1: %h\n rs_sim_NPC1: %h\n rs_sim_IR1: %h\n rs_sim_valid_inst1: %h\n rs_mul_NPC1: %h\n rs_mul_IR1: %h\n rs_mul_valid_inst1: %h\n rs_mem_NPC1: %h\n rs_mem_IR1: %h\n rs_mem_valid_inst1: %h\n cdb_broadcast: %h\n cdb_pr_tag0: %h\n cdb_pr_tag1: %h\n cdb_pr_tag2: %h\n cdb_pr_tag3: %h\n cdb_pr_tag4: %h\n cdb_pr_tag5: %h\n rob_retire_num: %h\n rob_retire_tag_a: %h\n  rob_retire_tag_b: %h\n",$time,reset,mem2proc_response,mem2proc_data,mem2proc_tag,proc2mem_command,proc2mem_addr,proc2mem_data,pipeline_completed_insts,pipeline_error_status,pipeline_commit_wr_data,pipeline_commit_wr_idx,pipeline_commit_wr_en,pipeline_commit_NPC,if_NPC0,if_IR0,if_valid_inst0,id_NPC0,id_IR0,id_valid_inst0,rs_sim_NPC0,rs_sim_IR0,rs_sim_valid_inst0,rs_mul_NPC0,rs_mul_IR0,rs_mul_valid_inst0,rs_mem_NPC0,rs_mem_IR0,rs_mem_valid_inst0,if_NPC1,if_IR1,if_valid_inst1,id_NPC1,id_IR1,id_valid_inst1,rs_sim_NPC1,rs_sim_IR1,rs_sim_valid_inst1,rs_mul_NPC1,rs_mul_IR1,rs_mul_valid_inst1,rs_mem_NPC1,rs_mem_IR1,rs_mem_valid_inst1,cdb_broadcast,cdb_pr_tag0,cdb_pr_tag1,cdb_pr_tag2,cdb_pr_tag3,cdb_pr_tag4,cdb_pr_tag5,rob_retire_num,rob_retire_tag_a, rob_retire_tag_b);

    // Pulse the reset signal
    $display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);

    $readmemh("program.mem", memory.unified_memory);

    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges

    reset = 1'b0;
    $display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);

   #10000  $finish; 
  end


  // Count the number of posedges and number of instructions completed
  // till simulation ends
  always @(posedge clock or posedge reset)
  begin
    if(reset)
    begin
      clock_count <= `SD 0;
      instr_count <= `SD 0;
    end
    else
    begin
      clock_count <= `SD (clock_count + 1);
      instr_count <= `SD (instr_count + rob_retire_num);
    end
  end  


  always @(negedge clock)
  begin
    if(reset)
      $display("@@\n@@  %t : System STILL at reset, can't show anything\n@@",
               $realtime);
    else
    begin
      `SD;
      `SD;
      
       // print the piepline stuff via c code to the pipeline.out
       print_cycles();
       
       print_reg(pipeline_commit_wr_data[63:32], pipeline_commit_wr_data[31:0],
                 {27'b0,pipeline_commit_wr_idx}, {31'b0,pipeline_commit_wr_en});
       print_membus({30'b0,proc2mem_command}, {28'b0,mem2proc_response},
                    proc2mem_addr[63:32], proc2mem_addr[31:0],
                    proc2mem_data[63:32], proc2mem_data[31:0]);


       // print the writeback information to writeback.out
       if(pipeline_completed_insts>0) begin
         if(pipeline_commit_wr_en)
           $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     pipeline_commit_NPC-4,
                     pipeline_commit_wr_idx,
                     pipeline_commit_wr_data);
        else
          $fdisplay(wb_fileno, "PC=%x, ---",pipeline_commit_NPC-4);
      end

      // deal with any halting conditions
      if(pipeline_error_status!=`NO_ERROR)
      begin
        $display("@@@ Unified Memory contents hex on left, decimal on right: ");
        show_mem_with_decimal(0,`MEM_64BIT_LINES - 1); 
          // 8Bytes per line, 16kB total

        $display("@@  %t : System halted\n@@", $realtime);

        case(pipeline_error_status)
          `HALTED_ON_MEMORY_ERROR:  
              $display("@@@ System halted on memory error");
          `HALTED_ON_HALT:          
              $display("@@@ System halted on HALT instruction");
          `HALTED_ON_ILLEGAL:
              $display("@@@ System halted on illegal instruction");
          default: 
              $display("@@@ System halted on unknown error code %x",
                       pipeline_error_status);
        endcase
        $display("@@@\n@@");
        show_clk_count;
        print_close(); // close the pipe_print output file
        $fclose(wb_fileno);
        #100 $finish;
      end

    end  // if(reset)
  end 

  // Translate IRs into strings for opcodes (for waveform viewer)
  always @* begin
    if_instr0_str  = get_instr_string(if_IR0, if_valid_inst0);
		if_instr1_str  = get_instr_string(if_IR1, if_valid_inst0);
		id_instr0_str  = get_instr_string(id_IR0, id_valid_inst0);
		id_instr1_str  = get_instr_string(id_IR1, id_valid_inst1);
		
		rs_sim_instr0_str  = get_instr_string(rs_sim_IR0, rs_sim_valid_inst0);
		rs_sim_instr1_str  = get_instr_string(rs_sim_IR1, rs_sim_valid_inst0);
		rs_mul_instr0_str  = get_instr_string(rs_mul_IR0, rs_mul_valid_inst0);
		rs_mul_instr1_str  = get_instr_string(rs_mul_IR1, rs_mul_valid_inst0);
		rs_mem_instr0_str  = get_instr_string(rs_mem_IR0, rs_mem_valid_inst0);
		rs_mem_instr1_str  = get_instr_string(rs_mem_IR1, rs_mem_valid_inst0);
   
  end

  function [8*7:0] get_instr_string;
    input [31:0] IR;
    input        instr_valid;
    begin
      if (!instr_valid)
        get_instr_string = "-";
      else if (IR==`NOOP_INST)
        get_instr_string = "nop";
      else
        case (IR[31:26])
          6'h00: get_instr_string = (IR == 32'h555) ? "halt" : "call_pal";
          6'h08: get_instr_string = "lda";
          6'h09: get_instr_string = "ldah";
          6'h0a: get_instr_string = "ldbu";
          6'h0b: get_instr_string = "ldqu";
          6'h0c: get_instr_string = "ldwu";
          6'h0d: get_instr_string = "stw";
          6'h0e: get_instr_string = "stb";
          6'h0f: get_instr_string = "stqu";
          6'h10: // INTA_GRP
            begin
              case (IR[11:5])
                7'h00: get_instr_string = "addl";
                7'h02: get_instr_string = "s4addl";
                7'h09: get_instr_string = "subl";
                7'h0b: get_instr_string = "s4subl";
                7'h0f: get_instr_string = "cmpbge";
                7'h12: get_instr_string = "s8addl";
                7'h1b: get_instr_string = "s8subl";
                7'h1d: get_instr_string = "cmpult";
                7'h20: get_instr_string = "addq";
                7'h22: get_instr_string = "s4addq";
                7'h29: get_instr_string = "subq";
                7'h2b: get_instr_string = "s4subq";
                7'h2d: get_instr_string = "cmpeq";
                7'h32: get_instr_string = "s8addq";
                7'h3b: get_instr_string = "s8subq";
                7'h3d: get_instr_string = "cmpule";
                7'h40: get_instr_string = "addlv";
                7'h49: get_instr_string = "sublv";
                7'h4d: get_instr_string = "cmplt";
                7'h60: get_instr_string = "addqv";
                7'h69: get_instr_string = "subqv";
                7'h6d: get_instr_string = "cmple";
                default: get_instr_string = "invalid";
              endcase
            end
          6'h11: // INTL_GRP
            begin
              case (IR[11:5])
                7'h00: get_instr_string = "and";
                7'h08: get_instr_string = "bic";
                7'h14: get_instr_string = "cmovlbs";
                7'h16: get_instr_string = "cmovlbc";
                7'h20: get_instr_string = "bis";
                7'h24: get_instr_string = "cmoveq";
                7'h26: get_instr_string = "cmovne";
                7'h28: get_instr_string = "ornot";
                7'h40: get_instr_string = "xor";
                7'h44: get_instr_string = "cmovlt";
                7'h46: get_instr_string = "cmovge";
                7'h48: get_instr_string = "eqv";
                7'h61: get_instr_string = "amask";
                7'h64: get_instr_string = "cmovle";
                7'h66: get_instr_string = "cmovgt";
                7'h6c: get_instr_string = "implver";
                default: get_instr_string = "invalid";
              endcase
            end
          6'h12: // INTS_GRP
            begin
              case(IR[11:5])
                7'h02: get_instr_string = "mskbl";
                7'h06: get_instr_string = "extbl";
                7'h0b: get_instr_string = "insbl";
                7'h12: get_instr_string = "mskwl";
                7'h16: get_instr_string = "extwl";
                7'h1b: get_instr_string = "inswl";
                7'h22: get_instr_string = "mskll";
                7'h26: get_instr_string = "extll";
                7'h2b: get_instr_string = "insll";
                7'h30: get_instr_string = "zap";
                7'h31: get_instr_string = "zapnot";
                7'h32: get_instr_string = "mskql";
                7'h34: get_instr_string = "srl";
                7'h36: get_instr_string = "extql";
                7'h39: get_instr_string = "sll";
                7'h3b: get_instr_string = "insql";
                7'h3c: get_instr_string = "sra";
                7'h52: get_instr_string = "mskwh";
                7'h57: get_instr_string = "inswh";
                7'h5a: get_instr_string = "extwh";
                7'h62: get_instr_string = "msklh";
                7'h67: get_instr_string = "inslh";
                7'h6a: get_instr_string = "extlh";
                7'h72: get_instr_string = "mskqh";
                7'h77: get_instr_string = "insqh";
                7'h7a: get_instr_string = "extqh";
                default: get_instr_string = "invalid";
              endcase
            end
          6'h13: // INTM_GRP
            begin
              case (IR[11:5])
                7'h01: get_instr_string = "mull";
                7'h20: get_instr_string = "mulq";
                7'h30: get_instr_string = "umulh";
                7'h40: get_instr_string = "mullv";
                7'h60: get_instr_string = "mulqv";
                default: get_instr_string = "invalid";
              endcase
            end
          6'h14: get_instr_string = "itfp"; // unimplemented
          6'h15: get_instr_string = "fltv"; // unimplemented
          6'h16: get_instr_string = "flti"; // unimplemented
          6'h17: get_instr_string = "fltl"; // unimplemented
          6'h1a: get_instr_string = "jsr";
          6'h1c: get_instr_string = "ftpi";
          6'h20: get_instr_string = "ldf";
          6'h21: get_instr_string = "ldg";
          6'h22: get_instr_string = "lds";
          6'h23: get_instr_string = "ldt";
          6'h24: get_instr_string = "stf";
          6'h25: get_instr_string = "stg";
          6'h26: get_instr_string = "sts";
          6'h27: get_instr_string = "stt";
          6'h28: get_instr_string = "ldl";
          6'h29: get_instr_string = "ldq";
          6'h2a: get_instr_string = "ldll";
          6'h2b: get_instr_string = "ldql";
          6'h2c: get_instr_string = "stl";
          6'h2d: get_instr_string = "stq";
          6'h2e: get_instr_string = "stlc";
          6'h2f: get_instr_string = "stqc";
          6'h30: get_instr_string = "br";
          6'h31: get_instr_string = "fbeq";
          6'h32: get_instr_string = "fblt";
          6'h33: get_instr_string = "fble";
          6'h34: get_instr_string = "bsr";
          6'h35: get_instr_string = "fbne";
          6'h36: get_instr_string = "fbge";
          6'h37: get_instr_string = "fbgt";
          6'h38: get_instr_string = "blbc";
          6'h39: get_instr_string = "beq";
          6'h3a: get_instr_string = "blt";
          6'h3b: get_instr_string = "ble";
          6'h3c: get_instr_string = "blbs";
          6'h3d: get_instr_string = "bne";
          6'h3e: get_instr_string = "bge";
          6'h3f: get_instr_string = "bgt";
          default: get_instr_string = "invalid";
        endcase
    end
  endfunction


endmodule  // module testbench

