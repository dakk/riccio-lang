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