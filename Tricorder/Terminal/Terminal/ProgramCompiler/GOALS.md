# Primary:
* Correctness

## Short-term:
* Closures implementation
* Function composition
* * For composition to work everywhere type inference for lambdas is required
* Control flow operator `?`
* Map operator `<#>`
* * Will require multichar symbols support in tokenizer

## Backlog:
* Floating point
* Memory management
* * retain/release calls must be balanced
* Basic type inference
* Constant bindings
* Simple optimizations

### Gedanken:
* How do we simplify the language compared to C?
* Reserve the uppercase for *something*
* Should we use refrain from using keywords in favor of symbols (operators)?
* Is it even possible to GADT in such a simple language?
* Do we need protocols (interfaces)?
* * If We can't express a Monad with protocol like in Swift — then we do not
* * Structs with closures already allow polymorphism
