module divison(
	input i_clk,i_rst,
	input [15:0] i_a,
	input [15:0] i_b,
	input i_vld,
	output reg o_exception,
	output reg [15:0] o_res,
	output reg o_vld
);

wire w_sign;
wire [7:0] w_shift;
wire [7:0] w_exp_a;
wire [15:0] w_divisor;
wire [15:0] w_op_a;
wire [15:0] w_Intermediate_X0;
wire [15:0] w_Iteration_X0;
wire [15:0] w_Iteration_X1;
wire [15:0] w_Iteration_X2;
wire [15:0] w_Iteration_X3;
wire [15:0] w_solution;
wire [15:0] w_reciprocal;
wire [7:0] w_exponent;
wire w_exception ;
wire [15:0] w_res;
assign w_exception = (&i_a[14:7]) | (&i_b[14:7]);

assign w_sign = i_a[15] ^ i_b[15];

assign w_divisor = {1'b0,8'd126,i_b[6:0]};

always @(posedge i_clk)
begin
	if(i_rst)
	begin
		o_exception <= 0;
		o_vld <= 0;
		o_res <= 16'd0;
	end
	
	else
	begin	
		o_exception <= w_exception;
		o_vld <= i_vld;
		o_res <= w_res;
	end
end

//16'hC00B = (-37)/17
multiplication m0(.i_a(16'hC00B),.i_b(w_divisor),.int8_ip(1'b0),.o_res(w_Intermediate_X0));

//16'h4034 = 48/17
adder_single_cycle a0(.i_a(w_Intermediate_X0),.i_b(16'h4034),.int8_ip(1'b0),.o_res(w_Iteration_X0));

Iteration x1(w_Iteration_X0,w_divisor,w_Iteration_X1);

Iteration x2(w_Iteration_X1,w_divisor,w_Iteration_X2);

Iteration x3(w_Iteration_X2,w_divisor,w_Iteration_X3);

assign w_exponent = w_Iteration_X3[14:7]+8'd126-i_b[14:7];
assign w_reciprocal = {i_b[15],w_exponent,w_Iteration_X3[6:0]};



multiplication last(.i_a(w_reciprocal),.i_b(i_a),.int8_ip(1'b0),.o_res(w_solution));

assign w_res = {w_sign,w_solution[14:0]};

endmodule


module Iteration(
	input [15:0] i_operand_1,
	input [15:0] i_operand_2,
	output [15:0] o_solution
	);

wire [15:0] w_Intermediate_Value1,w_Intermediate_Value2;

multiplication m1(.i_a(i_operand_1),.i_b(i_operand_2),.int8_ip(1'b0),.o_res(w_Intermediate_Value1));

//16'h4000 -> 2.
adder_single_cycle a1(.i_a(16'h4000),.i_b({1'b1,w_Intermediate_Value1[14:0]}),.int8_ip(1'b0),.o_res(w_Intermediate_Value2));

multiplication m2(.i_a(i_operand_1),.i_b(w_Intermediate_Value2),.int8_ip(1'b0),.o_res(o_solution));

endmodule 

module multiplication(i_a,i_b,int8_ip,exception,overflow,underflow,o_res);

input int8_ip;
input [15:0] i_a,i_b;

output exception,overflow,underflow;
output  [15:0] o_res;


wire sign,round,normalised,zero;
wire [8:0] exponent,sum_exponent;
wire [6:0] product_mantissa;
wire [7:0] op_a,op_b;
wire [15:0] product,product_normalised,res; 

wire int8,sign_int8;

wire [15:0] a,b;

assign o_res=res;


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
					
assign zero = exception ? 1'b0 : (product_mantissa == 7'b0) ? 1'b1 : 1'b0;

assign sum_exponent = a[14:7] + b[14:7];

assign exponent = sum_exponent - 8'd127 + normalised;

assign overflow =(int8 ? ((!sign_int8) & product>16'd127) : (exponent[8] & !exponent[7]) & !zero) ;
									
assign underflow =(int8 ? (sign_int8 & product>16'd128) : (exponent[8] & exponent[7]) & !zero); 							

assign res = (overflow ?(int8 ? {8'b0,8'h7F} : {sign,8'hFF,7'b0} ) : underflow ? (int8 ? {8'b0,8'h80} : {sign,15'b0}) : int8 ?(sign_int8 ? {8'b0,-(product[7:0])} : {8'b0,product[7:0]}): exception ? 16'b0 : {sign,exponent[7:0],product_mantissa});

endmodule


module adder_single_cycle(i_a,i_b,int8_ip,o_res,overflow); // capable of both addition and substraction of Bloat 16 inputs

input [15:0] i_a,i_b;
input		 int8_ip;

output  [15:0] o_res;
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

assign o_res=res;

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


module addition_s(signa,signb,mantissa_11,mantissa_21,mantissa_sum);

input signa,signb;
input [9:0] mantissa_11,mantissa_21;

output [10:0] mantissa_sum;

wire [9:0] Mantissa_11,Mantissa_21;

assign Mantissa_11 = (signa?(-mantissa_11):mantissa_11);
assign Mantissa_21 = (signb?(-mantissa_21):mantissa_21);

assign mantissa_sum = Mantissa_11+Mantissa_21; // can instantiate full adder here instead of + operation

endmodule 

module normalisation_s(int8,signa_int,signb_int,mantissa_sum,exponent_res,mantissa_final,exponent_final,sign_res,overflow);

input [10:0] mantissa_sum;
input [7:0] exponent_res;
input int8;
input signa_int,signb_int;
 
output reg [7:0] mantissa_final;
output reg [7:0] exponent_final;
output sign_res;
output reg overflow;
wire [10:0] Mantissa_sum;

assign sign_res=mantissa_sum[9];

assign Mantissa_sum=(mantissa_sum[9]?(-mantissa_sum):mantissa_sum);

always @(*)
begin
	
	overflow=0;
	if(Mantissa_sum[9:0]==10'b0)
	begin
		mantissa_final=8'b0;
		exponent_final=8'b0;
	end
	
	else if(int8)
	begin
		 mantissa_final=mantissa_sum[7:0];
		 exponent_final=8'b0;
		 
		 if(((!signa_int)&(!signb_int)&mantissa_sum[7]) |(signa_int & signb_int & (!mantissa_sum[7])))
		 begin
			  overflow=1;
		 end
		 
	end
	
	else
	begin
		mantissa_final=Mantissa_sum[8:1];
      exponent_final=exponent_res;
		
		repeat(8)
		begin
         if(mantissa_final[7]==0)
          begin
              mantissa_final=(mantissa_final<<1'b1);
              exponent_final=exponent_final-1'b1;
          end
		end
		
		if(exponent_final==8'b11111111)
		begin
			overflow=1;
		end
		
	end
	
end
endmodule

