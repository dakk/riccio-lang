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
open Errors

module Pt_loc = Pt_loc
module I = Parser.MenhirInterpreter

exception SyntaxErrorLoced of (int * int) option * string 

let pos lexbuf = let pos = Lexing.lexeme_start_p lexbuf in (pos.pos_lnum, pos.pos_cnum - pos.pos_bol + 1)

let reset_lexer () = 
  Lexer.indent_stack := [0]; 
  Lexer.paren_depth := 0;
  Lexer.pending := []; 
  Lexer.bol := true; 
  Lexer.nl_pending := false;
  ()

let get_parse_error env =
    match I.stack env with
    | lazy Nil -> "Invalid syntax"
    | lazy (Cons (I.Element (state, _, _, _), _)) ->
        try (Parser_messages.message (I.number state)) with
        | Not_found -> "invalid syntax (no specific message for this eror)"


let rec parse_inc lexbuf (checkpoint : Ast.t I.checkpoint) =
  match checkpoint with
  | I.InputNeeded _env ->
      let token = Lexer.next_token lexbuf in
      let startp = lexbuf.lex_start_p
      and endp = lexbuf.lex_curr_p in
      let checkpoint = I.offer checkpoint (token, startp, endp) in
      parse_inc lexbuf checkpoint
  | I.Shifting _
  | I.AboutToReduce _ ->
      let checkpoint = I.resume checkpoint in
      parse_inc lexbuf checkpoint
  | I.HandlingError _env ->
      let line, pos = pos lexbuf in
      let err = get_parse_error _env in
      raise (SyntaxErrorLoced (Some (line, pos), err))
  | I.Accepted v -> v
  | I.Rejected ->
       raise (SyntaxErrorLoced (None, "invalid syntax (parser rejected the input)"))


let parse filename s = 
  reset_lexer ();
  let lexbuf = Lexing.from_string s in 
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  Pt_loc.filename := filename;

  try parse_inc lexbuf (Parser.Incremental.program lexbuf.lex_curr_p)
  with SyntaxErrorLoced (pos, err) ->
    match pos with
    | Some (line, pos) -> raise @@ SyntaxError (Some (lexbuf.lex_curr_p, filename, line, pos), err)
    | None -> raise @@ SyntaxError (Some(lexbuf.lex_curr_p, filename, -1, 0), err)


let parse_file filename = 
  let rec readfile ic = 
    try let line = input_line ic in (line ^ "\n")::(readfile ic) with _ -> close_in_noerr ic; []
  in
  filename 
  |> open_in 
  |> readfile 
  |> List.fold_left (fun acc x -> acc ^ x) "" 
  |> parse filename