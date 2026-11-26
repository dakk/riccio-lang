open Ast
open Pp_utils
open Errors 
open Format

let rec pp_type fmt t = 
  match t with
  | TBase(i) -> fprintf fmt "%s" i
  | _ -> raise (CompilerError ("Type not handled by gen_ml: " ^ Ast.show_texpr t))

let rec pp_expr fmt e =
  match e with
  | EBool(v) -> pp_str fmt (if v then "true" else "false")
  | EVal(i) -> pp_str fmt i

  | ENot(e) -> fprintf fmt "not %a" pp_expr e
  | EAnd(a,b) -> fprintf fmt "%a && %a" pp_expr a pp_expr b
  | EOr(a,b) -> fprintf fmt "%a || %a" pp_expr a pp_expr b

  | EEq(a, b) -> fprintf fmt "%a == %a" pp_expr a pp_expr b
  | ELt(a, b) -> fprintf fmt "%a < %a" pp_expr a pp_expr b
  | ELte(a, b) -> fprintf fmt "%a <= %a" pp_expr a pp_expr b
  | EGt(a, b) -> fprintf fmt "%a > %a" pp_expr a pp_expr b
  | EGte(a, b) -> fprintf fmt "%a >= %a" pp_expr a pp_expr b

  | EIf(c, e1, e2) -> 
    fprintf fmt "if (%a) then (%a) else (%a)" pp_expr c pp_expr e1 pp_expr e2
  | ELet(i, r, t, e, e2) -> 
    fprintf fmt "let %s = (%a) in (%a)" i pp_expr e pp_expr e2
  | EFun(p, ret, e) -> 
    let rec ps v = match v with | [] -> "" | (x,_)::xl -> x ^ " " ^ (ps xl) in
    fprintf fmt "fun %s-> (%a)" (ps p) pp_expr e
  | _ -> raise (CompilerError ("Expr not handled by gen_ml: " ^ Ast.show_expr e))

let pp_ast fmt ast = 
  let rec pp_s fmt def =
    match def with 
    | DType(i, gl, t) -> fprintf fmt "type %s = %a;\n" i pp_type t
    | DDef(i, r, None, e) -> fprintf fmt "let %s = %a;\n" i pp_expr e
    | DDef(i, r, Some(t), e) -> fprintf fmt "let %s: %a = %a;\n" i pp_type t pp_expr e
    (*
    | DImport(m) -> pp_str fmt ""
    | DImportFrom(sl, m) -> pp_str fmt "" *)
    | _ -> raise (CompilerError ("Ast not handled by gen_ml: " ^ Ast.show_def def))
  in
  (pp_list "" pp_s) fmt ast

let emit_ml ast = 
  pp_ast sfmt ast;
  sget ()
