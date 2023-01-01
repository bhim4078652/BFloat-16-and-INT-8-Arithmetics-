module adder_single_cycle(clk,rst,i_a,i_b,i_vld,int8_ip,o_res,o_res_vld,overflow); // capable of both addition and substraction of Bloat 16 inputs

input clk,rst;
input [15:0] i_a,i_b;
input		 i_vld;
input		 int8_ip;

output reg [15:0] o_res;
output reg		  o_res_vld;
output overflow;

wire [9:0] mantissa_10,mantissa_20;
wire [9:0] mantissa_11,mantissa_21;
wire [10:0] mantissa_sum;
wire [7:0] mantissa_final;
wire [7:0]  exponent_final;
wire sign_res;
wire int8;
wire exception_a,exception_b,zero_a,zero_b;

wire [15:0] a,b;
wire [15:0] res;

assign a = i_a;
assign b = i_b;

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

assign exception_a=(&a[14:7]);
assign exception_b=(&b[14:7]);
assign zero_a=!(|a[14:0]);
assign zero_b=!(|b[14:0]);
assign int8=int8_ip;


assign mantissa_10 = (int8 ? {a[7],a[7],a[7:0]} : (|a[14:7]) ? {3'b001,a[6:0]} : {3'b000,a[6:0]});		  
assign mantissa_20 = (int8 ? {b[7],b[7],b[7:0]} : (|b[14:7]) ? {3'b001,b[6:0]} : {3'b000,b[6:0]});

wire [7:0] exponent_res;

compare_and_shift cas(int8,mantissa_10,mantissa_20,a[14:7],b[14:7],exponent_res,mantissa_11,mantissa_21);
addition_s add(a[15],b[15],mantissa_11,mantissa_21,mantissa_sum);
normalisation_s norm(int8,a[7],b[7],mantissa_sum,exponent_res,mantissa_final,exponent_final,sign_res,overflow);

assign res=(exception_a?{a[15],8'hFF,7'b0}:exception_b?{b[15],8'hFF,7'b0}:overflow?(int8?(mantissa_final[7]?16'h7F:16'h80):{1'b0,8'hFF,7'b0}):zero_a?b:zero_b?a:int8?{exponent_final,mantissa_final}:{sign_res,exponent_final,mantissa_final[6:0]});
endmodule 