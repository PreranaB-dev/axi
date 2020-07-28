//================================================================
//---------AXI MASTER WRITE INTERFACE-----------------------------------
// Description : This is the axi master write interface. It supports
//               single transaction for fixed burst mode. 
//               Working on others as well.
// Warning     : No guarantee. Use at your own risk.
//================================================================

`include "../src/defines/define.sv"
module axi_master_wr ( input aclk,
		       input areset_n,

//WRITE ADDRESS CHANNEL SIGNALS
	input aw_ready,
	output logic [`ADDR_BITS -1	: 0] aw_addr,
	output logic [`LEN_BITS -1	: 0] aw_len,
	output logic [`SIZE_BITS -1	: 0] aw_size,
	output logic [1:0] aw_burst,
	output logic [3:0] aw_cache,
	output logic aw_valid,
	
//WRITE DATA CHANNEL SIGNALS		    
	input w_ready,
	output logic [`DATA_BITS -1	: 0] w_data,
	output logic w_valid,
	output logic w_last,
	output logic [`DATA_BITS/8 -1	: 0] w_strb,

//WRITE RESPONSE SIGNALS	
	input b_valid,
	output logic b_ready,
	input [1:0] b_resp,

//TB DRIVEN INPUTS
        input [`ADDR_BITS -1 : 0] AWADDR,
	input [`LEN_BITS -1 : 0]  AWLEN,
	input [`DATA_BITS -1 : 0] WDATA,
        input [`SIZE_BITS -1 : 0] AWSIZE,
	input [1:0] AWBURST,
	input [3:0] AWCACHE,
	input AWVALID	
);


logic [`LEN_BITS-1 : 0] w_data_sent;

parameter IDLE		= 2'b00,
	  WRITE_ADD	= 2'b01,
	  WRITE_DATA	= 2'b10,
	  WRITE_RESP	= 2'b11;

logic [1:0] state;



always @(posedge aclk or negedge areset_n)
	if (~areset_n)
	begin
	       	aw_addr	<= {`ADDR_BITS {1'b0}};
      		aw_len	<= {`LEN_BITS {1'b0}};
		aw_size	<= {`SIZE_BITS {1'b0}};
		aw_burst<= 2'b00;
		aw_cache<= 4'b0000;
		aw_valid<= 1'b0;
			
		w_data	<= {`ADDR_BITS {1'b0}};
		w_last	<= 1'b0;
		w_valid	<= 1'b0;
		w_strb	<= {`DATA_BITS/8 {1'b0}};
		b_ready <= 1'b0;
		w_data_sent	<= {`LEN_BITS {1'b0}};
		state		<= IDLE; 	
		end
	else 
	begin
		case (state)
		IDLE :
	       	begin 	
			aw_addr	<= {`ADDR_BITS {1'b0}};
      			aw_len	<= {`LEN_BITS {1'b0}};
			aw_size	<= {`SIZE_BITS {1'b0}};
			aw_burst<= 2'b00;
			aw_cache<= 4'b0000;
	        	aw_valid<= 1'b0;
			
			w_data	<= {`ADDR_BITS {1'b0}};
	      		w_last	<= 1'b0;
			w_valid	<= 1'b0;
			w_strb	<= {`DATA_BITS/8 {1'b0}};
			b_ready <= 1'b0;
			w_data_sent	<= {`LEN_BITS {1'b0}};
			if (AWVALID) 	
				state	<= WRITE_ADD;
			else 
				state	<=IDLE;

		end

		WRITE_ADD : 
		begin
			aw_addr		<= AWADDR;
      			aw_len		<= AWLEN;
			aw_size		<= AWSIZE;
			aw_burst	<= AWBURST;
			aw_cache	<= AWCACHE;
			aw_valid	<= 1;
			if (aw_ready)
				state	 <= WRITE_DATA;
			else
				state	  <= WRITE_ADD;
		end
		
		WRITE_DATA :

			if (w_data_sent <= aw_len-1) 
			begin
				w_data		<= WDATA;
				w_valid		<= 1'b1;
				b_ready		<= 1'b1;
				if (w_ready)
					w_data_sent	<= w_data_sent + 1;
				else
					w_data_sent	<= w_data_sent;
				if (w_data_sent == aw_len -1)
					w_last		<= 1;
				else
					w_last		<= 0;
				state	<= WRITE_DATA;
			end
			else if (w_data_sent == aw_len)
			begin
				w_data		<= WDATA ;
       				w_valid		<= 1'b1;
				w_last		<= 1'b0;
				b_ready		<= 1'b1;
				if (w_ready)
				begin
					w_data_sent	<= {`LEN_BITS {1'b0}};
					state	<= WRITE_RESP;
				end
				else
				begin
					w_data_sent	<= w_data_sent;
					state	<= WRITE_DATA;
				end
				
			end	


		WRITE_RESP : 
		begin
			if (b_valid)
		//	if ((b_resp == 2'b00) && (b_valid))
			begin
				b_ready		<= 1'b0;
				state	<= IDLE ;
			end
			else
				state	<= WRITE_RESP;
		end
		endcase
	end
			

endmodule
	
