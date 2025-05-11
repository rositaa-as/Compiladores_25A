%{
#include <stdio.h>  // Para impresión en consola
#include <stdlib.h> // Para memoria dinámica
#include <string.h> // Para manejo de cadenas

int yylex(void);    // Función léxica
int yyparse(void);  // Función sintáctica
int yyerror(char *s) { printf("Error: %s\n", s); return 0; } // Errores sintácticos

#define MAX_SCOPE 10
#define MAX_ID 100
char *ambitos[MAX_SCOPE][MAX_ID] = {{0}}; // Tabla para múltiples niveles de ámbito
int niveles[MAX_SCOPE] = {0}; // Conteo de variables por nivel
int tope = 0; // Índice del ámbito actual

void entrar_ambito() {
    if (tope + 1 >= MAX_SCOPE) {
        printf("Error: demasiados ámbitos anidados\n");
        exit(1);
    }
    tope++;
    niveles[tope] = 0;
}

void salir_ambito() {
    for (int j = 0; j < niveles[tope]; j++) {
        free(ambitos[tope][j]); // Libera cada identificador
        ambitos[tope][j] = NULL;
    }
    niveles[tope] = 0;
    tope--;
}

void agregar_local(char *id) {
    if (niveles[tope] >= MAX_ID) {
        printf("Error: demasiadas variables en el ámbito actual\n");
        exit(1);
    }
    ambitos[tope][niveles[tope]++] = strdup(id);
}

int buscar_local(char *id) {
    for (int i = tope; i >= 0; i--) {
        for (int j = 0; j < niveles[i]; j++) {
            if (strcmp(ambitos[i][j], id) == 0) return 1; // Encuentra en ámbito
        }
    }
    return 0; // No encontrado
}

void liberar_memoria() {
    for (int i = 0; i <= tope; i++) {
        for (int j = 0; j < niveles[i]; j++) {
            free(ambitos[i][j]);
            ambitos[i][j] = NULL;
        }
        niveles[i] = 0;
    }
    tope = 0;
}
%}

%union { char *str; } // Asociación de tipo
%token <str> ID
%token INT LLAVEIZQ LLAVEDER PUNTOYCOMA

%%
programa:
	    /* vacío */ // Permitir programa vacío
  | instrucciones // Permitir una secuencia de instrucciones o bloques
    ;

bloque:
          LLAVEIZQ { entrar_ambito(); } instrucciones LLAVEDER { salir_ambito(); }
    ;

instrucciones:
	         /* vacío */ // Permitir bloques vacíos
  | instrucciones instruccion
    ;

instruccion:
	       INT ID PUNTOYCOMA { agregar_local($2); } // Declaración de variable
  | ID PUNTOYCOMA {
        if (!buscar_local($1))
            printf("Error semántico: '%s' no está declarado\n", $1);
    } // Uso de variable
  | bloque // Bloque anidado
    ;
%%

int main() {
    int result = yyparse();
    liberar_memoria();
    return result;
}
