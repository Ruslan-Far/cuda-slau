#ifndef SLAU_H
# define SLAU_H

# define N 4
# define SIZE N * N
# define BLOCK_N 2

# include <stdio.h>
# include <math.h>

__device__ int def_n(int n);

void	host_check_cuda_error(const char *msg);
int		host_get_n();
void	host_init_dim3(dim3 *blocksPerGrid, dim3 *threadsPerBlock);
void	host_init_a(double *a);
void	host_init_b(int *b);

void	host_print_matrix(double *a);
void	host_print_matrix(int *a);
void	host_print_vector(double *a);
void	host_print_vector(int *a);

__device__ void dev_print_matrix(double *a, int n);
__device__ void dev_print_matrix(int *a);

__device__ void transform_matrix(double *a, int n);
__device__ int get_det(double *a, int n);
__device__ void init_sub_a(double *a, double *sub_a, int r, int c);

#endif