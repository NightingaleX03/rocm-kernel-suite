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

// CPU versino of matrix multiplication for verification
void matmul_cpu(const std::vector<float>& A, const std::vector<float>& B, std::vector<float>& C, int N) {

    for (int row = 0; row < N; ++row) {
        
        for (int col = 0; col < N; ++col) {
            
            float sum = 0.0f;
            for (int k = 0; k < N; ++k) {
                sum += A[row * N + k] * B[k * N + col];
            }
            C[row * N + col] = sum;
        }
    }
}

// main method
int main(int argc, char** argv){
    int N = (argc > 1) ? atoi(argv[1]) : 1024; // default size is 1024 if not specified
    const size_t size = (size_t)N * N * sizeof(float);
    
    hipDeviceProp_t props;
    HIP_CHECK(hipGetDeviceProperties(&props, 0));

    std::printf("Device: %s (%s), wavefront size: %d, CUs: %d\n", 
        props.name, props.gcnArchName, props.warpSize, props.multiProcessorCount);
    std::printf("Matrix size: %d x %d\n", N, N);

    // creating matrix
    std::vector<float> hostA(N * N), hostB(N * N), hostC(N * N), hostRef(N * N); // hostRef is for CPU verification
    for (int i = 0; i < N * N; ++i) {
        hostA[i] = static_cast<float>(std::rand()) / RAND_MAX; // random float between 0 and 1
        hostB[i] = static_cast<float>(std::rand()) / RAND_MAX; // random float between 0 and 1
    }

    // allocate memory on device
    float *deviceA, *deviceB, *deviceC; 
    HIP_CHECK(hipMalloc(&deviceA, size));
    HIP_CHECK(hipMalloc(&deviceB, size));
    HIP_CHECK(hipMalloc(&deviceC, size));

    // copy input from CPU to GPU
    HIP_CHECK(hipMemcpy(deviceA, hostA.data(), size, hipMemcpyHostToDevice));
    HIP_CHECK(hipMemcpy(deviceB, hostB.data(), size, hipMemcpyHostToDevice));
    
    // dim3 means dimension of 3D grid 
    dim3 threadsPerBlock(16, 16); // 16x16 = 256 threads per block
    dim3 blocksPerGrid((N + threadsPerBlock.x - 1) / threadsPerBlock.x, 
        (N + threadsPerBlock.y - 1) / threadsPerBlock.y);

    // starting timer
    hipEvent_t start, stop;
    
    // setting up
    HIP_CHECK(hipEventCreate(&start));
    HIP_CHECK(hipEventCreate(&stop));

    // warmup kernel launch
    matmul_naive<<<blocksPerGrid, threadsPerBlock>>>(deviceA, deviceB, deviceC, N);
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipDeviceSynchronize());

    // 15 launches and average <3
    const int iterations = 15;
    HIP_CHECK(hipEventRecord(start));

    // launches 15 times and takes average <3
    for (int i = 0; i < iterations; ++i) {
        matmul_naive<<<blocksPerGrid, threadsPerBlock>>>(deviceA, deviceB, deviceC, N);
    }

    HIP_CHECK(hipGetLastError()); // check if kernel launch was successful
    HIP_CHECK(hipEventRecord(stop)); // stop timer
    HIP_CHECK(hipEventSynchronize(stop)); // wait for GPU to finish before continuing

    float milliseconds = 0;
    HIP_CHECK(hipEventElapsedTime(&milliseconds, start, stop)); // get elapsed time
    milliseconds /= iterations; // average time per launch
    std::printf("Average Kernal Naive Time: %f ms\n", milliseconds);

     // copy GPU result back to CPU
    HIP_CHECK(hipMemcpy(hostC.data(), deviceC, size, hipMemcpyDeviceToHost));

    // calculate correct answer on the CPU
    std::printf("Running CPU reference (may take a few seconds)...\n");
    matmul_cpu(hostA, hostB, hostRef, N);

    // compare GPU vs CPU
    int errors = 0;

    for (int i = 0; i < N * N; ++i) {
        float diff = std::fabs(hostC[i] - hostRef[i]);

        if (diff > 1e-3f * std::fabs(hostRef[i])) {   // allow 0.1% difference
            
            if (errors < 5) {
                std::printf("Mismatch at %d: GPU %f, CPU %f\n", i, hostC[i], hostRef[i]);
            }
            errors++;
        }
    }

    // GFLOPS: each of the N*N outputs does N multiplies + N adds = 2*N^3 total
    double flops = 2.0 * N * N * N;
    double gflops = flops / (milliseconds / 1000.0) / 1e9;
    std::printf("Naive GFLOPS: %.1f\n", gflops);
    std::printf("%s (%d errors)\n", errors == 0 ? "PASSED" : "FAILED", errors);

    // clean up <3 <3 <3
    HIP_CHECK(hipEventDestroy(start));
    HIP_CHECK(hipEventDestroy(stop));
    HIP_CHECK(hipFree(deviceA));
    HIP_CHECK(hipFree(deviceB));
    HIP_CHECK(hipFree(deviceC));

    return errors == 0 ? 0 : 1;
}