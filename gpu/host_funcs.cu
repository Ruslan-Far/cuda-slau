#include "slau.h"

void	host_check_cuda_error(const char *msg)
{
    cudaError_t err = cudaGetLastError();

    if (cudaSuccess != err)
	{
		fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString(err));
		exit(EXIT_FAILURE);
    }
}

void	host_init_dim3(dim3 *blocksPerGrid, dim3 *threadsPerBlock)
{
	if (N <= BLOCK_N)
	{
		*blocksPerGrid = dim3(1);
		*threadsPerBlock = dim3(N, N);
	}
	else
	{
		if (N % BLOCK_N == 0)
			*blocksPerGrid = dim3(N / BLOCK_N, N / BLOCK_N);
		else
			*blocksPerGrid = dim3(N / BLOCK_N + 1, N / BLOCK_N + 1);
		*threadsPerBlock = dim3(BLOCK_N, BLOCK_N);
	}
}

void	host_init_a(double *a)
{
	for (int i = 0; i < SIZE; i++)
	{
		a[i] = rand();
		if (a[i] > 100000)
			a[i] = round(a[i] / 100000000);
	}
}

void	host_init_b(int *b)
{
	for (int i = 0; i < N; i++)
		b[i] = N - i;
}
