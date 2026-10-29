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