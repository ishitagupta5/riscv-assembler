%{
#include <stdlib.h>
#include <stdio.h>

enum instruction_format { IF_R, IF_I, IF_UI, IF_S, IF_B, IF_J };

static struct instruction {
  enum instruction_format format;
  int funct3 : 3;
  int funct7 : 7;
  int imm : 20;
  int opcode : 7;
  int rd : 5;
  int rs1 : 5;
  int rs2 : 5;
  int shift_invalid : 1;
} instruction;

static void printbin(int val, char bits);
static int bit_range(int val, char begin, char end);
static void print_instruction(struct instruction);
int yylex();
void yyerror(char* s);
%}

%start program
%union {
  long l;
}
%token <l> REGISTER NEWLINE COMMA LEFT_PAREN RIGHT_PAREN MINUS IMMEDIATE
%token ADD SUB ADDI LW SLLI SW BEQ J AUIPC
%type <l> imm

%%
program : segments
;
segments : segments segment
| segment
;
segment : %empty
| text
;
text : text NEWLINE instruction
| instruction
;
instruction : r-type
{
  instruction.shift_invalid = 0;
  print_instruction(instruction);
}
;
r-type : add
{
}
| sub
{
}
;
add: ADD REGISTER COMMA REGISTER COMMA REGISTER
{
  instruction.format = IF_R;
  instruction.opcode = 51;
  instruction.funct3 = 0;
  instruction.funct7 = 0;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.rs2 = $6;
}
;
sub: SUB REGISTER COMMA REGISTER COMMA REGISTER
{
  instruction.format = IF_R;
  instruction.opcode = 51;
  instruction.funct3 = 0;
  instruction.funct7 = 32;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.rs2 = $6;
}
;
instruction : i-type
{ 
  instruction.shift_invalid = 0;
}
;
i-type : addi
{
}
| slli
{
}
| lw
{
}
;
addi: ADDI REGISTER COMMA REGISTER COMMA imm
{
  instruction.shift_invalid = 0;
  instruction.format = IF_I;
  instruction.opcode = 19;
  instruction.funct3 = 0;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.imm = $6;
  print_instruction(instruction);
}
;
slli: SLLI REGISTER COMMA REGISTER COMMA imm
{
  instruction.format = IF_I;
  instruction.opcode = 19;
  instruction.funct3 = 1;
  instruction.funct7 = 0;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.imm = $6;
  if (instruction.imm > 31 || instruction.imm < 0) {
    instruction.shift_invalid = 1;
  } 
  print_instruction(instruction);
 
}
;
lw: LW REGISTER COMMA imm LEFT_PAREN REGISTER RIGHT_PAREN
{
  instruction.shift_invalid = 0;
  instruction.format = IF_I;
  instruction.opcode = 3;
  instruction.funct3 = 2;
  instruction.rd = $2;
  instruction.rs1 = $6;
  instruction.imm = $4;
  print_instruction(instruction);
}
;
instruction : s-type
{
  instruction.shift_invalid = 0; 
  print_instruction(instruction);
}
;
s-type : sw
{
}
;
sw: SW REGISTER COMMA imm LEFT_PAREN REGISTER RIGHT_PAREN
{
  instruction.format = IF_S;
  instruction.opcode = 35;
  instruction.funct3 = 2;
  instruction.rs2 = $2;
  instruction.imm = $4;
  instruction.rs1 = $6;

}
;
instruction : ui-type
{
  instruction.shift_invalid = 0;
  print_instruction(instruction);
}
;
ui-type : auipc
{
}
;
auipc: AUIPC REGISTER COMMA imm 
{
  instruction.format = IF_UI;
  instruction.opcode = 23;
  instruction.rd = $2;
  instruction.imm = $4;
}
;
instruction : b-type
{
  instruction.shift_invalid = 0;
  print_instruction(instruction); 
}
b-type : beq
{
}
;
beq: BEQ REGISTER COMMA REGISTER COMMA imm 
{
  instruction.format = IF_B;
  instruction.opcode = 99;
  instruction.funct3 = 0;
  instruction.rs1 = $2;
  instruction.rs2 = $4;
  instruction.imm = $6;
}
;
instruction : j-type
{
  instruction.shift_invalid = 0;
  print_instruction(instruction); 
}
;
j-type : j
{
}
;
j: J imm 
{
  instruction.format = IF_J;
  instruction.opcode = 111;
  instruction.imm = $2;
  instruction.rd = 0;
}
;
imm : MINUS IMMEDIATE
{
$$ = -1 * $2;
}
| IMMEDIATE
{
$$ = $1;
}
;
%%
static void print_instruction(struct instruction instruction) {
  if (instruction.shift_invalid) {
    printf("Shift amount invalid\n");
    return;
  }

  switch (instruction.format) {
    case IF_R:
      printbin(instruction.funct7, 7);
      printbin(instruction.rs2, 5);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      break;
    case IF_I:
      printbin(instruction.imm, 12);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      break;
    case IF_UI:
      printbin(instruction.imm, 20);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      break;
    case IF_S:
      printbin(bit_range(instruction.imm,5, 12), 7);
      printbin(instruction.rs2, 5);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(bit_range(instruction.imm,0, 5), 5);
      printbin(instruction.opcode, 7);
      break;
    case IF_B:
      printbin(bit_range(instruction.imm,12, 13), 1);
      printbin(bit_range(instruction.imm,5, 11), 6);
      printbin(instruction.rs2, 5);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(bit_range(instruction.imm, 1, 5), 4);
      printbin(bit_range(instruction.imm, 11, 12), 1);
      printbin(instruction.opcode, 7);
      break;
    case IF_J:
      printbin(bit_range(instruction.imm, 20, 21), 1);
      printbin(bit_range(instruction.imm, 1, 11), 10);
      printbin(bit_range(instruction.imm, 11, 12), 1);
      printbin(bit_range(instruction.imm, 12, 20), 8);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);  
      break;
    default:
      exit(-1);
  }
  printf("\n");
}
static void printbin(int val, char bits) {
  for (char i = bits - 1; i >= 0; i--) {
    if (val & (1 << i)) {
      putchar('1');
    } else {
      putchar('0');
    }
  }
}

static int bit_range(int val, char begin, char end) {
  int mask = ((1 << end) - 1) ^ ((1 << begin) - 1);
  return (val & mask) >> begin;
}

void yyerror(char *msg){
    // If your assembler cannot parse input it will exit, make sure to test locally using the tests on canvas
}

int main(){
 #ifdef YYDEBUG
 int yydebug = 1;
 #endif /* YYDEBUG */
 yyparse();
 return 0;
}