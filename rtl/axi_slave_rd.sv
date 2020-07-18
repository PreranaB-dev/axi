
`include "define.sv"
module axi_slave_rd ( input aclk,
                    input areset_n,
//READ ADDRESS CHANNEL SIGNALS
        output ar_ready,
        input [ADDR_BITS -1     : 0] ar_addr,
        input [LEN_BITS -1      : 0] ar_len,
        input [SIZE_BITS -1     : 0] ar_size,
        input [1:0] ar_burst,
        input [3:0] ar_cache,
        input ar_valid,

//READ DATA CHANNEL SIGNALS
        input r_ready,
        output [DATA_BITS -1    : 0] r_data,
        output r_valid,
        output r_last,
        output [1:0] r_resp
);





endmodule
