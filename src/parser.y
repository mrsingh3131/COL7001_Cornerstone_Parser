%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

// External functions from lexer
extern int yylex();
extern int yylineno;
extern FILE *yyin;

void yyerror(const char *s);
ASTNode *root = NULL; // The final result of our parsing
%}

/* 1. ThiS code tells Bison to give detailed error messages instead of just "syntax error" */
%error-verbose
/* 2. Expect 1 shift/reduce conflict (the dangling else) */
%expect 1

/* This defines the types our tokens and rules can return */
%union {
    int int_val;      // For integers (10)
    char *str_val;    // For identifiers ("x")
    struct ASTNode *node; // For everything else (the tree nodes)
}

/* Tokens received from Lexer */
%token <int_val> TOK_NUM
%token <str_val> TOK_ID
%token TOK_VAR TOK_IF TOK_ELSE TOK_WHILE
%token TOK_EQ TOK_NEQ TOK_LE TOK_GE

/* Which types do our grammar rules return? -> ASTNodes */
%type <node> program statement_list statement block
%type <node> variable_decl assignment if_statement while_statement
%type <node> expression equality comparison term factor unary primary

/* Operator Precedence (Lowest to Highest) */
/* We don't strictly need this because our grammar is stratified, but it's safe */
%left '+' '-'
%left '*' '/'

%%

/* 1. Program is a list of statements [cite: 179] */
program:
    statement_list { root = $1; }
    ;

/* 2. Statement List: can be empty or a sequence [cite: 181] */
statement_list:
    /* empty */ { $$ = NULL; }
    | statement statement_list {
        $1->next = $2; // Link the current statement to the rest
        $$ = $1;
    }
    ;

/* 3. Types of Statements [cite: 183] */
statement:
    variable_decl
    | assignment
    | if_statement
    | while_statement
    | block
    | error ';' { 
        yyerrok; // Tells Bison the error is handled
        printf("Recovering from syntax error at line %d...\n", yylineno);
        $$ = NULL; // Create an empty node so the AST doesn't crash
    }
    ;

/* 4. Block: { statements } [cite: 189] */
block:
    '{' statement_list '}' { $$ = create_block($2); }
    ;

/* 5. Variable Decl: var x; OR var x = 5; [cite: 191] */
variable_decl:
    TOK_VAR TOK_ID ';' { 
        $$ = create_decl($2, NULL); 
    }
    | TOK_VAR TOK_ID '=' expression ';' { 
        $$ = create_decl($2, $4); 
    }
    ;

/* 6. Assignment: x = 10; [cite: 192] */
assignment:
    TOK_ID '=' expression ';' { 
        $$ = create_assign($1, $3); 
    }
    ;

/* 7. If Statement [cite: 194] */
if_statement:
    TOK_IF '(' expression ')' statement { 
        $$ = create_if($3, $5, NULL); 
    }
    | TOK_IF '(' expression ')' statement TOK_ELSE statement { 
        $$ = create_if($3, $5, $7); 
    }
    ;

/* 8. While Loop [cite: 195] */
while_statement:
    TOK_WHILE '(' expression ')' statement { 
        $$ = create_while($3, $5); 
    }
    ;

/* --- EXPRESSION LOGIC (Stratified for Precedence) [cite: 196-214] --- */

expression:
    equality
    ;

equality:
    comparison
    | comparison TOK_EQ comparison { $$ = create_bin_op("==", $1, $3); }
    | comparison TOK_NEQ comparison { $$ = create_bin_op("!=", $1, $3); }
    ;

comparison:
    term
    | term '<' term { $$ = create_bin_op("<", $1, $3); }
    | term '>' term { $$ = create_bin_op(">", $1, $3); }
    | term TOK_LE term { $$ = create_bin_op("<=", $1, $3); }
    | term TOK_GE term { $$ = create_bin_op(">=", $1, $3); }
    ;

term:
    factor
    | term '+' factor { $$ = create_bin_op("+", $1, $3); }
    | term '-' factor { $$ = create_bin_op("-", $1, $3); }
    ;

factor:
    unary
    | factor '*' unary { $$ = create_bin_op("*", $1, $3); }
    | factor '/' unary { $$ = create_bin_op("/", $1, $3); }
    ;

unary:
    primary
    | '-' unary { 
        // Treat "-5" as "0 - 5" or create a specific unary node. 
        // For simplicity, we stick to primary or implement a 0-X binop here.
        $$ = create_bin_op("-", create_num(0), $2); 
    }
    ;

primary:
    TOK_NUM { $$ = create_num($1); }
    | TOK_ID { $$ = create_var($1); }
    | '(' expression ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error on line %d: %s\n", yylineno, s);
}