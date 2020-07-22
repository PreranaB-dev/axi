
`include "define.sv"
module axi_slave_wr ( input aclk,
                    input areset_n,

//WRITE ADDRESS CHANNEL SIGNALS
        output aw_ready,
        input [ADDR_BITS -1     : 0] aw_addr,
        input [LEN_BITS -1      : 0] aw_len,
        input [SIZE_BITS -1     : 0] aw_size,
        input [1:0] aw_burst,
        input [3:0] aw_cache,
        input aw_valid,

//WRITE DATA CHANNEL SIGNALS                
        output w_ready,
        input [DATA_BITS -1     : 0] w_data,
        input w_valid,
        input w_last,
        input [DATA_BITS/8 -1   : 0] w_strb,

//WRITE RESPONSE SIGNALS        
        output b_valid,
        input b_ready,
        output [1:0] b_resp
);

logic w_ready = 1;
logic b_valid = 0;

//-----------------------------------
logic [DATA_BITS -1 : 0] mem [1024];
logic [ADDR_BITS -1: 0] mem_aw_addr;
logic [LEN_BITS -1 : 0] mem_aw_len;
logic [LEN_BITS -1 : 0] len;
logic [SIZE_BITS -1: 0] mem_aw_size;
logic [1:0] mem_aw_burst;
logic [3:0] mem_aw_cache;
logic mem_aw_valid;

logic [DATA_BITS -1 : 0] mem_w_data;
logic mem_w_valid;
logic mem_w_last;
logic [DATA_BITS/8 -1 : 0] mem_w_strb;
logic ready;
logic wr_en;
logic wr_resp;

parameter IDLE		= 2'b00,
	  DATA_PHASE	= 2'b01,
	  LAST_PHASE	= 2'b10,
	  RESP_PHASE	= 2'b11;

logic [1:0] state, next_state;
logic latch_ctrl, latch_data;

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		state <= IDLE;
	else
		state <= next_state;
end


always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n) 
	begin
		mem_aw_addr	<= {`ADDR_BITS {1'b0}};
      		mem_aw_len	<= {`LEN_BITS {1'b0}};
		mem_aw_size 	<= {`SIZE_BITS {1'b0}};
		mem_aw_burst 	<= 2'b0;
		mem_aw_cache 	<= 4'b0;
	       	//mem_aw_valid	 <= 1'b0;
	end
	else
	begin
		if (latch_ctrl) 
		begin
			 mem_aw_addr     <= aw_addr;
			 mem_aw_len      <= aw_len;
			 mem_aw_size     <= aw_size;
			 mem_aw_burst    <= aw_burst;
			 mem_aw_cache    <= aw_cache;
		 end
	end
end

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		mem_w_data <= {`DATA_BITS {1'b0}};
	else if (latch_data)
		mem_w_data <= w_data;	
end

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		mem_wr_valid <= 0;
	else
		mem_wr_valid <= wr_en;	
end


always_ff @(posedge aclk)
begin 
	if (mem_wr_valid)
		mem[mem_aw_addr] <= mem_w_data;
end


always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		aw_ready <= 1;
	else 
		aw_ready <= ready;
end

always @(posedge aclk or negedge areset_n )
begin	
	if (~areset_n)
	begin
		b_valid <= 0 ;
		b_resp	<= 2'b0;
	end
	else if (wr_resp)
		b_valid	<= 1;
	else
		b_valid <= 0;
end

always_comb 
begin 
	latch_ctrl = 0;
	latch_data = 0;
	next_state = state;
	len = mem_aw_len;
	ready = aw_ready;
	wr_en = 0;
	case (state)
	IDLE: 
		if ( aw_ready && aw_valid)
		begin
			latch_ctrl = 1;
			ready	   = 0;
			if (aw_len == {`LEN_BITS {1'B0}})
				next_state = LAST_PHASE;
			else
				next_state = DATA_PHASE;
		end

	DATA_PHASE: 
		if ( w_valid && w_ready )
		begin
			wr_en = 1;
			latch_data = 1;
			len = len -1;
			if (len == {`LEN_BITS {1'b0}})
				next_state = LAST_PHASE;
			else 
				next_state = DATA_PHASE;
		end

	LAST_PHASE:
			if (w_valid && w_ready)
			begin
				wr_en      = 1;
				latch_data = 1;
				ready      =1;
				next_state = RESP_PHASE;
			end
	RESP_PHASE:
			if (w_last)
			begin
				w_en    = 0;
				wr_resp = 1;
			       //	b_valid = 1;
		 	      //	b_resp  = 2'b00;
			end
			else 
			begin
				wr_resp = 0;
				next_state = IDLE;
			end
	endcase


end


endmodule

//memory address increment still pending






