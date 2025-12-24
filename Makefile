CC = gcc
CFLAGS = -Wall -g
BISON = bison
FLEX = flex

# The final executable name
TARGET = lab2b_parser

# Source files
SRCS = src/ast.c src/main.c src/parser.tab.c src/lex.yy.c

all: $(TARGET)

# 1. Generate Parser C code from .y file
src/parser.tab.c src/parser.tab.h: src/parser.y
	$(BISON) -d -o src/parser.tab.c src/parser.y

# 2. Generate Lexer C code from .l file
src/lex.yy.c: src/lexer.l src/parser.tab.h
	$(FLEX) -o src/lex.yy.c src/lexer.l

# 3. Compile everything together
$(TARGET): src/parser.tab.c src/lex.yy.c src/ast.c src/main.c
	$(CC) $(CFLAGS) -I src -o $(TARGET) $(SRCS)

clean:
	rm -f src/parser.tab.c src/parser.tab.h src/lex.yy.c $(TARGET)

test: $(TARGET)
	@echo "Running valid tests..."
	@for file in tests/valid/*.txt; do \
		echo "Testing $$file..."; \
		./$(TARGET) $$file; \
	done