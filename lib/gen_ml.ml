open Ast
open Pp_utils

let pp_type fmt t = 
  match t with
  | TBase(i) -> Format.fprintf fmt "%s" i
  | _ -> raise (Errors.CompilerError ("Type not handled by gen_ml: " ^ Ast.show_texpr t))

let pp_expr fmt e =
  match e with
  | _ -> raise (Errors.CompilerError ("Expr not handled by gen_ml: " ^ Ast.show_expr e))

let pp_ast fmt ast = 
  let rec pp_s fmt def =
    match def with 
    | DType(i, t) -> Format.fprintf fmt "type %s = %a;\n" i pp_type t
    | DDef(i, e) -> Format.fprintf fmt "let %s = %a;\n" i pp_expr e
    (*
    | DImport(m) -> pp_str fmt ""
    | DImportFrom(sl, m) -> pp_str fmt ""
    | DDef(i, e) -> pp_str fmt "" *)
    | _ -> raise (Errors.CompilerError ("Ast not handled by gen_ml: " ^ Ast.show_def def))
  in
  (pp_list "" pp_s) fmt ast

let emit_ml ast = 
  let sfmt = Format.str_formatter in 
  pp_ast sfmt ast;
  sget ()
