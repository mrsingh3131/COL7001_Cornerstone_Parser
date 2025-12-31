# Cornerstone Parser (Lab 2B)

A robust Abstract Syntax Tree (AST) generator built using **Flex** and **Bison**. This parser supports a C-like language with advanced features like function definitions, error recovery, and semantic validation.

## 🚀 Features

- **Core Grammar**: Supports variable declarations, initializers, assignments, `if-else` logic, and `while` loops.
- **Functions (Extension)**: Support for function definitions (`func`), `return` statements, and function calls within expressions.
- **Script Support (Extension)**: Capable of parsing multiple top-level statements in a single file (statement lists).
- **Error Recovery (Extension)**: Uses the `error` token to recover from syntax errors and continue parsing subsequent code without crashing.
- **Semantic Validation**: Enforces the "Declare-before-use" rule using a symbol table.
- **Comments**: Handles both single-line (`//`) and multi-line (`/* ... */`) comments.

---

## 🛠 Build Instructions

### Prerequisites
Ensure you have `flex`, `bison`, and `gcc` installed on your system.

### Compiling
Use the provided `Makefile` to generate the lexer, parser, and executable:

```bash
make clean
make
```

This will generate the executable named `lab2b_parser`.

## ▶️ How to Run

### Running the Parser
To parse a source file and display the AST:

```bash
./lab2b_parser <path_to_source_file>
```

**Example:**

```bash
./lab2b_parser tests/valid/01_full_program.txt
```

## 🧪 Testing

### Running Valid Tests
All files in `tests/valid/` should pass both the syntax and semantic checks.

```bash
for f in tests/valid/*.txt; do 
    echo "Testing $f..."
    ./lab2b_parser "$f"
    echo "--------------------------"
done
```

### Running Invalid Tests
Files in `tests/invalid/` demonstrate the parser's ability to catch errors.

- **Syntax Errors**: The parser will report the line number and attempt to recover at the next semicolon.
- **Semantic Errors**: The program will report: `SEMANTIC ERROR: Variable 'x' used before declaration.`

## 📌 Assumptions & Deviations

- **Variable Scoping**: The current symbol table is implemented as a flat global table. This satisfies the requirement that a variable must be declared using `var` before any use (assignment or expression).
- **Function Arguments**: Function definitions currently support zero parameters `func name()`. Function calls are supported as expressions and can accept one optional argument.
- **Error Recovery**: The parser recovers at the statement level. If an error occurs within a statement, Bison discards tokens until it finds a semicolon `;` and resumes parsing.
- **Dangling Else**: The grammar handles the dangling else ambiguity by giving precedence to the closest `if` (standard C behavior). This results in 1 expected shift/reduce conflict.
- **Unary Operations**: The unary minus (e.g., `-5`) is internally transformed into `0 - expression` within the AST for simplified processing.

## 🌳 AST Node Structure

The AST uses a multi-child approach to represent the program structure:

- **left**: Primary child, expression, or condition.
- **right**: Secondary child or "then" block for `if` statements.
- **third**: "else" block for `if` statements.
- **next**: Sibling pointer used to link statements in a `statement_list`.