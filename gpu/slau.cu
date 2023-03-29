#include "slau.h"

__global__ void search_det(double *a, double *det)
{
	__shared__ double divider;

	for (int k = 0; k < N - 1; k++)
	{
		if (threadIdx.x == k && blockIdx.x + k < N - 1)
		{
			if (blockIdx.x == 0 && a[N * threadIdx.x + threadIdx.x] == 0)
			{
				*det = 0;
				// return;
			}
			__syncthreads();
			// if (*det == 0)
			// 	return;
			if (*det != 0)
				divider = a[N * (blockIdx.x + threadIdx.x + 1) + threadIdx.x] / a[N * threadIdx.x + threadIdx.x];
		}
		__syncthreads();
		if (*det == 0)
			return;
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
		*det = __double2int_rn(*det);
	}
}

__global__ void search_minor_algaddit_matrix(double *a, int *minor_algaddit)
{
	__shared__ double sub_a[(N - 1) * (N - 1)];
	__shared__ double divider;
	__shared__ double det;

	if (!(threadIdx.x == blockIdx.x || threadIdx.y == blockIdx.y))
	{
		if (threadIdx.x > blockIdx.x && threadIdx.y > blockIdx.y)
			sub_a[N * threadIdx.y + threadIdx.x - (blockDim.y + 1) - (threadIdx.y - 1)] = a[N * threadIdx.y + threadIdx.x];
		else if (threadIdx.x < blockIdx.x && threadIdx.y < blockIdx.y)
			sub_a[N * threadIdx.y + threadIdx.x - threadIdx.y] = a[N * threadIdx.y + threadIdx.x];
		else if (threadIdx.x > blockIdx.x && threadIdx.y < blockIdx.y)
			sub_a[N * threadIdx.y + threadIdx.x - (threadIdx.y + 1)] = a[N * threadIdx.y + threadIdx.x];
		else
			sub_a[N * threadIdx.y + threadIdx.x - blockDim.y - (threadIdx.y - 1)] = a[N * threadIdx.y + threadIdx.x];
	}
	if (threadIdx.x == N - 1 || threadIdx.y != 0)
		return;
	__syncthreads();
	det = 1;
	for (int k = 0; k < (N - 1) - 1; k++)
	{
		if (threadIdx.x == k)
		{
			if (sub_a[(N - 1) * threadIdx.x + threadIdx.x] == 0)
			{
				printf("blockIdx.x = %d; blockIdx.y = %d\n", blockIdx.x, blockIdx.y);
				det = 0;
				// break;
			}
			// __syncthreads();
			// if (det == 0)
			// 	break;
			if (det != 0)
				divider = sub_a[(N - 1) * (threadIdx.x + 1) + threadIdx.x] / sub_a[(N - 1) * threadIdx.x + threadIdx.x];
		}
		__syncthreads();
		if (det == 0)
			break;
		sub_a[(N - 1) * (k + 1) + threadIdx.x] -= divider * sub_a[(N - 1) * k + threadIdx.x];
		__syncthreads();
	}
	if (threadIdx.x == 0)
	{
		if (det == 1)
		{
			for (int i = 0; i < (N - 1); i++)
			{
				det *= sub_a[(N - 1) * i + i];
			}
			det = __double2int_rn(det);
		}
	}
	__syncthreads();
	minor_algaddit[N * blockIdx.y + blockIdx.x] = det * pow(-1, blockIdx.x + blockIdx.y);
}

__global__ void transpose_matrix(int *a, double *at)
{
	int a_idx = N * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
	if (a_idx >= SIZE)
		return;
	int at_idx = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (at_idx >= SIZE)
		return;
	at[at_idx] = a[a_idx];
}

__global__ void get_inverse_matrix(double *a, double *det)
{
	int idx = N * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
	if (idx >= SIZE)
		return;
	int idx2 = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (idx2 >= SIZE)
		return;
	a[idx2] /= *det;
}

__global__ void mult_matrix_to_vector(double *a, int *b, double *x)
{
	int i0 = N * (blockDim.y * blockIdx.y + threadIdx.y);
	if (i0 >= SIZE)
		return;
	double sum = 0;
	for (int k = 0; k < N; k++)
		sum += a[i0 + k] * b[k];
	int idx = blockDim.y * blockIdx.y + threadIdx.y;
	x[idx] = sum;
}

int	main()
{
	// double  host_a[SIZE] = {2, 3, 4, 1}; // det = -10
	// double  host_a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9}; // det = 2904
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82}; // det = 8765568
	// double host_a[SIZE] = {0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}; // det = 0
	// double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82, -103, 71, 51, 21, 33, -367, 16, 2, 1}; // det = -1047253641
	double host_a[SIZE] = {5, 3, 21, 7, 4, 47, 0, 2, 3, 4, 12, 5, 6, 7, 8, 18, 9, 10, 11, 12, 77, 13, 14, 15, 16}; // det = -2332
	// int host_b[N] = {8, 6};
	// int host_b[N] = {8, 6, 17};
	// int host_b[N] = {8, 6, 17, 7};
	int host_b[N] = {8, 6, 17, 7, 9};

	// double *host_a;
	// int *host_b;
	double *host_x;
	int *host_minor_algaddit;
	double host_det;
	double *dev_a;
	int *dev_b;
	double *dev_x;
	double *dev_det;
	int *dev_minor_algaddit;
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

	host_x = (double *) malloc(double_size * N);
	host_minor_algaddit = (int *) malloc(int_size * SIZE);
	host_det = 1;
	host_init_dim3(&blocksPerGrid, &threadsPerBlock);

	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_b, int_size * N);
	cudaMalloc(&dev_x, double_size * N);
	cudaMalloc(&dev_det, double_size);
	cudaMalloc(&dev_minor_algaddit, int_size * SIZE);

	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, host_b, int_size * N, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_det, &host_det, double_size, cudaMemcpyHostToDevice);

	search_det<<<N - 1, N>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, double_size, cudaMemcpyDeviceToHost);
	printf("Определитель матрицы = %f\n", host_det);
	if (host_det != 0)
	{
		cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
		search_minor_algaddit_matrix<<<dim3(N, N), dim3(N, N)>>>(dev_a, dev_minor_algaddit);
		cudaMemcpy(host_minor_algaddit, dev_minor_algaddit, int_size * SIZE, cudaMemcpyDeviceToHost);
		printf("Матрица алгебраических дополнений\n");
		host_print_matrix(host_minor_algaddit);
		transpose_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_minor_algaddit, dev_a);
		cudaMemcpy(host_a, dev_a, double_size * SIZE, cudaMemcpyDeviceToHost);
		printf("Транспонированная матрица\n");
		host_print_matrix(host_a);
		get_inverse_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_a, dev_det);
		cudaMemcpy(host_a, dev_a, double_size * SIZE, cudaMemcpyDeviceToHost);
		printf("Обратная матрица\n");
		host_print_matrix(host_a);
		mult_matrix_to_vector<<<dim3(1, blocksPerGrid.y), dim3(1, threadsPerBlock.y)>>>(dev_a, dev_b, dev_x);
		cudaMemcpy(host_x, dev_x, double_size * N, cudaMemcpyDeviceToHost);
		printf("Ответ\n");
		host_print_vector(host_x);
	}
	else
		printf("Невозможно решить данную СЛАУ\n");

	// free(host_a);
	// free(host_b);
	free(host_x);
	free(host_minor_algaddit);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_x);
	cudaFree(dev_det);
	cudaFree(dev_minor_algaddit);

	host_check_cuda_error("");

	return 0;
}



// 2 * 2 - (1; 2)
// 3 * 3 - ()
// 4 * 4 - ()
// 2) 4 * 4 - ()
// 5 * 5 - ()
// 2) 5 * 5 - ()
