# Results 

Hardware: AMD Radeon 8060S (gfx1151, RDNA 3.5, 40 CUs / 20 WGPs), wave32
Memory Bandwidth: 256 GB/s
Timing: hipEvents, used average of 100 launches 

#01 Vector Add 

### Cold vs. warm launch (1M elements)
| Launch | Time (ms) |
|---|---|
| First launch (cold) | 3.98 |
| After warm-up | 0.45 |

### Array size sweep (256 threads/block)
| Elements | Data moved | Time (ms) | Bandwidth (GB/s) |
|---|---|---|---|
| 1M (2^20) | 12 MB | 0.014 | 885.2 |
| 4M (2^22) | 48 MB | 0.219 | 229.3 |
| 16M (2^24) | 192 MB | 0.870 | 231.3 |
| 64M (2^26) | 768 MB | 3.485 | 231.0 |


### Block size sweep (16M elements)
| Threads/block | Bandwidth (GB/s) |
|---|---|
| 64 | 229.5 |
| 128 | 230.3 |
| 256 | 231.3 |
| 512 | 230.0 |
| 1024 | 229.3 |


Elements: 16777216 (2^24), threads/block: 256
Bandwidth: 232.297164 GB/s

232.3 / 256 = 0.907

**Best: 232.3 GB/s = ~91% of theoretical peak**

### Summary

Array size Sweep (how much homework in total)
Number of elements processed changed from 1M up to 64M
Amount of threads stayed the same 256 threads per block
I learned small data (1M) was very fast because it fit in the GPU's cache. Bigger data had to come from main memory and maxed out at ~230 GB/s.

Block Size Sweep (analogy how many students in classroom)
Number of threads per block changed from 64 to 1024
Amount of elements stayed the same this time fo 16M
I learned that there is almost no difference. Vector add is limited by memory speed, so how threads are grouped doesn't matter.