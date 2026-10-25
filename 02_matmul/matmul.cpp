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

rule of matrix multiplication: [A[row][column] * B[row][column]] = C[row][column]
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