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

