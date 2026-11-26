open Alcotest


let test_nothing () = ()

let test_parser v () = 
  let ast = Riccio.Parse.parse_file v in   
  ()
let test_gen_ml v () = 
  let ast = Riccio.Parse.parse_file v in   
  let ml = Riccio.Gen_ml.emit_ml ast in 
  ()

let make_units dir test_runner =
  let ct = Sys.readdir dir |> Array.to_list in 
  let build_test v = test_case v `Quick (test_runner @@ dir ^ "/" ^ v) in
  List.map build_test ct

let () =
  run "Utils" [
    "units_parse", make_units "test/units" test_parser;
    "units_gen_ml", make_units "test/units" test_gen_ml;
  ]