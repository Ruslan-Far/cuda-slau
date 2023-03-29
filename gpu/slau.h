#ifndef SLAU_H
# define SLAU_H

# define N 4
# define SIZE N * N
# define BLOCK_N 5

# include <stdio.h>
# include <math.h>

void			host_check_cuda_error(const char *msg);
void			host_init_dim3(dim3 *blocksPerGrid, dim3 *threadsPerBlock);
void			host_init_a(double *a);
void			host_init_b(int *b);

void			host_print_matrix(double *a);
void			host_print_matrix(int *a);
void			host_print_vector(double *a);
void			host_print_vector(int *a);

__device__ void	dev_print_matrix(double *a, int n);
__device__ void	dev_print_matrix(int *a);

#endif
