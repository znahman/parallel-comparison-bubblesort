#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <ctime>
#include <cstdlib>

/*
 * Class: CSCI563 - Introduction to Parallel Computing
 * Student: Zachary Nahman
 * Professor: Dr. Wu
 * Assignment: Course Project for Graduate Students
 * Due Date: 5/6/2018
*/

/*
 * TODO:
 * - take a positive integer N as an argument
 * - create an input integer array of size N
 * - populate the array with integers from the range [1,1000]
 * - sort the array using sequential bubblesort
 * - sort the array using parallel bubblesort
 * - compare sequential bubblesort and paralle bubblesort
*/


// CUDA kernel
__global__ void even_swapper(int *X, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i % 2 == 0 && i < N-1){
        if(X[i+1] < X[i]){
            // switch in the x array
            int temp = X[i];
            X[i] = X[i+1];
            X[i+1] = temp;
        }
    }
}

__global__ void odd_swapper(int *X, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i % 2 != 0 && i < N-2){
        if(X[i+1] < X[i]){
            // switch in the x array
            int temp = X[i];
            X[i] = X[i+1];
            X[i+1] = temp;
        }
    }
}


int main( int argc, char* argv[] )
{
    int N;
    // get the command line argument N (the size of the array)
    if(argc == 2){
        N = atoi(argv[1]);
    }
    else if(argc == 1){
        std::cout << "No number entered for N - please run with N specified" << "\n";
    }
    else if(argc > 2){
        std::cout << "Too many arguments entered, expected 1 - the array size" << "\n";
    }

    // declare the host input array
    int *h_input_array;
    size_t bytes = N * sizeof(int);
    h_input_array= (int*)malloc(bytes);

    // declare the host output array
    int *h_output_array;
    int *seq_h_output_array;
    h_output_array = (int*)malloc(bytes);
    seq_h_output_array = (int*)malloc(bytes);

    // fill the host input array with integers between [1,1000]
    // seed random number generator
    srand(time(0));

    //std::cout << "Array: " << "\n";
    for(int i = 0; i < N; i++){
         h_input_array[i] = (rand() % 1000) + 1;
         //std::cout << h_input_array[i] << "\n";
    }

    // sequential bubblesort algorithm
    // copy the array to sort
    for(int k = 0; k < N; k++){
         seq_h_output_array[k] = h_input_array[k];
         //std::cout << seq_h_output_array[k] << "\n";
    }
    // sort seq_h_output_array (with bubble sort)
    clock_t seq_begin = clock();
    bool sorted = false;
    while(!sorted){
        bool swapped = false;
        for(int k = 0; k < N-1; k++){
             if(seq_h_output_array[k+1] < seq_h_output_array[k]){
                 int temp = seq_h_output_array[k];
                 seq_h_output_array[k] = seq_h_output_array[k+1];
                 seq_h_output_array[k+1] = temp;
                 swapped = true;
             }
        }
        if(!swapped){
            sorted = true;
        }
    }
    clock_t seq_end = clock();


    // print results of sequential bubble sort for debugging
    // std::cout << "Sequential Array (sorted with bubblesort):" << "\n";
    // for(int k = 0; k < N; k++){
    //      std::cout << seq_h_output_array[k] << "\n";
    // }

    // declare and allocate device memory for arrays
    int *d_input_array;
    int *d_output_array;

    cudaMalloc(&d_input_array, bytes);
    cudaMalloc(&d_output_array, bytes);

    // Copy host input array to device
    cudaMemcpy(d_input_array, h_input_array, bytes, cudaMemcpyHostToDevice);

    int threadsToLaunch = ceil(N/32.0);
    //invoke the kernel function
    clock_t par_begin = clock();
    for(int i = 0; i < N;  i++){
        even_swapper<<<threadsToLaunch, 32>>>(d_input_array, N);
        odd_swapper<<<threadsToLaunch, 32>>>(d_input_array, N);
    }
    clock_t par_end = clock();

    // Copy array back to host
    cudaMemcpy(h_output_array, d_input_array, bytes, cudaMemcpyDeviceToHost);

    // printing parallel result for debugging
    // std::cout << "Parallel: " << "\n";
    // for(int k = 0; k < N; k++){
    //      std::cout << h_output_array[k] << "\n";
    // }

    // confirm both arrays are sorted:
    bool seq_sorted = true;
    bool par_sorted = true;
    for(int i = 0; i < N-1;  i++){
        if(h_output_array[i] > h_output_array[i+1]){
            par_sorted = false;
        }
        if(seq_h_output_array[i] > seq_h_output_array[i+1]){
            seq_sorted = false;
        }
    }

    if(seq_sorted){
        std::cout << "The sequential array is sorted properly!" << "\n";
    }else{
        std::cout << "The sequential array is NOT sorted properly!" << "\n";
    }

    if(par_sorted){
        std::cout << "The parallel array is sorted properly!" << "\n";
    }else{
        std::cout << "The parallel array is NOT sorted properly!" << "\n";
    }


    double seq_elapsed_secs = double(seq_end - seq_begin)/CLOCKS_PER_SEC;
    std::cout << "\n";
    std::cout << "Elapsed Time for Sequential Bubblesort: ";
    std::cout << seq_elapsed_secs;
    std::cout << " seconds";
    std::cout << "\n";

    double par_elapsed_secs = double(par_end - par_begin)/CLOCKS_PER_SEC;
    std::cout << "\n";
    std::cout << "Elapsed Time for Parallel Bubblesort: ";
    std::cout << par_elapsed_secs;
    std::cout << " seconds";
    std::cout << "\n";

    // Release device memory
    cudaFree(d_input_array);
    cudaFree(d_output_array);

    // Release host memory
    free(h_input_array);
    free(h_output_array);
    free(seq_h_output_array);

    return 0;
}
