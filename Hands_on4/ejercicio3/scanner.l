%{
#include "parser.tab.h"
%}
%%
[ \t\n]+        ;  /* ignora espacios, tab, newline */
"func"          return FUNC;
"("             return PARIZQ;
")"             return PARDER;
","             return COMA;
";"             return PUNTOYCOMA;
[a-zA-Z_][a-zA-Z0-9_]* {
                  yylval.str = strdup(yytext);
                  return ID;
                }
.               return yytext[0];
%%
