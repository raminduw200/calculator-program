%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int linenum;
int yylex();


%}

%token  TOK_PRINT_VAR TOK_PRINT TOK_MAIN
        TOK_INT TOK_FLOAT
        TOK_LBRACE TOK_RBRACE TOK_SEMICOLON
        TOK_ASSIGN TOK_ADD TOK_MUL
        TOK_INT_NUM TOK_FLOAT_NUM
        TOK_ID TOK_ID_ERR

%type <string> Prog Stmt 
%type <int_val> TOK_INT_NUM TOK_FLOAT_NUM E
%type <name> TOK_ID
%type <name> TOK_ID_ERR


%start Prog

%left PLUS
%left MULTIPLY

%union{
	char name[20];
    int int_val;
    float float_val;

}


%type <name> TOK_PRINT_VAR
%type <name> TOK_PRINT
%type <name> TOK_MAIN

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

Prog:
	TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE    { printf("Valid program\n"); }

;

Stmts: 
    |Stmt TOK_SEMICOLON Stmts
;

Stmt:
    TOK_INT TOK_ID  { $2.type = 0; }
    |TOK_FLOAT TOK_ID   { $2.type = 1; }
    |TOK_ID TOK_ASSIGN E
    {
        if ($1.type != $3.type) {
            fprintf(stderr, "Type error: Assignment mismatch\n");
            exit(1);
        }
    }
    |TOK_PRINT_VAR TOK_ID   {printf("%s\n", $2);}
;   

E:
    TOK_INT_NUM     { $$ = $1; $$->type = 0; }
    |TOK_FLOAT_NUM  { $$ = $1; $$->type = 1; }
    |TOK_ID         { $$ = $1; $$->type = $1.type; }
    |E TOK_ADD E    {
        if ($1->type == $3->type) {
            $$ = $1;
            $$->type = $1->type;
        } else {
            fprintf(stderr, "Type error: Addition mismatch\n");
            exit(1);
        }
    }
    |E TOK_MUL E    {
        if ($1->type == $3->type) {
            $$ = $1;
            $$->type = $1->type;
        } else {
            fprintf(stderr, "Type error: Multiplication mismatch\n");
            exit(1);
        }
    }
;



%%cd

int yyerror(char *s)
{
	printf("Syntax Error on line %d\n%s\n",linenum, s);
	return 0;
}


int main()
    {
        yyparse();
        return 0;
    }
