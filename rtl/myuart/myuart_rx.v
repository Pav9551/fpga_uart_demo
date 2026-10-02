//file name:       myuart_rx.v
//author:           BigTree
//date:             2017.7.29
//function:        数据接收
//log:  

module myuart_rx (
		input clk,
		input rst_n,
		output reg bps_start,
		input clk_bps,
		input rxd,
		output reg [15:0] rx_data
);

//串口接收buffer
reg rxd0;
reg rxd1;
reg rxd2;
reg rxd3;	

always @ (posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
	begin
			rxd0 <= 1'b1;
			rxd1 <= 1'b1;
			rxd2 <= 1'b1;
			rxd3 <= 1'b1;
	end
	else 
		begin
			rxd0 <= rxd;
			rxd1 <= rxd0;
			rxd2 <= rxd1;
			rxd3 <= rxd2;
		end
end
	
wire rxd_pos;	//串口接收数据的上升沿
wire rxd_neg;  //串口接收数据的下降沿

assign rxd_pos = ~rxd3 & ~rxd2 & rxd1 & rxd0;	
assign rxd_neg = rxd3 & ~rxd2 & ~rxd1 & ~rxd0;

//-------------接收使能信号-------------------
reg rx_en;	  //串口接收使能信号

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
   	begin
			bps_start <= 1'bz;
			rx_en <= 1'b0;
		end
	else 
		if(rxd_neg) 
			begin		
				bps_start <= 1'b1;	
				rx_en <= 1'b1;
			end
		else 
			if(num==4'd9)
				begin		
					bps_start <= 1'b0;	
					rx_en <= 1'b0;
				end
			else
				begin
					bps_start <= bps_start;
					rx_en <= rx_en;
				end
end


//-------------------串转并---------------------------
reg [3:0] num;				//串口接收Bit计数器
reg [7:0] rx_data_r;		//串转并数据buffer

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) 
	begin
		num <= 0;
		rx_data_r <= 0;
	end
	else
		if(rx_en) 
		begin	
			if(clk_bps) 
			begin	
				num <= num + 1'b1;
				case(num)
				4'd1: rx_data_r[0] <= rxd;	
				4'd2: rx_data_r[1] <= rxd;	
				4'd3: rx_data_r[2] <= rxd;	
				4'd4: rx_data_r[3] <= rxd;	
				4'd5: rx_data_r[4] <= rxd;	
				4'd6: rx_data_r[5] <= rxd;	
				4'd7: rx_data_r[6] <= rxd;	
				4'd8: rx_data_r[7] <= rxd;	
//				4'd9: rx_data_r[8] <= rxd;
				default: rx_data_r <= rx_data_r;
				endcase
			end
			else 
				if(num == 4'd9) 
				begin		
					num <= 4'd0;			
					rx_data_r <= rx_data_r;	
				end
				else
					begin
						num <= num;
						rx_data_r <= rx_data_r;
					end
		end
		else
			begin
				num <= num;
				rx_data_r <= rx_data_r;
			end
end

//------------高低字节拼接-----------------
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rx_data <= 0;
	else if(num == 4'd9) 
		rx_data <= {rx_data[7:0],rx_data_r};
	else
		rx_data <= rx_data;
end


endmodule

