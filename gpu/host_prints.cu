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

void host_print_vector(double *a)
{
	for (int i = 0; i < N; i++)
	{
		printf("%f ", a[i]);
	}
	printf("\n");
}

void host_print_vector(int *a)
{
	for (int i = 0; i < N; i++)
	{
		printf("%d ", a[i]);
	}
	printf("\n");
}
