# กุ้ง programming language:

Kung is a simple C/Swift inspired language with static typing system,
executed in VM, written in C that runs on Arduino or similar low spec hardware.

## Example code:

```
; The line that starts with `;` is a comment

; Type def starts with `:` identifer `=` <type>
: id = int;

; Fixed size array with 32 elements of type `char`
: string = char 32;

; Struct def works by assigning a tuple to an identifier
: person = (
	identifier: id,
	name: string,
	email: string
);

; `[` is a variable declaration token
[ quad: int 4 = (0, 0, 0, 0);

; Character literal
[ letter: char = "A";

; A counter
[ cnt: int = 0;
cnt = cnt + 1;

; Function decl as a lambda expression
[ inc: int > void = \x > cnt = cnt + x;

; Compound function with flattened struct input,
; where each member of the struct is accessible by name directly.
[ len: person > int = \_ > {
	; `#` is a function call operator with priority
	; higher than assignment but lower than everything else.
	; The last expression is returned
	count # name + email
};

; Function composition for point free notation
[ inc_by_len: person > void = inc • len;

; Can assign a tuple to struct variable if matches labels and types
[ p: person = (id: 0xFF, name: "Kostya", email: "kostya@me.com");

; Equivalent function calls
inc(len(p));
(inc • len)(p);
inc • len # p;
inc # len # p
```
