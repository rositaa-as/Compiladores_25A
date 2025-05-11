%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
int yyerror(char *s) { fprintf(stderr, "Error: %s\n", s); return 0; }

#define MAX 100
char *tabla[MAX];
int ntabla = 0;

void declarar(char *id) {
  for (int i = 0; i < ntabla; i++)
    if (strcmp(tabla[i], id) == 0)
      return;
  tabla[ntabla++] = strdup(id);
}

int existe(char *id) {
  for (int i = 0; i < ntabla; i++)
    if (strcmp(tabla[i], id) == 0)
      return 1;
  return 0;
}
%}

%union { char *str; }
%token <str> ID
%token INT IGUAL PUNTOYCOMA

%%
programa:
    declaraciones
  ;

declaraciones:
    declaracion
  | declaraciones declaracion
  ;

declaracion:
    INT ID PUNTOYCOMA
      { declarar($2); }
  | ID IGUAL ID PUNTOYCOMA
      {
        if (!existe($1) || !existe($3))
          printf("Error: identificador no declarado\n");
      }
  ;
%%
int main() { return yyparse(); }
