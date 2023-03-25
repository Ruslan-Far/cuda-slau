#include <stdio.h>
#include <math.h>
#define N 2
#define SIZE N * N

__device__ float fact(int n)
{
	int factorial = 1;

	while (n > 1)
	{
		factorial *= n;
		n -= 1;
	}
	return factorial;
}

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
			// printf("divider = %f\n", divider);
			for (int j = 0; j < N; j++)
			{
				a[N * (i + 1) + k + j] -= divider * a[N * k + k + j];
			}
		}
	}
}

__global__ void search_det(double *a, double *det)
{
	transform_matrix(a);
	print_matrix(a);
	*det = 1;
	for (int i = 0; i < N; i++)
	{
		*det *= a[N * i + i];
	}
	printf("%f\n", *det);
	// int term;
	// int n_fact;

	// n_fact = fact(N);
	// printf("n_fact = %d\n", n_fact);
	// *det = 0;
	// for (int k = 0; k < n_fact; k++)
	// {
	// 	term = pow(-1, k);
	// 	if (term > 0)
	// 	{
	// 		for (int i = 0, cpk = k; i < N; i++)
	// 		{
	// 			printf("%d\n", a[N * i + cpk % N]);
	// 			term *= a[N * i + cpk % N];
	// 			cpk++;
	// 		}
	// 	}
	// 	else
	// 	{
	// 		for (int i = 0, cpk = k; i < N; i++)
	// 		{
	// 			printf("%d\n", a[N * i + cpk % N]);
	// 			term *= a[N * i + cpk % N];
	// 			cpk--;
	// 			if (cpk < 0)
	// 				cpk = N - 1;
	// 		}
	// 	}
	// 	printf("term = %d\n\n\n", term);
	// 	*det += term;
	// }
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
	double host_det;
	double *dev_a;
	double *dev_det;
	int	int_size;
	int double_size;

	int_size = sizeof(int);
	double_size = sizeof(double);
	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_det, double_size);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	search_det<<<1, 1>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, double_size, cudaMemcpyDeviceToHost);
	host_det = round(host_det);
	printf("Определитель матрицы А = %f\n", host_det);
	cudaFree(dev_a);
	cudaFree(dev_det);

	check_cuda_error("");
	return 0;
}
