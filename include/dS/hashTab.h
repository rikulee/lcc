#ifndef HASH_TAB_H
#define HASH_TAB_H
#include "common.h"
#include "mtNode.h"
#define TAB_MAX_VOL 0x3ff

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


void htElem_init(htElem *elem);

u64 ht_hash(char *name);

htHeader *ht_init();

/* 0 -> 在HashTable里面找到了该元素 */
/* 1 -> 未找到且该元素对应的Hash项从未出现其他元素 */
/* 2 -> 不包含上述1的未找到 */
u64 ht_find(htHeader *head, char *uID, htElem *elem);

/* 0 -> 填表成功 */
/* 1 -> 冲突 */
/* 2 -> 未知错误 */
u64 ht_add(htHeader* head, htElem *elem);
#endif
