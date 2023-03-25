#include <stdio.h>
#include <math.h>
#define N 2
#define SIZE N * N

__device__ void print_matrix(double *a)
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

__device__ void transform_matrix(double *a)
{
	double divider;

	for (int k = 0; k < N - 1; k++)
	{
		for (int i = k; i < N - 1; i++)
		{
			divider = a[N * (i + 1) + k] / a[N * k + k];
			for (int j = 0; j < N; j++)
			{
				a[N * (i + 1) + k + j] -= divider * a[N * k + k + j];
			}
		}
	}
}

__device__ int get_det(double *a)
{
	double det;

	transform_matrix(a);
	print_matrix(a);
	det = 1;
	for (int i = 0; i < N; i++)
	{
		det *= a[N * i + i];
	}
	return ((int) round(det));
}

__global__ void search_det_and_minor_matrix(double *a, int *det)
{
	*det = get_det(a);
}

void check_cuda_error(const char *msg)
{
    cudaError_t err = cudaGetLastError();

    if (cudaSuccess != err)
	{
		fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString(err));
		exit(EXIT_FAILURE);
    }
}

int	main()
{
	double  host_a[SIZE] = {2, 3, 4, 1};
	// double  host_a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82, -103, 71, 51, 21, 33, -367, 16, 2, 1};
	// int host_b[N] = {8, 6};
	int host_det;
	double *dev_a;
	int *dev_det;
	int	int_size;
	int double_size;

	int_size = sizeof(int);
	double_size = sizeof(double);
	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_det, int_size);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	search_det_and_minor_matrix<<<1, 1>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, int_size, cudaMemcpyDeviceToHost);
	printf("Определитель матрицы А = %d\n", host_det);
	cudaFree(dev_a);
	cudaFree(dev_det);

	check_cuda_error("");
	return 0;
}
