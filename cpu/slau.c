#include "slau.h"

void	search_minor_algaddit_matrix(double *a, double *sub_a, int *minor_algaddit)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			init_sub_a(a, sub_a, i, j);
			minor_algaddit[N * i + j] = get_det(sub_a, N - 1);
		}
	}
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
			minor_algaddit[N * i + j] *= pow(-1, i + j);
	}
}

void	transpose_matrix(int *a, double *at)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
			at[N * j + i] = a[N * i + j];
	}
}

void	get_inverse_matrix(double *a, int det)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
			a[N * i + j] /= det;
	}
}

void	mult_matrix_to_vector(double *a, int *b, double *x)
{
	double	sum;

	for (int i = 0; i < N; i++)
	{
		sum = 0;
		for (int j = 0; j < N; j++)
			sum += a[N * i + j] * b[j];
		x[i] = sum;
	}
}


int	main(void)
{
	double	*a;
	int		*b;
	double	*x;
	double	*copy_a;
	double	*sub_a;
	int		*minor_algaddit;
	int		det;
	int		int_size;
	int		double_size;

	int_size = sizeof(int);
	double_size = sizeof(double);

	a = (double *) malloc(double_size * SIZE);
	b = (int *) malloc(int_size * N);
	x = (double *) malloc(double_size * N);
	copy_a = (double *) malloc(double_size * SIZE);
	sub_a = (double *) malloc(double_size * (N - 1) * (N - 1));
	minor_algaddit = (int *) malloc(int_size * SIZE);

	init_a(a);
	init_b(b);
	copy(copy_a, a);

	printf("Матрица A\n");
	print_matrix(a);
	printf("Вектор B\n");
	int_print_vector(b);

	search_det(copy_a, &det);
	if (det != 0)
	{
		search_minor_algaddit_matrix(a, sub_a, minor_algaddit);
		transpose_matrix(minor_algaddit, a);
		get_inverse_matrix(a, det);
		mult_matrix_to_vector(a, b, x);
		printf("Ответ\n");
		print_vector(x);
	}
	else
		printf("Невозможно решить данную СЛАУ, так как определитель = 0\n");

	free(a);
	free(b);
	free(x);
	free(copy_a);
	free(sub_a);
	free(minor_algaddit);
	return 0;
}
