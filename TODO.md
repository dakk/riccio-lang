# TODO

Discrepancies found by running every SPEC.md example through `parser.mly` -> `Ast`
(see test/units/*.ric, one rule per file; `# TODO` marks files that currently fail).

## Parser: spec constructs not parseable yet

- [ ] Block `if cond:` / `else:` with indented branches — if-rule has no INDENT/DEDENT, only flat bodies or the ternary parse
- [ ] `match` / `case` with guards (`case (c, 12) if c < 12:`) and wildcard `_` — MATCH / CASE / UNDERSCORE unused
- [ ] IO effect annotations (`def ask() -> IO str`, `def print(s: str): IO unit`) — IO token unused
- [ ] Bodyless def declarations (`def print(s: str): IO unit`) — grammar requires a block
- [ ] Multi-expression bodies (`print("name?")` then `read_line()`) — `block` is a single expr; only let/def chains work
- [ ] Nested `def` as the last expression of a body — expr-level def rule requires a trailing expr
- [ ] Top-level expression statements (`sum(5)`, `std.print()`) — `program` is defs only

## Correctness bugs (parse, but wrong AST)

- [ ] `(e)` grouping parses as a 1-tuple `ETuple [e]` — no single-element paren case

## Tests / infra
