#include <hip/hip_runtime.h>
#include <cmath>
#include <cstdio> // output library
#include <vector>
#include <cstdlib>
#include "hip_check.h"

/** blockiIdx blockDim, threadIdx are build in variables HIP provides every gpu function
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
int main(int argc, char** argv){

    int power = (argc > 1) ? std::atoi(argv[1]) : 24; // to test for results file 
    int threadsPerBlock = (argc > 2) ? std::atoi(argv[2]) : 256;

    int number = 1 << power; // 1M elements <- 1 with n number of zeros in binary
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
        hostB[i] = static_cast<float>(67.0f * i); // initialize hostA and hostB with some values
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

    int blocksPerGrid = (number + threadsPerBlock - 1) / threadsPerBlock; // number of blocks in a grid

    // how to time stuff on GPU 
    hipEvent_t start, stop;
    HIP_CHECK(hipEventCreate(&start));
    HIP_CHECK(hipEventCreate(&stop)); 

    vector_add<<<blocksPerGrid, threadsPerBlock>>>(deviceA, deviceB, deviceC, number);
    HIP_CHECK(hipGetLastError()); // check if kernel launch was successful
    HIP_CHECK(hipDeviceSynchronize()); // wait for GPU to finish before continuing


    // time 100 launches and average
    const int iterations = 100;
    HIP_CHECK(hipDeviceSynchronize()); // gpu is idle before starting
    HIP_CHECK(hipEventRecord(start));


    for (int iter = 0; iter < iterations; iter++) {
        vector_add<<<blocksPerGrid, threadsPerBlock>>>(deviceA, deviceB, deviceC, number);
    }

    // check for errors during kernel launch
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipEventRecord(stop));
    HIP_CHECK(hipEventSynchronize(stop));

    float milliseconds = 0;
    HIP_CHECK(hipEventElapsedTime(&milliseconds, start, stop)); // calculate time
    milliseconds /= iterations; // average time per iteration

    std::printf("Time elapsed: %f ms\n", milliseconds); // average time per iteration

    // copy output from GPU to CPU
    HIP_CHECK(hipMemcpy(hostC.data(), deviceC, size, hipMemcpyDeviceToHost));

    // for which testing we're on
    std::printf("Elements: %d (2^%d), threads/block: %d\n", number, power, threadsPerBlock);

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

    std::printf("Verification passed!\n");

    // Bandwidth how much data moved between CPU and GPU in a given time
    double gbPerSec = (size * 3) / (milliseconds / 1000.0) / 1e9; // 3 because we read A and B and write C
    std::printf("Bandwidth: %f GB/s\n", gbPerSec);

    // free device memory
    HIP_CHECK(hipEventDestroy(start));
    HIP_CHECK(hipEventDestroy(stop));

    HIP_CHECK(hipFree(deviceA));
    HIP_CHECK(hipFree(deviceB));
    HIP_CHECK(hipFree(deviceC));

}