%option yylineno

%{
    #include <stdlib.h>
    #include <string.h>
    #include "syntax.tab.h"

    int yycolumn = 1;
    int is_lexical_error = 0;
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_column = yycolumn + yyleng - 1; \
        yycolumn += yyleng;

    #define ADD_LEXICAL_UNIT(TOKEN) \
        yylval.mt_node = (mtNode *)malloc(sizeof(mtNode)); \
        yylval.mt_node->type = LU; \
        yylval.mt_node->text = (char *)malloc((strlen(#TOKEN) + 1) * sizeof(char)); \
        strcpy(yylval.mt_node->text, #TOKEN); \
        yylval.mt_node->lineno = yylineno; \
        yylval.mt_node->father = NULL; \
        yylval.mt_node->child_max = 0; \
        yylval.mt_node->child = NULL;

    #define EXTRA \
        yylval.mt_node->extra = (char *)malloc((strlen(yytext) + 1) * sizeof(char)); \
        strcpy(yylval.mt_node->extra, yytext);


%}

digit    [0-9]
p_digit  [1-9]
letter   [_a-zA-Z]
identify [0-9_a-zA-Z]
dot      \.
nl       \n
ws       [ \t\r]
%%
"+"                                       {
                                             ADD_LEXICAL_UNIT(PLUS)
                                             return PLUS;
                                          }
"-"                                       {
                                             ADD_LEXICAL_UNIT(MINUS)
                                             return MINUS;
                                          }
"*"                                       {
                                             ADD_LEXICAL_UNIT(STAR)
                                             return STAR;
                                          }
"/"                                       {
                                             ADD_LEXICAL_UNIT(DIV)
                                             return DIV;
                                          }
"="                                       {
                                             ADD_LEXICAL_UNIT(ASSIGNOP)
                                             return ASSIGNOP;
                                          }
";"                                       {
                                             ADD_LEXICAL_UNIT(SEMI)
                                             return SEMI;
                                          }
","                                       {
                                             ADD_LEXICAL_UNIT(COMMA)
                                             return COMMA;
                                          }
"."                                       {
                                             ADD_LEXICAL_UNIT(DOT)
                                             return DOT;
                                          }
"&&"                                      {
                                             ADD_LEXICAL_UNIT(AND)
                                             return AND;
                                          }
"||"                                      {
                                             ADD_LEXICAL_UNIT(OR)
                                             return OR;
                                          }
"!"                                       {
                                             ADD_LEXICAL_UNIT(NOT)
                                             return NOT;
                                          }
"("                                       {
                                             ADD_LEXICAL_UNIT(LP)
                                             return LP;
                                          }
")"                                       {
                                             ADD_LEXICAL_UNIT(RP)
                                             return RP;
                                          }
"["                                       {
                                             ADD_LEXICAL_UNIT(LB)
                                             return LB;
                                          }
"]"                                       {
                                             ADD_LEXICAL_UNIT(RB)
                                             return RB;
                                          }
"{"                                       {
                                             ADD_LEXICAL_UNIT(LC)
                                             return LC;
                                          }
"}"                                       {
                                             ADD_LEXICAL_UNIT(RC)
                                             return RC;
                                          }
">"|"<"|">="|"<="|"=="|"!="               {
                                             ADD_LEXICAL_UNIT(RELOP)
                                             return RELOP;
                                          }

"struct"                                  {
                                             ADD_LEXICAL_UNIT(STRUCT)
                                             return STRUCT;
                                          }
"return"                                  {
                                              ADD_LEXICAL_UNIT(RETURN)
                                              return RETURN;
                                          }
"if"                                      {
                                              ADD_LEXICAL_UNIT(IF)
                                              return IF;
                                          }
"else"                                    {
                                              ADD_LEXICAL_UNIT(ELSE)
                                              return ELSE;
                                          }
"while"                                   {
                                              ADD_LEXICAL_UNIT(WHILE)
                                              return WHILE;
                                          }
"int"|"float"                             {
                                              ADD_LEXICAL_UNIT(TYPE)
                                              EXTRA
                                              return TYPE;
                                          }

{nl}  { yycolumn = 1; }
{ws}+
{letter}({letter}|{digit}){0,31}                {
                                               ADD_LEXICAL_UNIT(ID)
                                               EXTRA
                                               return ID;
                                           }
{digit}|({p_digit}{digit}*)                {
                                               ADD_LEXICAL_UNIT(INT)
                                               EXTRA
                                               return INT;
                                           }
({digit}|({p_digit}{digit}*)[.])?{digit}+  {
                                               ADD_LEXICAL_UNIT(FLOAT)
                                               EXTRA
                                               return FLOAT;
                                           }

"//"[^\n]*|"\/\*".*"\*\/"                 /* COMMENT_A */
"/*"([^*]|\*+[^*/])*\*+"/"                /* COMMENT_B */

{identify}+                               { printf("Error type A at Line %d: Mysterious characters \'%s\'\n", yylineno, yytext); is_lexical_error = 1; }
.                                         { printf("Error type A at Line %d: Mysterious characters \'%s\'\n", yylineno, yytext); is_lexical_error = 1; }
%%
