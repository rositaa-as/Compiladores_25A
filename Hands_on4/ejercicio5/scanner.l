/* scanner.l */
%{
#include "parser.tab.h"
%}
%%
[ \t\n]+            ;               /* Ignora espacios y saltos de línea */
"int"               return INT;
"func"              return FUNC;
"return"            return RETURN;
"("                 return PARIZQ;
")"                 return PARDER;
"{"                 return LLAVEIZQ;
"}"                 return LLAVEDER;
","                 return COMA;
";"                 return PUNTOYCOMA;
"="                 return IGUAL;
[a-zA-Z_][a-zA-Z0-9_]* {
                      yylval.str = strdup(yytext);
                      return ID;
                    }
[0-9]+             {
                    yylval.num = atoi(yytext);
                    return NUM;
                   }
.                   { printf("Error: carácter no reconocido '%s'\n", yytext); }
%%
