/* 
 * File:   	calc.l
 * Author: 	Ramindu Walgama, Oshani Wikramasinghe
 * Index: 	20001959, 20002149
 * RegNo: 	2020/CS/195, 2020/CS/214
 * Course: 	SCS3211 Compiler Theory
 * Created: Wednesday, 28 June 2023 at 11:11
 */

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
"main()"	{	return TOK_MAIN; 		}

"int" 		{	return TOK_INT;			}
"float" 	{	return TOK_FLOAT;		}

"{"			{	return(TOK_LBRACE);		}
"}"			{	return(TOK_RBRACE);		}
";"			{	return(TOK_SEMICOLON);	}

"="			{	return(TOK_ASSIGN);		}
"+"			{	return(TOK_ADD);		}
"-"			{	return(TOK_SUB);		}
"*"			{	return(TOK_MUL);		}
"/"			{	return(TOK_DIV);		}


{digit}+			{
						yylval.var.int_val = atoi(yytext);
						yylval.var.float_val = 0;
						return TOK_INT_NUM;
					}

{digit}+"."{digit}+	{
						yylval.var.float_val = atof(yytext);
						yylval.var.int_val = 0;
						return TOK_FLOAT_NUM;
					}

[a-z][A-Za-z0-9]*	{sscanf(yytext, "%s", &yylval.name);return TOK_ID;}
([0-9])[A-Za-z0-9]*	{sscanf(yytext, "%s", &yylval.name);return TOK_ID_ERR;}



[\n] 	{line_number++;}
[ \t] 	{/* ignore whitespace */}

.		{
			printf("Invalid character '%c', ignored\n", 
			yytext[0]);
		}

%%

/* 
 * References: 
 *  - https://docs.oracle.com/cd/E19504-01/802-5880/lex-6/index.html
 */