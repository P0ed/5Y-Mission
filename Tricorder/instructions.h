typedef enum : unsigned char {
  RXI = 0x00,
  RXU = 0x01,
  RXRX = 0x02,
  RXST = 0x03,
  STRX = 0x04,
  STI = 0x05,
  STU = 0x06,
  POP = 0x07,
  INC = 0x08,
  ADD = 0x09,
  MUL = 0x0A,
  NAND = 0x0B,
  SHL = 0x0C,
  SHR = 0x0D,

  CFN = 0xFD,
  FN = 0xFE,
  RET = 0xFF
} OPCode;

typedef struct {
  OPCode op;
  unsigned char x;
  unsigned char y;
  unsigned char z;
} Instruction;
