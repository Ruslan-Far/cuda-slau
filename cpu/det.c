#include "slau.h"

static int	transform_matrix(double *a, int n)
{
	double divider;

	for (int k = 0; k < n - 1; k++)
	{
		for (int i = k; i < n - 1; i++)
		{
			if (a[n * k + k] == 0)
				return 0;
			divider = a[n * (i + 1) + k] / a[n * k + k];
			for (int j = 0; j < n - k; j++)
				a[n * (i + 1) + k + j] -= divider * a[n * k + k + j];
		}
	}
	return 1;
}

double	get_det(double *a, int n)
{
	double det;

	det = transform_matrix(a, n);
	if (det == 0)
		return 0;
	for (int i = 0; i < n; i++)
		det *= a[n * i + i];
	return det;
}

void	search_det(double *a, double *det)
{
	*det = get_det(a, N);
}
