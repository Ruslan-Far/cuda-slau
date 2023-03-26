#include "slau.h"

int get_n()
{
	int k;

	k = 1;
	for (int i = 1; i < SIZE; i += k)
	{
		k += 2;
	}
	return sqrt(SIZE - k);
}

void check_cuda_error(const char *msg)
{
    cudaError_t err = cudaGetLastError();

    if (cudaSuccess != err)
	{
		fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString(err));
		exit(EXIT_FAILURE);
    }
}

void host_print_matrix(int *a)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			printf("%d ", a[N * i + j]);
		}
		printf("\n");
	}
}
