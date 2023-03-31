#include "slau.h"

void	init_a(double *a)
{
	for (int i = 0; i < SIZE; i++)
	{
		a[i] = rand();
		if (a[i] > 100000)
			a[i] = round(a[i] / 100000000);
	}
}

void	init_b(double *b)
{
	for (int i = 0; i < N; i++)
		b[i] = N - i;
}

void	init_sub_a(double *a, double *sub_a, int r, int c)
{
	int	idx_sub_a;

	idx_sub_a = 0;
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			if (i == r || j == c)
				continue;
			sub_a[idx_sub_a++] = a[N * i + j];
		}
	}
}

void	copy(double *copy_a, double *a)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
			copy_a[N * i + j] = a[N * i + j];
	}
}
