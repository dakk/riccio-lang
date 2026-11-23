type texpr = 
| TBase of string
| TAnon of string
| TTuple of texpr list
| TRecord of (string * texpr) list
| TList of texpr
[@@deriving show {with_path = false}]

type expr =
| EUnit
| EInt of int
| EStr of string
| EBool of bool
| EBytes of bytes
| EVal of string
| EApp of expr * expr
| ELet of string * expr
| ELetTyped of string * texpr * expr
[@@deriving show {with_path = false}]

type def = 
| DType of string * texpr
| DFun of string * (string * texpr option) list * texpr option * expr list
| DRecFun of string * (string * texpr option) list * texpr option * expr list
| DImport of string 
| DImportFrom of string list * string
[@@deriving show {with_path = false}]


type t = def list [@@deriving show {with_path = false}]