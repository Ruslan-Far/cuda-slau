#include "slau.h"

// __device__ void transform_matrix(double *a, int n)
// {
// 	double divider;

// 	for (int k = 0; k < n - 1; k++)
// 	{
// 		for (int i = k; i < n - 1; i++)
// 		{
// 			if (a[n * k + k] == 0)
// 				break;
// 			divider = a[n * (i + 1) + k] / a[n * k + k];
// 			for (int j = 0; j < n; j++)
// 			{
// 				a[n * (i + 1) + k + j] -= divider * a[n * k + k + j];
// 			}
// 		}
// 	}
// }

// __device__ int get_det(double *a, int n)
// {
// 	double det;

// 	n = def_n(n);
// 	// printf("n = %d\n", n);
// 	transform_matrix(a, n);
// 	// dev_print_matrix(a, n);
// 	det = 1;
// 	for (int i = 0; i < n; i++)
// 	{
// 		det *= a[n * i + i];
// 	}
// 	// printf("dev_det = %d\n", (int) round(det));
// 	return ((int) round(det));
// }

__device__ void init_sub_a(double *a, double *sub_a, int r, int c)
{
	int idx_sub_a;

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
