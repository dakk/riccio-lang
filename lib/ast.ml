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
| EFloat of float
| EStr of string
| EBool of bool
| EBytes of bytes
| EVal of string
| EApp of expr * expr

| ENot of expr
| ENeg of expr
| EAnd of expr * expr
| EOr of expr * expr
| EJoin of expr * expr
| ECons of expr * expr
| EAdd of expr * expr
| ESub of expr * expr
| EMul of expr * expr
| EDiv of expr * expr
| EMod of expr * expr

| ENeq of expr * expr
| EEq of expr * expr
| ELt of expr * expr
| ELte of expr * expr
| EGt of expr * expr
| EGte of expr * expr


| EIf of expr * expr * expr
| ELet of string * texpr option * expr * expr
| EFun of bool * (string * texpr option) list * texpr option * expr
[@@deriving show {with_path = false}]

type def = 
| DType of string * texpr
| DImport of string 
| DImportFrom of string list * string
| DDef of string * texpr option * expr
[@@deriving show {with_path = false}]


type t = def list [@@deriving show {with_path = false}]