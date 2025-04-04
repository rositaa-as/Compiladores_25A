%{
#include <stdio.h>
#include <stdlib.h>
/* Declaración para manejo de estados */
%}

%x COMMENT

%%

"int"                     { printf("Keyword: int\n"); }
"return"                  { printf("Keyword: return\n"); }
[0-9]+                    { printf("Number: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*     { printf("Identifier: %s\n", yytext); }
"//".*                   { printf("Comentario de línea: %s\n", yytext); }
"/*"                     { BEGIN(COMMENT); }
<COMMENT>[^*]+           { /* Se consume contenido dentro del comentario */ }
<COMMENT>"*"+([^/][^*]*)? { /* Manejando casos intermedios */ }
<COMMENT>"*/"            { BEGIN(INITIAL); printf("Fin de comentario multilínea\n"); }
\"([^\\\"]|\\.)*\"       { printf("Cadena: %s\n", yytext); }
[ \t\n]+                { /* Ignorar espacios y saltos de línea */ }
.                        { printf("Caracter no reconocido: %s\n", yytext); }

%%

int main(int argc, char **argv) {
    yylex();
    return 0;
}
