#pragma once
#include <hip/hip_runtime.h>

/* reduction = squish a big array into ONE number (here: the sum)
example: [3, 1, 4, 1, 5, 9, 2, 6] -> 31

CPU does it one by one (7 adds in a row)
GPU does it like a tournament, adding pairs at the same time:
  3 1 4 1 5 9 2 6
   4   5   14  8      <- step 1
     9      22        <- step 2
         31           <- step 3
8 numbers = only 3 steps, 1024 numbers = only 10 steps
*/

#define THREADS_PER_BLOCK 256

// ===================== VERSION 1: LDS TREE =====================

__global__ void reduce_lds(const float* input, float* blockTotals, int N) {
    // shared memory (LDS) that the whole block can see
    __shared__ float sharedNumbers[THREADS_PER_BLOCK];

    int threadInBlock = threadIdx.x; // my spot inside the block (0 to 255)
    int globalIndex = blockIdx.x * blockDim.x + threadInBlock; // my spot in the whole array

    // each thread loads one number into shared memory (0 if we fall off the end)
    sharedNumbers[threadInBlock] = (globalIndex < N) ? input[globalIndex] : 0.0f;
    __syncthreads(); // wait until all 256 numbers are loaded

    // tournament: half the threads add a pair each step
    // gap goes 128 -> 64 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
    for (int gap = blockDim.x / 2; gap > 0; gap /= 2) {
        if (threadInBlock < gap) {
            // add my number + the number gap spots away
            sharedNumbers[threadInBlock] += sharedNumbers[threadInBlock + gap];
        }
        __syncthreads(); // wait until everyone's done this step before the next one
    }

    // thread 0 now has the whole block's total in sharedNumbers[0]
    if (threadInBlock == 0) {
        blockTotals[blockIdx.x] = sharedNumbers[0];
    }
}