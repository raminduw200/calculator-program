%option noyywrap
%{
#include <stdio.h>
#include "calc.tab.h"

int line_number = 1;
%}

digit	([0-9])

%%

"printvar" 	{	return TOK_PRINT_VAR;	}
"print" 	{	return TOK_PRINT;		}

"int" 		{	return TOK_INT;			}
"float" 	{	return TOK_FLOAT;		}

";"	{	return(TOK_SEMICOLON);	}

"="	{	return(TOK_ASSIGN);	}
"+"	{	return(TOK_ADD);	}
"-"	{	return(TOK_SUB);	}
"*"	{	return(TOK_MUL);	}
"/"	{	return(TOK_DIV);	}

[a-zA-Z]	{
		sscanf(yytext, "%c", &yylval.var);
		return TOK_ID;
        }

{digit}+	{
		sscanf(yytext, "%d", &yylval.int_val);
		return TOK_NUM;
		}

[\n] 	{line_number++;}

.	{printf("Invalid character '%c', ignored\n", 
			yytext[0]);
	}

%%

