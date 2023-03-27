#include "slau.h"

void host_print_matrix(double *a)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			printf("%f ", a[N * i + j]);
		}
		printf("\n");
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

__device__ void print_matrix(double *a, int n)
{
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < n; j++)
		{
			printf("%f ", a[n * i + j]);
		}
		printf("\n");
	}
}

__device__ void print_matrix(int *a)
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
