# $\color{#F06292}{\textsf{ROCm GPU Kernel Suite}}$

GPU kernels I wrote in HIP and tested on my AMD Radeon 8060S (RDNA 3.5, gfx1151).
I wanted to learn how memory and shared memory (LDS) change how fast GPU code runs.

## $\color{#F06292}{\textsf{Highlights}}$
- **Vector add:** got ~231 GB/s, which is about 90% of the memory's max speed
- **Matrix multiplication:** the tiled version (using LDS) hit $\color{#F06292}{\textsf{1149 GFLOPS}}$ at 2048x2048, up to 2.8x faster than the naive version
- **Parallel reduction:** wavefront shuffle was up to 2x faster than an LDS tree (160 vs 80 GB/s)
- **Histogram:** giving each block its own bins in LDS made it 5.2x faster than global atomics on random data, and 16x faster when every value is the same
- **Prefix scan:** Blelloch scan was up to 12x faster than the CPU from 1M to 64M numbers
- **ISA trace:** looked at the LLVM IR and AMDGPU assembly for matmul and saw tiling cut global loads 16x per multiply-add
- Every GPU result gets checked against a CPU version to make sure it's correct

## $\color{#F06292}{\textsf{Kernels}}$

| # | Kernel | What I tested |
|---|---|---|
| 01 | Vector add | How fast memory can go, warm-up launches, and cache effects |
| 02 | Matrix multiplication | Naive (reads from global memory) vs. tiled (reuses data in LDS) |
| 03 | Parallel reduction | LDS tree vs. wavefront shuffle (passing values through registers) |
| 04 | Histogram | Global atomics vs. privatized bins in LDS |
| 05 | Prefix scan | Blelloch up-sweep / down-sweep, multi-level for big arrays |

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

## $\color{#F06292}{\textsf{What's next}}$
- Profiling with Radeon GPU Profiler. I got it connected to my HIP app but captures failed cause the driver couldn't set peak clocks on my laptop GPU
- Register tiling for matmul (each thread does a few spots at once)
- Having each thread add up several numbers first in reduction
- Doing scan in one pass instead of two