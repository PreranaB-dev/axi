//================================================================
//---------AXI MASTER INTERFACE-----------------------------------
// Description : This is the axi master interface. It supports
//                single transaction. Working on others as well.
// Warning     : No gurantee. Use at your own risk.
//================================================================

`include "define.svh"
module axi_master #(
     parameter DATA_BITS = 32,
     parameter ADDR_BITS = 32,
     parameter LEN_BITS  = 1 ,
     parameter SIZE_BITS = 1
)
(
    input aclk,     // input clock.
    input areset_n, // active low reset.

//WRITE ADDRESS CHANNEL SIGNALS
   axi_address_channel.addr_master      axi_m_write_address,

//WRITE DATA CHANNEL SIGNALS
    axi_data_channel.master_write       axi_m_data_write,
//WRITE RESPONSE SIGNALS
    output                       b_valid,
    input                        b_ready,
    input [1:0]                  b_resp ,

//READ ADDRESS CHANNEL SIGNALS
    axi_address_channel.addr_master     axi_m_read_address,

//READ DATA CHANNEL SIGNALS
    axi_data_channel.master_read        axi_m_data_read,
);

endmodule