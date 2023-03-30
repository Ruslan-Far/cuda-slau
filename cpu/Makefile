NAME		=	slau

SRC			=	slau.c inits.c det.c prints.c

HEADER		=	slau.h

OBJ			=	${SRC:%.c=%.o}

CC			=	gcc
RM			=	rm -f

.PHONY	:		all clean fclean re

all		:		${NAME}
	
${NAME}	:		${OBJ}
	${CC} -o ${NAME} ${OBJ}

%.o		:		%.c ${HEADER}
	${CC} -c $< -o $@

clean	:		
	${RM} ${OBJ}

fclean	:		clean
	${RM} ${NAME}

re		:		fclean all
