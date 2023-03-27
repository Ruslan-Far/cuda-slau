#include "slau.h"

__constant__ int const_n;

__device__ int def_n(int n)
{
	if (n == 0)
		return N;
	return const_n;
}

__device__ void transform_matrix(double *a, int n)
{
	double divider;

	for (int k = 0; k < n - 1; k++)
	{
		for (int i = k; i < n - 1; i++)
		{
			if (a[n * k + k] == 0)
				break;
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

	n = def_n(n);
	// printf("n = %d\n", n);
	transform_matrix(a, n);
	// dev_print_matrix(a, n);
	det = 1;
	for (int i = 0; i < n; i++)
	{
		det *= a[n * i + i];
	}
	// printf("dev_det = %d\n", (int) round(det));
	return ((int) round(det));
}

__global__ void search_det(double *a, int *det)
{
	// *det = get_det(a, 0);



	__shared__ double divider;

	for (int k = 0; k < N - 1; k++)
	{
		if (threadIdx.x == k && blockIdx.x + k < N - 1)
		{
			if (blockIdx.x == 0 && a[N * threadIdx.x + threadIdx.x] == 0)
			{
				printf("Невозможно решить данную СЛАУ, так как определитель = 0\n");
				*det = 0;
				return;
			}
			__syncthreads();
			if (*det == 0)
				return;
			divider = a[N * (blockIdx.x + threadIdx.x + 1) + threadIdx.x] / a[N * threadIdx.x + threadIdx.x];
		}
		__syncthreads();
		if (blockIdx.x + k < N - 1)
			a[N * (blockIdx.x + k + 1) + threadIdx.x] -= divider * a[N * k + threadIdx.x];
		__syncthreads();
	}

	if (blockIdx.x == 0 && threadIdx.x == 0)
	{
		for (int i = 0; i < N; i++)
		{
			*det *= a[N * i + i];
		}
		*det = (int) (*det);
	}
	
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
	dev_print_matrix(minor_algaddit);
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
		// printf("a_idx = %d\n", a_idx);
		return;
	}
	// else printf("ELSE a_idx = %d; blockIdx.x = %d; threadIdx.x = %d; blockIdx.y = %d; threadIdx.y = %d\n", a_idx, blockIdx.x, threadIdx.x, blockIdx.y, threadIdx.y);
	int at_idx = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (at_idx >= SIZE)
	{
		// printf("at_idx = %d; blockIdx.x = %d; threadIdx.x = %d; blockIdx.y = %d; threadIdx.y = %d\n", at_idx, blockIdx.x, threadIdx.x, blockIdx.y, threadIdx.y);
		return;
	}
	// else printf("ELSE at_idx = %d; blockIdx.x = %d; threadIdx.x = %d; blockIdx.y = %d; threadIdx.y = %d\n", at_idx, blockIdx.x, threadIdx.x, blockIdx.y, threadIdx.y);
	at[at_idx] = a[a_idx];
}

__global__ void get_inverse_matrix(double *a, int *det)
{
	int idx = N * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
	if (idx >= SIZE)
		return;
	int idx2 = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (idx2 >= SIZE)
		return;
	// a[N * threadIdx.y + threadIdx.x] /= *det;
	// printf("idx = %d\n", idx);
	a[idx2] /= *det;
}

__global__ void mult_matrix_to_vector(double *a, int *b, double *x)
{
	int i0 = N * (blockDim.y * blockIdx.y + threadIdx.y);
	if (i0 >= SIZE)
	{
		// printf("blockDim.y = %d; blockIdx.y = %d; threadIdx.y = %d\n", blockDim.y, blockIdx.y, threadIdx.y);
		return;
	}
	double sum = 0;

	for (int k = 0; k < N; k++)
	{
		sum += a[i0 + k] * b[k];
	}
	int idx = blockDim.y * blockIdx.y + threadIdx.y;
	x[idx] = sum;
}

int	main()
{
	// double  host_a[SIZE] = {2, 3, 4, 1};
	// double  host_a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9};
	double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82};
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82, -103, 71, 51, 21, 33, -367, 16, 2, 1};
	// int host_b[N] = {8, 6};
	// int host_b[N] = {8, 6, 17};
	int host_b[N] = {8, 6, 17, 7};
	// double *host_a;
	// int *host_b;
	double *host_x;
	int *host_minor_algaddit;
	int host_det;
	double *dev_a;
	double *dev_sub_a;
	int *dev_b;
	double *dev_x;
	int *dev_det;
	int *dev_minor_algaddit;
	int host_n;
	int	int_size;
	int double_size;
	dim3 blocksPerGrid;
	dim3 threadsPerBlock;

	int_size = sizeof(int);
	double_size = sizeof(double);
	// host_a = (double *) malloc(double_size * SIZE);
	// host_b = (int *) malloc(int_size * N);
	// host_init_a(host_a);
	// host_init_b(host_b);
	host_print_matrix(host_a);
	host_print_vector(host_b);

	host_n = host_get_n();
	host_x = (double *) malloc(double_size * N);
	host_minor_algaddit = (int *) malloc(int_size * SIZE);
	host_det = 1;
	host_init_dim3(&blocksPerGrid, &threadsPerBlock);

	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_sub_a, double_size * host_n);
	cudaMalloc(&dev_b, int_size * N);
	cudaMalloc(&dev_x, double_size * N);
	cudaMalloc(&dev_det, int_size);
	cudaMalloc(&dev_minor_algaddit, int_size * SIZE);

	cudaMemcpyToSymbol(const_n, &host_n, int_size, 0, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, host_b, int_size * N, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_det, &host_det, int_size, cudaMemcpyHostToDevice);

	search_det<<<3, 4>>>(dev_a, dev_det);
	// search_det<<<1, 1>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, int_size, cudaMemcpyDeviceToHost);
	printf("Определитель матрицы = %d\n", host_det);
	// if (host_det != 0)
	// {
	// 	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	// 	search_minor_algaddit_matrix<<<1, 1>>>(dev_a, dev_sub_a, dev_minor_algaddit);
	// 	cudaMemcpy(host_minor_algaddit, dev_minor_algaddit, int_size * SIZE, cudaMemcpyDeviceToHost);
	// 	printf("Матрица алгебраических дополнений\n");
	// 	host_print_matrix(host_minor_algaddit);
	// 	transpose_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_minor_algaddit, dev_a);
	// 	cudaMemcpy(host_a, dev_a, double_size * SIZE, cudaMemcpyDeviceToHost);
	// 	printf("Транспонированная матрица\n");
	// 	host_print_matrix(host_a);
	// 	get_inverse_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_a, dev_det);
	// 	cudaMemcpy(host_a, dev_a, double_size * SIZE, cudaMemcpyDeviceToHost);
	// 	printf("Обратная матрица\n");
	// 	host_print_matrix(host_a);
	// 	mult_matrix_to_vector<<<dim3(1, blocksPerGrid.y), dim3(1, threadsPerBlock.y)>>>(dev_a, dev_b, dev_x);
	// 	cudaMemcpy(host_x, dev_x, double_size * N, cudaMemcpyDeviceToHost);
	// 	printf("Ответ\n");
	// 	host_print_vector(host_x);
	// }
	// else
	// 	printf("Невозможно решить данную СЛАУ\n");

	// free(host_a);
	// free(host_b);
	free(host_x);
	free(host_minor_algaddit);
	cudaFree(dev_a);
	cudaFree(dev_sub_a);
	cudaFree(dev_b);
	cudaFree(dev_x);
	cudaFree(dev_det);
	cudaFree(dev_minor_algaddit);

	host_check_cuda_error("");

	return 0;
}
