%{
#include "validar.tab.h"
%}

%%
"AND"       { return AND; }
"OR"        { return OR; }
"NOT"       { return NOT; }
[01]        { yylval = yytext[0] - '0'; return BOOLEAN; }
[0-9]+      { yylval = atoi(yytext); return NUMBER; }
[ \t]
[\n]        { return '\n'; }
[+\-*/()]   { return yytext[0]; }
.           { return yytext[0]; }
%%
