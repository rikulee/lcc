typedef enum TokenType { LU, GU } TokenType;

typedef struct mtNode {
    TokenType type;
    char *text;
    int lineno;
    struct mtNode *father;
    int child_max;
    struct mtNode **child;
    char *extra;
} mtNode;
