# RISC-V Assembler (Flex + Bison)

RISC-V Assembler using Flex and Bison — parses and translates a subset of RISC-V assembly instructions into binary machine code.

This project implements a simple assembler for a subset of RISC-V instructions using Flex (for lexical analysis) and Bison (for syntax parsing). The output is binary machine code printed to standard output.

---

## What It Does

- Tokenizes input RISC-V assembly code with a lexer (`assembler.l`)
- Parses instructions using a Bison parser (`assembler.y`)
- Builds an internal representation of instructions based on their format (R, I, S, B, J, and UI types)
- Converts each instruction into its corresponding binary representation based on opcode, funct3, funct7, register indices, and immediate values
- Outputs binary instruction encoding to stdout

---

## How It Works

The `assembler.y` file contains grammar rules for different instruction formats:
- **R-type**: e.g. `add x1, x2, x3`
- **I-type**: e.g. `addi x1, x2, 5` or `lw x1, 0(x2)`
- **S-type**: e.g. `sw x1, 0(x2)`
- **B-type**: e.g. `beq x1, x2, label`
- **J-type**: e.g. `j label`
- **UI-type**: e.g. `auipc x1, imm`

The lexer (`assembler.l`) handles parsing of registers (`x0` to `x31`), immediates in decimal, binary (`0b`), octal (`0o`), and hexadecimal (`0x`) formats.

Once parsed, each instruction is printed in binary format, as per its encoding rules.

---

## Files

- `assembler.l`: Lexer definition (Flex)
- `assembler.y`: Parser/grammar definition (Bison)
- `makefile`: Builds the assembler
- `assembler.tab.h/c/o`: Bison-generated headers/implementation
- `lex.yy.c/o`: Flex-generated scanner

> **Note:** The `spam` and `ham` folders referenced in class are **not included** here due to their large size.

---

## How To Use

### Build:
```bash
make
