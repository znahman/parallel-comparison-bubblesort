# parallel-comparison-bubblesort
Parallel implementation of bubble sort originally done for a Parallel Computing course at Colorado School of Mines. 

# Description
This is a parallel implementation of bubblesort using NVIDIA's CUDA parallel programming abstraction. Bubblesort has no data dependence so long as each comparison operates on its own set of data. To achieve this, there's an even swapper that executes first followed by an odd swapper. All of the comparisons and swaps for each iteration of the bubblesort are carried out in parallel on the GPU. However, the kernel functions are invoked n times. This is non-ideal, because extra work is done after the array is sorted (if it takes less than n iterations to sort the array). 

# Results
When the problem size is less than 1300, sequential bubble sort is the faster implementation. However, for n > 1300, the parallel implementation is much faster. 

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
