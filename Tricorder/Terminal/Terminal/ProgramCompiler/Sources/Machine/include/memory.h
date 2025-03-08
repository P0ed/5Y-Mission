typedef struct {
	int pc;
	int sc;

	int rx[256];
	int stack[256 * 256];

} Memory;
