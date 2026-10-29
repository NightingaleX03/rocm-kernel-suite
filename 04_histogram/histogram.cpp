#include <hip/hip_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "hip_check.h"
#include "histogram_kernal.h"

// the two versions we're comparing
// GlobalAtomics = every thread adds straight into the 256 global bins (lots of threads fighting over the same counters)
// Privatized    = each block counts into its own private bins in LDS first, then adds them to the global bins once at the end
enum HistogramVersion { GlobalAtomics, Privatized };

// launches one version (so we don't write the if/else everywhere)
void launchHistogram(HistogramVersion version, const unsigned char* deviceInput,
                     unsigned int* deviceBins, int N, int numBlocks) {
    
    if (version == GlobalAtomics){
        histogram_global<<<numBlocks, THREADS_PER_BLOCK>>>(deviceInput, deviceBins, N);
    } 
    else {
        histogram_privatized<<<numBlocks, THREADS_PER_BLOCK>>>(deviceInput, deviceBins, N);
    }
}

/* runs one version: times it, then does one clean run to check the answer
gives back the average time (ms) and the GPU's bins */
void runHistogram(HistogramVersion version, const unsigned char* deviceInput, unsigned int* deviceBins,
                  std::vector<unsigned int>& hostBins, int N, int numBlocks, float& averageMs) {

    hipEvent_t start, stop;
    HIP_CHECK(hipEventCreate(&start));
    HIP_CHECK(hipEventCreate(&stop));

    // warmup launch
    launchHistogram(version, deviceInput, deviceBins, N, numBlocks);
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipDeviceSynchronize());

    // 100 launches and average <3
    // (the counts keep piling up across launches, that's okay, we only care about time here)
    const int iterations = 100;
    HIP_CHECK(hipEventRecord(start));
    for (int i = 0; i < iterations; ++i) {
        launchHistogram(version, deviceInput, deviceBins, N, numBlocks);
    }
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipEventRecord(stop));
    HIP_CHECK(hipEventSynchronize(stop));

    float totalMs = 0;
    HIP_CHECK(hipEventElapsedTime(&totalMs, start, stop));
    averageMs = totalMs / iterations;

    // clean run for checking: zero the bins first, then count once
    HIP_CHECK(hipMemset(deviceBins, 0, NUM_BINS * sizeof(unsigned int)));
    launchHistogram(version, deviceInput, deviceBins, N, numBlocks);
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipMemcpy(hostBins.data(), deviceBins, NUM_BINS * sizeof(unsigned int),
                        hipMemcpyDeviceToHost));

    HIP_CHECK(hipEventDestroy(start));
    HIP_CHECK(hipEventDestroy(stop));
}

int main(int argc, char** argv) {
    int power = (argc > 1) ? std::atoi(argv[1]) : 24;          // 2^24 = ~16.7M numbers by default
    bool allSameValue = (argc > 2) && (std::atoi(argv[2]) == 1); // 1 = every number is the same (worst case)
    int N = 1 << power;
    const int numBlocks = 1024; // fixed number of blocks, each thread loops through many numbers

    hipDeviceProp_t props;
    HIP_CHECK(hipGetDeviceProperties(&props, 0));
    std::printf("Device: %s (%s)\n", props.name, props.gcnArchName);
    std::printf("Numbers to count: %d (2^%d), data: %s\n", N, power,
                allSameValue ? "all the same value" : "random 0-255");

    // input: random bytes 0 to 255 (or all 7s for the worst case)
    std::vector<unsigned char> hostInput(N);
    for (int i = 0; i < N; ++i) {
        hostInput[i] = allSameValue ? 7 : static_cast<unsigned char>(std::rand() % NUM_BINS);
    }

    // correct answer on the CPU
    std::vector<unsigned int> cpuBins(NUM_BINS, 0);
    for (int i = 0; i < N; ++i) {
        cpuBins[hostInput[i]]++;
    }

    // GPU memory: the input + 256 bins
    unsigned char* deviceInput;
    unsigned int* deviceBins;
    HIP_CHECK(hipMalloc(&deviceInput, N * sizeof(unsigned char)));
    HIP_CHECK(hipMalloc(&deviceBins, NUM_BINS * sizeof(unsigned int)));
    HIP_CHECK(hipMemcpy(deviceInput, hostInput.data(), N * sizeof(unsigned char), hipMemcpyHostToDevice));

    std::vector<unsigned int> hostBins(NUM_BINS);
    bool allPassed = true;

    //GLOBAL ATOMICS <3 <3 <3
    float globalAtomicsMs = 0;

    runHistogram(GlobalAtomics, deviceInput, deviceBins, hostBins, N, numBlocks, globalAtomicsMs);

    bool globalAtomicsPassed = (hostBins == cpuBins); // every bin has to match exactly
    allPassed = allPassed && globalAtomicsPassed;

    // GB/s = (N bytes) / (time in seconds) / 1e9
    double globalAtomicsGBps = N / (globalAtomicsMs / 1000.0) / 1e9; // 1 byte per number
    std::printf("Global atomics: %.3f ms, %.1f GB/s %s\n",
                globalAtomicsMs, globalAtomicsGBps, globalAtomicsPassed ? "PASSED" : "FAILED");

    // PRIVATIZED <3 <3 <3
    float privatizedMs = 0;
    runHistogram(Privatized, deviceInput, deviceBins, hostBins, N, numBlocks, privatizedMs);

    // check answer passed if every bin matches the CPU's answer
    bool privatizedPassed = (hostBins == cpuBins);
    allPassed = allPassed && privatizedPassed;

    double privatizedGBps = N / (privatizedMs / 1000.0) / 1e9;
    std::printf("Privatized: %.3f ms, %.1f GB/s %s\n",
                privatizedMs, privatizedGBps, privatizedPassed ? "PASSED" : "FAILED");

    // how much faster privatized is <3
    std::printf("Speedup (privatized vs global atomics): %.2fx\n", globalAtomicsMs / privatizedMs);

    // clean up <3
    HIP_CHECK(hipFree(deviceInput));
    HIP_CHECK(hipFree(deviceBins));

    return allPassed ? 0 : 1;
}