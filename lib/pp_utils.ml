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

let pp_str fmt str =
  Format.fprintf fmt "%s" str

let pp_list sep pp =
  Format.pp_print_list
    ~pp_sep:(fun fmt () -> Format.fprintf fmt "%(%)" sep)
    pp

let pp_capit fmt i =
  Format.fprintf fmt "%s" (String.capitalize_ascii i)

let sfmt = Format.str_formatter
let sget = Format.flush_str_formatter

let temp_i = ref 0
let temp_v () = temp_i := !temp_i + 1; Format.sprintf "a__%d" !temp_i
let temp_c () = Format.sprintf "a__%d" !temp_i
let reset_temp () = temp_i := 1