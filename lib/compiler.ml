type options = {
  print_ast: bool;
  verbose: bool;
}

let default_options = {
  print_ast = true;
  verbose = true;
}


let compile (filename: string) opt =
  let p_ast = Parse.parse_file filename in
  p_ast |> Ast.show |> print_endline