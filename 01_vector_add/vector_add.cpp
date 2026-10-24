#include <hip/hip_runtime.h>
#include <cmath>
#include <cstdio> // output library
#include <vector>
#include "hip_check.h"

/** blockiIdx blockDim, threadIdx are build in variables CUDA provides every gpu function
 __global__ is a keyword that tells the compiler that this function will be executed 
     on the GPU and can be called from the CPU
This function adds two vectors A and B and stores the result in vector C */

/**__global__: runs on GPU called from  CPU ALWAYS returns void
__device__: runs on GPU called from GPU, used for helper functions
__host__: runs on CPU called from CPU, used for normal functions */

__global__ void vector_add(const float* A, const float* B, float* C, int N) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < N) {
        C[index] = A[index] + B[index];
    }
}

// main
int main(){
    const int number = 1 << 20; // 1M elements <- 1 with n number of zeros in binary
    const size_t size = number * sizeof(float);

    hipDeviceProp_t props; // info about GPU <3
    HIP_CHECK(hipGetDeviceProperties(&props, 0)); // tells hip to get details about GPU, 0 means just the first one on system
    std::printf("Device: %s (%s), wavefront size: %d, CUs: %d\n", 
        props.name, props.gcnArchName, props.warpSize, props.multiProcessorCount);

        /*props.name = gpu name
        props.gcnArchName = gpu architecture name
        props.warpSize = number of threads in a warp
        props.multiProcessorCount = number of compute units
        */

    // adding data
    std::vector<float> hostA(number), hostB(number), hostC(number); // initialize vector with 1.0f
    for (int i = 0; i < number; i++) {
        hostA[i] = static_cast<float>(i);
        hostB[i] = static_cast<float>(67*i);
        // hostC is an output array 
    }

    
}