%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex(void);
extern int yylineno;
void yyerror(char* s);
%}

%token TOK_SEMICOLON TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_NUM TOK_ID TOK_TYPE TOK_PRINT

%union {
    int int_val;
    char var;
}

%type <int_val> expr TOK_NUM

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

stmt:
    | stmt expr_stmt
    ;

expr_stmt:
    TOK_TYPE TOK_ID TOK_SEMICOLON
    | expr TOK_SEMICOLON
    | TOK_PRINT expr TOK_SEMICOLON
    {
        printf("The value is %d\n", $2);
    }
    ;

expr:
    expr TOK_ADD expr
    {
        $$ = $1 + $3;
    }
    | expr TOK_SUB expr
    {
        $$ = $1 - $3;
    }
    | expr TOK_MUL expr
    {
        $$ = $1 * $3;
    }
    | expr TOK_DIV expr
    {
        $$ = $1 / $3;
    }
    | TOK_NUM
    {
        $$ = $1;
    }
    ;

%%

void yyerror(char* s)
{
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    exit(1);
}

int main()
{
    yyparse();
    return 0;
}
