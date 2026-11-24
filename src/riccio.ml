open Core
open Riccio
open Errors

let red s = Printf.sprintf "\x1b[31m%s\x1b[0m" s
let yellow s = Printf.sprintf "\x1b[33m%s\x1b[0m" s

let pp_message p cc m err = match p with 
| Some (_, fn, l, c) -> Printf.sprintf "File %s, line %d, character %d: %s\n%s %s\n" 
  fn l c cc (if err then red "Error:" else yellow "Warning:") m
| None -> Printf.sprintf "File ?, line -1, character 0: %s\n%s %s\n" 
  cc (if err then red "Error:" else yellow "Warning:") m 


let emit_warning p cc m = pp_message p cc m false |> print_endline

let run action filename opt = 
  (match action with 
  | "compile" -> Compiler.compile filename opt
  )

let summary = ""
^ "=== actions ===\n\n"
^ "  compile file.riccio\n"

let command =
  Command.basic
    ~summary:"f3l-lang compiler"
    ~readme:(fun () -> summary)
    (let open Command.Let_syntax in
      let open Command.Param in
      let%map
            action    = anon ("action" %: string)
        and filename  = anon ("filename" %: string)
        and past      = flag "-print-ast" no_arg ~doc:" print ast"
        and verbose   = flag "-verbose" no_arg ~doc:" enable verbosity"
        and target    = flag "-target" (optional string) ~doc:" target output (ml)"
      in fun () -> 
        let opt = Compiler.{
          target = Option.value target ~default:"ml";
          print_ast = past;
          verbose = verbose;
        } in (
          let pp_err p cc m = pp_message p cc m true in 
          try run action filename opt with 
          | CompilerError (m) -> print_endline @@ pp_err None "CompilerError" m
          | SyntaxError (p,m) -> print_endline @@ pp_err p "SyntaxError" m
          | ParsingError (p,m) -> print_endline @@ pp_err p "ParsingError" m
          | TypeError (p,m) -> print_endline @@ pp_err p "TypeError" m
          | SymbolNotFound (p,m) -> print_endline @@ pp_err p "SymbolNotFound" m
          | LexerError(e) -> print_endline @@ "LexerError" ^ e
        )
      )
        
let () = Command_unix.run ~version:"0.1" ~build_info:"git" command