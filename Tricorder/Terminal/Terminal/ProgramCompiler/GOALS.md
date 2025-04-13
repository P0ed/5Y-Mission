# Primary:
* Correctness

## Short-term:
* Closures implementation
* Function composition
* * For composition to work everywhere type inference for lambdas is required
* Control flow operator `?`
* Map operator `<#>`
* * Multichar symbols support in tokenizer

## Backlog:
* Floating point
* Memory management
* * retain/release calls must be balanced
* Basic type inference
* Constant bindings
* Simple precompile optimizations
* * Replace `.binary` containing constants with a constant
* * Replace `f • g # x` with `f # g # x`

## Gedanken:
* How do we simplify the language compared to C?
* Reserve the uppercase for *something*
* Should we use refrain from using keywords in favor of symbols (operators)?
* Is it even possible to GADT in such a simple language?
* Rename `int` to `i32`, `float` to `f32`, `bool` to `bit`?
* * Do we need `true`, `false` literals or will do just fine with `0` and `1`?
* * Maybe even `0b0` and `0b1`
* Do we need protocols (interfaces)?
* * If We can't express a `Monad` with protocol (like in Swift) — then we do not
* * Structs with closures already enable polymorphism
