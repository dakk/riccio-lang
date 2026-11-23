type expr =
  | EUnit
  | EInt of int
  | EStr of string
  | EBool of bool
  | EBytes of bytes


type defs = (string * expr) list