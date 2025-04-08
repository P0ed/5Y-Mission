let testProgram = """
: person = (id: int, name: char 24);

[ id: int = 255;
[ p: person = (id, "P0ed");

[ count: int = 0;
[ square: int > int = \\x > {
	x * x
};

; [ add: int > int > int = \\x > { \\y > { x + y } };
; count = square # 3;

count = count + 1;

print # "Hello, World!"

"""
