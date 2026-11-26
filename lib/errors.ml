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

exception LexerError of string
exception SyntaxError of Pt_loc.l option * string
exception ParsingError of Pt_loc.l option * string
exception TypeError of Pt_loc.l option * string
exception SymbolNotFound of Pt_loc.l option * string
exception DuplicateSymbolError of Pt_loc.l option * string
exception DeclarationError of Pt_loc.l option * string
exception InvalidExpression of Pt_loc.l option * string
exception APIError of Pt_loc.l option * string
exception GenerateError of Pt_loc.l option * string
exception CompilerError of string
exception ModuleNotFound of string

let red s = Printf.sprintf "\x1b[31m%s\x1b[0m" s
let yellow s = Printf.sprintf "\x1b[33m%s\x1b[0m" s

let pp_message p cc m err = match p with 
| Some (_, fn, l, c) -> Printf.sprintf "File %s, line %d, character %d: %s\n%s %s\n" 
  fn l c cc (if err then red "Error:" else yellow "Warning:") m
| None -> Printf.sprintf "File ?, line -1, character 0: %s\n%s %s\n" 
  cc (if err then red "Error:" else yellow "Warning:") m


let emit_warning p cc m = pp_message p cc m false |> print_endline