#include "dS/hashTab.h"

void htElem_init(htElem *elem) {
    elem->uID = NULL;
    elem->next = NULL;
    elem->is_stated = true;
}

u64 ht_hash(char *name) {
    u64 val = 0, i;
    for (; *name; ++name) {
        val = (val << 2) + *name;
        if ((i = (val & ~TAB_MAX_VOL)))
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

    return head;
}

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
