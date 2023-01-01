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


