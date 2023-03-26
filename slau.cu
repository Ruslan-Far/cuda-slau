#include "slau.h"

__constant__ int const_n;

__device__ int def_n(int n)
{
	if (n == 0)
		return N;
	return const_n;
}

__global__ void search_det(double *a, int *det)
{
	*det = get_det(a, 0);
}

__global__ void search_minor_algaddit_matrix(double *a, double *sub_a, int *minor_algaddit)
{
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			init_sub_a(a, sub_a, i, j);
			minor_algaddit[N * i + j] = get_det(sub_a, 1);
		}
	}
	printf("Матрица миноров\n");
	print_matrix(minor_algaddit);
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			minor_algaddit[N * i + j] *= pow(-1, i + j);
		}
	}
}

__global__ void transpose_matrix(int *a, double *at)
{
	int a_idx = N * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
	if (a_idx >= SIZE)
	{
		printf("a_idx = %d\n", a_idx);
		return;
	}
	int at_idx = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (at_idx >= SIZE)
	{
		printf("at_idx = %d\n", at_idx);
		return;
	}
	at[at_idx] = a[a_idx];
}

void init_dim3(dim3 *blocksPerGrid, dim3 *threadsPerBlock)
{
	if (N <= BLOCK_N)
	{
		*blocksPerGrid = dim3(1);
		*threadsPerBlock = dim3(N, N);
	}
	else
	{
		if (N % BLOCK_N == 0)
			*blocksPerGrid = dim3(N / BLOCK_N, N / BLOCK_N);
		else
			*blocksPerGrid = dim3(N / BLOCK_N + 1, N / BLOCK_N + 1);
		*threadsPerBlock = dim3(BLOCK_N, BLOCK_N);
	}
}

int	main()
{
	double  host_a[SIZE] = {2, 3, 4, 1};
	// double  host_a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82, -103, 71, 51, 21, 33, -367, 16, 2, 1};
	// int host_b[N] = {8, 6};
	int *host_minor_algaddit;
	int host_det;
	double *dev_a;
	double *dev_sub_a;
	int *dev_det;
	int *dev_minor_algaddit;
	int host_n;
	int	int_size;
	int double_size;
	dim3 blocksPerGrid;
	dim3 threadsPerBlock;

	int_size = sizeof(int);
	double_size = sizeof(double);
	host_n = get_n();
	host_minor_algaddit = (int *) malloc(int_size * SIZE);
	// blocksPerGrid = dim3(N / BLOCK_N + 1, N / BLOCK_N + 1);
	// threadsPerBlock = dim3(BLOCK_N, BLOCK_N);
	init_dim3(&blocksPerGrid, &threadsPerBlock);

	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_sub_a, double_size * host_n);
	cudaMalloc(&dev_det, int_size);
	cudaMalloc(&dev_minor_algaddit, int_size * SIZE);

	cudaMemcpyToSymbol(const_n, &host_n, int_size, 0, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);

	search_det<<<1, 1>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, int_size, cudaMemcpyDeviceToHost);
	printf("Определитель матрицы = %d\n", host_det);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	search_minor_algaddit_matrix<<<1, 1>>>(dev_a, dev_sub_a, dev_minor_algaddit);
	cudaMemcpy(host_minor_algaddit, dev_minor_algaddit, int_size * SIZE, cudaMemcpyDeviceToHost);
	printf("Матрица алгебраических дополнений\n");
	host_print_matrix(host_minor_algaddit);
	transpose_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_minor_algaddit, dev_a);
	cudaMemcpy(host_a, dev_a, double_size * SIZE, cudaMemcpyDeviceToHost);
	printf("Транспонированная матрица\n");
	host_print_matrix(host_a);

	free(host_minor_algaddit);
	cudaFree(dev_a);
	cudaFree(dev_sub_a);
	cudaFree(dev_det);
	cudaFree(dev_minor_algaddit);

	check_cuda_error("");

	return 0;
}
