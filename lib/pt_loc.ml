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
open Lexing

module PTEmp = struct 
  type t = | Decl of Ast.def | Expr of Ast.expr
end 

type l = (Lexing.position * string * int * int )

module LocationTable  = Ephemeron.K1.Make(struct
  type t = PTEmp.t
  let hash = Hashtbl.hash 
  let equal = (=) 
end) 

let filename = ref ""
let locations = ref @@ LocationTable.create 10000
let ladd = LocationTable.add !locations
let pp_pos s e = s, !filename, s.pos_lnum, (s.pos_cnum - s.pos_bol + 1)

let locd s e x = ladd (Decl (x)) @@ pp_pos s e; x
let loce s e x = ladd (Expr (x)) @@ pp_pos s e; x
(* let loci s e x = ladd (Iden (x)) @@ pp_pos s e; x *)

let dline p = try Some (LocationTable.find !locations @@ Decl (List.hd p)) with | _ -> None
let eline ee = try Some (LocationTable.find !locations @@ Expr (ee)) with | _ -> None
(* let iline ii = try Some (LocationTable.find !locations @@ Iden (ii)) with | _ -> None  *)