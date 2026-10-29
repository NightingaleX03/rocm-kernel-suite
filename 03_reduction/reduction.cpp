#include <hip/hip_runtime.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "hip_check.h"
#include "reduce_kernels.h" // both kernels live here

// the two versions we're comparing (an enum = a list of named options)
enum ReductionVersion { LDSTree, WavefrontShuffle };

// runs one version of the reduction, times it, and adds up the block totals
// gives back the average time (ms) and the final sum
void runReduction(ReductionVersion version, const float* deviceInput, float* deviceBlockTotals,
                  std::vector<float>& hostBlockTotals, int N, int numBlocks,
                  float& averageMs, double& gpuSum) {

    hipEvent_t start, stop;
    HIP_CHECK(hipEventCreate(&start));
    HIP_CHECK(hipEventCreate(&stop));

    // warmup launch
    if (version == LDSTree) reduce_lds<<<numBlocks, THREADS_PER_BLOCK>>>(deviceInput, deviceBlockTotals, N);
    else                    reduce_shuffle<<<numBlocks, THREADS_PER_BLOCK>>>(deviceInput, deviceBlockTotals, N);
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipDeviceSynchronize());

    // 100 launches and average <3
    const int iterations = 100;
    HIP_CHECK(hipEventRecord(start));
    for (int i = 0; i < iterations; ++i) {
        if (version == LDSTree) reduce_lds<<<numBlocks, THREADS_PER_BLOCK>>>(deviceInput, deviceBlockTotals, N);
        else                    reduce_shuffle<<<numBlocks, THREADS_PER_BLOCK>>>(deviceInput, deviceBlockTotals, N);
    }
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipEventRecord(stop));
    HIP_CHECK(hipEventSynchronize(stop));

    float totalMs = 0;
    HIP_CHECK(hipEventElapsedTime(&totalMs, start, stop));
    averageMs = totalMs / iterations;

    // copy the block totals back and add them up on the CPU (only 65536 numbers)
    HIP_CHECK(hipMemcpy(hostBlockTotals.data(), deviceBlockTotals,
                        numBlocks * sizeof(float), hipMemcpyDeviceToHost));
    gpuSum = 0.0;
    for (int b = 0; b < numBlocks; ++b) {
        gpuSum += hostBlockTotals[b];
    }

    HIP_CHECK(hipEventDestroy(start));
    HIP_CHECK(hipEventDestroy(stop));
}

int main(int argc, char** argv) {
    int power = (argc > 1) ? std::atoi(argv[1]) : 24; // 2^24 = ~16.7M numbers by default
    int N = 1 << power;
    int numBlocks = (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK; // rounds up
    const size_t size = (size_t)N * sizeof(float);

    hipDeviceProp_t props;
    HIP_CHECK(hipGetDeviceProperties(&props, 0));
    std::printf("Device: %s (%s), wavefront size: %d\n", props.name, props.gcnArchName, props.warpSize);
    std::printf("Numbers to add: %d (2^%d)\n", N, power);

    // random numbers between 0 and 1
    std::vector<float> hostInput(N);
    for (int i = 0; i < N; ++i) {
        hostInput[i] = static_cast<float>(std::rand()) / RAND_MAX;
    }

    // correct answer on the CPU (double so it doesn't lose precision with 16M adds)
    double cpuSum = 0.0;
    for (int i = 0; i < N; ++i) {
        cpuSum += hostInput[i];
    }

    // GPU memory: the input + one spot per block for its total
    float *deviceInput, *deviceBlockTotals;
    HIP_CHECK(hipMalloc(&deviceInput, size));
    HIP_CHECK(hipMalloc(&deviceBlockTotals, numBlocks * sizeof(float)));
    HIP_CHECK(hipMemcpy(deviceInput, hostInput.data(), size, hipMemcpyHostToDevice));

    std::vector<float> hostBlockTotals(numBlocks);
    bool allPassed = true;

    //LDS TREE <3 <3 <3
    float ldsTreeMs = 0;
    double ldsTreeSum = 0.0;

    runReduction(LDSTree, deviceInput, deviceBlockTotals, hostBlockTotals,
                 N, numBlocks, ldsTreeMs, ldsTreeSum);

    bool ldsTreePassed = std::fabs(ldsTreeSum - cpuSum) / cpuSum < 1e-4; // within 0.01%
    allPassed = allPassed && ldsTreePassed;

    // how fast the GPU was able to read the input and write the block totals
    double ldsTreeGBps = size / (ldsTreeMs / 1000.0) / 1e9;
    std::printf("LDS tree: %.3f ms, %.1f GB/s, sum %.1f (CPU %.1f) %s\n",
                ldsTreeMs, ldsTreeGBps, ldsTreeSum, cpuSum, ldsTreePassed ? "PASSED" : "FAILED");

    // WAVEFRONT SHUFFLE <3 <3 <#
    float wavefrontShuffleMs = 0;
    double wavefrontShuffleSum = 0.0;

    runReduction(WavefrontShuffle, deviceInput, deviceBlockTotals, hostBlockTotals,
                 N, numBlocks, wavefrontShuffleMs, wavefrontShuffleSum);

    bool wavefrontShufflePassed = std::fabs(wavefrontShuffleSum - cpuSum) / cpuSum < 1e-4;
    allPassed = allPassed && wavefrontShufflePassed;

    // how fast the GPU was able to read the input and write the block totals
    double wavefrontShuffleGBps = size / (wavefrontShuffleMs / 1000.0) / 1e9;
    std::printf("Wavefront shuffle: %.3f ms, %.1f GB/s, sum %.1f (CPU %.1f) %s\n",
                wavefrontShuffleMs, wavefrontShuffleGBps, wavefrontShuffleSum, cpuSum,
                wavefrontShufflePassed ? "PASSED" : "FAILED");

    // how much faster shuffle is <3
    std::printf("Speedup (shuffle vs LDS tree): %.2fx\n", ldsTreeMs / wavefrontShuffleMs);

    // clean up <3
    HIP_CHECK(hipFree(deviceInput));
    HIP_CHECK(hipFree(deviceBlockTotals));

    return allPassed ? 0 : 1;
}