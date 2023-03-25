#include <stdio.h>
#include <math.h>
#define N 4
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

__global__ void searchDet(int *a, int *det)
{
	int term;
	int n_fact;

	n_fact = fact(N);
	printf("n_fact = %d\n", n_fact);
	*det = 0;
	for (int k = 0; k < n_fact; k++)
	{
		term = pow(-1, k);
		if (term > 0)
		{
			for (int i = 0, cpk = k; i < N; i++)
			{
				printf("%d\n", a[N * i + cpk % N]);
				term *= a[N * i + cpk % N];
				cpk++;
			}
		}
		else
		{
			for (int i = 0, cpk = k; i < N; i++)
			{
				printf("%d\n", a[N * i + cpk % N]);
				term *= a[N * i + cpk % N];
				cpk--;
				if (cpk < 0)
					cpk = N - 1;
			}
		}
		printf("term = %d\n\n\n", term);
		*det += term;
	}
}

void checkCUDAError(const char *msg)
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
	// int host_a[SIZE] = {2, 3, 4, 1};
	// int host_a[SIZE] = {1, -2, 3, 4, 90, 6, -7, 8, 9};
	int host_a[SIZE] = {5, 3, 21, 7, 4, 47, 12, 18, 77, 45, 3, 1, -6, 90, 34, -82};
	// int host_b[N] = {8, 6};
	int host_det;
	int *dev_a;
	int *dev_det;
	int	size;

	size = sizeof(int);
	host_det = 0;
	cudaMalloc(&dev_a, size * SIZE);
	cudaMalloc(&dev_det, size);
	cudaMemcpy(dev_a, host_a, size * SIZE, cudaMemcpyHostToDevice);
	searchDet<<<1, 1>>>(dev_a, dev_det);
	cudaMemcpy(&host_det, dev_det, size, cudaMemcpyDeviceToHost);
	printf("Определитель матрицы А = %d\n", host_det);
	cudaFree(dev_a);
	cudaFree(dev_det);

	checkCUDAError("");
	return 0;
}
