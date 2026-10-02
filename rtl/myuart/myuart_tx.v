//file name:       myuart_tx.v
//author:           BigTree
//date:             2017.7.29
//function:        数据发送
//log:

module myuart_tx(
		input clk,
		input rst_n,
		output reg bps_start,
		input clk_bps,
		input key_valid,
		input [7:0] data_in,
		input [3:0] version,
		output txd
);

reg tx_en;				//发送使能信号
reg [3:0] num;			//并转串bit计数器
reg [7:0] tx_data_r;		//发送字节数据 buffer
reg uart_tx_r;       		//发送接口 buffer
reg byte_num;			//当前发送的字节

//-----------使能信号生成---------------
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			bps_start <= 1'bz;
			tx_en <= 1'b0;
			tx_data_r <= 8'd0;
			byte_num <= 1'b0;
		end
	else if(key_valid && !tx_en)
		begin
			bps_start <= 1'b1;
			tx_data_r <= data_in;
			tx_en <= 1'b1;
			byte_num <= 1'b0;
		end
	else if(num==4'd10 && byte_num==1'b0)
		begin
			bps_start <= 1'b1;
			tx_data_r <= 8'h30 + version;
			tx_en <= 1'b1;
			byte_num <= 1'b1;
		end
	else if(num==4'd10 && byte_num==1'b1)
		begin
			bps_start <= 1'b0;
			tx_en <= 1'b0;
			tx_data_r <= 8'h0;
			byte_num <= 1'b0;
		end
	else
		begin
			bps_start <= bps_start;
			tx_data_r <= tx_data_r;
			tx_en <= tx_en;
			byte_num <= byte_num;
		end
end

//----------------并转串--------------------
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			num <= 4'd0;
			uart_tx_r <= 1'b1;
		end
	else if(tx_en)
		begin
			if(clk_bps)
			begin
				num <= num + 1'b1;
				case(num)
				4'd0: uart_tx_r <= 1'b0;
				4'd1: uart_tx_r <= tx_data_r[0];
				4'd2: uart_tx_r <= tx_data_r[1];
				4'd3: uart_tx_r <= tx_data_r[2];
				4'd4: uart_tx_r <= tx_data_r[3];
				4'd5: uart_tx_r <= tx_data_r[4];
				4'd6: uart_tx_r <= tx_data_r[5];
				4'd7: uart_tx_r <= tx_data_r[6];
				4'd8: uart_tx_r <= tx_data_r[7];
				4'd9: uart_tx_r <= 1'b1;
				default: uart_tx_r <= 1'b1;
				endcase
			end
			else if(num==4'd10)
				num <= 4'd0;
			else
				num <= num;
		end
	else
		uart_tx_r <= 1'b1;
end

assign txd = uart_tx_r;

endmodule