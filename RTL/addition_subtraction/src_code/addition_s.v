module addition_s(signa,signb,mantissa_11,mantissa_21,mantissa_sum);

input signa,signb;
input [9:0] mantissa_11,mantissa_21;

output [10:0] mantissa_sum;

wire [9:0] Mantissa_11,Mantissa_21;

assign Mantissa_11 = (signa?(-mantissa_11):mantissa_11);
assign Mantissa_21 = (signb?(-mantissa_21):mantissa_21);

assign mantissa_sum = Mantissa_11+Mantissa_21; // can instantiate full adder here instead of + operation

endmodule 