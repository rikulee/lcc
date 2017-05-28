# Dirs
DIR_SRC  := src
DIR_INC  := include
DIR_OBJ  := obj
DIR_BIN  := bin
DIR_TEST := testcase

DIR_CRT  := $(shell mkdir -p $(DIR_OBJ) $(DIR_BIN))

# Complier and flags
CC      := gcc
LEX     := flex
YACC    := bison
CFLAGS  := -g -O2 -Wall -I$(DIR_INC)
LDFLAGS := -lfl -ly

#Files
TARGET     = lcc
BIN_TARGET = $(DIR_BIN)/$(TARGET)
SRCS       = $(shell find $(DIR_SRC) -name "*.c")
OBJS       = $(patsubst $(DIR_SRC)/%.c,$(DIR_OBJ)/%.o,$(SRCS))
LFILE      = $(shell find $(DIR_SRC) -name "*.l")
YFILE      = $(shell find $(DIR_SRC) -name "*.y")
LFC        = $(DIR_OBJ)/lex.yy.c
YFC        = $(DIR_OBJ)/syntax.tab.c
YFO        = $(YFC:.c=.o)

# Targets
$(BIN_TARGET): syntax $(OBJS)
	@echo "Generating $@ ..."
	@$(CC) $(CFLAGS) -o $@ $(OBJS) $(YFO) $(LDFLAGS)

$(DIR_OBJ)/%.o: $(DIR_SRC)/%.c
	@echo "Compiling  $< ..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -o $@ -c $<

syntax: lexical syntax-c
	@echo "Compiling  $(YFC) ..."
	@$(CC) $(CFLAGS) -o $(YFO) -c $(YFC)

lexical: $(LFILE)
	@echo "Compiling  $< ..."
	@$(LEX) -o $(LFC) $(LFILE)

syntax-c: $(YFILE)
	@echo "Compiling  $< ..."
	@$(YACC) -o $(YFC) -d -v $(YFILE)

# PHONY
.PHONY: clean test

clean:
	@echo "Cleaning obj/ ..."
	@rm -rf $(DIR_OBJ)
	@echo "Cleaning bin/ ..."
	@rm -rf $(DIR_BIN)

test:
	$(BIN_TARGET) $(DIR_TEST)/test.cmm
