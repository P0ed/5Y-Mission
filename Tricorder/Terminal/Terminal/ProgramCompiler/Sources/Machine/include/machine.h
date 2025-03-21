typedef enum : unsigned char {
	/// `rx[x] = y << 8 | z`
	RXI = 0x00,
	/// `rx[x] |= (y << 8 | z) << 16`
	RXU = 0x01,
	/// `rx[x] = stack[rx[y] + z]`
	RXST = 0x02,
	/// `stack[rx[x] + y] = rx[z]`
	STRX = 0x03,
	/// `rx[x] = rx[y] + rx[z]`
	ADD = 0x04,
	/// `rx[x] += y << 8 | z`
	INC = 0x05,
	/// `rx[x] = rx[y] * rx[z]`
	MUL = 0x06,
	/// `rx[x] = ~(rx[y] & rx[z])`
	NAND = 0x07,
	/// `rx[x] = rx[y] << rx[z]`
	SHL = 0x08,
	/// `rx[x] = rx[y] >> rx[z]`
	SHR = 0x09,
	/// `runFunction(x, y << 8 | z)`
	FN = 0xFE,
	/// `return`
	RET = 0xFF
} OPCode;

typedef union { char s; unsigned char u; } i8;
typedef union { short s; unsigned short u; } i16;

typedef struct {
	OPCode op;
	i8 x;
	union { i16 yz; struct { i8 y, z; }; };
} Instruction;

typedef struct {
	int pc;
	int sc;

	unsigned char cc;
	unsigned char sortedc[128];
	unsigned char rc[128];
	int closures[128][4];

	int stack[256 * 256];

} Memory;

extern Memory mem __attribute__((swift_attr("nonisolated(unsafe)")));

#define stack mem.stack
#define sc mem.sc
#define pc mem.pc
#define rx (stack + sc)

static inline void loadProgram(const Instruction *program, const int len) {
	sc = len;
	pc = 0;
	for (int i = 0; i < len; ++i) stack[i] = ((int *)program)[i];
	for (char i = 0; i > 0; ++i) mem.sortedc[i] = i;
	for (char i = 0; i > 0; ++i) mem.rc[i] = 0;
}

static inline int readRegister(char idx) { return rx[idx]; }

static inline char closure() {
	return mem.cc == 127 ? -1: mem.sortedc[mem.cc++];
}

static inline void retain(char closure) {
	mem.rc[closure] += 1;
}

static void release(char closure) {
	if ((mem.rc[closure] -= 1) != 0) return;

	mem.cc -= 1;
	for (char i = mem.cc; i >= 0; --i) if (mem.sortedc[i] == closure) {
		if (i == mem.cc) return;
		mem.sortedc[i] = mem.sortedc[mem.cc];
		mem.sortedc[mem.cc] = closure;
		return;
	}
}

static inline int runFunction(const int frame, const int function) {
	const int ret = pc;
	sc += frame;
	pc = function;

	while (1) {
		Instruction inst = *((Instruction *)(stack + pc));

		switch (inst.op) {
			case RXI:
				rx[inst.x.u] = inst.yz.u;
				break;
			case RXU:
				rx[inst.x.u] |= inst.yz.u << 16;
				break;
			case RXST:
				rx[inst.x.u] = stack[rx[inst.y.u] + inst.z.u];
				break;
			case STRX:
				stack[rx[inst.x.u] + inst.y.u] = rx[inst.z.u];
				break;
			case ADD:
				rx[inst.x.u] = rx[inst.y.u] + rx[inst.z.u];
				break;
			case INC:
				rx[inst.x.u] += inst.yz.u;
				break;
			case MUL:
				rx[inst.x.u] = rx[inst.y.u] * rx[inst.z.u];
				break;
			case NAND:
				rx[inst.x.u] = ~(rx[inst.y.u] & rx[inst.z.u]);
				break;
			case SHL:
				rx[inst.x.u] = rx[inst.y.u] << rx[inst.z.u];
				break;
			case SHR:
				rx[inst.x.u] = rx[inst.y.u] >> rx[inst.z.u];
				break;
			case FN:
				if (runFunction(inst.x.u, inst.yz.u)) return 1;
				break;
			case RET:
				pc = ret;
				sc -= frame;
				return 0;
			default:
				break;
		}

		pc += 1;
	}
	return 1;
}
