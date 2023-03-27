#ifndef SLAU_H
# define SLAU_H

# define N 4
# define SIZE N * N
# define BLOCK_N 3

# include <stdio.h>
# include <math.h>

__device__ int def_n(int n);

void	check_cuda_error(const char *msg);

void	host_print_matrix(double *a);
void	host_print_matrix(int *a);
void	host_print_vector(double *a);
__device__ void print_matrix(double *a, int n);
__device__ void print_matrix(int *a);

int		get_n();
__device__ void transform_matrix(double *a, int n);
__device__ int get_det(double *a, int n);
__device__ void init_sub_a(double *a, double *sub_a, int r, int c);

#endif