#include "slau.h"

void	init_a(double *a)
{
	for (int i = 0; i < SIZE; i++)
	{
		a[i] = rand();
		if (a[i] > 100000)
		{
			// a[i] = round(a[i] / 100000000);
		}
	}
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

void	init_b(int *b)
{
	for (int i = 0; i < N; i++)
	{
		b[i] = N - i;
	}
}
