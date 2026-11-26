# TODO

## Parser: spec constructs not parseable yet

- [ ] Block `if cond:` / `else:` with indented branches - if-rule has no INDENT/DEDENT, only flat bodies or the ternary parse
- [ ] IO effect annotations (`def ask() -> IO str`, `def print(s: str): IO unit`) - IO token unused
- [ ] Multi-expression bodies (`print("name?")` then `read_line()`) - `block` is a single expr; only let/def chains work
- [ ] Nested `def` as the last expression of a body - expr-level def rule requires a trailing expr
- [ ] Top-level expression statements (`sum(5)`, `std.print()`) - `program` is defs only

## Correctness bugs (parse but wrong AST)

- [ ] `(e)` grouping parses as a 1-tuple `ETuple [e]` - no single-element paren case


## Backend

- [ ] Gen_ml: utility for compiling to native
- [ ] Gen_ml: match case translation

## Tests / infra
