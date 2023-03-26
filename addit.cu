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
