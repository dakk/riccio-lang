open Ast
open Pp_utils
open Errors 
open Format


let rec pp_type fmt t = 
  match t with
  | TBase(i) -> fprintf fmt "%s" i
  | TAnon(i) -> fprintf fmt "\'%s" i
  | TTuple(ts) -> fprintf fmt "(%a)" (pp_list " * " pp_type) ts
  | TRecord(xs) ->
    fprintf fmt "{ %a }" (pp_list "; " (fun fmt (i, t) -> fprintf fmt "%s: %a" i pp_type t)) xs
  | TLambda(l, r) ->
    (match l with
     | TLambda(_) -> fprintf fmt "(%a) -> %a" pp_type l pp_type r
     | _ -> fprintf fmt "%a -> %a" pp_type l pp_type r)
  | TUnion(ctors) ->
    fprintf fmt "%a" (pp_list " | " (fun fmt (i, t) ->
      match t with
      | None -> fprintf fmt "%s" i
      | Some(t) -> fprintf fmt "%s of %a" i pp_type t)) ctors
  | TGeneric(i, [t]) -> fprintf fmt "%a %s" pp_type t i
  | TGeneric(i, ts) -> fprintf fmt "(%a) %s" (pp_list ", " pp_type) ts i

let rec pp_expr fmt e =
  match e with
  | EUnit -> fprintf fmt "()"
  | EInt(n) -> fprintf fmt "%d" n
  | EFloat(n) -> fprintf fmt "%f" n
  | EStr(_) -> raise (CompilerError "gen_ml: not implemented: EStr")
  | EBool(v) -> pp_str fmt (if v then "true" else "false")
  | EBytes(_) -> raise (CompilerError "gen_ml: not implemented: EBytes")
  | EVal(i) -> pp_str fmt i
  | EApp(_) -> raise (CompilerError "gen_ml: not implemented: EApp")
  | EList(_) -> raise (CompilerError "gen_ml: not implemented: EList")
  | ETuple(_) -> raise (CompilerError "gen_ml: not implemented: ETuple")
  | EAccess(_) -> raise (CompilerError "gen_ml: not implemented: EAccess")
  | ERecordUpdate(_) -> raise (CompilerError "gen_ml: not implemented: ERecordUpdate (|)")
  | EDot(_) -> raise (CompilerError "gen_ml: not implemented: EDot")
  | ERecord(_) -> raise (CompilerError "gen_ml: not implemented: ERecord")

  | ENot(e) -> fprintf fmt "not %a" pp_expr e
  | ENeg(e) -> fprintf fmt "-%a" pp_expr e
  | EAnd(a,b) -> fprintf fmt "%a && %a" pp_expr a pp_expr b
  | EOr(a,b) -> fprintf fmt "%a || %a" pp_expr a pp_expr b
  | ECons(a, b) -> fprintf fmt "%a :: %a" pp_expr a pp_expr b
  | EAdd(a, b) -> fprintf fmt "%a + %a" pp_expr a pp_expr b
  | ESub(a, b) -> fprintf fmt "%a - %a" pp_expr a pp_expr b
  | EMul(a, b) -> fprintf fmt "%a * %a" pp_expr a pp_expr b
  | EDiv(a, b) -> fprintf fmt "%a / %a" pp_expr a pp_expr b
  | EMod(a, b) -> fprintf fmt "%a %% %a" pp_expr a pp_expr b

  | ENeq(a, b) -> fprintf fmt "%a <> %a" pp_expr a pp_expr b
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
    | DType(i, gl, t) ->
      let params = match gl with
        | [] -> ""
        | [v] -> "'" ^ v ^ " "
        | vs -> "(" ^ String.concat ", " (List.map (fun v -> "'" ^ v) vs) ^ ") "
      in
      fprintf fmt "type %s%s = %a;\n" params i pp_type t
    | DImport(_) -> raise (CompilerError "gen_ml: not implemented: DImport")
    | DImportFrom(_) -> raise (CompilerError "gen_ml: not implemented: DImportFrom")
    | DDef(i, r, None, e) -> fprintf fmt "let %s = %a;\n" i pp_expr e
    | DDef(i, r, Some(t), e) -> fprintf fmt "let %s: %a = %a;\n" i pp_type t pp_expr e
  in
  (pp_list "" pp_s) fmt ast

let emit_ml ast = 
  pp_ast sfmt ast;
  sget ()
