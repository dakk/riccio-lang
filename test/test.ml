open Alcotest


let test_nothing () = ()

let test_parser v () = 
  let ast = Riccio.Parse.parse_file v in   
  ()

let make_units dir =
  let ct = Sys.readdir dir |> Array.to_list in 
  let build_test v = test_case v `Quick (test_parser @@ dir ^ "/" ^ v) in
  List.map build_test ct

let () =
  run "Utils" [
    "units", make_units "test/units";
  ]