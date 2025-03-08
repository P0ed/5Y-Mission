typedef struct {
  int pc = 0;
  int sc = 0;
  
  int rx[256];
  int stack[256 * 256];

} Memory;
