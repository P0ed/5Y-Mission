typedef enum : unsigned char {
	/// `rx[x] = y << 8 | z`
	RXI = 0x00,
	/// `rx[x] |= y << 24 | z << 16`
	RXU = 0x01,
	RXRX = 0x02,
	RXST = 0x03,
	STRX = 0x04,
	STI = 0x05,
	STU = 0x06,
	POP = 0x07,
	ADD = 0x08,
	INC = 0x09,
	MUL = 0x0A,
	NAND = 0x0B,
	SHL = 0x0C,
	SHR = 0x0D,

	FN = 0xFE,
	RET = 0xFF
} OPCode;

typedef struct {
	OPCode op;
	unsigned char x;
	unsigned char y;
	unsigned char z;
} Instruction;

typedef struct {
	int pc;
	int sc;

	int rx[256];
	int stack[256 * 256];

} Memory;

extern Memory mem __attribute__((swift_attr("nonisolated(unsafe)")));

static inline void runFunction(const int pc) {
	const int ret = mem.pc + 1;
	mem.pc = pc;
	while (1) {
		Instruction inst = *((Instruction *)(mem.stack + mem.pc));
		mem.pc += 1;
		
		switch (inst.op) {
			case RXI:
				mem.rx[inst.x] = inst.y << 8 | inst.z;
				break;
			case RXU:
				mem.rx[inst.x] |= (inst.y << 8 | inst.z) << 16;
				break;
			case RXRX:
				mem.rx[inst.x] = mem.rx[inst.y];
				break;
			case RXST:
				mem.rx[inst.x] = mem.stack[mem.rx[inst.y] + inst.z];
				break;
			case STRX:
				mem.stack[mem.rx[inst.x] + inst.y] = mem.rx[inst.z];
				mem.sc = mem.rx[inst.x] + inst.y < mem.sc ? mem.sc : mem.rx[inst.x] + inst.y;
				break;
			case STI:
				mem.stack[mem.sc] = inst.y << 8 | inst.z;
				mem.sc += 1;
				break;
			case STU:
				mem.stack[mem.sc - 1] |= (inst.y << 8 | inst.z) << 16;
				break;
			case POP:
				mem.sc -= inst.y << 8 | inst.z;
				break;
			case ADD:
				mem.rx[inst.x] = mem.rx[inst.y] + mem.rx[inst.z];
				break;
			case INC:
				mem.rx[inst.x] += inst.y << 8 | inst.z;
				break;
			case MUL:
				mem.rx[inst.x] = mem.rx[inst.y] * mem.rx[inst.z];
				break;
			case NAND:
				mem.rx[inst.x] = ~(mem.rx[inst.y] & mem.rx[inst.z]);
				break;
			case SHL:
				mem.rx[inst.x] = mem.rx[inst.y] << mem.rx[inst.z];
				break;
			case SHR:
				mem.rx[inst.x] = mem.rx[inst.y] >> mem.rx[inst.z];
				break;
			case FN:
				runFunction(inst.y << 8 | inst.z);
				break;
			case RET:
				mem.pc = ret;
				mem.sc -= inst.y << 8 | inst.z;
				return;
			default:
				break;
		}
	}
}

static inline void loadProgram(const Instruction *program, const int len) {
	for (int i = 0; i < len; ++i) mem.stack[i] = ((int *)program)[i];
	mem.sc = len;
	mem.pc = 0;
}
