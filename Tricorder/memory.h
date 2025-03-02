typedef struct {
  int a, b, c, d;
} Page;

typedef struct {
  float a, b, c, d;
} FPage;

static const int fnLen = 64;

typedef struct {
  int sidx = 0;
  
  Page rx = { 0, 0, 0, 0 };
  Page idx = { 0, 0, 0, 0 };
  int ints[4][16];

  FPage fx = { 0, 0, 0, 0 };
  FPage fidx = { 0, 0, 0, 0 };
  float floats[4][16];

  char strings[128][16];
  char longString[128];

  Instruction functions[64][fnLen];

  int ram[384 * 256];
  int stack[16 * 256];

} Memory;

extern Memory mem;

static inline void runFunc(int fn, int x, int y, int z) {
  Instruction *instructions = mem.functions[fn];
  
  for (int i = 0; i < fnLen; ++i) {
    switch (instructions[i].opcode) {
      case RET: return;
      case MOV: break;
      case MAP: break;
      default: break;
    }
  }
}
