extern Memory mem;

static inline void run(const int pc) {
  const int ret = mem.pc + 1;
  mem.pc = pc;
  while (true) {
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
      case INC:
      mem.rx[inst.x] += inst.y << 8 | inst.z;
      break;
      case ADD:
      mem.rx[inst.x] = mem.rx[inst.y] + mem.rx[inst.z];
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
      run(inst.y << 8 | inst.z);
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
