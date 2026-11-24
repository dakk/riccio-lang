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