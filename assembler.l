%option noyywrap

%{
#include "assembler.tab.h"
extern YYSTYPE yylval;
%}

%%
x[0-9]+             yylval.l = strtol(yytext + 1, NULL, 10); return REGISTER;
0b[0-1]+            yylval.l = strtol(yytext + 2, NULL, 2); return IMMEDIATE;
0[0-7]+             yylval.l = strtol(yytext + 1, NULL, 8); return IMMEDIATE;
0x[0-9A-Fa-f]+      yylval.l = strtol(yytext + 2, NULL, 16); return IMMEDIATE;
[0-9]+              yylval.l = strtol(yytext, NULL, 10); return IMMEDIATE;
\r?\n               return NEWLINE;
\(                  return LEFT_PAREN;
\)                  return RIGHT_PAREN;
,                   return COMMA;
-                   return MINUS;
add                 return ADD;
sub                 return SUB;
addi                return ADDI;
slli                return SLLI;
lw                  return LW;
sw                  return SW;
beq                 return BEQ;
j                   return J;
auipc               return AUIPC;
[ \t]+              ;
%%

