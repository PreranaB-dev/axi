
`include "define.sv"
module axi_slave ( input aclk,
		    input areset_n,

//WRITE ADDRESS CHANNEL SIGNALS
	output aw_ready,
	input [ADDR_BITS -1	: 0] aw_addr,
	input [LEN_BITS -1	: 0] aw_len,
	input [SIZE_BITS -1	: 0] aw_size,
	input [1:0] aw_burst,
	input [3:0] aw_cache,
	input aw_valid,
	
//WRITE DATA CHANNEL SIGNALS		    
	output w_ready,
	input [DATA_BITS -1	: 0] w_data,
	input w_valid,
	input w_last,
	input [DATA_BITS/8 -1	: 0] w_strb,

//WRITE RESPONSE SIGNALS	
	output b_valid,
	input b_ready,
	output [1:0] b_resp,

//READ ADDRESS CHANNEL SIGNALS
	output ar_ready,
	input [ADDR_BITS -1	: 0] ar_addr,
	input [LEN_BITS -1	: 0] ar_len,
	input [SIZE_BITS -1	: 0] ar_size,
	input [1:0] ar_burst,
	input [3:0] ar_cache,
	input ar_valid,

//READ DATA CHANNEL SIGNALS
	input r_ready,
	output [DATA_BITS -1	: 0] r_data,
	output r_valid,
	output r_last,
	output [1:0] r_resp
);
