# lishp-flick

The [lishp](https://github.com/bondiano/lishp) Lisp interpreter rewritten in
[Flick](https://github.com/bondiano/flick-lang), compiled to a standalone Go
executable. `std.lsp` and every example of the original work unchanged.

The interpreter reads Lishp source at run time: it is the same dynamically
typed language, not a translation of the examples into Flick. The command
line itself is a Flick `cli` block, and `flick build --emit go` turns the
whole program into one binary.

## Build and run

```sh
# from a flick-lang checkout, with the compiler on PATH
flick build --project . --emit go
./dist/flick-main run examples/test_factorial.lsp     # reads a number on stdin
./dist/flick-main run --eval '(print (range 1 5))'    # (1 2 3 4)
./dist/flick-main repl
```

`flick run --project . -- run examples/test_simple.lsp` builds and runs in
one step, and `flick test --emit go` runs the tests on the Go backend.

## Where `std.lsp` comes from

`std.lsp` is loaded before every expression and file, in this order: the path
in `LISHP_STD_PATH`, then `./std.lsp`, then `~/.lishp/std.lsp`. None found
means the program runs without it, as in the original.

## The language

`src/Lishp/Value.fl` is the value model (numbers, strings, symbols, lists,
lexical `lambda`, dynamic `dambda`, `macro`, the special forms and the
binary operators), `src/Lishp/Parser.fl` reads source text into values, and
`src/Lishp/Eval.fl` evaluates them: environments are frames of bindings
behind `Ref`s, closures keep the frame they were built in, and macros expand
in the environment of their call. `src/App/Main.fl` is the `run`/`repl`
command line.

### Differences from the original

- Integers are arbitrary-precision (`BigInt`); the original uses `i64` and
  wraps or panics at its bounds. Arithmetic, division and comparison behave
  the same below that bound.
- Floats print through Flick's `show`; the original prints Rust's `Display`.
  They agree on everyday values and can differ in exponent form (`1e+21`).
- Error messages are worded differently, and `run` reports an undefined
  variable as an error where the original exits quietly.
- `read` at end of input fails with an error instead of an I/O error.

## Tests

```sh
flick test --emit go    # 15 tests: the parser and the evaluator
./verify.sh             # the examples of the original, with expected output
```

## Credit

`std.lsp`, `examples/` and the language itself come from
[bondiano/lishp](https://github.com/bondiano/lishp). The Flick compiler is
[bondiano/flick-lang](https://github.com/bondiano/flick-lang).
