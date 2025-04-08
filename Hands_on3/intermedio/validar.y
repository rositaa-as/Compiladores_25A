%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
int yyerror(char *s);
int yywrap(void);
%}

%token BOOLEAN
%left AND OR
%right NOT

%%
input:
      expr '\n'      { printf("Expresión válida\n"); }
    | error '\n'     { yyerror("Expresión inválida"); yyerrok; }
    ;

expr:
      expr AND expr
    | expr OR expr
    | NOT expr      %prec NOT
    | '(' expr ')'
    | BOOLEAN
    ;
%%

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}

int yywrap(void) { return 1; }
int main(void) {
    return yyparse();
}
