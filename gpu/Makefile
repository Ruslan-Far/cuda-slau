NAME		=	slau

SRC			=	slau.cu addit.cu prints.cu det_minor.cu

HEADER		=	slau.h

OBJ			=	${SRC:%.cu=%.o}

CC			=	nvcc
RM			=	rm -f

.PHONY	:		all clean fclean re

all		:		${NAME}
	
${NAME}	:		${OBJ}
	${CC} -o ${NAME} ${OBJ}

%.o		:		%.cu ${HEADER}
	${CC} -dc $< -o $@

clean	:		
	${RM} ${OBJ}

fclean	:		clean
	${RM} ${NAME}

re		:		fclean all