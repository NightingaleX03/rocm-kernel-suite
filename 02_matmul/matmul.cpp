#include <hip/hip_runtime.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "hip_check.h"


/* example data would be like
A = [1,2,3,4]
B = [5,6,7,8]
N = 2

A = [1, 2,
     3, 4]

B = [5, 6,
     7, 8]

rule of matrix multiplication: C[row][col] = sum over k of A[row][k] * B[k][col]
C = [1*5+2*7, 1*6+2*8, 3*5+4*7, 3*6+4*8] = [19, 22, 43, 50]
*/

__global__ void matmul_naive(const float* A, const float* B, float* C, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y; // y will go down
    int col = blockIdx.x * blockDim.x + threadIdx.x; // x will go across

    if (row < N && col < N) { // stays withing bounds
        float sum = 0.0f; 

        for (int k = 0; k < N; ++k) { // does dot product of row and column
            sum += A[row * N + k] * B[k * N + col]; // A[row][k] * B[k][col]
        }

        C[row * N + col] = sum; // result of dot product is stored in C[row][col]
    }
}

// main method
int main(int argc, char** argv){
    int N = (argc > 1) ? atoi(argv[1]) : 1024; // default size is 1024 if not specified
    const size_t bytes = (size_t)N * N * sizeof(float);
    
    hipDeviceProp_t props;
    HIP_CHECK(hipGetDeviceProperties(&props, 0));

    std:printf("Device: %s (%s), wavefront size: %d, CUs: %d\n", 
        props.name, props.gcnArchName, props.warpSize, props.multiProcessorCount);
    printf("Matrix size: %d x %d\n", N, N);

    // creating matrix
    std::vector<float> hostA(N * N), hostB(N * N), hostC(N * N);
    for (int i = 0; i < N * N; ++i) {
        hostA[i] = static_cast<float>(i);
        hostB[i] = static_cast<float>(i * 2);
    }

    // allocate memory on device
    float *deviceA, *deviceB, *deviceC; 
    HIP_CHECK(hipMalloc(&deviceA, size));
    HIP_CHECK(hipMalloc(&deviceB, size));
    HIP_CHECK(hipMalloc(&deviceC, size));

    // copy input from CPU to GPU
    HIP_CHECK(hipMemcpy(deviceA, hostA.data(), size, hipMemcpyHostToDevice));
    HIP_CHECK(hipMemcpy(deviceB, hostB.data(), size, hipMemcpyHostToDevice));
    
}