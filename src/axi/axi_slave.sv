
`include "define.sv"
module axi_slave #(
     parameter DATA_BITS = 32,
     parameter ADDR_BITS = 32,
     parameter LEN_BITS  = 1 ,
     parameter SIZE_BITS = 1
)
(
    input aclk,      // input clock.
    input areset_n,  // active low reset.

//WRITE ADDRESS CHANNEL SIGNALS
    axi_address_channel.addr_slave  axi_s_write_address,

//WRITE DATA CHANNEL SIGNALS
    axi_data_channel.slave_write   axi_s_data_write,

//WRITE RESPONSE SIGNALS
    output       b_valid,
    input        b_ready,
    output [1:0] b_resp,

//READ ADDRESS CHANNEL SIGNALS
    axi_address_channel.addr_slave axi_s_read_address,

//READ DATA CHANNEL SIGNALS
    axi_data_channel.slave_read   axi_s_data_read,
);
