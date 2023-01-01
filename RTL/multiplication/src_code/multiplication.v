module multiplication(clk,rst,i_a,i_b,i_vld,int8_ip,exception,overflow,underflow,o_res,o_res_vld);

input clk,rst;
input int8_ip;
input i_vld;
input [15:0] i_a,i_b;

output exception,overflow,underflow;
output reg [15:0] o_res;
output reg o_res_vld;

wire sign,round,normalised,zero;
wire [8:0] exponent,sum_exponent;
wire [6:0] product_mantissa;
wire [7:0] op_a,op_b;
wire [15:0] product,product_normalised,res; 

wire int8,sign_int8;

wire [15:0] a,b;

always @(posedge clk)
begin
	if(rst)
	begin
		o_res <= 16'd0;
		o_res_vld <= 1'b0;
	end
	
	else 
	begin
		o_res <= res;
		o_res_vld <= i_vld;
	end

end

assign a = i_a;
assign b = i_b;

assign int8 = int8_ip;
assign sign = a[15] ^ b[15];
assign sign_int8 = a[7] ^ b[7]; // to handle overflow and underflow in case of int8 operations
  													
assign exception = (&a[14:7]) | (&b[14:7]);								
																							
																																														
assign op_a = (int8 ?(a[7] ? -(a[7:0]) : a[7:0] ) : |(a[14:7]) ? {1'b1,a[6:0]} : {1'b0,a[6:0]});		  
assign op_b = (int8 ?(b[7] ? -(b[7:0]) : b[7:0] ) : |(b[14:7]) ? {1'b1,b[6:0]} : {1'b0,b[6:0]});


assign product = op_a * op_b ;	// can use modified booth recoding multiplier here instead of * operation
											
assign round = |product_normalised[6:0]; 
 							
assign normalised = product[15] ? 1'b1 : 1'b0;
	
assign product_normalised = normalised ? product : product << 1;								

assign product_mantissa = product_normalised[14:8] + (product_normalised[7] & round); 
					
//assign zero = exception ? 1'b0 : (product_mantissa == 7'b0) ? 1'b1 : 1'b0;

assign sum_exponent = a[14:7] + b[14:7];

assign exponent = sum_exponent - 8'd127 + normalised;

assign overflow =(int8 ? ((!sign_int8) & product>16'd127) : (exponent[8] & !exponent[7]) & !zero) ;
									
assign underflow =(int8 ? (sign_int8 & product>16'd128) : (exponent[8] & exponent[7]) & !zero); 							

assign res = (overflow ?(int8 ? {8'b0,8'h7F} : {sign,8'hFF,7'b0} ) : underflow ? (int8 ? {8'b0,8'h80} : {sign,15'b0}) : int8 ?(sign_int8 ? {8'b0,-(product[7:0])} : {8'b0,product[7:0]}): exception ? 16'b0 : {sign,exponent[7:0],product_mantissa});

endmodule
