# Working on lishp-flick

A Lishp interpreter written in Flick. `std.lsp` and `examples/` are copied
from [bondiano/lishp](https://github.com/bondiano/lishp) and must not change.

## Checks

```sh
flick build --project . --emit go   # must end with "Success!" and no warnings
flick test --project . --emit go    # 15 tests
./verify.sh                         # examples, byte for byte
```

The compiler must be built from the same `flick-lang` checkout as
`packages/std`. A compiler older than `std` fails with `FLICK-P043`; run
`cargo install --path flick --force` in that checkout, not a released tag.
The Go target needs `go` on `PATH` and the grant in `flick.toml`:
`[tools] "flick/go" = ["go"]` (without it the build fails with `FLICK-P029`).

## Where code goes

- `src/App/Main.fl`: the entry point only.
- `src/App/Commands.fl`: every `cli` block and its flags, arguments and
  subcommands. No evaluation and no I/O here.
- `src/App/Handlers.fl`: the work behind the commands and the REPL.
- `src/Lishp/Value.fl`: the value model, the environment and its mutation.
- `src/Lishp/Parser.fl`: text to values.
- `src/Lishp/Operators.fl`: the binary operators and predicates.
- `src/Lishp/Parameters.fl`: the parameter list of `lambda`, `dambda` and
  `macro`.
- `src/Lishp/Eval.fl`: evaluation, the special forms and macro expansion.

## Conventions

- A mapping from constructors or words to constants is a `match` that
  returns one value per arm. The linter measures it as a table (complexity 1
  in the compiler this project builds against); it is still exhaustive.
- `if`/`else if` chains for constant mappings are rewritten as `match`.
- Keep a function under 60 lines, 10 branches and 4 nested `if`/`match`
  levels. Split a special form into its own `special_*` helper instead of
  growing `special`.
- `special` is a dispatcher: each arm calls a helper and nothing else.
- `_` on a type of another module is fine. On `Value` in `Value.fl` it
  hides constructors: `[lint] allow = ["FLICK-T055"]` covers the two arms
  that deliberately treat everything else alike (`truthy`, `repr`).
- Errors are `String` throughout. `?` needs an error declared with
  `type error`, so sequencing a `Result String` uses explicit matches.
  Split a two-step chain into a helper (for example `eval_second`,
  `eval_rest`) so the linter does not read it as `flat_map` (T035), and
  do not reach for `do`: a `do` continuation must be pure, and evaluation
  is effectful.
- A wildcard binding (`other ->`) is not a wildcard pattern for the linter;
  write `_` when the value is unused and name it when it is used.

## Known non-FP spots

- `Env` is a `Ref` of an association list, mutated by `env_define`,
  `env_set` and `env_remove`. This is the Lisp environment; it is not a
  functional map. Keep all mutation in `Lishp.Value`.
- The effect row `{Async, Terminal.Terminal, File.FileSystem, Host.Console}`
  is repeated verbatim on every evaluator helper because Flick has no
  effect-row alias.
- Declaring `type error EvalError = EvalError String` would let the
  evaluator use `?` and remove most of the explicit error plumbing. It
  touches every module and the tests, so it is a deliberate future change,
  not a drive-by one.
- Macros expand by mutating the call environment (`expand_call` saves and
  restores bindings). The save/restore is explicit; keep it in one place.
