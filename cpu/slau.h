#ifndef SLAU_H
# define SLAU_H

# define N 2
# define SIZE N * N

# include <stdio.h>
# include <math.h>
# include <stdlib.h>

int		get_det(double *a, int n);
void	search_det(double *a, int *det);

void	init_a(double *a);
void	init_sub_a(double *a, double *sub_a, int r, int c);
void	init_b(int *b);

void	print_matrix(double *a);
void	int_print_matrix(int *a);
void	print_vector(int *a);

#endif
