module adder_single_cycle_tb;

reg clk,rst;
reg [15:0] a,b;

wire [15:0] res;
wire overflow;
adder_single_cycle DUT(clk,rst,a,b,res,overflow);

initial 
begin
	 clk=0;
	 rst=0;
	 
	 #2
	 rst=1;
	 
	 #5
	 rst=0;
	 
	 #3
	 a=16'h4130; // 1.5
	 b=16'hc0b0; // -1.5 expected result = 0x0000
	 
	 #10 
	 a=16'h40C8; // 6.25
	 b=16'h41EE; // 29.75 expected result = 0x4210
	 
	 #10
	 
	 a=16'h42C7; // 99
	 b=16'h0000; // 0 expected result = 0x42c6
	 
	 #10
	 
	 a=16'h7f40; 
	 b=16'h7f40; // overflow case where both the inputs are 1.1*2^127 
	 
	 #10
	 a=16'h007c;
	 b=16'h001e;
	 
	 #1
	 a=16'h0084;
	 b=16'h00f6;
	 
	 #10
	 a=16'h0047;
	 b=16'h00ed;
	 
	 #20
	 $finish;
	
end

always #5 clk=!clk;

endmodule