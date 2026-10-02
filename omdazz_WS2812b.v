module omdazz_WS2812b #(
    parameter integer WS2812_NUM   = 10 - 1,
    parameter integer WS2812_WIDTH = 24,
    parameter integer CLK_FRE      = 50_000_000
	 //parameter [WS2812_NUM:0] LED_MASK 
)(
    input  wire CLOCK_50,
	 input  wire [WS2812_NUM :0] LED_MASK,
    output reg  WS2812 
);


parameter F_SCALE      = 50 / 27;     // conversion factor from 27 MHz to 50 MHz

parameter DELAY_1_HIGH = (CLK_FRE / 1_000_000 * 85 / 100 * F_SCALE) - 1;
parameter DELAY_1_LOW  = (CLK_FRE / 1_000_000 * 40 / 100 * F_SCALE) - 1;
parameter DELAY_0_HIGH = (CLK_FRE / 1_000_000 * 40 / 100 * F_SCALE) - 1;
parameter DELAY_0_LOW  = (CLK_FRE / 1_000_000 * 85 / 100 * F_SCALE) - 1;
parameter DELAY_RESET  = (CLK_FRE / 10 * F_SCALE) - 1;

parameter RESET  = 0; // state machine declaration
parameter DATA_SEND  = 1;
parameter BIT_SEND_HIGH   = 2;
parameter BIT_SEND_LOW   = 3;

reg [ 1:0] state       = 0; // synthesis preserve // main state machine control
reg [ 8:0] bit_send    = 0; // amount of bits sent // increase it for larger LED strips/matrix
reg [ 8:0] data_send   = 0; // amount of data words sent // increase it for larger LED strips/matrix
reg [31:0] clk_count   = 0; // delay control
reg [23:0] WS2812_data = 24'd1; // WS2812 color data

wire send_bit;
assign send_bit = WS2812_data[bit_send] & LED_MASK[data_send];
//assign send_bit = (data_send == 0) ? WS2812_data[bit_send] : 1'b0;
//assign send_bit = WS2812_data[bit_send] & 16'd1;
always@(posedge CLOCK_50)
	case (state)
		RESET:begin
			WS2812 <= 0;

			if (clk_count < DELAY_RESET) 
				clk_count <= clk_count + 1;
			else begin
				clk_count <= 0;
				WS2812_data <= {WS2812_data[22:0],WS2812_data[23]};// color shifting for cyclic 
				state <= DATA_SEND;
			end
		end

		DATA_SEND:
			if (data_send == WS2812_NUM && bit_send == WS2812_WIDTH)begin 
				data_send <= 0;
				bit_send  <= 0;
				state <= RESET;
			end 
			else if (bit_send < WS2812_WIDTH) begin
				state    <= BIT_SEND_HIGH;
			end
			else begin// if (bit_send == WS2812_WIDTH)
				data_send <= data_send + 1;
				bit_send  <= 0;
				state    <= BIT_SEND_HIGH;
			end
			
		BIT_SEND_HIGH:begin
			WS2812 <= 1;

			if (send_bit) 
				if (clk_count < DELAY_1_HIGH)
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;
					state    <= BIT_SEND_LOW;
				end
			else 
				if (clk_count < DELAY_0_HIGH)
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;
					state    <= BIT_SEND_LOW;
				end
		end

		BIT_SEND_LOW:begin
			WS2812 <= 0;

			if (send_bit) 
				if (clk_count < DELAY_1_LOW) 
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;

					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
			else 
				if (clk_count < DELAY_0_LOW) 
					clk_count <= clk_count + 1;
				else begin
					clk_count <= 0;
					
					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
		end
	endcase
endmodule
