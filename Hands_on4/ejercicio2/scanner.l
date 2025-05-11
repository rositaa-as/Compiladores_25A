%{
#include "parser.tab.h"
%}
%%
[ \t\n]+               ;               /* ignora espacios, tab y newline */
"int"                  return INT;
[a-zA-Z_][a-zA-Z0-9_]* {
                         yylval.str = strdup(yytext);
                         return ID;
                       }
[0-9]+                 {
                         yylval.num = atoi(yytext);
                         return NUMBER;
                       }
"="                    return IGUAL;
";"                    return PUNTOYCOMA;
.                      return yytext[0];
%%
