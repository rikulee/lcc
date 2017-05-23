#include <stdio.h>
#include "hashTab.h"

extern mtNode *root;

void se_analyze();

void mt_walk(mtNode *, htHeader *);

void draw_ExtDef(mtNode *, htElem *);
void draw_Specifier(mtNode *, htElem *);
void draw_Struct(mtNode *, htElem *);
void draw_FunDec(mtNode *, htElem *);
void draw_Def(mtNode *, htElem *);
void draw_DecList(mtNode *, htElem *);
void draw_Dec(mtNode *, htElem *);
void draw_VarDec(mtNode *, htElem *);
void draw_VarList(mtNode *, htElem *);
void draw_ParamDec(mtNode *, htElem *);
types *check_Exp(mtNode *, htHeader *);
types *check_ID(mtNode *, htHeader *);
types *check_INT(mtNode *, htHeader *);
types *check_FLOAT(mtNode *, htHeader *);
types *check_FUN(mtNode *, htHeader *);
types *check_ARRAY(mtNode *, htHeader *);
types *check_1OP1(mtNode *, types *, types *);
types *check_1BOOL1(mtNode *, types *, types *);
types *check_NOT1(mtNode *, types *);
types *check_MINUS1(mtNode *, types *);
types *check_1DOT1(mtNode *, mtNode *);

void se_debug() {
    se_analyze();
}

void se_analyze() {
    htHeader *head = ht_init();
    mt_walk(root, head);
}

void draw_ParamDec(mtNode *node, htElem *elem) {
    draw_Specifier(node->child[0], elem);
    draw_VarDec(node->child[1], elem);
}

void draw_VarList(mtNode *node, htElem *elem) {
    htElem *_tmp = (htElem *)malloc(sizeof(htElem));
    htElem_init(_tmp);
    _tmp->kind = VAR;
    elem->next = _tmp;
    draw_ParamDec(node->child[0], _tmp);
    if (node->child_max != 1) {
        draw_VarList(node->child[2], _tmp);
    }
}

void draw_VarDec(mtNode *node, htElem *elem) {
    if (node->child_max == 1) {
        elem->uID =(char *)malloc(sizeof(char) * strlen(node->child[0]->extra) + 1);
        strcpy(elem->uID, node->child[0]->extra);
    } else {
        char *size = node->child[2]->extra;
        if (elem->basic_type.type == BASIC) {
            types *_tmp = (types *)malloc(sizeof(types));
            _tmp->extra.basic = elem->basic_type.extra.basic;
            _tmp->type = BASIC;
            elem->basic_type.extra.array.type = _tmp;
            elem->basic_type.extra.array.size = atoi(size);
            elem->basic_type.type = ARRAY;
        }
        draw_VarDec(node->child[0], elem);
    }
}

void draw_Dec(mtNode *node, htElem *elem) {
    draw_VarDec(node->child[0], elem);
}

void draw_DecList(mtNode *node, htElem *elem) {
    draw_Dec(node->child[0], elem);
    if (node->child_max > 1) {
        htElem *_tmp=(htElem *)malloc(sizeof(htElem));
        htElem_init(_tmp);
        _tmp->kind = VAR;
        elem->next = _tmp;
        draw_DecList(node->child[2], _tmp);
    }
}

void draw_Def(mtNode *node, htElem *elem) {
    draw_Specifier(node->child[0], elem);
    draw_DecList(node->child[1], elem);
}

void draw_Struct(mtNode *node, htElem *elem) {

}

void draw_Specifier(mtNode *node, htElem *elem) {
    char *pattern = node->child[0]->text;
    if (strcmp(pattern, "TYPE") == 0) {
        elem->basic_type.type = BASIC;
        if (strcmp(node->child[0]->extra, "int") == 0) {
            elem->basic_type.extra.basic = 0;
        } else {
            elem->basic_type.extra.basic = 1;
        }
    } else {
        elem->basic_type.type = STRUCTURE;
        draw_Struct(node->child[0], elem);
    }
}

void draw_FunDec(mtNode *node, htElem *elem) {
    char *uID = node->child[0]->extra;
    elem->uID = (char *)malloc(sizeof(char) * strlen(uID) + 1);
    strcpy(elem->uID, uID);
    elem->extra.fun.n = 0;
    if (node->child_max == 4) {
        draw_VarList(node->child[2], elem);
    }
}

void draw_ExtDef(mtNode *node, htElem *elem) {
    draw_Specifier(node->child[0], elem);
    char *pattern = node->child[1]->text;
    if (strcmp(pattern, "FunDec") == 0) {
        elem->kind = FUN;
        draw_FunDec(node->child[1], elem);
    }
}

types *check_ARRAY(mtNode *node, htHeader *head) {
    types *type0 = check_Exp(node->child[0], head);
    types *type1 = check_Exp(node->child[2], head);
    if (type1->type == BASIC && type1->extra.basic == 0) {
        if (type0->type != ARRAY) {
            printf("Error type 10 at Line %d: x[n] is not a array\n", node->child[0]->lineno);
        }
    } else {
        printf("Error type 12 at Line %d: [x] is not a integer.\n", node->child[2]->lineno);
    }
}

types *check_FUN(mtNode *node, htHeader *head) {
    htElem *elem = (htElem *)malloc(sizeof(htElem));
    u64 _flag = ht_find(head, node->child[0]->extra, elem);
    if (_flag != 0) {
        printf("Error type 2 at Line %d: Undefined function \"%s\"\n", node->child[0]->lineno, node->child[0]->extra);
    } else {
        if (elem->kind != FUN) {
            printf("Error type 11 at Line %d: \"%s\" is not a function.\n", node->child[0]->lineno, node->child[0]->extra);
        } else {
        }
    }
}

types *check_ID(mtNode *node, htHeader *head) {
    htElem *elem = (htElem *)malloc(sizeof(htElem));
    u64 _flag = ht_find(head, node->extra, elem);
    if (_flag == 0) {
        return &(elem->basic_type);
    } else {
        printf("Error type 1 at Line %d: Undefined variable \"%s\"\n", node->lineno, node->extra);
        return NULL;
    }
}

types *check_INT(mtNode* node, htHeader *head) {
    types *type = (types *)malloc(sizeof(types));
    type->type = BASIC;
    type->extra.basic = 0;
    return type;
}

types *check_FLOAT(mtNode* node, htHeader *head) {
    types *type = (types *)malloc(sizeof(types));
    type->type = BASIC;
    type->extra.basic = 1;
    return type;
}

types *check_1OP1(mtNode *node, types *type0, types *type1) {
    if (type0 == NULL || type1 == NULL)
        return NULL;
    if (strcmp(node->child[1]->text, "ASSIGNOP") == 0) {
        mtNode *_tmpNode = node->child[0];
        bool _flag = true;
        if (strcmp(_tmpNode->child[0]->text, "ID") == 0)
            _flag = false;
        else if (strcmp(node->child[1]->text, "LB") == 0) {
            _flag = false;
        } else if (strcmp(node->child[1]->text, "DOT") == 0) {
            _flag = false;
        }
        if (_flag) {
            printf("Error type 6 at Line %d: left-hand error\n", node->lineno);
            return NULL;
        }
    }
    bool _flag = false;
    /* printf("%d %d\n", type0->extra.basic, type1->extra.basic); */
    if (type0->type != type1->type)
        _flag = true;
    else {
        if (type0->type == BASIC
                && type0->extra.basic != type1->extra.basic)
            _flag = true;
    }
    if (_flag) {
        if (strcmp(node->child[1]->text, "ASSIGNOP") == 0) {
            printf("Error type 5 at Line %d: Type mismatched for assign.\n", node->lineno);
        } else {
            printf("Error type 7 at Line %d: Type mismatched for op.\n", node->lineno);
        }
        return NULL;
    }
    return type0;
}

types *check_1BOOL1(mtNode *node, types *type0, types *type1) {
    if (type0 == NULL || type1 == NULL)
        return NULL;
    if (type0->type == BASIC
            && type1->type == BASIC
            && type0->extra.basic == 0
            && type1->extra.basic == 0)
        return type0;
    else {
        printf("Error type 5 at Line %d: Type mismatched for bool.\n", node->lineno);
        return NULL;
    }
}

types *check_Exp(mtNode *node, htHeader *head) {
    int _mode = node->child_max;
    switch(_mode) {
        case 1:
            {
                char *exp = node->child[0]->text;
                if (strcmp(exp, "ID") == 0) {
                    return check_ID(node->child[0], head);
                } else if (strcmp(exp, "INT") == 0) {
                    return check_INT(node->child[0], head);
                } else if (strcmp(exp, "FLOAT") == 0) {
                    return check_FLOAT(node->child[0], head);
                }
            }
            break;
        case 2:
            break;
        case 3:
            {
                char *exp0 = node->child[0]->text;
                char *exp1 = node->child[1]->text;
                char *exp2 = node->child[2]->text;
                if (strcmp(exp0, "Exp") == 0 && strcmp(exp2, "Exp") == 0) {
                    types *type0 = check_Exp(node->child[0], head);
                    types *type1 = check_Exp(node->child[2], head);
                        if (strcmp(exp1, "ASSIGNOP") == 0
                                || strcmp(exp1, "PLUS") == 0
                                || strcmp(exp1, "MINUS") == 0
                                || strcmp(exp1, "STAR") == 0
                                || strcmp(exp1, "DIV") == 0) {
                            return check_1OP1(node, type0, type1);
                        } else {
                            return check_1BOOL1(node, type0, type1);
                        }
                } else if (strcmp(exp0, "ID") == 0) {
                    return check_FUN(node, head);
                } else if (strcmp(exp1, "Exp")) {
                    return check_Exp(node->child[1], head);
                } else if (strcmp(exp1, "Dot")) {

                }
            }
            break;
        case 4:
            {
                char *exp0 = node->child[0]->text;
                if (strcmp(exp0, "ID") == 0) {
                    return check_FUN(node, head);
                } else if (strcmp(exp0, "Exp") == 0) {
                    return check_ARRAY(node, head);
                }
            }
            break;
        default:
            ;
    }
    return NULL;
}

void mt_walk(mtNode *node, htHeader *head) {
    if (strcmp(node->text, "ExtDef") == 0) {
        htElem elem;
        htElem_init(&elem);
        draw_ExtDef(node, &elem);
        int arg_n = -1;
        for (htElem *cur = &elem; cur != NULL; cur = cur->next) {
            arg_n++;
        }
        elem.extra.fun.n = arg_n;
        elem.extra.fun.elems = (htElem *)malloc(sizeof(htElem) * arg_n);
        int _index = 0;
        for (htElem *cur = elem.next; cur != NULL; cur = cur->next) {
            elem.extra.fun.elems[_index] = *cur;
            _index++;
        }
        for (htElem *cur = &elem; cur != NULL; cur = cur->next) {
            u64 _flag = ht_add(head, cur);
            if (_flag == 1) {
                if (cur->kind == FUN) {
                    printf("Error type 4 at Line %d: Redefinded function \"%s\"\n", node->lineno, cur->uID);
                } else if (cur->kind == VAR) {
                    printf("Error type 3 at Line %d: Redefinded variable \"%s\"\n", node->lineno, cur->uID);
                }
            }
        }
    } else if (strcmp(node->text, "Def") == 0) {
        htElem elem;
        htElem_init(&elem);
        elem.kind = VAR;
        draw_Def(node, &elem);
        for (htElem *cur = &elem; cur != NULL; cur = cur->next) {
            u64 _flag = ht_add(head, cur);
            if (_flag == 1 && cur->kind == VAR) {
                printf("Error type 3 at Line %d: Redefinded variable \"%s\"\n", node->lineno, cur->uID);
            }
        }
    } else if (strcmp(node->text, "Exp") == 0) {
        check_Exp(node, head);
        return;
    }
    if (node->child_max == 0)
        return;
    for (int i = 0; i < node->child_max; i++)
        mt_walk(node->child[i], head);
}

