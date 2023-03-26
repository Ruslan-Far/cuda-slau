#ifndef SLAU_H
# define SLAU_H

# define N 2
# define SIZE N * N

# include <stdio.h>
# include <math.h>

int		get_n();
void	check_cuda_error(const char *msg);
void	host_print_matrix(int *a);

#endif