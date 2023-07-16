%option noyywrap
%{
#include <stdio.h>
#include "calc.tab.h"

int line_number = 1;
%}

digit	([0-9])

%%
"printvar"	{	return(TOK_PRINT_VAR);	}
"print"     {	return(TOK_PRINT);		}
"main()"    {	return(TOK_MAIN);		}

"int"		{	return(TOK_INT);		}
"float"		{	return(TOK_FLOAT);		}

"{"        	{	return(TOK_LBRACE);		}
"}"        	{	return(TOK_RBRACE);		}
";"			{	return(TOK_SEMICOLON);	}

"="			{	return(TOK_ASSIGN);		}
"+"			{	return(TOK_ADD);		}
"-"			{	return(TOK_SUB);		}
"*"			{	return(TOK_MUL);		}
"/"			{	return(TOK_DIV);		}

{digit}+				{
							yylval.var.int_val = atoi(yytext); 
							yylval.var.float_val = 0; 
							return TOK_NUM; 
						}

{digit}+[.]{digit}+ 	{
							yylval.var.int_val = 0; 
							yylval.var.float_val = atof(yytext); 
							return TOK_FNUM; 
						}

[a-z][A-Za-z0-9]*   	{	sscanf(yytext, "%s", yylval.name); return(TOK_IDENT);		}
([0-9])[A-Za-z0-9]* 	{	sscanf(yytext, "%s", yylval.name); return(TOK_IDENT_ERR);	}	


[\n] 	{line_number++;}
[" "] 	{/* ignore whitespace */}
[\t] 	{/* ignore whitespace */}

.	{
		printf("Invalid character '%c', ignored\n", 
		yytext[0]);
	}

%%

