module speed_select(
		input clk,		
		input rst_n,
		input bps_start,
		output reg clk_bps
			);	

//波特率选择	   9600bps	
`define		   BPS_PARA		5207	  
`define 	      BPS_PARA_2	2603	

reg [12:0] cnt;					

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) 
		cnt <= 13'd0;
	else 
		if((cnt == `BPS_PARA) || !bps_start) 
			cnt <= 13'd0;	
		else 
			cnt <= cnt + 1'b1;	
end		

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) 
		clk_bps <= 1'b0;
	else 
		if(cnt == `BPS_PARA_2) 
			clk_bps <= 1'b1;	
		else 
			clk_bps <= 1'b0;
end

endmodule
