We are designing a simple programming language with compiler and VM.

Compiler is written in Swift and VM is in C for targeting embedded ARM
microcontrollers like Arduino C33 200MHz CPU with 512KB SRAM and 16MB Flash.

The goal is to compile text on a laptop/smartphone (macOS/iOS) into bytecode,
then send the instructions via BLE/WiFi to the microcontroller and execute them there.
The hardware setup and workflow will be similar to Monome Crow,
except for a compiler running on an external device.
Performance wise I'd like to beat Lua, implementing minimum optimisations to keep things simple.
This project only touches the program compilation and execution,
leaving aside any means of communication between devices.

The language is C/Swift inspired with static typing system.
Only static allocation out of the box, with a special case for closures.

Closures are preallocated behind the stack and limited in quantity and size
(255 clusures available to user for dynamic allocation + one preallocated reserved closure).

Exceeding closures count is a runtime error. Exceeding closure size is a compile-time error.
Closure size is 64 words. Word size is 32bit.

Pointers are 16bit and minimum offset is a word. Stack size is 256 * 256 * 4 bytes
(256KB is a half of available SRAM). Closures take up an additional 64 * 256 * 4 bytes (64KB).
Leaving the rest (192KB) to the C runtime.

Instructions are 32bits wide, with the following layout:
	`opcode: UInt8, x: UInt8, y: UInt8, z: UInt8`.
Some instructions combine `y` and `z` to `yz: UInt16`

Two bits from either `x`, `y` or `z` encode the selector and the remaining 6 bits represent
the register address.

Selectors:
* 0b00 —> top of the stack
* 0b01 —> current closure
* 0b10 —> auxilary closure
* 0b11 —> bottom of the stack

That way it is possible to reference any word in current and aux closures,
and 64 first and last words from the stack in any instruction.

Closures are reference-counted and have reference semantics. The rest has value semantics.

Function can capture one closure. Same closure can be captured by different functions.
When function is called, it's closure, becomes current. Function is static when `closure == 0`.

Function layout:
	`address: UInt16, closure: UInt8, reserved: UInt8`
