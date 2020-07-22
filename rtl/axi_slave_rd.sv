
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



logic mem_ar_addr [ADDR_BITS - 1	: 0];
logic mem_ar_len  [LEN_BITS - 1		: 0];
logic mem_ar_size  [SIZE_BITS -1	: 0];
logic mem_ar_burst [1:0];
logic mem_ar_cache [3:0];

logic [LEN_BITS -1	: 0] rd_len;
logic rd_en;
logic rd_ar_ready;
logic latch_rd_ctrl;
logic send_data_flag;
logic last_data_flag;
logic [1:0] state , next_state;

parameter IDLE		= 2'b00,
	  DATA_PHASE_RD	= 2'b01,
	  LAST_PHASE_RD	= 2'b10;

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		state	<= IDLE;
	else
		state	<= next_state;
end



always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
	begin
		mem_ar_addr	<= {`ADDR_BITS {1'b0}};
		mem_ar_len	<= {`LEN_BITS {1'b0}};
		mem_ar_size	<= {`SIZE_BITS {1'b0}};
		mem_ar_burst	<= 2'b0;
		mem_ar_cache	<= 4'b0;
	end
	else if (latch_rd_ctrl) 
	begin
		mem_ar_addr	<= ar_addr;
		mem_ar_len	<= ar_len;
		mem_ar_size	<= ar_size;
		mem_ar_burst	<= ar_burst;
		mem_ar_cache	<= ar_cache;
	end
end

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
	begin
		r_data	<= {`DATA_BITS {1'b0}};
		r_valid	<= 0;
	end
	else if (send_data_flag)
	begin
		r_data	<= mem[mem_ar_addr];
		r_valid <= 1;
	end
end

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		r_last	<= 0;
	else if (last_data_flag)
		r_last	<= 1;
end 


always_comb
begin
	latch_rd_ctrl	= 0;
	last_data_flag	= 0;
	send_data_flag	= 0;
	next_state	= state;
	rd_len		= mem_ar_len;
	rd_ar_ready	= ar_ready;
	rd_en		= 0;
	case (state)
	IDLE:
		if(ar_ready && ar_valid)
		begin
			latch_rd_ctrl	= 1;
			rd_ar_ready	= 0;
			if (ar_len == {`LEN_BITS {1'b0}})
				next_state = LAST_PHASE_RD;
			else 
				next_state = DATA_PHASE_RD;
		end

	DATA_PHASE_RD:
		if (r_ready) 
		begin
			rd_en		= 1;
			send_data_flag 	= 1;
			len		= len -1;
			if (len == {`LEN_BITS{1'b0}})
			       	next_state = LAST_PHASE_RD;
	       		else
				next_state = DATA_PHASE_RD;
		end

	LAST_PHASE_RD:
		if (r_ready)
		begin
			rd_en		= 1;
			send_data_flag	= 1;
			rd_ar_ready	= 1;
			last_data_flag	= 1;
			next_state	= IDLE;
		end
	endcase
end


endmodule




		
