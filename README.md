# parallel-comparison-bubblesort
Parallel implementation of bubble sort originally done for a Parallel Computing course at Colorado School of Mines. 

# Description
This is a parallel implementation of bubblesort using NVIDIA's CUDA parallel programming abstraction. Bubblesort has no data dependence so long as each comparison operates on its own set of data. To achieve this, there's an even swapper that executes first followed by an odd swapper. All of the comparisons and swaps for each iteration of the bubblesort are carried out in parallel on the GPU. However, the kernel functions are invoked n times. This is non-ideal, because extra work is done after the array is sorted (if it takes less than n iterations to sort the array). 

# Results
When the problem size is less than 1300, sequential bubble sort is the faster implementation. However, for n > 1300, the parallel implementation is much faster. The table below shows the results for different sized n. 

| n             | Seq Time (s)  | Par Time (s) | Speedup: |
| ------------- | ------------- | ------------ | -------- |
| 10            | 0.000005      | 0.000148     | 0.03     |
| 100           | 0.000107      | 0.001279     | 0.08     |
| 500           | 0.002251      | 0.006103     | 0.37     |
| 1000          | 0.009119      | 0.011971     | 0.76     |
| 1300          | 0.01434       | 0.014118     | 1.02     |
| 2000          | 0.03317       | 0.021113     | 1.57     |
| 5000          | 0.163066      | 0.052298     | 3.12     |
| 10000         | 0.544062      | 0.107072     | 5.08     |
| 20000         | 2.2235        | 0.321811     | 6.91     |
| 50000         | 13.1171       | 0.935332     | 14.02    |
| 100000        | 53.1152       | 2.8784       | 18.45    |
| 500000        | 1357          | 62.2014      | 21.82    |
