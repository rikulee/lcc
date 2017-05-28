#include "common.h"

extern void yyrestart(FILE*);
extern int yyparse();
extern void mt_print();
extern void se_analyze();

int main(int argc, char** argv) {
    if (argc <= 1) return 1;
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return 1;
    }
    yyrestart(f);
    if (!yyparse()) {
        se_analyze();
    }
    return 0;
}
