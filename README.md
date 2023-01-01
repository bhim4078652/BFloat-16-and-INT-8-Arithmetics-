# BFloat-16-Arithmetics

Machine learning workloads are computationally intensive and often run for hours or days. To help organizations significantly improve the running time of these workloads, Google developed custom processors called Tensor Processing Units, or TPUs, which make it possible to train and run cutting-edge deep neural networks at higher performance and lower cost. 


This custom floating point format is called “Brain Floating Point Format,” or “bfloat16” for short. The name flows from “Google Brain”, which is an artificial intelligence research group at Google where the idea for this format was conceived. Bfloat16 is carefully used within systolic arrays to accelerate matrix multiplication operations on Cloud TPUs. More precisely, each multiply-accumulate operation in a matrix multiplication uses bfloat16 for the multiplication and 32-bit IEEE floating point for accumulation.


## Bfloat16 semantics

Bfloat16 is a custom 16-bit floating point format for machine learning that’s comprised of one sign bit, eight exponent bits, and seven mantissa bits. This is different from the industry-standard IEEE 16-bit floating point, which was not designed with deep learning applications in mind.

  ![App Screenshot](https://github.com/bhim4078652/BFloat-16-and-INT-8-Arithmetics-/blob/main/REQ_IMAGES/p1.jpg)


Bfloat16 has a greater dynamic range—i.e., number of exponent bits—than FP16. In fact, the dynamic range of bfloat16 is identical to that of FP32.The bfloat16 format works as well as the FP32 format while delivering increased performance and reducing memory usage.

