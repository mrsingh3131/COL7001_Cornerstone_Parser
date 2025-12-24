#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include <string.h>

#define MAX_SYMBOLS 100
extern FILE *yyin;
extern int yyparse();
extern ASTNode *root;



char *symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

void add_symbol(char *id) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i], id) == 0) return; // Already declared
    }
    symbol_table[symbol_count++] = strdup(id);
}

int is_declared(char *id) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i], id) == 0) return 1;
    }
    return 0;
}

void semantic_check(ASTNode *node) {
    if (!node) return;

    switch (node->type) {
        case NODE_VAR_DECL:
            add_symbol(node->id);
            break;
        case NODE_VAR:
        case NODE_ASSIGN:
            if (!is_declared(node->id)) {
                fprintf(stderr, "SEMANTIC ERROR: Variable '%s' used before declaration.\n", node->id);
                exit(1);
            }
            break;
        default: break;
    }

    semantic_check(node->left);
    semantic_check(node->right);
    semantic_check(node->else_branch);
    semantic_check(node->next);
}


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
        semantic_check(root); // Enforce "Var before use"
    
        printf("Semantic Check Passed! AST Structure:\n");
        printf("----------------------------------\n");
        print_ast(root, 0);
        printf("----------------------------------\n");
    } else {
        printf("Parsing Failed.\n");
    }

    fclose(input);
    return 0;
}