#include "slau.h"

static void	transform_matrix(double *a, int n)
{
	double divider;

	for (int k = 0; k < n - 1; k++)
	{
		for (int i = k; i < n - 1; i++)
		{
			divider = a[n * (i + 1) + k] / a[n * k + k];
			for (int j = 0; j < n; j++)
			{
				a[n * (i + 1) + k + j] -= divider * a[n * k + k + j];
			}
		}
	}
}

int	get_det(double *a, int n)
{
	double det;

	transform_matrix(a, n);
	// print_matrix(a, n);
	det = 1;
	for (int i = 0; i < n; i++)
	{
		det *= a[n * i + i];
	}
	// printf("det = %d\n", (int) round(det));
	return ((int) round(det));
}

void	search_det(double *a, int *det)
{
	*det = get_det(a, N);
}
