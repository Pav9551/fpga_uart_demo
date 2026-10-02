//file name:       myuart.v
//author:           BigTree
//date:             2017.7.29
//function:        串口发送与接收顶层模块
//log:  

module myuart(
		input clk,
		input rst_n,
		
		input rxd,
		output txd,
		
		input key_valid,
		input test_result,
		input [3:0] version,
		output [15:0] data_out
);

wire bps_start1;
wire bps_start2;
wire clk_bps1;
wire clk_bps2;
wire [7:0] data_in;

//发送字节数据
//assign data_in = 8'h4a;
assign data_in = test_result ? 8'h31 : 8'h30;

speed_select inst_rx(
		clk,
		rst_n,
		bps_start1,
		clk_bps1
);

speed_select inst_tx(
		clk,
		rst_n,
		bps_start2,
		clk_bps2
);

myuart_rx inst_myuart_rx(
		clk,
		rst_n,
		bps_start1,
		clk_bps1,
		rxd,
		data_out
);

myuart_tx inst_myuart_tx(
		.clk(clk),
		.rst_n(rst_n),
		.bps_start(bps_start2),
		.clk_bps(clk_bps2),
		.key_valid(key_valid),
		.version(version),
		.data_in(data_in),
		.txd(txd)
);

endmodule

