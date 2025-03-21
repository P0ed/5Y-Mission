public let testProgram = """
// int k[256] = { 0, 1, 2 };

// rx[0] = 0
int cnt: 0;

// rx[0] = rx[0] + 1
cnt = cnt + 1;

// static function
// rx[1] = f[0]
int < int square: { x |
	// rx[0] = rx[1] * k[2]
	x * 2
};

// rx[2] = fn[1]
int < int < int add: { x | { y | x + y } };

// runFunction(3, rx[1])
int x: square(2)

"""
