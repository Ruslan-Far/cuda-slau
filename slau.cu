#include "slau.h"

__constant__ int const_n;

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

__device__ void print_matrix(int *a, int n)
{
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < n; j++)
		{
			printf("%d ", a[n * i + j]);
		}
		printf("\n");
	}
}

__device__ void transform_matrix(double *a, int n)
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

__device__ int get_det(double *a, int n)
{
	double det;

	if (n == 0)
		n = N;
	else
		n = const_n;
	transform_matrix(a, n);
	print_matrix(a, n);
	det = 1;
	for (int i = 0; i < n; i++)
	{
		det *= a[n * i + i];
	}
	printf("det = %d\n", (int) round(det));
	return ((int) round(det));
}

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

__global__ void search_det(double *a, int *det)
{
	*det = get_det(a, 0);
	// printf("const_n = %d\n", const_n);
}

__global__ void search_minor_matrix(double *a, double *sub_a, int *minor)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			init_sub_a(a, sub_a, i, j);
			minor[N * i + j] = get_det(sub_a, 1);
		}
	}
	printf("Матрица миноров\n");
	print_matrix(minor, N);
}

int	main()
{
	double  host_a[SIZE] = {2, 3, 4, 1};
	// double  host_a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82, -103, 71, 51, 21, 33, -367, 16, 2, 1};
	// int host_b[N] = {8, 6};
	int *host_minor;
	int host_det;
	double *dev_a;
	double *dev_sub_a;
	int *dev_det;
	int *dev_minor;
	int host_n;
	int	int_size;
	int double_size;

	int_size = sizeof(int);
	double_size = sizeof(double);
	host_minor = (int *) malloc(int_size * SIZE);
	host_n = get_n();
	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_sub_a, double_size * host_n);
	cudaMalloc(&dev_det, int_size);
	cudaMalloc(&dev_minor, int_size * SIZE);

	cudaMemcpyToSymbol(const_n, &host_n, int_size, 0, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);

	search_det<<<1, 1>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, int_size, cudaMemcpyDeviceToHost);
	printf("Определитель матрицы А = %d\n", host_det);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	search_minor_matrix<<<1, 1>>>(dev_a, dev_sub_a, dev_minor);

	free(host_minor);
	cudaFree(dev_a);
	cudaFree(dev_sub_a);
	cudaFree(dev_det);
	cudaFree(dev_minor);

	check_cuda_error("");
	return 0;
}
