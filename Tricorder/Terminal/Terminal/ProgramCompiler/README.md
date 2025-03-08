#### Program language:
======================

```
// type def
id = int;

// struct def
person = (
	char 31 name,
	char 31 email
);

// static arrays
int 4 quad = [0, 0, 0, 0];

// counters
int cnt = 0;
cnt += 1;

// function decl and closure assignment
void <- int inc = x -> cnt = cnt + x;

// compound expression closure with flattened struct input
int <- person len = -> {
	// # — low priority call operator
	// returns last expression
	count # name + email
};

// functions are srored in argument types namespece
int <- char 31 len -> {
	enumerated first -> idx, ch { 

	}
}

// anonymous struct assignment if matches type
person p = (name: "Kostya", email: "x@y.z");

// function composition
void <- person inc_by_len = inc . len;


// equivalent function calls
int lx = len p; inc lx;
inc len p;
inc . len p;
inc . len # p;
inc # len # p;
```
