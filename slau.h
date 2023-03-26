#ifndef SLAU_H
# define SLAU_H

# define N 2
# define SIZE N * N

# include <stdio.h>
# include <math.h>

__device__ int def_n(int n);

void	check_cuda_error(const char *msg);

void	host_print_matrix(int *a);
__device__ void print_matrix(double *a, int n);
__device__ void print_matrix(int *a);

int		get_n();
__device__ void transform_matrix(double *a, int n);
__device__ int get_det(double *a, int n);
__device__ void init_sub_a(double *a, double *sub_a, int r, int c);

#endif