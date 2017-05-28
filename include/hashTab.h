#ifndef HASH_TABLE
#define HASH_TABLE
#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "mtNode.h"
#define TAB_MAX_VOL 0x3ff

typedef unsigned int u64;
typedef struct fieldList_* fieldList;
typedef struct types {
    enum { BASIC, ARRAY, STRUCTURE } type;
    union {
        int basic;
        struct {
            struct types *type;
            int size;
        } array;
        fieldList structure;
    } extra;
} types;
struct fieldList_ {
    char *name;
    types type;
    fieldList tail;
};
typedef struct htElem {
    char* uID;
    enum {VAR, FUN} kind;
    bool is_stated;
    types basic_type;
    union {
        float val;
        struct {
            struct htElem *elems;
            int n;
        } fun;
    } extra;
    struct htElem *next;
} htElem;
typedef struct htHeader {
    u64 elem_amt;
    htElem *tail;
    htElem *next;
} htHeader;

void htElem_init(htElem *elem) {
    elem->uID = NULL;
    elem->next = NULL;
    elem->is_stated = true;
}

u64 ht_hash(char *name) {
    u64 val = 0, i;
    for (; *name; ++name) {
        val = (val << 2) + *name;
        if (i = val & ~TAB_MAX_VOL)
            val = (val ^ (i >> 12)) & TAB_MAX_VOL;
    }
    return val;
}

htHeader *ht_init() {
    htHeader* head = (htHeader *)malloc(sizeof(htHeader) * TAB_MAX_VOL);
    for (int i = 0; i < TAB_MAX_VOL; i++) {
        head[i].elem_amt = 0;
        head[i].tail = NULL;
        head[i].next = NULL;
    }
}

/* 0 -> 在HashTable里面找到了该元素 */
/* 1 -> 未找到且该元素对应的Hash项从未出现其他元素 */
/* 2 -> 不包含上述1的未找到 */
u64 ht_find(htHeader *head, char *uID, htElem *elem) {
    u64 no = ht_hash(uID);
    if (head[no].elem_amt == 0) {
        return 1;
    } else {
        htElem *cur = head[no].next;
        for (; cur != NULL; cur = cur->next) {
            if (strcmp(cur->uID, uID) == 0) {
                elem->uID = cur->uID;
                elem->kind = cur->kind;
                elem->basic_type = cur->basic_type;
                elem->is_stated = cur->is_stated;
                elem->extra = cur->extra;
                elem->next = cur->next;
                return 0;
            }
        }
        return 2;
    }
}

/* 0 -> 填表成功 */
/* 1 -> 冲突 */
/* 2 -> 未知错误 */
u64 ht_add(htHeader* head, htElem *elem) {
    htElem *_tmp = (htElem *)malloc(sizeof(htElem));
    u64 no = ht_hash(elem->uID);
    u64 _flag = ht_find(head, elem->uID, _tmp);
    switch (_flag) {
        case 0:
            return 1;
        case 1:
            head[no].next = elem;
            head[no].tail = elem;
            head[no].elem_amt++;
            return 0;
        case 2:
            head[no].tail->next = elem;
            head[no].tail = elem;
            head[no].elem_amt++;
            return 0;
        default:
            return 2;
    }
}
#endif
