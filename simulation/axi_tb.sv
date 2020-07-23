//================================================================
//---------AXI Test Bench-----------------------------------
// Description : This is the testbench module. It provides vectors for 
// 		single transactions currently. It can be modified for
// 		other supported modes as well. 
//                
// Warning     : No guarantee. Use at your own risk.
//================================================================

`include "define.sv"
module axi_tb;

logic clock, reset_n;
logic [ADDR_BITS -1 :	0] AWADDR,
logic [LEN_BITS -1  :	0]  AWLEN,
logic [DATA_BITS -1 :	0] WDATA,
logic [SIZE_BITS -1 :	0] AWSIZE,
logic [1:0] AWBURST,
logic [3:0] AWCACHE,

logic [ADDR_BITS -1 :	0] ARADDR,
logic [LEN_BITS -1  :	0] ARLEN,
logic [SIZE_BITS -1 :	0] ARSIZE,
logic [1:0] ARBURST,
logic [3:0] ARCACHE

wire [ADDR_BITS -1 :	0] aw_addr, ar_addr;
wire [LEN_BITS -1  :	0] aw_len, ar_len;
wire [SIZE_BITS -1 :	0] aw_size, ar_size;
wire [DATA_BITS -1 :	0] w_data, r_data;
wire [1:0] aw_burst, ar_burst;
wire [3:0] aw_cache, ar_cache;
wire aw_valid, ar_valid, aw_ready,ar_ready;
wire r_ready, r_valid,r_last, w_ready, w_valid, w_last;
wire [DATA_BITS/8 -1 :	0] w_strb;
wire b_valid, b_ready;
wire [1:0] b_resp;


always 
#5 clock = ~clock;

task reset();
	#2 reset_n = 0;
	#12 reset_n= 1;
endtask


initial
begin
	reset();	
	AWADDR	= 32'h4;
	AWLEN	= 4'b0000;	//Single transfer
	AWSIZE	= 3'b000;	// 1 Byte transfer
	AWBURST	= 2'b00;	//Fixed Address burst   
	AWCACHE = 4'b0000;	//Non-cacheable and Non-bufferable 
	WDATA	= 8'h23;

	#150 

	ARADDR	= 32'h4;
	ARLEN	= 4'b0000;	//Single transfer
	ARSIZE	= 3'b000;	//1 Byte transfer
	ARBURST	= 2'b00;	//Fixed Address burst
	ARCACHE = 4'b0000;	//Non-cacheable and Non-bufferable
end



axi_master axi_m ( .aclk(clock),
		    .areset_n(reset_n),

//WRITE ADDRESS CHANNEL SIGNALS
	.aw_ready(aw_ready),
	.aw_addr(aw_addr),
	.aw_len(aw_len),
	.aw_size(aw_size),
	.aw_burst(aw_burst),
	.aw_cache(aw_cache),
	.aw_valid(aw_valid),

//WRITE DATA CHANNEL SIGNALS
	.w_ready(w_ready),
	.w_data(w_data),
	.w_valid(w_valid),
	.w_last(w_last),
	.w_strb(w_strb),

//WRITE RESPONSE SIGNALS
	.b_valid(b_valid),
	.b_ready(b_ready),
	.b_resp(b_resp),

//READ ADDRESS CHANNEL SIGNALS
	.ar_ready(ar_ready),
	.ar_addr(ar_addr),
	.ar_len(ar_len),
	.ar_size(ar_size),
	.ar_burst(ar_burst),
	.ar_cache(ar_cache),
	.ar_valid(ar_valid),

//READ DATA CHANNEL SIGNALS
	.r_ready(r_ready),
	.r_data(r_data),
	.r_valid(r_valid),
	.r_last(r_last),
	.r_resp(r_resp),

//TB DRIVEN INPUTS
        .AWADDR(AWADDR),
	.AWLEN(AWLEN),
	.WDATA(WDATA),
        .AWSIZE(AWSIZE),
        .AWBURST(AWBURST),
	.AWCACHE(AW_CACHE),

        .ARADDR(ARADDR),
	.ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
	.ARBURST(ARBURST),
	.ARCACHE(ARCACHE)
) ;

axi_slave axi_s ( .aclk(clock),
		   .areset_n(reset_n),

//WRITE ADDRESS CHANNEL SIGNALS
	.aw_ready(aw_ready),
	.aw_addr(aw_addr),
	.aw_len(aw_len),
	.aw_size(aw_size),
	.aw_burst(aw_burst),
	.aw_cache(aw_cache),
	.aw_valid(aw_valid),
	
//WRITE DATA CHANNEL SIGNALS		    
	.w_ready(w_ready),
	.w_data(w_data),
	.w_valid(w_valid),
	.w_last(w_last),
	.w_strb(w_strb),

//WRITE RESPONSE SIGNALS	
	.b_valid(b_valid),
	.b_ready(b_ready),
	.b_resp(b_resp),

//READ ADDRESS CHANNEL SIGNALS
	.ar_ready(ar_ready),
	.ar_addr(ar_addr),
	.ar_len(ar_len),
	.ar_size(ar_size),
	.ar_burst(ar_burst),
	.ar_cache(ar_cache),
	.ar_valid(ar_valid),

//READ DATA CHANNEL SIGNALS
	.r_ready(r_ready),
	.r_data(r_data),
	.r_valid(r_valid),
	.r_last(r_last),
	.r_resp(r_resp)
);

endmodule

