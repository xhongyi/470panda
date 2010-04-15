module dcache_test;
`define VERILOG_CLOCK_PERIOD 10

reg         	clock;
reg         	reset;
reg   [3:0] 	Dmem2proc_response;//number called
reg  [63:0] 	Dmem2proc_data;
reg   [3:0] 	Dmem2proc_tag;//get number
reg 					rob_halt;
reg  [63:0] 	proc2Dcache_addr;//addr on ld/st
reg  [63:0]   proc2Dcache_st_addr;
reg  [63:0]   proc2Dcache_st_data;
wire  [63:0] 	cachemem_data;//data from cache
wire         	cachemem_valid;//if the data is valid
reg						rob_wr_mem;//lsq signal of store
reg						lsq_rd_mem;//lsq signal of read
reg		 [6:0]	lsq_pr;
reg		 [4:0]	lsq_ar;
wire					dcache_wr_dirty;//read the dirty bit of the 
wire [63:0] 		proc2Dmem_data;
wire  [1:0] 	proc2Dmem_command;//store? load? none?
wire [63:0] 	proc2Dmem_addr;//addr to dmem
wire					lsq_load_avail;
wire [63:0] 	Dcache_data_out;     // value is memory[proc2Dcache_addr]
wire        	Dcache_valid_out;    // when this is high
wire 					cdb_load_en;
wire  [6:0]   cdb_pr;
wire  [4:0]   cdb_ar;
wire [63:0]   dcache_wr_data;
wire  [6:0] 	dcache_rd_idx;
wire [21:0] 	dcache_rd_tag;
wire  [6:0] 	dcache_wr_idx0;
wire [21:0] 	dcache_wr_tag0;
wire  [6:0] 	dcache_wr_idx1;
wire [21:0] 	dcache_wr_tag1;
wire        	dcache_wr_en0;
wire					dcache_wr_en1;

reg 			  correct;

dcache dcache0(// inputs
              clock,
              reset,
              
              Dmem2proc_response,
              Dmem2proc_data,
              Dmem2proc_tag,
							rob_halt,
              proc2Dcache_addr,
              proc2Dcache_st_data,
              proc2Dcache_st_addr,
              cachemem_data,
              cachemem_valid,
							dcache_wr_dirty,
							rob_wr_mem,
							lsq_rd_mem,
							lsq_pr,
							lsq_ar,
              // outputs
              proc2Dmem_command,
              proc2Dmem_addr,
              proc2Dmem_data,
							lsq_load_avail,
              Dcache_data_out,
              Dcache_valid_out,   
							cdb_load_en,
							cdb_pr,
							cdb_ar,
							dcache_wr_data,
              dcache_rd_idx,
              dcache_rd_tag,
              dcache_wr_idx1,
              dcache_wr_tag1,
							dcache_wr_idx0,
							dcache_wr_tag0,
              dcache_wr_en1,
							dcache_wr_en0
             );



cachemem128x64 cache0(// inputs
                       .clock(clock),
                       .reset(reset), 
                       .wr1_en(dcache_wr_en1),
                       .wr1_tag(dcache_wr_tag1),
                       .wr1_idx(dcache_wr_idx1),
                       .wr1_data(dcache_wr_data),
											 .wr0_en(dcache_wr_en0),
											 .wr0_tag(dcache_wr_tag0),
                       .wr0_idx(dcache_wr_idx0),
                       .wr0_data(Dmem2proc_data),
                       .rd1_tag(dcache_rd_tag),
                       .rd1_idx(dcache_rd_idx),

                       // outputs
                       .rd1_data(cachemem_data),
                       .rd1_valid(cachemem_valid),
                       .wr1_dirty(dcache_wr_dirty)
                      
                      );

	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clock = ~clock;
	end

	// Compare the results with the correct ones
	always @(posedge clock)
	begin
		$monitor();


		#(`VERILOG_CLOCK_PERIOD/4.0);

		

		correct = 1;
end


	initial
	begin
		clock = 0;

		// Initializing

		// The reg values
		reset = 1;

		clock = 0;
		Dmem2proc_data			= 0;
    Dmem2proc_response	= 0;
		Dmem2proc_tag				= 0;
    proc2Dcache_addr		= 0;
    proc2Dcache_st_addr = 0;
    proc2Dcache_st_data	= 0;
		rob_halt						= 0;
		rob_wr_mem					= 0;
		lsq_rd_mem					= 0;
		@(negedge clock)//#10
		reset = 0;
		@(negedge clock)//#20
	  //Testcase 1: Save
		proc2Dcache_st_addr		= 'h12340;
    proc2Dcache_st_data		= 'h5678;
		rob_wr_mem					= 1;
		lsq_rd_mem					= 0;
		lsq_pr							= 0;
		lsq_ar              = 0;
		Dmem2proc_response  = 2;
		@(negedge clock)//#30
		rob_wr_mem					= 0;
	 // Dmem2proc_response  = 2;
	 Dmem2proc_response	= 0;
		@(negedge clock)
		
		
		@(negedge clock)//#40
		//Dmem2proc_data 			= 'h760;
		Dmem2proc_tag 			= 'h2;
		//Testcase 2: Load
		
    proc2Dcache_addr		= 'h12371;
    proc2Dcache_st_data	= 'h5679;
   
		rob_wr_mem					= 0;
		lsq_rd_mem					= 1;
		Dmem2proc_response  = 1;
		@ (negedge clock)//#50
		lsq_rd_mem 					= 0;
			Dmem2proc_response	= 0;
		//Dmem2proc_response  = 1;
		@(negedge clock)//#60
	
		
		@(negedge clock)//#70
		Dmem2proc_data 			= 'h890;
		Dmem2proc_tag 			= 'h1;
		//Testcase 2: Continuous Save
		Dmem2proc_tag				= 1;
		Dmem2proc_data			= 0;
    proc2Dcache_addr		= 'h12340;
    proc2Dcache_st_data	= 'h5680;
 
		rob_wr_mem					= 0;
		lsq_rd_mem					= 1;
		@(negedge clock)//#80
		Dmem2proc_tag				= 0;
		@(negedge clock)
		$finish;
	end

endmodule		
						 
