module compare_and_shift(int8,mantissa_10,mantissa_20,ein_a,ein_b,exponent_res,mantissa_11,mantissa_21);
input [9:0] mantissa_10,mantissa_20;
input [7:0] ein_a,ein_b;
input int8;

output reg [7:0] exponent_res;
output reg [9:0] mantissa_11,mantissa_21 ;

always @(*)
begin
		 
	if(ein_a==ein_b | int8==1'b1)
	begin
		 mantissa_11=mantissa_10;
		 mantissa_21=mantissa_20;
		 exponent_res=ein_a+8'd1;
	end
	
	else if(ein_a>ein_b)
	begin
		mantissa_11=mantissa_10;
		mantissa_21=(mantissa_20>>(ein_a-ein_b));
		exponent_res=ein_a+8'd1;
	end
	
	else
	begin
		mantissa_11=(mantissa_10>>(ein_b-ein_a));
		mantissa_21=mantissa_20;
		exponent_res=ein_b+8'd1;
	end
	
end
endmodule
