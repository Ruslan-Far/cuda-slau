#include "slau.h"

void print_matrix(double *a)
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

void int_print_matrix(int *a)
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

void print_vector(int *a)
{
	for (int i = 0; i < N; i++)
	{
		printf("%d ", a[i]);
	}
	printf("\n");
}
