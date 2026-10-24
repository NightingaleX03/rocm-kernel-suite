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
        props.warpSize = number of threads in a wavefront (group of threads GPU runs together)
        props.multiProcessorCount = number of compute units
        */

    // adding data
    std::vector<float> hostA(number), hostB(number), hostC(number); // initialize vector with 1.0f
    for (int i = 0; i < number; i++) {
        hostA[i] = static_cast<float>(i);
        hostB[i] = static_cast<float>(67*i);
        // hostC is an output array 
    }
    
    // allocate memory on device
    float *deviceA, *deviceB, *deviceC; 
    HIP_CHECK(hipMalloc(&deviceA, size));
    HIP_CHECK(hipMalloc(&deviceB, size));
    HIP_CHECK(hipMalloc(&deviceC, size));

    // copy input from CPU to GPU
    HIP_CHECK(hipMemcpy(deviceA, hostA.data(), size, hipMemcpyHostToDevice));
    HIP_CHECK(hipMemcpy(deviceB, hostB.data(), size, hipMemcpyHostToDevice));
    // no host C cause it's output
    
    // launch kernel

    /*thread kind of like student, classroom is a block (students share room and work together)
    school is grid of all classrooms
    
    thread = student, 1 worker
    wavefront = 32 threads 
    block = classroom so if it's 256 threads that's 8 wavefronts
    grid = school with all the classrooms
    */

    int threadsPerBlock = 256; // number of threads in a block
    int blocksPerGrid = (number + threadsPerBlock - 1) / threadsPerBlock; // number of blocks in a grid

    // how to time stuff on GPU 
    hipEvent_t start, stop;
    HIP_CHECK(hipEventCreate(&start));
    HIP_CHECK(hipEventCreate(&stop)); 

    HIP_CHECK(hipEventRecord(start)); // record start time
    vector_add<<<blocksPerGrid, threadsPerBlock>>>(deviceA, deviceB, deviceC, number); // launch kernel
    HIP_CHECK(hipEventRecord(stop)); // record stop time
    HIP_CHECK(hipEventSynchronize(stop)); // wait for stop event to complete


    float milliseconds = 0;
    HIP_CHECK(hipEventElapsedTime(&milliseconds, start, stop)); // calculate time

    std::printf("Time elapsed: %f ms\n", milliseconds);

    // copy output from GPU to CPU
    HIP_CHECK(hipMemcpy(hostC.data(), deviceC, size, hipMemcpyDeviceToHost));

    // verify results
    for (int i = 0; i < number; i++) {

        float expected = hostA[i] + hostB[i];

        // check if the result is within expected range
        // if not return -1 to indicate failure
        if (std::fabs(hostC[i] - expected) > 1e-5) {
            std::printf("Verification failed at index %d: %f, expected %f\n", i, hostC[i], expected);

            return -1;
        }
    }
}