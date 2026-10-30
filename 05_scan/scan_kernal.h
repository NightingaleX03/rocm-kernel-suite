#pragma once
#include <hip/hip_runtime.h>

/** scan = running total, each spot gets the sum of everything before it
example: [3, 1, 7, 0] -> [0, 3, 4, 11] */

/** big arrays take 3 steps cause one block only fits 512 numbers
1. scan each block and save its total
2. scan the block totals
3. add each block's total before it to its numbers */

#define THREADS_PER_BLOCK 256
#define NUMBERS_PER_BLOCK 512 // each thread 2 numbers so 256 x 2 = 512

// scan each block <3 <3 <3
__global__ void scan_blocks(const float* input, float* output, float* blockTotals, int N) {
    __shared__ float sharedNumbers[NUMBERS_PER_BLOCK];

    int threadInBlock = threadIdx.x;
    int blockStart = blockIdx.x * NUMBERS_PER_BLOCK;

    // load 2 numbers each
    int firstSpot = threadInBlock;
    int secondSpot = threadInBlock + THREADS_PER_BLOCK;
    sharedNumbers[firstSpot] = (blockStart + firstSpot < N) ? input[blockStart + firstSpot] : 0.0f;
    sharedNumbers[secondSpot] = (blockStart + secondSpot < N) ? input[blockStart + secondSpot] : 0.0f;

    // up-sweep add up chunks like reduction
    int gap = 1;
    for (int activeThreads = NUMBERS_PER_BLOCK / 2; activeThreads > 0; activeThreads /= 2) {
        
        __syncthreads(); // fixed issue of threads reading/writing the same spot at the same time <3

        if (threadInBlock < activeThreads) {

            int left = gap * (2 * threadInBlock + 1) - 1;
            int right = gap * (2 * threadInBlock + 2) - 1;
            sharedNumbers[right] += sharedNumbers[left];
        }
        gap *= 2;
    }

    // save block total, set last spot to 0
    if (threadInBlock == 0) {
        blockTotals[blockIdx.x] = sharedNumbers[NUMBERS_PER_BLOCK - 1];
        sharedNumbers[NUMBERS_PER_BLOCK - 1] = 0.0f;
    }

    // down-sweep hand the sums back down
    for (int activeThreads = 1; activeThreads < NUMBERS_PER_BLOCK; activeThreads *= 2) {
        
        gap /= 2;
        __syncthreads(); // fixed issue of threads reading/writing the same spot at the same time

        if (threadInBlock < activeThreads) {

            int left = gap * (2 * threadInBlock + 1) - 1;
            int right = gap * (2 * threadInBlock + 2) - 1;
            float temp = sharedNumbers[left];

            sharedNumbers[left] = sharedNumbers[right]; // left keeps what came before
            sharedNumbers[right] += temp; // right adds the left side
        }
    }

    __syncthreads();

    // write back
    if (blockStart + firstSpot < N){
        output[blockStart + firstSpot] = sharedNumbers[firstSpot];
    }

    if (blockStart + secondSpot < N){
        output[blockStart + secondSpot] = sharedNumbers[secondSpot];
    }
}

// add each block total before it to its numbers <3 <3 <3
__global__ void add_block_offsets(float* output, const float* blockOffsets, int N) {
    
    int blockStart = blockIdx.x * NUMBERS_PER_BLOCK;
    float offset = blockOffsets[blockIdx.x];

    int firstSpot = blockStart + threadIdx.x;
    int secondSpot = firstSpot + THREADS_PER_BLOCK;

    if (firstSpot < N){
        output[firstSpot] += offset;
    }

    if (secondSpot < N) {
        output[secondSpot] += offset;
    }
}