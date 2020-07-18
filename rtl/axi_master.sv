
`include "define.sv"
module axi_master ( input aclk,
		    input areset_n,

//WRITE ADDRESS CHANNEL SIGNALS
	input aw_ready,
	output logic [ADDR_BITS -1	: 0] aw_addr,
	output logic [LEN_BITS -1	: 0] aw_len,
	output logic [SIZE_BITS -1	: 0] aw_size,
	output logic [1:0] aw_burst,
	output logic [3:0] aw_cache,
	output logic aw_valid,
	
//WRITE DATA CHANNEL SIGNALS		    
	input w_ready,
	output logic [DATA_BITS -1	: 0] w_data,
	output logic w_valid,
	output logic w_last,
	output logic [DATA_BITS/8 -1	: 0] w_strb,

//WRITE RESPONSE SIGNALS	
	input b_valid,
	output logic b_ready,
	input [1:0] b_resp,

//READ ADDRESS CHANNEL SIGNALS
	input ar_ready,
	output logic [ADDR_BITS -1	: 0] ar_addr,
	output logic [LEN_BITS -1	: 0] ar_len,
	output logic [SIZE_BITS -1	: 0] ar_size,
	output logic [1:0] ar_burst,
	output logic [3:0] ar_cache,
	output logic ar_valid,

//READ DATA CHANNEL SIGNALS
	output logic r_ready,
	input [DATA_BITS -1	: 0] r_data,
	input r_valid,
	input r_last,
	input [1:0] r_resp,

//TB DRIVEN INPUTS
        input [ADDR_BITS -1 : 0] AWADDR,
	input [LEN_BITS -1 : 0]  AWLEN,
	input [DATA_BITS -1 : 0] WDATA,
        input [SIZE_BITS -1 : 0] AWSIZE,
        input [1:0] AWBURST,
	input [3:0] AWCACHE,

        input [ADDR_BITS -1 : 0] ARADDR,
	input [LEN_BITS -1 : 0] ARLEN,
        input [SIZE_BITS -1 : 0] ARSIZE,
	input [1:0] ARBURST,
	input [3:0] ARCACHE
       
);



axi_master_wr master_wr_inst ( .aclk		(aclk),
	        .areset_n	(areset_n),

//WRITE ADDRESS CHANNEL SIGNALS
		.aw_ready	(aw_ready),
		.aw_addr	(aw_addr),
		.aw_len		(aw_len),
		.aw_size	(aw_size),
		.aw_burst	(aw_burst),
		.aw_cache	(aw_cache),
		.aw_valid	(aw_valid),

//WRITE DATA CHANNEL SIGNALS
		.w_ready	(w_ready),
		.w_data		(w_data),
		.w_valid	(w_valid),
		.w_last		(w_last),
		.w_strb		(w_strb),

//WRITE RESPONSE SIGNALS
		.b_valid	(b_valid),
		.b_ready	(b_ready),
		.b_resp		(b_resp),

//TB DRIVEN INPUTS
        	.AWADDR		(AWAADR),
		.AWLEN		(AWLEN),
		.WDATA		(WDATA),
        	.AWSIZE		(AWSIZE),
		.AWBURST	(AWBURST),
		.AWCACHE	(AWCACHE)
	)

axi_master_rd master_rd_inst ( .aclk            (aclk),
                .areset_n       (areset_n),

//READ ADDRESS CHANNEL SIGNALS
                .ar_ready       (ar_ready),
                .ar_addr        (ar_addr),
                .ar_len         (ar_len),
                .ar_size        (ar_size),
                .ar_burst       (ar_burst),
                .ar_cache       (ar_cache),
                .ar_valid       (ar_valid),

//READ DATA CHANNEL SIGNALS
                .r_ready        (r_ready),
                .r_data         (r_data),
                .r_valid        (r_valid),
                .r_last         (r_last),

//READ RESPONSE SIGNALS
                .r_resp         (r_resp),

//TB DRIVEN INPUTS
                .ARADDR         (ARAADR),
                .ARLEN          (ARLEN),
                .ARSIZE         (ARSIZE),
                .ARBURST        (ARBURST),
                .ARCACHE        (ARCACHE)
        )


endmodule
