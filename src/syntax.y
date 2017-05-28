%locations
%{
    #include <stdarg.h>
    #include "common.h"
    #include "lex.yy.c"


    int is_grammar_error = 0;


    mtNode *root;
    static mtNode *mtChild(char *, int, int, mtNode*, ...);
    static void mt_p(mtNode *, int);
    void mt_print();
    static void yyerror(char *);
%}

%code requires {
    #include "dS/mtNode.h"
}

%union {
    mtNode *mt_node;
}

%token <mt_node> INT
%token <mt_node> FLOAT
%token <mt_node> ID
%token <mt_node> SEMI
%token <mt_node> COMMA
%token <mt_node> ASSIGNOP
%token <mt_node> RELOP
%token <mt_node> PLUS
%token <mt_node> MINUS
%token <mt_node> STAR
%token <mt_node> DIV
%token <mt_node> AND
%token <mt_node> OR
%token <mt_node> DOT
%token <mt_node> NOT
%token <mt_node> TYPE
%token <mt_node> LP
%token <mt_node> RP
%token <mt_node> LB
%token <mt_node> RB
%token <mt_node> LC
%token <mt_node> RC
%token <mt_node> STRUCT
%token <mt_node> RETURN
%token <mt_node> IF
%token <mt_node> ELSE
%token <mt_node> WHILE


%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%left NOT
%left LP RP LB RB DOT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <mt_node> Program ExtDefList ExtDef ExtDecList Specifier StructSpecifier
%type <mt_node> OptTag Tag VarDec FunDec VarList ParamDec CompSt StmtList Stmt
%type <mt_node> DefList Def DecList Dec Exp Args

%start Program
%%
Program: ExtDefList     { $$ = mtChild("Program", @1.first_line, 1, $1); root = $$; }
       ;

ExtDefList: ExtDef ExtDefList   { $$ = mtChild("ExtDefList", @1.first_line, 2, $1, $2); }
          | { $$ = mtChild("Epsilon", 0, 0, NULL); }
          ;

ExtDef: Specifier ExtDecList SEMI   { $$ = mtChild("ExtDef", @1.first_line, 3, $1, $2, $3); }
      | Specifier SEMI  { $$ = mtChild("ExtDef", @1.first_line, 2, $1, $2); }
      | Specifier FunDec CompSt     { $$ = mtChild("ExtDef", @1.first_line, 3, $1, $2, $3); }
      ;

ExtDecList: VarDec  { $$ = mtChild("ExtDecList", @1.first_line, 1, $1); }
          | VarDec COMMA ExtDecList     { $$ = mtChild("ExtDecList", @1.first_line, 3, $1, $2, $3); }
          ;

Specifier: TYPE     { $$ = mtChild("Specifier", @1.first_line, 1, $1); }
         | StructSpecifier  { $$ = mtChild("Specifier", @1.first_line, 1, $1); }
         ;

StructSpecifier: STRUCT OptTag LC DefList RC    { $$ = mtChild("StructSpecifier", @1.first_line, 5, $1, $2, $3, $4, $5); }
               | STRUCT Tag     { $$ = mtChild("StructSpecifier", @1.first_line, 2, $1, $2); }
               ;

OptTag: ID  { $$ = mtChild("OptTag", @1.first_line, 1, $1); }
      | { $$ = mtChild("Epsilon", 0, 0, NULL); }
      ;

Tag: ID     { $$ = mtChild("Tag", @1.first_line, 1, $1); }
   ;

VarDec: ID  { $$ = mtChild("VarDec", @1.first_line, 1, $1); }
      | VarDec LB INT RB    { $$ = mtChild("VarDec", @1.first_line, 4, $1, $2, $3, $4); }
      | error LB       { yyclearin; yyerrok; $$ = mtChild("Epsilon", 0, 0, NULL); is_grammar_error = 1; }

      ;

FunDec: ID LP VarList RP    { $$ = mtChild("FunDec", @1.first_line, 4, $1, $2, $3, $4); }
      | ID LP RP    { $$ = mtChild("FunDec", @1.first_line, 3, $1, $2, $3); }
      ;

VarList: ParamDec COMMA VarList     { $$ = mtChild("VarList", @1.first_line, 3, $1, $2, $3); }
       | ParamDec   { $$ = mtChild("ParamDec", @1.first_line, 1, $1); }
       ;

ParamDec: Specifier VarDec  { $$ = mtChild("ParamDec", @1.first_line, 2, $1, $2); }
        ;

CompSt: LC DefList StmtList RC  { $$ = mtChild("CompSt", @1.first_line, 4, $1, $2, $3, $4); }
      | error RC    { yyclearin; yyerrok; $$ = mtChild("Epsilon", 0, 0, NULL); is_grammar_error = 1; }

      ;

StmtList: Stmt StmtList     { $$ = mtChild("StmtList", @1.first_line, 2, $1, $2); }
        | { $$ = mtChild("Epsilon", 0, 0, NULL); }

        ;

Stmt: Exp SEMI  { $$ = mtChild("Stmt", @1.first_line, 2, $1, $2); }
    | CompSt    { $$ = mtChild("Stmt", @1.first_line, 1, $1); }
    | RETURN Exp SEMI   { mtChild("Stmt", @1.first_line, 3, $1, $2, $3); }
    | IF LP Exp RP Stmt  %prec LOWER_THAN_ELSE  { $$ = mtChild("Stmt", @1.first_line, 5, $1, $2, $3, $4, $5); }
    | IF LP Exp RP Stmt ELSE Stmt   { $$ = mtChild("Stmt", @1.first_line, 7, $1, $2, $3, $4, $5, $6, $7); }
    | WHILE LP Exp RP Stmt  { $$ = mtChild("Stmt", @1.first_line, 5, $1, $2, $3, $4, $5); }
    | error SEMI    { $$ = mtChild("Epsilon", 0, 0, NULL); is_grammar_error = 1; }
    ;

DefList: Def DefList    { $$ = mtChild("DefList", @1.first_line, 2, $1, $2); }
       | { $$ = mtChild("Epsilon", 0, 0, NULL); }
       ;

Def: Specifier DecList SEMI     { $$ = mtChild("Def", @1.first_line, 3, $1, $2, $3); }
   ;

DecList: Dec    { $$ = mtChild("DecList", @1.first_line, 1, $1); }
       | Dec COMMA DecList  { $$ = mtChild("DecList", @1.first_line, 3, $1, $2, $3); }
       ;

Dec: VarDec     { $$ = mtChild("Dec", @1.first_line, 1, $1); }
   | VarDec ASSIGNOP Exp    { $$ = mtChild("Dec", @1.first_line, 3, $1, $2, $3); }
   ;

Exp: Exp ASSIGNOP Exp   { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp AND Exp    { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp OR Exp     { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp RELOP Exp  { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp PLUS Exp   { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp MINUS Exp  { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp STAR Exp   { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp DIV Exp    { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | LP Exp RP      { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | MINUS Exp      { $$ = mtChild("Exp", @1.first_line, 2, $1, $2); }
   | NOT Exp        { $$ = mtChild("Exp", @1.first_line, 2, $1, $2); }
   | ID LP Args RP  { $$ = mtChild("Exp", @1.first_line, 4, $1, $2, $3, $4); }
   | ID LP RP       { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | Exp LB Exp RB  { $$ = mtChild("Exp", @1.first_line, 4, $1, $2, $3, $4); }
   | Exp DOT ID     { $$ = mtChild("Exp", @1.first_line, 3, $1, $2, $3); }
   | ID             { $$ = mtChild("Exp", @1.first_line, 1, $1); }
   | INT            { $$ = mtChild("Exp", @1.first_line, 1, $1); }
   | FLOAT          { $$ = mtChild("Exp", @1.first_line, 1, $1); }
   | error RP       { $$ = mtChild("Epsilon", 0, 0, NULL); is_grammar_error = 1; }
   ;

Args: Exp COMMA Args    { $$ = mtChild("Args", @1.first_line, 3, $1, $2, $3); }
    | Exp           { $$ = mtChild("Args", @1.first_line, 1, $1); }
    ;

%%
static mtNode *mtChild(char *token, int lineno, int n, mtNode* node, ...) {
    va_list ap;
    mtNode *father_node = (mtNode *)malloc(sizeof(mtNode));
    father_node->type = GU;
    father_node->text = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
    strcpy(father_node->text, token);
    father_node->lineno = lineno;
    father_node->father = NULL;
    father_node->child_max = n;
    father_node->child = (mtNode **)malloc(sizeof(mtNode *) * n);
    va_start(ap, node);
    mtNode *child_node = node;
    for (int i = 0; i < n; i++) {
        father_node->child[i] = child_node;
        child_node->father= father_node;
        child_node = va_arg(ap, mtNode *);
    }
    va_end(ap);
    return father_node;
}

static void mt_p(mtNode *node, int level) {
    if (strcmp(node->text, "Epsilon") != 0) {
        for (int i = 0; i < 2 * level; i++) {
            printf(" ");
         }
        printf("%s", node->text);
        if (node->type == GU)
            printf(" (%d)\n", node->lineno);
        else {
            if(strcmp(node->text, "TYPE") == 0 || strcmp(node->text, "ID") == 0 || strcmp(node->text, "INT") == 0 || strcmp(node->text, "FLOAT") == 0)
                printf(": %s", node->extra);
            printf("\n");
        }
        if (node->child_max == 0)
            return;
        for (int i = 0; i < node->child_max; i++)
            mt_p(node->child[i], level + 1);
    }
}

void mt_print() {
    if(!is_grammar_error && !is_lexical_error)
        mt_p(root, 0);
}

static void yyerror(char *text) {
    fprintf(stderr, "Error type B at Line %d: %s\n", yylloc.first_line, text);
}
