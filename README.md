# BFloat-16-Arithmetics

Machine learning workloads are computationally intensive and often run for hours or days. To help organizations significantly improve the running time of these workloads, Google developed custom processors called Tensor Processing Units, or TPUs, which make it possible to train and run cutting-edge deep neural networks at higher performance and lower cost. 


This custom floating point format is called “Brain Floating Point Format,” or “bfloat16” for short. The name flows from “Google Brain”, which is an artificial intelligence research group at Google where the idea for this format was conceived. Bfloat16 is carefully used within systolic arrays to accelerate matrix multiplication operations on Cloud TPUs. More precisely, each multiply-accumulate operation in a matrix multiplication uses bfloat16 for the multiplication and 32-bit IEEE floating point for accumulation.


## Bfloat16 semantics

Bfloat16 is a custom 16-bit floating point format for machine learning that’s comprised of one sign bit, eight exponent bits, and seven mantissa bits. This is different from the industry-standard IEEE 16-bit floating point, which was not designed with deep learning applications in mind.

  ![App Screenshot](https://github.com/bhim4078652/BFloat-16-and-INT-8-Arithmetics-/blob/main/REQ_IMAGES/p1.jpg)


Bfloat16 has a greater dynamic range—i.e., number of exponent bits—than FP16. In fact, the dynamic range of bfloat16 is identical to that of FP32.The bfloat16 format works as well as the FP32 format while delivering increased performance and reducing memory usage.

## Addition_and_subtraction Algorithm 
steps :
1) Align binary points - Shift number with smaller exponent.
2) Add or subtract the significands.
3) Normalize result & check for over/underflow.
4) Round and renormalize if necessary.

      ![App Screenshot](https://github.com/bhim4078652/BFloat-16-and-INT-8-Arithmetics-/blob/main/REQ_IMAGES/p2.jpg)


## Multiplication Algorithm 
steps:
1) Add exponents.
2) Multiply significands.
3) Normalize result & check for over/underflow
4) Round and renormalize if necessary.
5) Determine sign: +ve × –ve => –ve.

      ![App Screenshot](https://github.com/bhim4078652/BFloat-16-and-INT-8-Arithmetics-/blob/main/REQ_IMAGES/p3.png)

## Division Algorithm 
    Intial Seed : x0 = 48/17 - (32/17)*D
    where D - Divisor B adjusted to fit 0.5-1 range by replacing the exponent field with 8'd126
    
    Newton Raphson Iterations :
                  x1 = x0*(2-D*x0)
                  x2 = x1*(2-D*x1)
                  x3 = x2*(2-D*x2)
                  
    x3 - Reciprocal of Adusted value D.
    
    Adjust the exponents to produce the final reciprocal of B 
    
    1/B : {B[15],x3[14:7]+8'd126-B[14:7],x3[6:0]}
    Result =  A*1/B
