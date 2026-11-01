#include <hip/hip_runtime.h>
#include <chrono>
#include <cmath>
#include <cstdio> // output library
#include <cstdlib>
#include <vector>
#include "hip_check.h"
#include "scan_kernal.h" // both kernels are in here

/** scans the input one level at a time
1. scan each block and save its total
2. if there's more than 1 block, scan the block totals (same function again, one level up)
3. add each block's total-before-it to its numbers
blockTotals and blockOffsets hold one GPU array per level */
void scanLevel(const float* input, float* output, int N, int level,
               std::vector<float*>& blockTotals, std::vector<float*>& blockOffsets) {

    int numBlocks = (N + NUMBERS_PER_BLOCK - 1) / NUMBERS_PER_BLOCK; // rounds up

    // 1. scan each block
    scan_blocks<<<numBlocks, THREADS_PER_BLOCK>>>(input, output, blockTotals[level], N);

    if (numBlocks > 1) {
        // 2. scan the block totals, one level up
        scanLevel(blockTotals[level], blockOffsets[level], numBlocks, level + 1, blockTotals, blockOffsets);

        // 3. add each block's total-before-it
        add_block_offsets<<<numBlocks, THREADS_PER_BLOCK>>>(output, blockOffsets[level], N);
    }
}

// main
int main(int argc, char** argv) {
    int power = (argc > 1) ? std::atoi(argv[1]) : 24; // to test for results file
    int N = 1 << power;
    const size_t size = (size_t)N * sizeof(float);

    hipDeviceProp_t props; // info about GPU <3
    HIP_CHECK(hipGetDeviceProperties(&props, 0));
    std::printf("Device: %s (%s)\n", props.name, props.gcnArchName);
    std::printf("Numbers to scan: %d (2^%d)\n", N, power);

    // adding data, random numbers 0 to 1
    std::vector<float> hostInput(N), hostOutput(N);
    for (int i = 0; i < N; ++i) {
        hostInput[i] = static_cast<float>(std::rand()) / RAND_MAX;
    }

    // correct answer on the CPU (timed so we can compare)
    std::vector<double> cpuOutput(N);
    auto cpuStart = std::chrono::high_resolution_clock::now();
    double runningTotal = 0.0;

    for (int i = 0; i < N; ++i) {
        cpuOutput[i] = runningTotal; // everything before this spot
        runningTotal += hostInput[i];
    }

    auto cpuStop = std::chrono::high_resolution_clock::now();
    double cpuMs = std::chrono::duration<double, std::milli>(cpuStop - cpuStart).count();

    // allocate memory on device
    float *deviceInput, *deviceOutput;
    HIP_CHECK(hipMalloc(&deviceInput, size));
    HIP_CHECK(hipMalloc(&deviceOutput, size));

    // one block totals + offsets array per level (16M -> 32768 -> 64 -> 1)
    std::vector<float*> blockTotals, blockOffsets;
    int levelSize = N;

    while (true) {
        int numBlocks = (levelSize + NUMBERS_PER_BLOCK - 1) / NUMBERS_PER_BLOCK;
        float *totals, *offsets;

        HIP_CHECK(hipMalloc(&totals, numBlocks * sizeof(float)));
        HIP_CHECK(hipMalloc(&offsets, numBlocks * sizeof(float)));

        blockTotals.push_back(totals);
        blockOffsets.push_back(offsets);

        if (numBlocks == 1) break; // everything fits in one block now
        levelSize = numBlocks;
    }

    // copy input from CPU to GPU
    HIP_CHECK(hipMemcpy(deviceInput, hostInput.data(), size, hipMemcpyHostToDevice));

    // how to time stuff on GPU
    hipEvent_t start, stop;
    HIP_CHECK(hipEventCreate(&start));
    HIP_CHECK(hipEventCreate(&stop));

    // warmup launch
    scanLevel(deviceInput, deviceOutput, N, 0, blockTotals, blockOffsets);
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipDeviceSynchronize());

    // time 100 launches and average
    const int iterations = 100;
    HIP_CHECK(hipEventRecord(start));

    for (int i = 0; i < iterations; ++i) {
        scanLevel(deviceInput, deviceOutput, N, 0, blockTotals, blockOffsets);
    }

    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipEventRecord(stop));
    HIP_CHECK(hipEventSynchronize(stop));

    float gpuMs = 0;
    HIP_CHECK(hipEventElapsedTime(&gpuMs, start, stop));
    gpuMs /= iterations; // average time per scan

    // copy output from GPU to CPU
    HIP_CHECK(hipMemcpy(hostOutput.data(), deviceOutput, size, hipMemcpyDeviceToHost));

    // verify results (floats round a little so allow a tiny difference)
    int errors = 0;
    for (int i = 0; i < N; ++i) {

        double diff = std::fabs(hostOutput[i] - cpuOutput[i]);

        if (diff > 1e-4 * std::fmax(1.0, std::fabs(cpuOutput[i]))) {

            if (errors < 5) {
                std::printf("Mismatch at %d: GPU %f, CPU %f\n", i, hostOutput[i], cpuOutput[i]);
            }

            errors++;
        }
    }

    // bandwidth: read the input once and write the output once
    double gbPerSec = (2.0 * size) / (gpuMs / 1000.0) / 1e9;

    std::printf("GPU scan: %.3f ms, %.1f GB/s\n", gpuMs, gbPerSec);
    std::printf("CPU scan: %.3f ms\n", cpuMs);
    std::printf("Speedup (GPU vs CPU): %.2fx\n", cpuMs / gpuMs);
    std::printf("%s (%d errors)\n", errors == 0 ? "PASSED" : "FAILED", errors);

    // free device memory
    HIP_CHECK(hipEventDestroy(start));
    HIP_CHECK(hipEventDestroy(stop));

    for (size_t level = 0; level < blockTotals.size(); ++level) {
        HIP_CHECK(hipFree(blockTotals[level]));
        HIP_CHECK(hipFree(blockOffsets[level]));
    }

    HIP_CHECK(hipFree(deviceInput));
    HIP_CHECK(hipFree(deviceOutput));

    return errors == 0 ? 0 : 1;
}