# $\color{#F06292}{\textsf{ROCm GPU Kernel Suite}}$

GPU kernels I wrote in HIP and tested on my AMD Radeon 8060S (RDNA 3.5, gfx1151).
I wanted to learn how memory and shared memory (LDS) change how fast GPU code runs.

## $\color{#F06292}{\textsf{Highlights}}$
- **Vector add:** got ~231 GB/s, which is about 90% of the memory's max speed
- **Matrix multiplication:** the tiled version (using LDS) hit $\color{#F06292}{\textsf{1149 GFLOPS}}$ at 2048x2048, up to 2.8x faster than the naive version
- Every GPU result gets checked against a CPU version to make sure it's correct

## $\color{#F06292}{\textsf{Kernels}}$

| # | Kernel | What I tested |
|---|---|---|
| 01 | Vector add | How fast memory can go, warm-up launches, and cache effects |
| 02 | Matrix multiplication | Naive (reads from global memory) vs. tiled (reuses data in LDS) |

## $\color{#F06292}{\textsf{Hardware}}$
- AMD Ryzen AI Max+ 392 with Radeon 8060S built-in GPU (gfx1151, 40 CUs / 20 WGPs)
- Wavefronts on this GPU are 32 threads (AMD's data center GPUs use 64)
- The CPU and GPU share the same memory (LPDDR5X-8000, 256-bit, ~256 GB/s max)

## $\color{#F06292}{\textsf{How to Build (Windows, HIP SDK 7.2)}}$
HIP SDK 7.2 doesn't work with the newest Visual Studio C++ tools (14.51), so I use the VS 2022 tools (v143, 14.44) instead.

1. Open Command Prompt and load the 14.44 tools with Visual Studio's `vcvarsall.bat`:

       vcvarsall.bat x64 -vcvars_ver=14.44

2. Go into a kernel folder and build:

       hipcc -O3 --offload-arch=gfx1151 -I../common matmul.cpp -o matmul.exe

If your GPU is different, swap `gfx1151` for your GPU's architecture.

## $\color{#F06292}{\textsf{Results}}$
All my numbers and what I learned are in [RESULTS.md](RESULTS.md).