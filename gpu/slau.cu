#include "slau.h"

__global__ void	search_det(double *a, double *det)
{
	__shared__ double	divider;

	for (int k = 0; k < N - 1 && blockIdx.x < N - 1 - k; k++)
	{
		if (threadIdx.x == k)
		{
			if (blockIdx.x == 0 && a[N * threadIdx.x + threadIdx.x] == 0)
				*det = 0;
			__syncthreads();
			if (*det != 0)
				divider = a[N * (blockIdx.x + threadIdx.x + 1) + threadIdx.x] / a[N * threadIdx.x + threadIdx.x];
		}
		__syncthreads();
		if (*det == 0)
			return;
		a[N * (blockIdx.x + k + 1) + threadIdx.x] -= divider * a[N * k + threadIdx.x];
		__syncthreads();
	}
	if (blockIdx.x == 0 && threadIdx.x == 0)
	{
		for (int i = 0; i < N; i++)
			*det *= a[N * i + i];
		*det = __double2int_rn(*det);
	}
}

__global__ void	search_minor_algaddit_matrix(double *a, int *minor_algaddit)
{
	__shared__ double	sub_a[(N - 1) * (N - 1)];
	__shared__ double	divider[N - 1];
	__shared__ double	det;

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
	if (threadIdx.x == N - 1 || threadIdx.y == N - 1)
		return;
	__syncthreads();
	det = 1;
	for (int k = 0; k < (N - 1) - 1 && threadIdx.y < N - 2 - k; k++)
	{
		if (threadIdx.x == k)
		{
			if (threadIdx.y == 0 && sub_a[(N - 1) * threadIdx.x + threadIdx.x] == 0)
				det = 0;
			__syncthreads();
			if (det != 0)
				divider[threadIdx.y] = sub_a[(N - 1) * (threadIdx.y + threadIdx.x + 1) + threadIdx.x] / sub_a[(N - 1) * threadIdx.x + threadIdx.x];
		}
		__syncthreads();
		if (det == 0)
			break;
		sub_a[(N - 1) * (threadIdx.y + k + 1) + threadIdx.x] -= divider[threadIdx.y] * sub_a[(N - 1) * k + threadIdx.x];
		__syncthreads();
	}
	if (threadIdx.x == 0 && threadIdx.y == 0)
	{
		if (det == 1)
		{
			for (int i = 0; i < (N - 1); i++)
				det *= sub_a[(N - 1) * i + i];
			det = __double2int_rn(det);
		}
	}
	if (threadIdx.x > 0 || threadIdx.y > 0)
		return;
	__syncthreads();
	minor_algaddit[N * blockIdx.y + blockIdx.x] = det * pow(-1, blockIdx.x + blockIdx.y);
}

__global__ void	transpose_matrix(int *a, double *at)
{
	int a_idx = N * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
	if (a_idx >= SIZE)
		return;
	int at_idx = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (at_idx >= SIZE)
		return;
	at[at_idx] = a[a_idx];
}

__global__ void	get_inverse_matrix(double *a, double *det)
{
	int idx = N * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
	if (idx >= SIZE)
		return;
	int idx2 = N * (blockDim.x * blockIdx.x + threadIdx.x) + blockDim.y * blockIdx.y + threadIdx.y;
	if (idx2 >= SIZE)
		return;
	a[idx2] /= *det;
}

__global__ void	mult_matrix_to_vector(double *a, int *b, double *x)
{
	int i0 = N * (blockDim.x * blockIdx.x + threadIdx.x);
	if (i0 >= SIZE)
		return;
	double sum = 0;
	for (int k = 0; k < N; k++)
		sum += a[i0 + k] * b[k];
	int idx = blockDim.x * blockIdx.x + threadIdx.x;
	x[idx] = sum;
}

int	main()
{
	double		*host_a;
	int			*host_b;
	double		*host_x;
	double		host_det;
	double		*dev_a;
	double		*dev_copy_a;
	int			*dev_b;
	double		*dev_x;
	double		*dev_det;
	int			*dev_minor_algaddit;
	int			int_size;
	int			double_size;
	dim3		blocksPerGrid;
	dim3		threadsPerBlock;
	cudaEvent_t	start;
	cudaEvent_t	stop;
	float		time;

	int_size = sizeof(int);
	double_size = sizeof(double);

	host_a = (double *) malloc(double_size * SIZE);
	host_b = (int *) malloc(int_size * N);
	host_init_a(host_a);
	host_init_b(host_b);
	printf("Матрица A\n");
	host_print_matrix(host_a);
	printf("Вектор B\n");
	host_print_vector(host_b);
	host_x = (double *) malloc(double_size * N);
	host_det = 1;
	host_init_dim3(&blocksPerGrid, &threadsPerBlock);

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaMalloc(&dev_a, double_size * SIZE);
	cudaMalloc(&dev_copy_a, double_size * SIZE);
	cudaMalloc(&dev_b, int_size * N);
	cudaMalloc(&dev_x, double_size * N);
	cudaMalloc(&dev_det, double_size);
	cudaMalloc(&dev_minor_algaddit, int_size * SIZE);

	cudaMemcpy(dev_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_copy_a, host_a, double_size * SIZE, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, host_b, int_size * N, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_det, &host_det, double_size, cudaMemcpyHostToDevice);

	cudaEventRecord(start, 0);
	search_det<<<N - 1, N>>>(dev_copy_a, dev_det);
	cudaMemcpy(&host_det, dev_det, double_size, cudaMemcpyDeviceToHost);
	if (host_det == 0)
	{
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
	}
	if (host_det != 0)
	{
		search_minor_algaddit_matrix<<<dim3(N, N), dim3(N, N)>>>(dev_a, dev_minor_algaddit);
		transpose_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_minor_algaddit, dev_a);
		get_inverse_matrix<<<blocksPerGrid, threadsPerBlock>>>(dev_a, dev_det);
		mult_matrix_to_vector<<<blocksPerGrid.x, threadsPerBlock.x>>>(dev_a, dev_b, dev_x);
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaMemcpy(host_x, dev_x, double_size * N, cudaMemcpyDeviceToHost);
		printf("Ответ\n");
		host_print_vector(host_x);
	}
	else
		printf("Невозможно решить данную СЛАУ, так как определитель = 0\n");
	cudaEventElapsedTime(&time, start, stop);
	printf("Время решения данной СЛАУ с %d неизвестными: %.2f мс\n", N, time);

	free(host_a);
	free(host_b);
	free(host_x);

	cudaFree(dev_a);
	cudaFree(dev_copy_a);
	cudaFree(dev_b);
	cudaFree(dev_x);
	cudaFree(dev_det);
	cudaFree(dev_minor_algaddit);

	cudaEventDestroy(start);
	cudaEventDestroy(stop);

	host_check_cuda_error("");

	return 0;
}
