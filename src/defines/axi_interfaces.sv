//================================================================
//---------AXI MASTER INTERFACE-----------------------------------
// Description : This is the axi master interface. It supports
//                single transaction. Working on others as well.
// Warning     : No gurantee. Use at your own risk.
//================================================================

// AXI Address interface.
interface axi_address_channel #(
  parameter ADDR_BITS = 32,
  parameter LEN_BITS  = 32,
  parameter SIZE_BITS = 32
  );
   logic                    ready;
   logic [ADDR_BITS-1:0]    addr ;
   logic [LEN_BITS -1:0]    len  ;
   logic [SIZE_BITS-1:0]    size ;
   logic [1:0]              burst;
   logic [3:0]              cache;
   logic                    valid;

   modport addr_slave  (output  ready, input aw_addr, input len, input size, input burst, input cache, input valid);
   modport addr_master (input  ready, output aw_addr, output len, output size, output burst, output cache, output valid);

endinterface

// AXI Address interface.
interface axi_data_channel #(
  parameter DATA_BITS = 32
  );
   logic                   ready;
   logic [DATA_BITS-1:0]   data ;
   logic                   valid;
   logic                   last ;
   logic                   resp ; // response.
   logic [DATA_BITS/8-1:0] strb ; // strobe.

   modport master_read  (output  ready, input data, input valid, input last, input resp);
   modport master_write (input  ready, output data, output valid, output last, output strb);

   modport slave_write  (output  ready, input data, input valid, input last, input strb);
   modport slave_read   (input  ready, output data, output valid, output last, output resp);

endinterface

