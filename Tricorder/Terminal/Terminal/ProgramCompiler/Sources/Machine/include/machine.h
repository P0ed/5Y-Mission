typedef char s8;
typedef unsigned char u8;
typedef short s16;
typedef unsigned short u16;
typedef int s32;
typedef unsigned int u32;
typedef long long s64;
typedef unsigned long long u64;
typedef s32 word;

typedef union { s8 s; u8 u; struct { u8 reg: 6, sel: 2; }; } i8;
typedef union { s16 s; u16 u; } i16;

typedef enum : u8 {
	RXI,
	RXU,
	RXRX,
	RXST,
	STRX,
	ADD,
	SUB,
	INC,
	MUL,
	DIV,
	MOD,
	NAND,
	SHL,
	SHR,
	PRNT,
	FRME,
	CLMK,
	CLRT,
	CLRL,
	AUX,
	FN,
	FNRX,
	RET,
	BREK
} OPCode;

typedef struct {
	OPCode op;
	i8 x;
	union { i16 yz; struct { i8 y, z; }; };
} Instruction;

static const u32 closure_size = 1 << 6;
static const u32 stack_size = 1 << 16;

typedef struct {
	word *pc;

	word *top;
	word *closure;
	word *aux;
	word *base;

	// Number of used closures
	u8 cc;
	// Fast array of closure indices
	u8 sortedc[255];
	// Reference counters for closures
	u8 rc[255];

	// User closures from index 1 to 255. Closure 0 is reserved
	word closures[256][closure_size];
	word stack[stack_size];

} Memory;

typedef struct {
	u16 address;
	u8 reserved;
	u8 closure;
} Function;

extern Memory mem __attribute__((swift_attr("nonisolated(unsafe)")));

// Breakpoint callback will be called only in debug configuration
static s32 (*willRun)(const u16, const Instruction) = 0;
// Print function
static void (*prnt)(const char *const) = 0;
// Counter for preventing infinite loops
static s32 tick = 0;

// Register access
#define rx(x) *(*(&mem.top + x.sel) + x.reg)
// Function access
#define fn(x) *((Function *)(*(&mem.top + x.sel) + x.reg))

// Closure allocation
static inline u8 alloc() {
	return mem.cc < 255 ? mem.sortedc[mem.cc++] : 0;
}

// Ref count increase
static inline void retain(const u8 closure) {
	mem.rc[closure] += 1;
}

// Ref count decrease with dealloc if reached zero
static void release(const u8 closure) {
	if (closure == 0 || --(mem.rc[closure]) != 0) return;

	mem.cc -= 1;
	for (char i = mem.cc; i >= 0; --i) if (mem.sortedc[i] == closure) {
		if (i == mem.cc) return;
		mem.sortedc[i] = mem.sortedc[mem.cc];
		mem.sortedc[mem.cc] = closure;
		return;
	}
}

// Runs a function with address function.address and assigns a closure
static inline s32 runFunction(const Function function, const s32 frame) {
	word *const ret = mem.pc;
	word *const stk = mem.top;
	word *const clr = mem.closure;

	mem.top += frame;
	mem.pc = mem.stack + function.address;
	mem.closure = mem.closures[function.closure];

	while (tick++ < (1 << 12)) {
		Instruction inn = *((Instruction *)mem.pc);

		s32 halt = willRun((u16)(((long)mem.pc - (long)mem.stack) >> 2), inn);
		if (halt) return halt;

		switch (inn.op) {
			case RXI:
				rx(inn.x) = inn.yz.u;
				break;
			case RXU:
				rx(inn.x) |= inn.yz.u << 16;
				break;
			case RXRX:
				rx(inn.x) = rx(inn.y);
				break;
			case RXST:
				rx(inn.x) = mem.stack[rx(inn.y) + inn.z.u];
				break;
			case STRX:
				mem.stack[rx(inn.x) + inn.y.u] = rx(inn.z);
				break;
			case ADD:
				rx(inn.x) = rx(inn.y) + rx(inn.z);
				break;
			case SUB:
				rx(inn.x) = rx(inn.y) - rx(inn.z);
				break;
			case INC:
				rx(inn.x) += inn.yz.u;
				break;
			case MUL:
				rx(inn.x) = rx(inn.y) * rx(inn.z);
				break;
			case DIV:
				rx(inn.x) = rx(inn.y) / rx(inn.z);
				break;
			case MOD:
				rx(inn.x) = rx(inn.y) % rx(inn.z);
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
			case PRNT:
				prnt((const char *const)&rx(inn.x));
				break;
			case FRME:
				mem.top += inn.yz.s;
				break;
			case CLMK: {
				const u8 closure = alloc();
				mem.aux = mem.closures[closure];
				rx(inn.x) = closure << 24 | inn.yz.u;
				break;
			}
			case CLRT:
				retain(rx(inn.x) >> 24);
				break;
			case CLRL:
				release(rx(inn.x) >> 24);
				break;
			case AUX:
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
				mem.closure = clr;
				return 0;
			case BREK:
				break;
			default:
				return -2;
		}

		mem.pc += 1;
	}
	return -1;
}

// Loads instructions onto stack. Assigns callbacks. Runs the program
static inline s32 runProgram(const Instruction *const program,
							 const u16 len,
							 s32 (*const willRunInstruction)(const u16, const Instruction),
							 void (*const print)(const char *const)) {
	if (!len) return -1;
	const int last = len - 1;

	mem.pc = mem.stack + program[last].yz.u;
	mem.top = mem.stack + last;
	mem.closure = mem.closures[0];
	mem.aux = mem.closures[0];
	mem.base = mem.stack + last;
	mem.cc = 0;

	for (unsigned char i = 0; i < 255; ++i) mem.sortedc[i] = i + 1;
	for (unsigned char i = 0; i < 255; ++i) mem.rc[i] = 0;
	for (int i = 0; i < last; ++i) mem.stack[i] = ((word *)program)[i];

	willRun = willRunInstruction;
	prnt = print;
	tick = 0;

	return runFunction((Function){ .address = program[last].yz.u }, 0);
}

// External access to registers for debug purpuses
static inline int readRegister(const u8 sel, const u8 reg) {
	i8 x = (i8){ .sel = sel, .reg = reg };
	return rx(x);
}
