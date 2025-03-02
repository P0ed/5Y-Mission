
typedef enum : char {
  RET = 0x00,
  MOV = 0x01,
  PRINT,
  MAP,
  NOP
} OPCode;

typedef struct {
  OPCode opcode;
  char x;
  char y;
  char z;
} Instruction;
