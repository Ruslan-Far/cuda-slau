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
	printf("Матрица миноров\n");
	int_print_matrix(minor_algaddit);
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
			minor_algaddit[N * i + j] *= pow(-1, i + j);
	}
}

void	transpose_matrix(int *a, double *at)
{

}

void	get_inverse_matrix(double *a, int det)
{

}

void	mult_matrix_to_vector(double *a, int *b, double *x)
{

}


int	main(void)
{
	double  a[SIZE] = {2, 3, 4, 1};
	// double  a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9};
	// double a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82};
	// double a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82, -103, 71, 51, 21, 33, -367, 16, 2, 1};
	int b[N] = {8, 6};
	// int b[N] = {8, 6, 17};
	// int b[N] = {8, 6, 17, 7};

	// double	*a;
	// double	*b;
	double	*x;
	double  copy_a[SIZE] = {2, 3, 4, 1};
	// double	*copy_a;
	double	*sub_a;
	int		*minor_algaddit;
	int		det;
	int		int_size;
	int		double_size;

	int_size = sizeof(int);
	double_size = sizeof(double);

	// a = (double *) malloc(double_size * SIZE);
	// b = (int *) malloc(int_size * N);
	x = (double *) malloc(double_size * N);
	// copy_a = (double *) malloc(double_size * SIZE);
	sub_a = (double *) malloc(double_size * (N - 1) * (N - 1));
	minor_algaddit = (int *) malloc(int_size * SIZE);

	// init_a(a);
	// init_b(b);
	// copy(copy_a, a);
	det = 1;

	printf("Матрица A\n");
	print_matrix(a);
	printf("Вектор B\n");
	print_vector(b);

	search_det(copy_a, &det);
	printf("Определитель матрицы = %d\n", det);
	if (det != 0)
	{
		search_minor_algaddit_matrix(a, sub_a, minor_algaddit);
		printf("Матрица алгебраических дополнений\n");
		int_print_matrix(minor_algaddit);
		// transpose_matrix(minor_algaddit, a);
		// printf("Транспонированная матрица\n");
		// print_matrix(a);
		// get_inverse_matrix(a, det);
		// printf("Обратная матрица\n");
		// print_matrix(a);
		// mult_matrix_to_vector(a, b, x);
		// printf("Ответ\n");
		// print_vector(x);
	}
	else
		printf("Невозможно решить данную СЛАУ, так как определитель = 0\n");

	// free(a);
	// free(b);
	free(x);
	// free(copy_a);
	free(sub_a);
	free(minor_algaddit);
	return 0;
}
