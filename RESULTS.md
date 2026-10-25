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
