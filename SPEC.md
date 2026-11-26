# Specifications

This new language is mostly inspired by OCaml and Python syntax

- strict typing, infer system at compile time
- immutable data (let binding)
- possibly compatibilty with existing python libs, still undecided
- QBE compiler backend
- function bodies are expression, last is returned, intermediate should be unit type 
- eval? eagerly (but lazy type possible)


## Immutability

There are no variables, x = is a let binding
Last espression is what it is returned; intermediate expression should be of type unit, or
the result should be passed to ignore().

## Recursion

TCO is guaranteed by the compiler; if it can't, a warning is shown.
Keyword rec is used to bind the function itself in the body context.


```py
def rec fact(x):
    if x == 0:
        1 
    else:
        x * fact(x - 1)
```

Inferred type is int, since x - int = int (or maybe also float) (TODO)


## Currying by default

```py
def sum(x, y): # int -> int -> int
    x + y 
    

sum(5) # this is a int -> int

f(sum(5)) # f receives a (int -> int)
```


## Typing

Types are defined using the type keyword.

### Base types

#### unit
Type unit has only one value `()`. No operation is defined on it.

#### bool

Values: `True, False`
Operations: `True and False or not False`


#### int

Values: `12, -148`
Operations: `+, -, *, /, %`

#### float

Values: `12.3, -148.44`
Operations: `+, -, *, /, %`


#### str

Values: `"hello riccio"`
Join two strings: `"ciao" + "riccio"`


#### bytes

Values: `b"hello riccio"`
Join two bytes: `b"ciao" + b"riccio"`


### Tuple

```py
type t = int * float 
c = (12, 13.0)
```

Operations: `c[0], c[1]`


### List 

```py 
a: list[int] = [1, 2, 3]
```

Add value: `b = 3 :: a`

Concat two lists: `c = a + [3, 4]`


### Record 

```python
pp: { name: str, age: int } = { name: "Davide", age: 34 }

def birthday(person: pp):
    a | { age: pp.age + 1 }
```


### Functions

Functions always have a parameters; if `()` is provided, the parameter is unit:

```py
def v():
    ()

# v: unit -> unit
```

```py
def v (c: int) -> int * int:
    (c * 2, c / 2)

# v: int -> int
```

### Data constructors, generic types and unions

Data constructors are supported, as long with generic types (prefixed by ')

```ocaml
type option['a] = Some('a) | None

Some(5) # int option
```

```ocaml
type tupled['a, 'b] = 'a * 'b

b: tupled[str, int] = ("ciao", 12)
```


### If

```py
if cond:
    val1
else:
    val2
```

```py
x = val1 if cond else val2
```

### Lambdas

```py
inc = lambda (x) -> x + 1
# inc: int -> int
```

## Pattern matching

```py
match val with
    case 1: 'hola'
    case 2: 'ciao'
    case _: 'hello'
```

Match complex types (union, tuples, list)

```py
match val:
    case Some(a): a
    case None:    0
        
match atuple:
    case (c, 12) if c < 12:
        1
    case (12, 12):
        0
    case (c, _):
        2

match alist:
    case a::xl:
        a
    case []:
        'empty'
```

Multiple match with |:

```py
match astring:
    case "A" | "B": "alpha"
    case "Z":       "zeta"
    case _:         "?"
```
        
## Pipeline operator

```py
read_line() |> trim |> parse_int |> fact |> print
```

## Failable results

There are no exception, but we define a failable result:

```py
type result['a, 'e] = Ok('a) | Error('e)
```


## Impure functions

Types are represented internally with (value_type, effects); we can define IO
function with side effects.

```py
def print(s: str): IO unit

def greet(name):      # name is pure
    "hello " + name

def ask(): IO str  # inferred automatically
    print("name?")
    read_line()
```



## Files are modules

Files are modules, and import convention is inherited by python:

```py
import std

std.print()
```

or 

```py
from std import print

print()
```




## Future features

### Against function testing

```py
def rec fact ...

against fact:
    property: fact(x) >= 1
    property: fact(x) * x == fact(x + 1) 
```


### Holes

Compiler will suggest what are the possible things from the env to be put instead of _

```py
def test(a: int):
    _ * 2
```

### Question unroller (?)

This sugar allow to unroll an expression that returns Ok | Err. If the result
is ok, continue, otherwise returns the Err instead. It solves the Ok | Err 
cascading hell. This is translated as:

```ocaml
match r with Ok(v) -> cc = v; next_expr | Err -> r
```

### Bultin functions

Builtin functions are inherited from python:

```py
input()
# unit -> IO[string]

print(s)
# string -> IO[unit]

range(b)
# int -> list[int]

map(f, b)
# ('a -> 'b) -> 'a list -> 'b list

filter(f, b)
# ('a -> bool) -> 'a list -> 'a list

sum(a)
# 'a list -> 'a

zip(a, b)
# 'a list -> 'b list -> (a' * b') list

unzip(a)
# ('a * 'b) list -> ('a list * 'b list)

all(a)
# bool list -> bool

any(a)
# bool list -> bool 

min(a, b)
# int -> int -> int 

max(a, b)
# int -> int -> int 

len(a)
# a' list -> int

int(a)
# 'a -> int 

float(a)
# 'a -> float 

bool(a)
# 'a -> bool

bytes(a)
# 'a -> bytes

str(a)
# 'a -> str
```

