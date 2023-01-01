module divison_tb;

reg clk,rst;
reg [15:0] a,b;

wire w_exception;
wire [15:0] w_res;
wire w_res_vld;
divison DUT(clk,rst,a,b,1'b1,w_exception,w_res,w_res_vld);

initial
begin
		
	 clk=0;
	 rst=0;

	 #2
	 rst=1;
	 
	 #5
	 rst=0;
	 
	 #3
         a=16'h3e80; 
	 b=16'h4489; 
	 
	 #10 
	 a=16'h4108; 
	 b=16'h42dd; 
	 
	 #10
	 
	 a=16'h3fa0; 
	 b=16'h5af0; 
	 
	 #20
	 $finish;
	 
end

always #5 clk=!clk;

endmodule
