%{
#include <stdio.h>
#include <stdlib.h>

/* Contadores de tokens */
int keyword_count = 0;
int identifier_count = 0;
int number_count = 0;
int operator_count = 0;
int delimiter_count = 0;
%}

%%

"int"                     { keyword_count++; printf("Keyword: int\n"); }
"return"                  { keyword_count++; printf("Keyword: return\n"); }
[0-9]+                    { number_count++; printf("Number: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*     { identifier_count++; printf("Identifier: %s\n", yytext); }
("="|"\\+"|"\\-"|"\\*"|"/") { operator_count++; printf("Operator: %s\n", yytext); }
(";"|","|"\\("|"\\)"|"\\{"|"\\}") { delimiter_count++; printf("Delimiter: %s\n", yytext); }
[ \t\n]+                { /* Ignorar espacios */ }
.                        { printf("Caracter no reconocido: %s\n", yytext); }

%%

int main(int argc, char **argv) {
    yylex();
    printf("\nConteo de tokens:\n");
    printf("Palabras clave: %d\n", keyword_count);
    printf("Identificadores: %d\n", identifier_count);
    printf("Números: %d\n", number_count);
    printf("Operadores: %d\n", operator_count);
    printf("Delimitadores: %d\n", delimiter_count);
    return 0;
}
