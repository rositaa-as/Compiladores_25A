%{
#include <stdio.h>
%}

%%

"int"                     { printf("Keyword: int\n"); }
"return"                  { printf("Keyword: return\n"); }
[0-9]+                    { printf("Number: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*     { printf("Identifier: %s\n", yytext); }
[ \t\n]+                 { /* Ignorar espacios y saltos de línea */ }
.                         { printf("Caracter no reconocido: %s\n", yytext); }

%%

int main(int argc, char **argv) {
    yylex();
    return 0;
}
