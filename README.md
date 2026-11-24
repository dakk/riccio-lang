# RICCIO

![GitHub Release](https://img.shields.io/github/v/release/dakk/riccio-lang)
![CI Status](https://github.com/dakk/riccio-lang/actions/workflows/ci.yaml/badge.svg)
![License: GPL 3.0](https://img.shields.io/badge/license-GPL_3.0-blue)

A recursive immutable curried compiled IO-aware language.

```python
def clean(lines):
    lines
    |> map(parse)
    |> filter(ok)
    |> sum

total = clean(read("input.txt"))
print(total)
```

Specs at [/spec](/spec).

## Targets

Riccio currently only emits Ocaml output, but I plan to use the QBE backend.

## About the author

Davide Gessa (dakk(k)*)
- https://twitter.com/dagide
- https://mastodon.social/@dagide 
- https://bsky.app/profile/dagide.bsky.social
- https://dakk.github.io/
- https://medium.com/@dakk


## License

This software is licensed with [General Public License 3.0](LICENSE).


## Cite

```
@software{ricciolang2026,
  author = {Davide Gessa},
  title = {riccio: A recursive immutable curried compiled IO-aware language},
  url = {https://github.com/dakk/riccio-lang},
  year = {2026},
}
```