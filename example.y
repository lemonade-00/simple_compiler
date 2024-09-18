
%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);

struct Polynomial {
    int coefficient;
    int exponent;
    struct Polynomial* next;
};
struct Polynomial* create_polynomial(int coefficient, int exponent) {
    struct Polynomial* poly = (struct Polynomial*)malloc(sizeof(struct Polynomial));
    poly->coefficient = coefficient;
    poly->exponent = exponent;
    poly->next = NULL;
    return poly;
}
struct Polynomial* create_negpolynomial(int coefficient, int exponent) {
    struct Polynomial* poly = (struct Polynomial*)malloc(sizeof(struct Polynomial));
    poly->coefficient = coefficient*-1;
    poly->exponent = exponent;
    poly->next = NULL;
    return poly;
}

struct Polynomial* add_polynomials(struct Polynomial* p1, struct Polynomial* p2) {
    struct Polynomial dummy;
    struct Polynomial* tail = &dummy;
    dummy.next = NULL;

    while (p1 && p2) {
        if (p1->exponent > p2->exponent) {
            tail->next = create_polynomial(p1->coefficient, p1->exponent);
            p1 = p1->next;
        } else if (p1->exponent < p2->exponent) {
            tail->next = create_polynomial(p2->coefficient, p2->exponent);
            p2 = p2->next;
        } else {
            int coefficient = p1->coefficient + p2->coefficient;
            if (coefficient != 0) {
                tail -> next = create_polynomial(coefficient, p1 -> exponent);
            }
            p1 = p1->next;
            p2 = p2->next;
        }
        if (tail->next) tail = tail->next;
    }

    tail->next = p1 ? p1 : p2;

    return dummy.next;
}

struct Polynomial * minus_polynomials(struct Polynomial * p1, struct Polynomial * p2) {
    struct Polynomial clone;
    struct Polynomial * cloneTail = &clone;
    clone.next = NULL;
    p2 -> coefficient = p2 -> coefficient * -1;
    while (p1 && p2) {
        if (p1 -> exponent > p2 -> exponent) {
            cloneTail -> next = create_polynomial(p1 -> coefficient, p1 -> exponent);
            p1 = p1 -> next;
        } else if (p1 -> exponent < p2 -> exponent) {
            cloneTail -> next = create_polynomial(p2 -> coefficient, p2 -> exponent);
            p2 = p2 -> next;
        } else {
            int coefficient = p1 -> coefficient + p2 -> coefficient;
            if (coefficient != 0) {
                cloneTail -> next = create_polynomial(coefficient, p1 -> exponent);
            }
            p1 = p1 -> next;
            p2 = p2 -> next;
        }
        if (cloneTail -> next) cloneTail = cloneTail -> next;
    }

    
    cloneTail -> next = p1 ? p1: p2;

    return clone.next;
}

void print_polynomial(struct Polynomial * poly) {
    if (poly){
        while (poly) {
            if (poly -> coefficient < 0){
                printf(" - ");
                poly -> coefficient = poly -> coefficient*-1;
            }
            if ((poly -> coefficient != 1 && poly -> coefficient != -1) || poly -> exponent == 0) {
                printf("%d", poly -> coefficient);
            }
            if (poly -> exponent != 0) {
                printf("x");
                if (poly -> exponent != 1) {
                    printf("^%d", poly -> exponent);
                }
            }
            poly = poly -> next;
            if (poly && poly -> coefficient > 0) {
                printf(" + ");
            }
        }
    }else {
        printf(" 0 ");
    }

    printf("\n");
}
%}

%token <num>NUMBER X PLUS EXP MINUS
%token EOL

%left PLUS
%right EXP

%union {
    int num;
    struct Polynomial* poly;
}

%type <poly> expression term factor

%%
calclist:
    | calclist expression EOL{ print_polynomial($2); }
    ;

expression:
      expression PLUS term { $$ = add_polynomials($1, $3); }
    | expression MINUS term { $$ = minus_polynomials($1, $3); }
    | term { $$ = $1; }
    ;

term:
      factor { $$ = $1; }
    ;

factor:
      NUMBER X EXP NUMBER { $$ = create_polynomial($1, $4); }
    | X EXP NUMBER { $$ = create_polynomial(1, $3); }
    | NUMBER X { $$ = create_polynomial($1, 1); }
    | X { $$ = create_polynomial(1, 1); }
    | NUMBER { $$ = create_polynomial($1, 0); }
    | MINUS NUMBER { $$ = create_negpolynomial($2, 0); }
    | MINUS X { $$ = create_negpolynomial(1, 1); }
    | MINUS NUMBER X { $$ = create_negpolynomial($2, 1); }
    | MINUS X EXP NUMBER { $$ = create_negpolynomial(1, $4); }
    | MINUS NUMBER X EXP NUMBER { $$ = create_negpolynomial($2, $5); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    return yyparse();
}
