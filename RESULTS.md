# $\color{#F06292}{\textsf{Results}}$

- **Hardware:** AMD Radeon 8060S (gfx1151, RDNA 3.5, 40 CUs / 20 WGPs), wave32
- **Theoretical memory bandwidth:** ~256 GB/s
- **Timing:** hipEvents, 1 warm-up launch, then the average of 100 launches

## $\color{#F06292}{\textsf{01 Vector Add}}$

### $\color{#F8C8DC}{\textsf{Cold vs. warm launch (1M elements)}}$
| Launch | Time (ms) |
|---|---|
| First launch (cold) | 3.98 |
| After warm-up | 0.45 |

### $\color{#F8C8DC}{\textsf{Array size sweep (256 threads per block)}}$
| Elements | Data moved | Time (ms) | Bandwidth (GB/s) |
|---|---|---|---|
| 1M (2^20) | 12 MB | 0.014 | 885.2* |
| 4M (2^22) | 48 MB | 0.219 | 229.3 |
| 16M (2^24) | 192 MB | 0.870 | 231.3 |
| 64M (2^26) | 768 MB | 3.485 | 231.0 |

\*Faster than the memory's max because the 12 MB of data fits in the GPU's cache.

### $\color{#F8C8DC}{\textsf{Block size sweep (16M elements)}}$
| Threads/block | Bandwidth (GB/s) |
|---|---|
| 64 | 229.5 |
| 128 | 230.3 |
| 256 | 231.3 |
| 512 | 230.0 |
| 1024 | 229.3 |

**Best:** $\color{#F06292}{\textsf{232.3 GB/s}}$ (best of several runs at 16M), about 91% of theoretical peak

### $\color{#F8C8DC}{\textsf{Summary}}$

**Array size sweep** (how much homework in total)
- Number of elements changed from 1M up to 64M
- Threads stayed the same: 256 per block
- Small data (1M) was very fast because it fit in the GPU's cache. Bigger data had to come from main memory and maxed out at ~230 GB/s.

**Block size sweep** (how many students per classroom)
- Threads per block changed from 64 to 1024
- Elements stayed the same: 16M
- Almost no difference. Vector add is limited by memory speed, so how threads are grouped doesn't matter.

## $\color{#F06292}{\textsf{02 Matrix Multiplication}}$

### $\color{#F8C8DC}{\textsf{Naive vs. tiled (1024 x 1024)}}$
| Kernel | Time (ms) | GFLOPS |
|---|---|---|
| Naive (global memory) | 7.42 | 289.4 |
| Tiled (16x16 LDS tiles) | 3.26 | 657.9 |

**Speedup:** $\color{#F06292}{\textsf{2.27x}}$ from tiling

### $\color{#F8C8DC}{\textsf{Size sweep}}$
| Size | Naive (ms) | Naive GFLOPS | Tiled (ms) | Tiled GFLOPS | Speedup |
|---|---|---|---|---|---|
| 256 | 0.155 | 216.6 | 0.088 | 383.1 | 1.77x |
| 512 | 1.012 | 265.2 | 0.509 | 527.1 | 1.99x |
| 1024 | 7.417 | 289.5 | 3.335 | 643.9 | 2.22x |
| 2048 | 41.881 | 410.2 | 14.947 | 1149.4 | 2.80x |

### $\color{#F8C8DC}{\textsf{Summary}}$

**Naive** (every student walks to the library for every page)
- Each thread works out one spot of C by reading a full row of A and a full column of B
- Every number comes straight from global memory, which is slow
- Neighbouring threads keep loading the same numbers over and over
- Got 289 GFLOPS, which is only about 2% of what the GPU can do (~15 TFLOPS)
- Still ~5x faster than if every load went to main memory (~57 GFLOPS), so the GPU's cache was already helping a bit

**Tiled** (one trip to the library, then everyone reads from the shared table)
- Each block loads a 16x16 chunk of A and B into LDS (fast shared memory) once
- All 256 threads in the block reuse that chunk instead of going back to global memory
- `__syncthreads()` makes everyone wait until the chunk is fully loaded, and again until everyone is done using it
- Got 658 GFLOPS, 2.27x faster than naive

**Why not 16x faster?**
- Naive was already getting help from the cache, so it wasn't as slow as it could have been
- Tiled now reads from LDS twice for every multiply-add, so LDS speed becomes the new limit
- Each thread still only works out one spot of C. Next step would be register tiling (each thread does a few spots at once)

## $\color{#F06292}{\textsf{03 Parallel Reduction}}$

### $\color{#F8C8DC}{\textsf{LDS tree vs. wavefront shuffle (16M numbers)}}$
| Version | Time (ms) | Bandwidth (GB/s) |
|---|---|---|
| LDS tree | 0.838 | 80.1 |
| Wavefront shuffle | 0.419 | 160.2 |

**Speedup:** $\color{#F06292}{\textsf{2.00x}}$ from wavefront shuffle

### $\color{#F8C8DC}{\textsf{Size sweep}}$
| Numbers | Data | LDS tree (ms) | LDS tree (GB/s) | Shuffle (ms) | Shuffle (GB/s) | Speedup |
|---|---|---|---|---|---|---|
| 1M (2^20) | 4 MB | 0.061 | 68.3 | 0.045 | 93.8 | 1.37x |
| 4M (2^22) | 16 MB | 0.237 | 70.9 | 0.155 | 108.1 | 1.53x |
| 16M (2^24) | 64 MB | 0.838 | 80.1 | 0.419 | 160.2 | 2.00x |
| 64M (2^26) | 256 MB | 2.229 | 120.4 | 1.627 | 164.9 | 1.37x |

### $\color{#F8C8DC}{\textsf{Summary}}$

**LDS tree** (students writing on a shared whiteboard)
- Each block loads 256 numbers into LDS, then adds them in pairs like a tournament (128 -> 64 -> ... -> 1)
- Needs a `__syncthreads()` after every step, so 9 waits per block
- Half the threads go idle each step, by the end 255 out of 256 are just waiting
- Got ~80 GB/s at 16M

**Wavefront shuffle** (students passing notes directly to each other)
- Threads in the same wavefront pass numbers straight to each other through registers with `__shfl_down`
- No LDS and no `__syncthreads()` inside a wavefront because they already move together
- Only 1 `__syncthreads()` per block (to combine the 8 wavefront totals)
- Got ~160 GB/s at 16M, 2x faster

## $\color{#F06292}{\textsf{04 Histogram}}$

### $\color{#F8C8DC}{\textsf{Global atomics vs. privatized}}$
| Data | Size | Global atomics (ms) | Global (GB/s) | Privatized (ms) | Privatized (GB/s) | Speedup |
|---|---|---|---|---|---|---|
| Random 0-255 | 16M (16 MB) | 0.726 | 23.1 | 0.076 | 221.1* | 9.56x |
| Random 0-255 | 64M (64 MB) | 2.897 | 23.2 | 0.553 | 121.3 | 5.24x |
| All the same value | 16M (16 MB) | 5.813 | 2.9 | 0.363 | 46.3 | 16.03x |

\*16 MB fits in the GPU's cache so this one got extra help. 64M is the more realistic number.

**Speedup:** $\color{#F06292}{\textsf{5.2x}}$ on random data, $\color{#F06292}{\textsf{16x}}$ when every value is the same

### $\color{#F8C8DC}{\textsf{Summary}}$

**Global atomics** (everyone lining up at one tally board)
- Every thread adds straight into the 256 bins in global memory with `atomicAdd`
- Stuck at ~23 GB/s no matter how big the data is, so it's limited by how fast atomics can go, not memory
- When every value is the same it drops to 2.9 GB/s cause every thread in the GPU is fighting over 1 bin :(

**Privatized** (each polling station counts its own votes first)
- Each block counts into its own bins in LDS, then adds them to the global bins once at the end
- Way less waiting cause only threads in the same block compete, and LDS is fast
- Got 121 GB/s on 64M random numbers, 5.2x faster
- Still 46 GB/s in the worst case, 16x faster than global atomics

## $\color{#F06292}{\textsf{05 Prefix Scan (Blelloch)}}$

### $\color{#F8C8DC}{\textsf{GPU vs. CPU}}$
| Numbers | Data | GPU (ms) | GPU (GB/s) | CPU (ms) | Speedup |
|---|---|---|---|---|---|
| 1M (2^20) | 4 MB | 0.045 | 187.7 | 0.489 | 10.94x |
| 4M (2^22) | 16 MB | 0.177 | 189.2 | 2.143 | 12.08x |
| 16M (2^24) | 64 MB | 1.229 | 109.2 | 8.015 | 6.52x |
| 64M (2^26) | 256 MB | 8.004 | 67.1 | 32.217 | 4.03x |

GB/s only counts reading the input once and writing the output once. The real traffic is about 2x that cause the output gets read and written again in step 3.

**Speedup:** $\color{#F06292}{\textsf{up to 12x}}$ faster than the CPU

### $\color{#F8C8DC}{\textsf{Summary}}$

**Blelloch scan** (a fundraiser where groups report totals up, then hand them back down)
- Up-sweep adds up chunks once (pairs, groups of 4, groups of 8...) like reduction
- Down-sweep hands those sums back down so every spot knows how much came before it
- Each block scans 512 numbers in LDS (256 threads, 2 numbers each)

**Big arrays** (a stadium where each section counts its own rows first)
1. Scan each block and save its total
2. Scan the block totals (same kernel again, one level up: 16M -> 32768 -> 64 -> 1)
3. Add each block's total-before-it to its numbers

**Size sweep**
- Small sizes got cache help cause the data was still in cache for step 3
- At 16M it's limited by memory, the real traffic is around 218 GB/s, close to the max
- At 64M it drops to 67 GB/s, still figuring out why 

## $\color{#F06292}{\textsf{ISA Trace: HIP -> LLVM IR -> AMDGPU}}$

Generated with:

    hipcc -O3 --offload-arch=gfx1151 --offload-device-only -S -emit-llvm matmul.cpp -o matmul_gpu.ll
    hipcc -O3 --offload-arch=gfx1151 --offload-device-only -S matmul.cpp -o matmul_gpu.s

### $\color{#F8C8DC}{\textsf{Kernel info}}$
| | Naive | Tiled |
|---|---|---|
| LDS used | 0 bytes | 2048 bytes (2 tiles x 16 x 16 x 4 bytes) |
| Registers (VGPRs) | 9 | 26 |
| Wavefront size | 32 | 32 |

### $\color{#F8C8DC}{\textsf{What I found}}$

**LLVM IR** (the in between step)
- A, B, and C are `addrspace(1)` which means global memory
- tileA and tileB are `addrspace(3)` which means LDS (shared memory)
- My `__syncthreads()` shows up as `@llvm.amdgcn.s.barrier`, there's 2 of them just like in my code
- LLVM unrolled my k loop, so instead of looping 16 times it just wrote out all 16 steps

**AMDGPU assembly** (what the GPU actually runs)
- Naive does 2 global loads (one from A, one from B) for every multiply-add, so every number comes from slow memory
- Tiled only does 2 global loads every 16 multiply-adds, so 16x fewer, then saves them into LDS with `ds_store_b32`
- `s_barrier` is my `__syncthreads()` in machine code
- The compiler was smart and combined my LDS reads, 32 loads turned into 12
  - `ds_load_b128` grabs 4 floats at once from tileA cause a row is side by side in memory
  - `ds_load_2addr_b32` grabs 2 floats at once from tileB cause it's going down a column
- Tiled uses about 3x more registers (26 vs 9) cause it holds more values at once, which means fewer wavefronts can run at the same time

**ISA trace:** looked at the LLVM IR and AMDGPU assembly for matmul and saw tiling cut global loads 16x per multiply-add