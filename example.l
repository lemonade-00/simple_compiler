%{
#include "example.tab.h"
%}

%%
[0-9]+      { yylval.num = atoi(yytext); return NUMBER; }
"x"         { return X; }
"X"         { return X; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"^"         { return EXP; }
[ \t] 	{/*空白忽略*/}
\n  	{return EOL;}
.           { printf("invalid input %c\n",*yytext); }
%%

int yywrap() {
    return 1;
}
