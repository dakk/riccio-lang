# TODO

Discrepancies found by running every SPEC.md example through `parser.mly` -> `Ast`
(see tests/units/*.ric, one rule per file; `# TODO` marks files that currently fail).

## Parser: spec constructs not parseable yet

- [ ] Block `if cond:` / `else:` with indented branches — if-rule has no INDENT/DEDENT, only flat bodies or the ternary parse
- [ ] List literal `[1, 2, 3]` — no rule in `expr`
- [ ] Cons `::` and list concat `++` — CONS / PLUSPLUS / APPEND / MERGE tokens unused
- [ ] Record literal `{ name: "Davide", age: 34 }` — records only exist in `typeexpr`
- [ ] Field/module access `pp.name`, `std.print()` — DOT token unused
- [ ] Record update `p with { age: ... }` — no rule (`with` lexes as plain IDEN)
- [ ] Union constructors with args, e.g. `type option['a] = Some('a) | None` — lexer bug: `iden` rule shadows `capid`, so CAPID is unreachable and the unionelement rule can never match
- [ ] Lambda `lambda (x) -> x + 1` — LAMBDA token unused
- [ ] `match` / `case` with guards (`case (c, 12) if c < 12:`) and wildcard `_` — MATCH / CASE / UNDERSCORE unused
- [ ] Pipeline `read_line() |> trim |> print` — PIPEGT unused
- [ ] IO effect annotations (`def ask() -> IO str`, `def print(s: str): IO unit`) — IO token unused
- [ ] Bodyless def declarations (`def print(s: str): IO unit`) — grammar requires a block
- [ ] Multi-expression bodies (`print("name?")` then `read_line()`) — `block` is a single expr; only let/def chains work
- [ ] Nested `def` as the last expression of a body — expr-level def rule requires a trailing expr
- [ ] Top-level expression statements (`sum(5)`, `std.print()`) — `program` is defs only
- [ ] Future features: hole `_` in exprs, `?` unroller, `against` blocks — not lexable/parseable yet

## Correctness bugs (parse, but wrong AST)

- [ ] Lexer keeps layout state in global refs (`indent_stack`, `paren_depth`, `pending`, `bol`, `nl_pending`) and never resets it — parsing a second file in the same process starts from dirty state; add a reset in `Parse.parse`/`parse_file`

- [ ] Operator precedence/associativity: all `%left`/`%nonassoc` commented out, 337 shift/reduce conflicts resolved by shift — `1*2+3` -> `1*(2+3)`, `10-3-2` -> `10-(3-2)`, `a and b or c` -> `a&&(b||c)`, `not a and b` -> `!(a&&b)`
- [ ] `(e)` grouping parses as a 1-tuple `ETuple [e]` — no single-element paren case

## Tests / infra

