/* parser.y */
%debug
%define parse.error verbose

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}

/* Variables globales */
char *cur_fun_name;
int   cur_fun_params;

#define MAXP 50
char *param_names[MAXP];
int   param_count;

#define MAX 200
typedef struct {
    char *id;
    int   tipo;    /* 0=var, 1=func */
    int   aridad;  
    int   amb;     
} Sim;
Sim tabla[MAX];
int ntabla = 0, amb = 0;

/* Manejo de ámbito */
void entrar() { amb++; }
void salir() {
    for (int i = 0; i < ntabla; ++i) {
        if (tabla[i].id && tabla[i].amb == amb) {
            free(tabla[i].id);
            tabla[i].id = NULL;
        }
    }
    amb--;
}

/* Inserta parámetro sin chequear redeclaraciones */
void agregar_param(char *id) {
    if (param_count < MAXP)
        param_names[param_count++] = strdup(id);
    tabla[ntabla++] = (Sim){ strdup(id), 0, 0, amb };
}

/* Inserta variable local, detecta shadowing y redeclaración */
void agregar_var(char *id) {
    /* Shadowing de parámetro */
    if (amb > 1) {
        for (int i = 0; i < param_count; i++) {
            if (strcmp(param_names[i], id) == 0) {
                printf("Error: redeclaración de parámetro '%s'\n", id);
                break;  /* ¡sin return! seguimos para insertar */
            }
        }
    }
    /* Redeclaración en mismo nivel */
    for (int i = 0; i < ntabla; ++i) {
        if (tabla[i].id
         && tabla[i].tipo == 0
         && tabla[i].amb == amb
         && strcmp(tabla[i].id, id) == 0)
        {
            printf("Error: redeclaración de '%s'\n", id);
            return;
        }
    }
    tabla[ntabla++] = (Sim){ strdup(id), 0, 0, amb };
}

/* Inserta función en global, detecta redeclaración */
void agregar_fun(char *id, int a) {
    for (int i = 0; i < ntabla; ++i) {
        if (tabla[i].id
         && tabla[i].tipo == 1
         && tabla[i].amb == 0
         && strcmp(tabla[i].id, id) == 0)
        {
            printf("Error: función '%s' ya declarada\n", id);
            return;
        }
    }
    tabla[ntabla++] = (Sim){ strdup(id), 1, a, 0 };
    for (int i = 0; i < param_count; i++)
        free(param_names[i]);
    param_count = 0;
}

/* Búsqueda de variable */
int buscar_var(char *id) {
    for (int nivel = amb; nivel >= 0; --nivel)
        for (int i = 0; i < ntabla; ++i)
            if (tabla[i].id
             && tabla[i].tipo == 0
             && tabla[i].amb == nivel
             && strcmp(tabla[i].id, id) == 0)
                return 1;
    return 0;
}

/* Búsqueda de función */
int buscar_fun(char *id) {
    for (int i = 0; i < ntabla; ++i)
        if (tabla[i].id
         && tabla[i].tipo == 1
         && strcmp(tabla[i].id, id) == 0)
            return tabla[i].aridad;
    return -1;
}
%}

/* Semántica */
%union { char *str; int num; }
%token <str> ID
%token <num> NUM
%token INT FUNC RETURN
%token PARIZQ PARDER LLAVEIZQ LLAVEDER COMA PUNTOYCOMA IGUAL
%type <num> parametros lista_param argumentos lista_arg expr

%%

programa:
    bloque
  ;

bloque:
    LLAVEIZQ  { entrar(); }
      elementos
    LLAVEDER  { salir(); }
  ;

elementos:
  | elementos elemento
  ;

elemento:
    INT ID PUNTOYCOMA
      { agregar_var($2); }

  | FUNC ID PARIZQ param_scope PARDER body_scope
      {
        cur_fun_name   = strdup($2);
        agregar_fun(cur_fun_name, cur_fun_params);
        free(cur_fun_name);
      }

  | instruccion
  ;

instruccion:
    INT ID PUNTOYCOMA
      { agregar_var($2); }

  | ID IGUAL expr PUNTOYCOMA
      {
        if (!buscar_var($1))
          printf("Error: identificador no declarado en '%s'\n", $1);
      }

  | ID PARIZQ argumentos PARDER PUNTOYCOMA
      {
        int esp = buscar_fun($1);
        if (esp < 0)
          printf("Error: función '%s' no declarada\n", $1);
        else if (esp != $3)
          printf("Error: función '%s' espera %d argumentos\n", $1, esp);
      }

  | RETURN ID PUNTOYCOMA
      {
        if (!buscar_var($2))
          printf("Error: identificador no declarado en return\n");
      }

  | bloque
  ;

expr:
    ID
      {
        if (!buscar_var($1)) {
          printf("Error: identificador no declarado en '%s'\n", $1);
          $$ = 0;
        } else {
          $$ = 1;
        }
      }
  | NUM { $$ = 1; }
  ;

param_scope:
    { entrar(); param_count = 0; }
    parametros
    { cur_fun_params = $2; salir(); }
  ;

body_scope:
    { entrar(); }
    bloque
    { salir(); }
  ;

parametros:
    { $$ = 0; }
  | lista_param { $$ = $1; }
  ;

lista_param:
    ID
      { agregar_param($1); $$ = 1; }
  | lista_param COMA ID
      { agregar_param($3); $$ = $1 + 1; }
  ;

argumentos:
    { $$ = 0; }
  | lista_arg { $$ = $1; }
  ;

lista_arg:
    expr { $$ = 1; }
  | lista_arg COMA expr { $$ = $1 + 1; }
  ;

%%

int main(void) {
#ifdef YYDEBUG
//    yydebug = 1;
#endif
    return yyparse();
}
