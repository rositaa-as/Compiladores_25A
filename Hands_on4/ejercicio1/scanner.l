%{
#include "parser.tab.h"
%}
%%
[ \t\n]+        ;           /* ignora espacios, tab, newline */
"int"           return INT;
[a-zA-Z_][a-zA-Z0-9_]* {
                  yylval.str = strdup(yytext);
                  return ID;
                }
"="             return IGUAL;
";"             return PUNTOYCOMA;
.               return yytext[0];
%%
