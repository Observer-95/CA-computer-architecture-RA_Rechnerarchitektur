/*
 * author(s):   Patrick Stöckli 
 * modified:    2022-03-29
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "memory.h"
#include "mips.h"
#include "compiler.h"
 
int main ( int argc, char** argv ) {
	verbose = TRUE;
	if(argc != 3){
		printf("usage %s expression filename \n", argv[0]);
		exit(EXIT_FAILURE);
	}
	printf("Input: %s \n", argv[1]);
	printf("Postfix: ");
	compiler(argv[1], argv[2]);
	printf("\nMIPS binary saved to %s \n", argv[2]);
	return EXIT_SUCCESS;
}

