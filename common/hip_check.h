#pragma once
#include <hip/hip_runtime.h>
#include <cstdio>
#include <cstdlib>

// Wrap every HIP runtime call with this. If the call fails, it prints
// which call failed, where, and why, then exits.
#define HIP_CHECK(call)                                                   \
    do {                                                                  \
        hipError_t err_ = (call);                                         \
        if (err_ != hipSuccess) {                                         \
            std::fprintf(stderr, "HIP error %s at %s:%d: %s\n",           \
                         hipGetErrorName(err_), __FILE__, __LINE__,       \
                         hipGetErrorString(err_));                        \
            std::exit(EXIT_FAILURE);                                      \
        }                                                                 \
    } while (0)