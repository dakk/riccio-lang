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


```python
def rec fact(x):
    if x == 0:
        1 
    else:
        x * fact(x - 1)
```

Inferred type is int, since x - int = int (or maybe also float) (TODO)


## Currying by default

```python
def sum(x, y): # int -> int -> int
    x + y 
    

sum(5) # this is a int -> int

f(sum(5)) # f receives a (int -> int)
```


## Typing

Types are defined using the type keyword.

### Base types

#### unit
Type unit has only one value `()`

#### bool

#### int

#### float

#### str

#### bytes

### Tuple

```
type t = int * float 
c = (12, 13.0)
```

### List 

```
a: list(int) = [1, 2, 3]
b = 3 :: a 
c = a ++ [3, 4]
```

### Record 

```python
pp: { name: str, age: int } = { name: "Davide", age: 34 }

def birthday(person: pp):
    a with { age: pp.age + 1 }
```


### Data constructors and generic types

Data constructors are supported, as long with generic types (prefixed by ')

```ocaml
type option ('a) = Some('a) | None

Some(5) # int option
```


### Lambdas

```
inc = lambda (x) -> x + 1
# inc: int -> int
```

## Pattern matching

```
match val:
    case Some(a):
        a
    case None:
        0
        
match atuple:
    case (c, 12) if c < 12:
        1
    case (12, 12):
        0
    case (c, _):
        2
```
        
## Pipeline operator

```
read_line() |> trim |> parse_int |> fact |> print
```

## Failable results

There are no exception, but we define a failable result:

```
type result('a, 'e) = Ok('a) | Error('e)
```


## Impure functions

Types are represented internally with (value_type, effects); we can define IO
function with side effects.

```
def print(s: str): IO unit

def greet(name):      # note: `name` is pure
    "hello " + name

def ask(): IO str  # inferred automatically
    print("name?")
    read_line()
```




## Files are modules

Files are modules, and import convention is inherited by python:

```
import std

std.print()
```

or 

```
from std import print

print()
```




## Future features

### Against function testing

```
def rec fact ...

against fact:
    property: fact(x) >= 1
    property: fact(x) * x == fact(x + 1) 
```


### Holes

Compiler will suggest what are the possible things from the env to be put instead of _

```
def test(a: int):
    _ * 2
```
