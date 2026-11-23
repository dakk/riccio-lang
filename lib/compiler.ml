type options = {
  print_ast: bool;
  verbose: bool;
}

let default_options = {
  print_ast = true;
  verbose = true;
}


let compile (filename: string) opt =
  ()