# Program language concept:

Simple C/Swift inspired language with static typing system,
executed in VM, written in C that runs on Arduino or similar low spec hardware.

Only static allocation out of the box, with a special case for closures.
Closures are preallocated behind the stack and limited in quantity and size (255 clusures available to user).
Exceeding closures count is a runtime error. Exceeding closure size is a compile time error.
Closure size is 64 words. Word size is 32bit.

## Example code:

```
// Type def starts with `:` identifer `=` <type>
: id = int;

// Fixed size array with 32 elements of type `char`
: string = char 32;

// Struct def works by assigning a tuple to an identifier
: person = (
	identifier: id,
	name: string,
	email: string
);

// `[` is a variable declaration token
[ quad: int 4 = [0, 0, 0, 0];

// A counter
[ cnt: int = 0;
cnt += 1;

// Function decl and closure assignment
[ inc: int > void = \x > cnt = cnt + x;

// Compound expression closure with flattened struct input.
[ len: person > int = \_ > {
	// `#` is a function call operator with priority
	// higher than assignment but lower than everything else.
	// The last expression is returned
	count # name + email
};

// Function composition for point free notation
[ inc_by_len: person > void = inc * len;

// Can assign a tuple to struct variable if matches labels and types
[ p: person = (id: 420, name: "Kostya", email: "kostya420@me.com");

// Equivalent function calls
inc(len(p));
(inc * len)(p);
inc * len # p;
inc # len # p;
```
