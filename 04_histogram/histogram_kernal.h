#pragma once
#include <hip/hip_runtime.h>

/** histogram counts how many times each value shows up in the input
example: [2, 0, 3, 2, 2, 1, 0, 2] gives bin 0 = 2, bin 1 = 1, bin 2 = 4, bin 3 = 1
my input is random bytes so the values go from 0 to 255 which means 256 bins */

/** if 2 threads add to the same bin at the same time one of the counts can get lost (race condition)
atomicAdd fixes it cause it does read, add 1, and write all in one step nobody can interrupt
but if a lot of threads want the same bin they have to wait in line (atomic contention) */

#define NUM_BINS 256 // one bin for every value from 0 to 255
#define THREADS_PER_BLOCK 256

// <3 <3 <3

/** global atomics <3 <3 <3
every thread adds straight into the 256 bins in global memory
it's simple but every thread in the whole GPU is fighting over the same 256 counters
kind of like everyone in the country lining up at one tally board */

__global__ void histogram_global(const unsigned char* input, unsigned int* bins, int N) {
    int globalIndex = blockIdx.x * blockDim.x + threadIdx.x; // where this thread starts
    int totalThreads = gridDim.x * blockDim.x; // number of threads in the whole grid

    // each thread does a lot of numbers, jumps ahead by totalThreads every time (grid-stride loop)
    for (int i = globalIndex; i < N; i += totalThreads) {
        atomicAdd(&bins[input[i]], 1); // add 1 to this number's bin
    }
}

/** privatized <3 <3 <3
each block gets its own copy of the bins in shared memory (LDS)
threads count into their block's bins first which is faster cause LDS is fast and only this block is waiting
then at the end each block adds its bins into the global bins just once
like each polling station counting its own votes and then sending in the totals */

__global__ void histogram_privatized(const unsigned char* input, unsigned int* bins, int N) {
    __shared__ unsigned int privateBins[NUM_BINS]; // this block's own bins

    int threadInBlock = threadIdx.x; // spot in the block (0 to 255)
    int globalIndex = blockIdx.x * blockDim.x + threadInBlock; // where this thread starts
    int totalThreads = gridDim.x * blockDim.x; // number of threads in the whole grid

    // 256 threads and 256 bins so each thread clears one bin
    privateBins[threadInBlock] = 0;
    __syncthreads(); // wait until all the bins are cleared

    // count into this block's bins
    for (int i = globalIndex; i < N; i += totalThreads) {
        atomicAdd(&privateBins[input[i]], 1);
    }
    __syncthreads(); // wait until the whole block is done counting

    // each thread adds one of the block's bins into the global bins
    if (privateBins[threadInBlock] > 0) { // skip empty bins
        atomicAdd(&bins[threadInBlock], privateBins[threadInBlock]);
    }
}