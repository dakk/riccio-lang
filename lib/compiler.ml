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

type options = {
  target: string;
  print_ast: bool;
  verbose: bool;
}

let default_options = {
  target = "ml";
  print_ast = true;
  verbose = true;
}


let compile (filename: string) opt =
  let p_ast = Parse.parse_file filename in
  if opt.print_ast then p_ast |> Ast.show |> print_endline;
  let out = match opt.target with 
    | "ml" -> Gen_ml.emit_ml p_ast
    | _ -> "" 
  in
  print_endline out