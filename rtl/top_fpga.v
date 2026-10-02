//file name:       top_fpga.v
//author:           ETree
//date:             2017.9.9
//function:        顶层模块
//log:  


module top_fpga(
		//global signal
		input clk,						//System clock, 50MHz
		input rst_n,					//System reset, low active
		
		//Key
		input key0,
		input key1,
		input key2,
		input addkey0,
		
		output [15:0] dat_out,
		
		//uart
		input uart_rx,
		output uart_tx,
		
		//led
		output led,
		output wire WS2812_OUT
);

localparam integer LED_NUM       = 16;
wire [LED_NUM-1:0] led_mask;

assign led_mask = (~addkey0) ? 16'b1111111111111111 : 16'b0;

wire key0_valid;
wire key1_valid;
wire addkey0_valid;

wire [3:0] version;
version version_inst(
    .version(version)
);
//-------按键去抖模块--------
key_jitter key0_jitter_inst
(
	.clk(clk) ,	// input  clk_sig
	.key_n(key0) ,	// input  key_n_sig
	.key_valid(key0_valid) 	// output  key_valid_sig
);

key_jitter addkey0_jitter_inst
(
	.clk(clk) ,	// input  clk_sig
	.key_n(addkey0) ,	// input  key_n_sig
	.key_valid(addkey0_valid) 	// output  key_valid_sig
);

key_jitter key1_jitter_inst
(
	.clk(clk) ,	// input  clk_sig
	.key_n(key1) ,	// input  key_n_sig
	.key_valid(key1_valid) 	// output  key_valid_sig
);



user_puzzle user_puzzle_inst(
        .input_puzzle (~key0 || ~addkey0),
        .output_puzzle (led)
    );
wire puzzle_result;
	 
user_puzzle test_puzzle_inst(
        .input_puzzle (1'b0),
        .output_puzzle (puzzle_result)
    );

wire test_result;

puzzle_checker checker (
    .expected(1'b1),
    .actual(puzzle_result),
    .result(test_result)
);

myuart myuart_inst(
		.clk(clk),
		.rst_n(rst_n),
		.rxd(uart_rx),
		.txd(uart_tx),
		.key_valid(key0_valid || addkey0_valid),//.key_valid(key0_valid || key1_valid),
		.test_result(test_result),//.test_result(test_result || key1_valid)
		.version(version),
		.data_out(dat_out)
);

omdazz_WS2812b #(
        .WS2812_NUM(LED_NUM),
        .CLK_FRE     (50_000_000)
    ) u_ws2812 (
        .CLOCK_50(clk),
        .LED_MASK(led_mask),
        .WS2812  (WS2812_OUT)
    );
	 
endmodule
