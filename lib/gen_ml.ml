open Ast
open Pp_utils
open Errors 
open Format


let rec pp_type fmt t = 
  match t with
  | TBase(i) -> fprintf fmt "%s" i
  | TAnon(_) -> raise (CompilerError "gen_ml: not implemented: TAnon (type variable)")
  | TTuple(_) -> raise (CompilerError "gen_ml: not implemented: TTuple")
  | TRecord(_) -> raise (CompilerError "gen_ml: not implemented: TRecord")
  | TLambda(_) -> raise (CompilerError "gen_ml: not implemented: TLambda (function type)")
  | TUnion(_) -> raise (CompilerError "gen_ml: not implemented: TUnion")
  | TGeneric(_) -> raise (CompilerError "gen_ml: not implemented: TGeneric")

let rec pp_expr fmt e =
  match e with
  | EUnit -> raise (CompilerError "gen_ml: not implemented: EUnit")
  | EInt(_) -> raise (CompilerError "gen_ml: not implemented: EInt")
  | EFloat(_) -> raise (CompilerError "gen_ml: not implemented: EFloat")
  | EStr(_) -> raise (CompilerError "gen_ml: not implemented: EStr")
  | EBool(v) -> pp_str fmt (if v then "true" else "false")
  | EBytes(_) -> raise (CompilerError "gen_ml: not implemented: EBytes")
  | EVal(i) -> pp_str fmt i
  | EApp(_) -> raise (CompilerError "gen_ml: not implemented: EApp")
  | EList(_) -> raise (CompilerError "gen_ml: not implemented: EList")
  | EListCons(_) -> raise (CompilerError "gen_ml: not implemented: EListCons (::)")
  | ETuple(_) -> raise (CompilerError "gen_ml: not implemented: ETuple")
  | ETupleAccess(_) -> raise (CompilerError "gen_ml: not implemented: ETupleAccess")
  | ERecordUpdate(_) -> raise (CompilerError "gen_ml: not implemented: ERecordUpdate (|)")
  | ERecordAccess(_) -> raise (CompilerError "gen_ml: not implemented: ERecordAccess")
  | ERecord(_) -> raise (CompilerError "gen_ml: not implemented: ERecord")

  | ENot(e) -> fprintf fmt "not %a" pp_expr e
  | ENeg(_) -> raise (CompilerError "gen_ml: not implemented: ENeg")
  | EAnd(a,b) -> fprintf fmt "%a && %a" pp_expr a pp_expr b
  | EOr(a,b) -> fprintf fmt "%a || %a" pp_expr a pp_expr b
  | EJoin(_) -> raise (CompilerError "gen_ml: not implemented: EJoin")
  | ECons(_) -> raise (CompilerError "gen_ml: not implemented: ECons")
  | EAdd(_) -> raise (CompilerError "gen_ml: not implemented: EAdd (+)")
  | ESub(_) -> raise (CompilerError "gen_ml: not implemented: ESub (-)")
  | EMul(_) -> raise (CompilerError "gen_ml: not implemented: EMul (*)")
  | EDiv(_) -> raise (CompilerError "gen_ml: not implemented: EDiv (/)")
  | EMod(_) -> raise (CompilerError "gen_ml: not implemented: EMod (%)")

  | ENeq(_) -> raise (CompilerError "gen_ml: not implemented: ENeq (!=)")
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

let pp_ast fmt ast = 
  let rec pp_s fmt def =
    match def with 
    | DType(i, gl, t) -> fprintf fmt "type %s = %a;\n" i pp_type t
    | DImport(_) -> raise (CompilerError "gen_ml: not implemented: DImport")
    | DImportFrom(_) -> raise (CompilerError "gen_ml: not implemented: DImportFrom")
    | DDef(i, r, None, e) -> fprintf fmt "let %s = %a;\n" i pp_expr e
    | DDef(i, r, Some(t), e) -> fprintf fmt "let %s: %a = %a;\n" i pp_type t pp_expr e
  in
  (pp_list "" pp_s) fmt ast

let emit_ml ast = 
  pp_ast sfmt ast;
  sget ()
