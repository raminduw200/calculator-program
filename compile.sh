#!/bin/bash

flex calc.l

bison -d calc.y

gcc lex.yy.c calc.tab.c -o calculator 

./calculator