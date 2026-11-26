(* Copyright (C) 2026 Davide Gessa
 * This file is part of riccio-lang
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

type texpr = 
| TBase of string
| TAnon of string
| TTuple of texpr list
| TRecord of (string * texpr) list
| TLambda of texpr * texpr
| TUnion of (string * texpr option) list
| TGeneric of string * texpr list
[@@deriving show {with_path = false}]

type pattern =
| PAny                                   (* _ *)
| PVar of string                         (* x *)
| PStr of string                         (* "N" *)
| PInt of int
| PTuple of pattern list
| PList of pattern list
| PCons of pattern * pattern             (* h :: t *)
| PApp of string * pattern list          (* Ok(Some(n)) *)
| POr of pattern list                    (* "N" | "E" *)
| PRecord of (string * pattern) list     (* { x: 0, y: _ } *)
[@@deriving show {with_path = false}]

type case = {
    pat:   pattern;
    guard: expr option;
    body:  expr
} 
and expr =
| EUnit
| EInt of int
| EFloat of float
| EStr of string
| EBool of bool
| EBytes of bytes
| EVal of string
| EApp of expr * expr list
| EList of expr list
| ETuple of expr list
| EAccess of expr * expr
| ERecordUpdate of expr * expr
| EDot of expr * string
| ERecord of (string * expr) list
| EMatch of expr * case list 

| ENot of expr
| ENeg of expr
| EAnd of expr * expr
| EOr of expr * expr
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
| ELet of string * bool * texpr option * expr * expr
| EFun of (string * texpr option) list * texpr option * expr
[@@deriving show {with_path = false}]

type def = 
| DType of string * string list * texpr
| DImport of string 
| DImportFrom of string list * string
| DDef of string * bool * texpr option * expr
[@@deriving show {with_path = false}]


type t = def list [@@deriving show {with_path = false}]