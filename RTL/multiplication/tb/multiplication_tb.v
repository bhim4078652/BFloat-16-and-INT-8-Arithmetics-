module multiplication_tb;

reg clk,rst;
reg [15:0] a,b;
//wire exception,overflow,underflow;
wire [15:0] res;

multiplication DUT(.clk(clk),.rst(rst),.i_a(a),.i_b(b),.int8_ip(1'b0),.o_res(res));

initial
begin
		
	 clk=0;
	 rst=0;
	 
	 #2
	 rst=1;
	 
	 #5
	 rst=0;
	 
	 #3
         a=16'h3fc0; 
	 b=16'hbfc0; 
	 
	 #10 
	 a=16'h40C8; 
	 b=16'h41EE; 
	 
	 #10
	 
	 a=16'h3f48; 
	 b=16'h3fa4; 
	 
	 #10
	 
	 a=16'b00000000_11111011;
	 b=16'b00000000_11111010; 
	 
	 #10
	 
	 a=16'h00E4;
	 b=16'h0006; 
	 
	 #10
	 
	 a=16'h000E;
	 b=16'h000A; 
	 
	 #20
	 $finish;
	 
end

always #5 clk=!clk;

endmodule
