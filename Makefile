# Dirs
SRC_DIR  := src
INC_DIR  := include
OUT_DIR  := out
TEST_DIR := testcase

# Complier and flags
CC      := gcc
LEX     := flex
YACC    := bison
CFLAGS  := -I$(INC_DIR)
LDFLAGS := -lfl -ly

#Files
CFILES = $(wildcard $(SRC_DIR)/*.c)
OBJS   = $(patsubst $(SRC_DIR)/%.c,$(OUT_DIR)/%.o,$(CFILES))
LFILE  = $(wildcard $(SRC_DIR)/*.l)
YFILE  = $(wildcard $(SRC_DIR)/*.y)
LFC    = $(OUT_DIR)/lex.yy.c
YFC    = $(OUT_DIR)/syntax.tab.c
YFO    = $(YFC:.c=.o)

# Targets
all: lcc

lcc: syntax $(filter-out $(YFO),$(OBJS))
	$(CC) $(CFLAGS) -o $(OUT_DIR)/lcc $(filter-out $(YFO),$(OBJS)) $(YFO) $(LDFLAGS)

$(OUT_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

syntax: lexical syntax-c
	$(CC) $(CFLAGS) -c $(YFC) -o $(YFO)

lexical: $(LFILE)
	$(shell mkdir -p $(OUT_DIR))
	$(LEX) -o $(LFC) $(LFILE)

syntax-c: $(YFILE)
	$(YACC) -o $(YFC) -d -v $(YFILE)

# PHONY
.PHONY: clean test

clean:
	rm -rf $(OUT_DIR)

test:
	./out/lcc $(TEST_DIR)/test.cmm
