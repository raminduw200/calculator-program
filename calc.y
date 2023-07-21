%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_number;
extern FILE* yyin;

int yylex();
int search(char var_name_[]);
void insert(char name_[], int type_, char value_[]);
int yyerror(char *s);
void yyerror2(int type_, char *error_, char token_[]);
void insert_value(char value_[], int index_);
void assign_value(int type_, char col1_[], char col3_[]);

struct idarr{
	char name[20];
	int type; // 0 -> int, 1 -> float
	char value[20];
};

int pointer = 0;
struct idarr var_list[20];

%}

%token  TOK_SEMICOLON
		TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_ASSIGN
	    TOK_INT TOK_FLOAT TOK_IDENT
		TOK_PRINT_VAR TOK_PRINT TOK_EXIT TOK_MAIN TOK_LBRACE TOK_RBRACE
		TOK_IDENT_ERR
%token <var> TOK_NUM TOK_FNUM

%union{
	char name[20];
	struct var_struct{
		int int_val;
		float float_val;
	}var;
}


%type <var> E
%type <name> TOK_IDENT
%type <name> TOK_IDENT_ERR

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

Prog:
	TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE
	| {
		yyerror2(2,"Parsing Error","");
	}
;

Stmts:
	| Stmt TOK_SEMICOLON Stmts
;

Stmt:
	TOK_INT TOK_IDENT 
		{
			int index_ = search($2);

			if(index_ == -1){
				insert($2, 0, "0");
			} else {
				yyerror2(2,"Identifier already defined - ", $2);
			}
		}
	| TOK_INT TOK_IDENT_ERR
		{
			yyerror2(2,"Invalid Identifier - ",$2);
		}
	| TOK_FLOAT TOK_IDENT 
		{
			int index_ = search($2);

			if(index_ == -1){
				insert($2, 1, "0.0");
			} else {
				yyerror2(2,"Identifier already defined - ",$2);
			}
		}
	| TOK_FLOAT TOK_IDENT_ERR
		{
			yyerror2(2,"Invalid Identifier - ",$2);
		}
	| TOK_IDENT TOK_ASSIGN E
	  {
		int type_;
		char val_[15];
		if($3.int_val != 0) {
			type_ = 0;
			sprintf(val_, "%d", $3.int_val);
		}else if($3.float_val != 0){
			type_ = 1;
			sprintf(val_, "%f", $3.float_val);
		}
		assign_value(type_, $1, val_);
	  }
	| TOK_PRINT_VAR TOK_IDENT
	  {
		int index_ = search($2);

		if(index_ == -1){
			yyerror2(2," is used but not declared.", $2);
		} else {
			printf("%s\n", var_list[index_].value);
		}
	  }
	| TOK_PRINT E 
	{
		if($2.int_val != 0){
			printf("%d", $2.int_val);
		} else {
			printf("%f", $2.float_val);
		}
	}
;


E:
	E TOK_SUB E
	  {
		yyerror2(1," - ", NULL);
	  }
	|
	E TOK_DIV E
	  {
		yyerror2(1," / ", NULL);
	  }
	| E TOK_ADD E
	  {
		struct var_struct temp2;

		if($1.int_val != 0 && $3.int_val != 0) {
			temp2.float_val = 0;
			temp2.int_val = $1.int_val + $3.int_val;
		}else if($1.float_val != 0 && $3.float_val != 0) {
			temp2.int_val = 0;
			temp2.float_val = $1.float_val + $3.float_val;
		}else {
			yyerror2(2,"Type mismatch", "");
		}
		
		$$ = temp2;

	  }
	| E TOK_MUL E
	  {
		struct var_struct temp;

		if($1.int_val != 0 && $3.int_val != 0) {
			temp.float_val = 0;
			temp.int_val = $1.int_val * $3.int_val;
		} else if($1.float_val != 0 && $3.float_val != 0) {
			temp.int_val = 0;
			temp.float_val = $1.float_val * $3.float_val;
		} else {
			yyerror2(2,"Type mismatch", "");
		}
		
		$$ = temp;
	  }
	| TOK_IDENT
	  {
		int index_ = search($1);
		
		struct var_struct temp;

		if(index_ == -1){
			yyerror2(2, " is used but not declared.", $1);
		} else {
			if(var_list[index_].type == 0){
				temp.int_val = atoi(var_list[index_].value);
				temp.float_val = 0;
			} else {
				temp.int_val = 0;
				temp.float_val = atof(var_list[index_].value);
			}
		}
		
		$$ = temp;
	  }
	| TOK_NUM
	{
		$$ = $1;
	}
	| TOK_FNUM
	{
		$$ = $1;
	}
;


%%

void insert(char name_[], int type_, char value_[])
{
	strcpy(var_list[pointer].name, name_);
	strcpy(var_list[pointer].value, value_);
	var_list[pointer++].type = type_;
}

void insert_value(char value_[], int index_)
{
	strcpy(var_list[index_].value, value_);
}

int search(char var_name_[])
{
    // find the declared variable
    for(int i=0; i < pointer; i++)
        if(strcmp(var_list[i].name, var_name_) == 0)
            return i;
            
    // if variable is not declared before, return -1
    return -1; 
}

void assign_value(int type_, char col1_[], char col3_[])
{
    int is_type_checked = 0;
    int var_index = search(col1_);

    if(var_index == -1) { // variable not declared
        yyerror2(2, "Identifier not found - ", col1_);
    } else {
        // Type check
        switch(type_) {
            case 0:
                if (var_list[var_index].type == 0) is_type_checked = 1;
                break;
            case 1:
                if (var_list[var_index].type == 1) is_type_checked = 1;
                break;
        }
        if (is_type_checked){
            insert_value(col3_, var_index);
        } else {
            yyerror2(2, "Incorrect type error - ", col3_);
		}    
	}
}

int yyerror(char *s)
{
	printf("Syntax Error on line %d\n%s\n",line_number, s);
	return 0;
}

void yyerror2(int type_, char *error_, char token_[])
{
	switch(type_){
		case 1:
			printf("Lexical Error on line - %d: %s\n",line_number, error_);
			break;
		case 2:
			printf("Line - %d: %s%s\n",line_number, error_, token_);
			break;
	}
	exit(0);
}

int main(int argc , char **argv)
{
	if(argc > 1) {
		yyin = fopen(argv[1], "r");
		if(!yyin) {
			printf("File not found\n");
			return 1;
		}
	}
    yyparse();
    return 0;
}
