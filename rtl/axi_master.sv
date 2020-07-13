
`include "define.sv"
module axi_master ( input aclk,
		    input areset_n,

//WRITE ADDRESS CHANNEL SIGNALS
	input aw_ready,
	output [ADDR_BITS -1	: 0] aw_addr,
	output [LEN_BITS -1	: 0] aw_len,
	output [SIZE_BITS -1	: 0] aw_size,
	output [1:0] aw_burst,
	output [3:0] aw_cache,
	output aw_valid,
	
//WRITE DATA CHANNEL SIGNALS		    
	input w_ready,
	output [DATA_BITS -1	: 0] w_data,
	output w_valid,
	output w_last,
	output [DATA_BITS/8 -1	: 0] w_strb,

//WRITE RESPONSE SIGNALS	
	output b_valid,
	input b_ready,
	input [1:0] b_resp,

//READ ADDRESS CHANNEL SIGNALS
	input ar_ready,
	output [ADDR_BITS -1	: 0] ar_addr,
	output [LEN_BITS -1	: 0] ar_len,
	output [SIZE_BITS -1	: 0] ar_size,
	output [1:0] ar_burst,
	output [3:0] ar_cache,
	output ar_valid,

//READ DATA CHANNEL SIGNALS
	output r_ready,
	input [DATA_BITS -1	: 0] r_data,
	input r_valid,
	input r_last,
	input [1:0] r_resp
);
