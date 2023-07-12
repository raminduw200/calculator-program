%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_number;
int yylex();

struct idarr{
	char name[20];
	int type; // 1 is int, 2 is float
	char value[20];
};

struct idarr var_list[20];
int pointer = 0;
%}

%token  TOK_PRINT_VAR TOK_PRINT TOK_MAIN
        TOK_INT TOK_FLOAT
        TOK_LBRACE TOK_RBRACE TOK_SEMICOLON
        TOK_ASSIGN TOK_ADD TOK_MUL TOK_SUB TOK_DIV
        TOK_INT_NUM TOK_FLOAT_NUM
        TOK_ID TOK_ID_ERR

%union{
	char name[20];
    int int_val;
    float float_val;
}

%type <string> Prog Stmts Stmt 
%type <int_val> TOK_INT_NUM TOK_FLOAT_NUM E
%type <float_val> TOK_INT_NUM TOK_FLOAT_NUM 
%type <name> TOK_ID
%type <name> TOK_ID_ERR
%type <name> TOK_PRINT_VAR
%type <name> TOK_PRINT
%type <name> TOK_MAIN

%start Prog

%left PLUS
%left MULTIPLY



%%

Prog:
	TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE 
    { 
        printf("Valid program\n"); 
    }
;

Stmts: 
    | Stmt TOK_SEMICOLON Stmts
;

Stmt:
    TOK_INT TOK_ID  
    { 
        int var_index = search($2); // read second column and pass to search func

        if(var_index == -1)
            insert($2, 1, "0");
        else {
            char *err = "Identifier already defined - ";
            yyerror(3, err, $2);
        }
    }
    | TOK_INT TOK_ID_ERR 
    {
        char *err = "Invalid Identifier - ";
        yyerror(3, err, $2);
    }

    | TOK_FLOAT TOK_ID 
    { 
        int var_index = search($2);

        if(var_index == -1)
            insert($2, 2, "0.0");
        else {
            char *err = "Identifier already defined - ";
            yyerror(3, err, $2);
        }
    }
    | TOK_FLOAT TOK_ID_ERR 
    {
        char *err = "Invalid Identifier - ";
        yyerror(3, err, $2);
    }

    | TOK_ID TOK_ASSIGN E
    {
        if($3.int_var != 0) {
            
        }
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
    |E TOK_ADD E    
    {

        
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



%%

void insert(char name_, int type_, char value_[])
{
    strcpy(list[pointer].name, name_);
    strcpy(list[pointer].value, value_);
    list[pointer].type = type_
}

void insert_value(char value_[], int index_)
{
    strcpy(var_list[index_].value, value);
}

int search(char name_[])
{
    // find the declared variable
    for(int i=0; i < pointer; i++)
        if(strcmp(var_list[i].name, name_) == 0)
            return i;
            
    // if variable is not declared before, return -1
    return -1; 
}


/*
* col1  col2    col3    col4
* x     =       3       ;
* 
*/
void assign_value(int type_, char col1_[], char col3_[])
{
    bool is_type_checked = false;
    int var_index = search(col1_);

    if(var_index == -1) // variable not declared
    {
        char *errmsg = "Identifier not found - ";
        yyerror(3, errmsg, col1_);
    } else {
        // Type check
        switch(type_) {
            case 0:
                if (var_list[var_index].type == 0) is_type_checked = true;
                break;
            case 1:
                if (var_list[var_index].type == 1) is_type_checked = true;
                break;
        }
        if (is_type_checked)
            insert_value(col3_, var_index);
        else {
            yyerror(3, "Incorrect type error - ", col3_);
        }
    }
}


int yyerror(int type_, char *error_, char token_[])
{
    switch(type_) {
        // case 1:
        //     printf("Syntax Error on line - %d\n%s\n", line_number, error_);
        //     break;

        // Undefined tokens: TOK_SUB and TOK_DIV
        case 2:
            printf("Lexical Error on line - %d : %s\n", line_number, token_);
            break;
        case 3:
            printf("Line - %d: %s%s\n", line_number, error_, token_);
            break;
    }
    // Break the program
    exit(0)
}


int main()
    {
        yyparse();
        return 0;
    }
