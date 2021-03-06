//================================================================
//--------------------AXI SLAVE-----------------------------------
// Description : This is the axi slave module. It is designed for 
// 		supporting read and write transactions currently for
// 		fixed burst mode.It will be modified further for 
// 		supporting other modes and strobe pin functionality 
// 		will also be added. 
//         
// Warning     : No guarantee. Use at your own risk.
//================================================================


`include "/home/prerana/axi/src/defines/define.sv"
module axi_slave ( input aclk,
		    input areset_n,

//WRITE ADDRESS CHANNEL SIGNALS
	output logic aw_ready,
	input [`ADDR_BITS -1	: 0] aw_addr,
	input [`LEN_BITS -1	: 0] aw_len,
	input [`SIZE_BITS -1	: 0] aw_size,
	input [1:0] aw_burst,
	input [3:0] aw_cache,
	input aw_valid,
	
//WRITE DATA CHANNEL SIGNALS		    
	output  w_ready,
	input [`DATA_BITS -1	: 0] w_data,
	input w_valid,
	input w_last,
	input [`DATA_BITS/8 -1	: 0] w_strb,

//WRITE RESPONSE SIGNALS	
	output logic b_valid,
	input b_ready,
	output logic [1:0] b_resp,

//READ ADDRESS CHANNEL SIGNALS
	output logic ar_ready,
	input [`ADDR_BITS -1	: 0] ar_addr,
	input [`LEN_BITS -1	: 0] ar_len,
	input [`SIZE_BITS -1	: 0] ar_size,
	input [1:0] ar_burst,
	input [3:0] ar_cache,
	input ar_valid,

//READ DATA CHANNEL SIGNALS
	input r_ready,
	output logic [`DATA_BITS -1	: 0] r_data,
	output logic r_valid,
	output logic r_last,
	output logic [1:0] r_resp
);

//--------------------------------------------------------------------------
//----------------------WRITE_TRANSACTION_SIGNALS---------------------------
//--------------------------------------------------------------------------

assign w_ready = 1;
//logic b_valid = 0;


logic [`DATA_BITS -1 : 0] mem [1024];
logic [`ADDR_BITS -1: 0] mem_aw_addr;
logic [`LEN_BITS -1 : 0] mem_aw_len;
logic [`LEN_BITS -1 : 0] wr_len;
logic [`SIZE_BITS -1: 0] mem_aw_size;
logic [1:0] mem_aw_burst;
logic [3:0] mem_aw_cache;
logic mem_aw_valid;

logic [`DATA_BITS -1 : 0] mem_w_data;
logic mem_w_valid;
logic mem_w_last;
logic [`DATA_BITS/8 -1 : 0] mem_w_strb;
logic ready;
logic wr_en;
logic wr_resp;

parameter WRITE_IDLE	= 2'b00,
	  WR_DATA_PHASE	= 2'b01,
	  WR_LAST_PHASE	= 2'b10,
	  WR_RESP_PHASE	= 2'b11;

logic [1:0] wr_state, wr_next_state;
logic latch_wr_ctrl, latch_wr_data;

//--------------------------------------------------------------------------
//----------------READ_TRANSACTION_SIGNALS----------------------------------
//--------------------------------------------------------------------------

logic [`ADDR_BITS - 1	: 0] mem_ar_addr; 
logic [`LEN_BITS - 1	: 0] mem_ar_len; 
logic [`SIZE_BITS -1	: 0] mem_ar_size; 
logic [1:0] mem_ar_burst;
logic [3:0] mem_ar_cache;

logic [`LEN_BITS -1	: 0] rd_len;
logic rd_en;
logic rd_ar_ready;
logic latch_rd_ctrl;
logic send_data_flag;
logic last_data_flag;
logic [1:0] rd_state , rd_next_state;

parameter READ_IDLE	= 2'b00,
	  RD_DATA_PHASE	= 2'b01,
	  RD_LAST_PHASE	= 2'b10;

//--------------------------------------------------------------------------
//--------------------WRITE_CYCLE-------------------------------------------
//--------------------------------------------------------------------------


always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		wr_state <= WRITE_IDLE;
	else
		wr_state <= wr_next_state;
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
	else if (latch_wr_ctrl) 
	begin
		mem_aw_addr     <= aw_addr;
	       	mem_aw_len      <= aw_len;
	       	mem_aw_size     <= aw_size;
		mem_aw_burst    <= aw_burst;
		mem_aw_cache    <= aw_cache;
	end
	else
	begin
		if( latch_wr_data )
			mem_aw_len	<= wr_len;
			mem_aw_addr	<= mem_aw_addr + 1;
	end
end


always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		mem_w_data <= {`DATA_BITS {1'b0}};
	else if (latch_wr_data)
		mem_w_data <= w_data;	
end

always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		mem_w_valid <= 0;
	else
		mem_w_valid <= wr_en;	
end


always_ff @(posedge aclk)
begin 
	if (mem_w_valid)
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
	latch_wr_ctrl = 0;
	latch_wr_data = 0;
	wr_next_state = wr_state;
	wr_len = mem_aw_len;
	ready = aw_ready;
	wr_en = 0;
	case (wr_state)
	WRITE_IDLE: 
		if ( aw_ready && aw_valid)
		begin
			latch_wr_ctrl = 1;
			latch_wr_data = 0;
			ready	   = 0;
			if (aw_len == {`LEN_BITS {1'B0}})
				wr_next_state = WR_LAST_PHASE;
			else
				wr_next_state = WR_DATA_PHASE;
		end

	WR_DATA_PHASE: 
		if ( w_valid && w_ready )
		begin
			wr_en = 1;
			latch_wr_ctrl	= 0;
			latch_wr_data	= 1;
			wr_len = wr_len -1;
			if (wr_len == {`LEN_BITS {1'b0}})
				wr_next_state = WR_LAST_PHASE;
			else 
				wr_next_state = WR_DATA_PHASE;
		end

	WR_LAST_PHASE:
			if (w_valid && w_ready)
			begin
				wr_en      = 1;
				latch_wr_data = 1;
				ready      =1;
				wr_next_state = WR_RESP_PHASE;
			end
	WR_RESP_PHASE:
			if (w_last)
			begin
				wr_en    = 0;
				wr_resp = 1;
			       //	b_valid = 1;
		 	      //	b_resp  = 2'b00;
			end
			else 
			begin
				wr_resp = 0;
				wr_next_state = WRITE_IDLE;
			end
	endcase


end

//--------------------------------------------------------------------------
//------------------------READ_CYCLE----------------------------------------
//--------------------------------------------------------------------------


always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		rd_state	<= READ_IDLE;
	else
		rd_state	<= rd_next_state;
end


always @(posedge aclk or negedge areset_n)
begin
	if (~areset_n)
		ar_ready <= 1;
	else 
		ar_ready <= rd_ar_ready;
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
	else
	begin
		if (send_data_flag)
		begin
			mem_ar_len <= rd_len;
			mem_ar_addr<= mem_ar_addr + 1;
		end
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
	rd_next_state	= rd_state;
	rd_len		= mem_ar_len;
	rd_ar_ready	= ar_ready;   
	rd_en		= 0;
	case (rd_state)
	READ_IDLE:
		if(ar_ready && ar_valid)
		begin
			latch_rd_ctrl	= 1;
			rd_ar_ready	= 0;
			send_data_flag	= 0;
			if (ar_len == {`LEN_BITS {1'b0}})
				rd_next_state = RD_LAST_PHASE;
			else 
				rd_next_state = RD_DATA_PHASE;
		end

	RD_DATA_PHASE:
		if (r_ready) 
		begin
			rd_en		= 1;
			latch_rd_ctrl	= 0;				//When in data phase no new control will be latched
			send_data_flag	= 1;
			rd_len		= rd_len -1;
			if (rd_len == {`LEN_BITS{1'b0}})
			       	rd_next_state = RD_LAST_PHASE;
	       		else
				rd_next_state = RD_DATA_PHASE;
		end

	RD_LAST_PHASE:
		if (r_ready)
		begin
			rd_en		= 1;
			send_data_flag	= 1;
			rd_ar_ready	= 1;
			last_data_flag	= 1;
			rd_next_state	= READ_IDLE;
		end
	endcase
end


endmodule





