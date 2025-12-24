#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern FILE *yyin;
extern int yyparse();
extern ASTNode *root;

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error opening file");
        return 1;
    }

    yyin = input;
    
    printf("Parsing %s...\n", argv[1]);
    
    // Parse the file!
    if (yyparse() == 0) {
        printf("Parsing Successful! AST Structure:\n");
        printf("----------------------------------\n");
        print_ast(root, 0);
        printf("----------------------------------\n");
    } else {
        printf("Parsing Failed.\n");
    }

    fclose(input);
    return 0;
}