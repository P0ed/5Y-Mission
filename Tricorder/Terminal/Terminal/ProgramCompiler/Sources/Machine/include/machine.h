typedef enum : unsigned char {
	/// `rx[x] = yz`
	RXI,
	/// `rx[x] |= yz << 16`
	RXU,
	///  `rx[x] = rx[y]`
	RXRX,
	/// `rx[x] = stack[rx[y] + z]`
	RXST,
	/// `stack[rx[x] + y] = rx[z]`
	STRX,
	/// `rx[x] = rx[y] + rx[z]`
	ADD,
	/// `rx[x] += yz`
	INC,
	/// `rx[x] = rx[y] * rx[z]`
	MUL,
	/// `rx[x] = ~(rx[y] & rx[z])`
	NAND,
	/// `rx[x] = rx[y] << rx[z]`
	SHL,
	/// `rx[x] = rx[y] >> rx[z]`
	SHR,
	/// `top += yz`
	FRME,
	/// `closure = x`
	CLSR,
	/// `top += x; runFunction(yz)`
	FN,
	/// `top += x; runFunction(rx[y])`
	FNRX,
	/// `return`
	RET
} OPCode;

static const unsigned int closure_size = 1 << 6;
static const unsigned int stack_size = 1 << 16;

typedef union { char s; unsigned char u; struct { unsigned char reg: 6, sel: 2; }; } i8;
typedef union { short s; unsigned short u; } i16;

typedef unsigned short ptr;
typedef int word;

typedef struct {
	OPCode op;
	i8 x;
	union { i16 yz; struct { i8 y, z; }; };
} Instruction;

typedef struct {
	word *pc;

	word *top;
	word *closure;
	word *aux;
	word *base;

	unsigned char cc;
	unsigned char sortedc[255];
	unsigned char rc[255];

	word closures[256][closure_size];
	word stack[stack_size];

} Memory;

typedef struct {
	unsigned short address;
	unsigned char closure;
	unsigned char aux;
} Function;

extern Memory mem __attribute__((swift_attr("nonisolated(unsafe)")));

#define rx(x) *(*(&mem.top + x.sel) + x.reg)
#define fn(x) *((Function *)(*(&mem.top + x.sel) + x.reg))

static void (*willRun)(int) = 0;

static inline void loadProgram(const Instruction *program, int len, void (*willRunPC)(int)) {
	mem.pc = mem.stack;
	mem.top = mem.stack + len;
	mem.closure = mem.closures[0];
	mem.aux = mem.closures[0];
	mem.base = mem.stack + len;
	mem.cc = 0;

	willRun = willRunPC;

	for (unsigned char i = 0; i < 255; ++i) mem.sortedc[i] = i + 1;
	for (unsigned char i = 0; i < 255; ++i) mem.rc[i] = 0;

	for (int i = 0; i < len; ++i) mem.stack[i] = ((int *)program)[i];
}

static inline int readRegister(unsigned char reg) {
	i8 x = (i8){ .sel = 0, .reg = reg };
	return *(*(&mem.top + x.sel) + x.reg);
}

static inline Instruction readInstruction() {
	return *((Instruction *)mem.pc);
}

static inline unsigned char closure() {
	return mem.cc < 255 ? mem.sortedc[mem.cc++] : 0;
}

static inline void retain(unsigned char closure) {
	mem.rc[closure] += 1;
}

static void release(unsigned char closure) {
	if ((mem.rc[closure] -= 1) != 0) return;

	mem.cc -= 1;
	for (char i = mem.cc; i >= 0; --i) if (mem.sortedc[i] == closure) {
		if (i == mem.cc) return;
		mem.sortedc[i] = mem.sortedc[mem.cc];
		mem.sortedc[mem.cc] = closure;
		return;
	}
}

static inline int runFunction(const Function function, const int frame) {
	word *const ret = mem.pc;
	word *const stk = mem.top;
	mem.top += frame;
	mem.pc = mem.stack + function.address;
	mem.closure = mem.closures[function.closure];

	static int idx = 0;
	while (idx++ < (1 << 12)) {
		Instruction inn = *((Instruction *)mem.pc);
		willRun((int)(long)mem.pc - (int)(long)mem.stack);

		switch (inn.op) {
			case RXI:
				rx(inn.x) = inn.yz.u;
				break;
			case RXU:
				rx(inn.x) |= inn.yz.u << 16;
				break;
			case RXRX:
				rx(inn.x) = rx(inn.y);
			case RXST:
				rx(inn.x) = mem.stack[rx(inn.y) + inn.z.u];
				break;
			case STRX:
				mem.stack[rx(inn.x) + inn.y.u] = rx(inn.z);
				break;
			case ADD:
				rx(inn.x) = rx(inn.y) + rx(inn.z);
				break;
			case INC:
				rx(inn.x) += inn.yz.u;
				break;
			case MUL:
				rx(inn.x) = rx(inn.y) * rx(inn.z);
				break;
			case NAND:
				rx(inn.x) = ~(rx(inn.y) & rx(inn.z));
				break;
			case SHL:
				rx(inn.x) = rx(inn.y) << rx(inn.z);
				break;
			case SHR:
				rx(inn.x) = rx(inn.y) >> rx(inn.z);
				break;
			case FRME:
				mem.top += inn.yz.s;
				break;
			case CLSR:
				mem.aux = mem.closures[inn.x.u];
				break;
			case FN: {
				int r = runFunction((Function){ .address = inn.yz.u }, inn.x.u);
				if (r) return r; else break;
			}
			case FNRX: {
				Function f = fn(inn.y);
				int r = runFunction(f, inn.x.u);
				if (r) return r; else break;
			}
			case RET:
				mem.pc = ret;
				mem.top = stk;
				return 0;
			default:
				return -2;
		}

		mem.pc += 1;
	}
	return -1;
}
