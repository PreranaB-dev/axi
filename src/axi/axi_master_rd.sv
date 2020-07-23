//================================================================
//---------AXI MASTER READ INTERFACE-----------------------------------
// Description : This is the axi master read interface. It supports
//               fixed burst mode and single transaction currently. 
//               Working on others as well.
// Warning     : No guarantee. Use at your own risk.
//================================================================

`include "define.sv"
module axi_master_rd ( input aclk,
                       input areset_n,
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
        
        input [ADDR_BITS -1 : 0] ARADDR,
	input [LEN_BITS -1 : 0] ARLEN,
        input [SIZE_BITS -1 : 0] ARSIZE,
	input [1:0] ARBURST,
	input [3:0] ARCACHE
);


logic [DATA_BITS -1 : 0] r_data_int;
logic r_valid_int;
logic r_last_int;
logic [1:0] r_resp_int;


parameter IDLE         = 2'b00,
          READ_ADD     = 2'b01,
          READ_DATA    = 2'b10;

logic [1:0] state;

always @(posedge aclk or negedge areset_n)
        if (~areset_n)
                state   <= IDLE;
        else
        begin
                case (state)
                IDLE :
                begin
			ar_addr		<= {`ADDR_BITS {1'b0}};
      			ar_len		<= {`LEN_BITS {1'b0}};
			ar_size		<= {`SIZE_BITS {1'b0}};
			ar_burst	<= 2'b00;
			ar_cache	<= 4'b0000;
	        	ar_valid	<= 1'b0;
                        
                        r_data_int	<= {`DATA_BITS {1'b0}};
			r_valid_int	<= 1'b0;
			r_last_int	<= 1'b0;
			r_resp_int	<= 2'b00;
			r_ready		<= 1'b1 ;
		        state           <= READ_ADD;
                end

 		READ_ADD :
                begin
                        ar_addr		<= ARADDR;
                        ar_len		<= ARLEN;
                        ar_size		<= ARSIZE;
                        ar_burst	<= ARBURST;
                        ar_cache	<= ARCACHE;

			if (ar_ready)
                        begin
                                ar_valid <= 1'b0;
                                state    <= READ_DATA;
                        end
                        else
                        begin
                                ar_valid  <= 1'b1;
                                state     <= READ_ADD;
                        end
                end

                READ_DATA :
		begin
			if (r_valid == 1)
			begin   
	   			r_data_int	<= r_data;
				r_valid_int	<= r_valid;
				r_last_int 	<= r_last;
				r_resp_int	<= r_resp;
			end
			else
			begin       	
				r_data_int	<= r_data_int;
				r_valid_int	<= r_valid_int;
				r_last_int	<= r_last_int;
				r_resp_int	<= r_resp_int;
			end
               		state		<= IDLE; 
	       	end
		endcase
	end
              


endmodule


