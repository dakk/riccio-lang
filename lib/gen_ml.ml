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

let is_atomic = function
  | EVal(_) | EInt(_) | EFloat(_) | EBool(_) | EStr(_) | EBytes(_) | EUnit | EList(_) -> true
  | _ -> false

let pp_ocaml_string fmt s =
  pp_print_char fmt '"';
  String.iter (fun c -> match c with
    | '"' -> pp_str fmt "\\\""
    | '\\' -> pp_str fmt "\\\\"
    | '\n' -> pp_str fmt "\\n"
    | '\t' -> pp_str fmt "\\t"
    | '\r' -> pp_str fmt "\\r"
    | c -> pp_print_char fmt c) s;
  pp_print_char fmt '"'

let rec pp_expr fmt e =
  match e with
  | EUnit -> fprintf fmt "()"
  | EInt(n) -> fprintf fmt "%d" n
  | EFloat(n) -> fprintf fmt "%f" n
  | EStr(s) -> pp_ocaml_string fmt s
  | EBool(v) -> pp_str fmt (if v then "true" else "false")
  | EBytes(b) -> fprintf fmt "Bytes.of_string %a" pp_ocaml_string (Bytes.to_string b)
  | EVal(i) -> pp_str fmt i
  | EApp(f, args) ->
    fprintf fmt "%a" pp_arg f;
    List.iter (fprintf fmt " %a" pp_arg) args
  | EList(xs) -> fprintf fmt "[%a]" (pp_list "; " pp_arg) xs
  | ETuple(xs) -> fprintf fmt "(%a)" (pp_list ", " pp_arg) xs
  | EAccess(e, i) -> fprintf fmt "List.nth (%a) (%a)" pp_arg e pp_expr i
  | ERecordUpdate(e, r) ->
    (match r with
     | ERecord(xs) ->
       fprintf fmt "{ %a with %a }" pp_arg e
         (pp_list "; " (fun fmt (i, x) -> fprintf fmt "%s = %a" i pp_arg x)) xs
     | _ -> raise (CompilerError "gen_ml: ERecordUpdate expects a record literal on the right"))
  | EDot(e, f) -> fprintf fmt "%a.%s" pp_arg e f
  | ERecord(xs) ->
    fprintf fmt "{ %a }" (pp_list "; " (fun fmt (i, x) -> fprintf fmt "%s = %a" i pp_arg x)) xs

  | ENot(e) -> fprintf fmt "not %a" pp_expr e
  | ENeg(e) -> fprintf fmt "(~- %a)" pp_arg e
  | EAnd(a,b) -> fprintf fmt "%a && %a" pp_expr a pp_expr b
  | EOr(a,b) -> fprintf fmt "%a || %a" pp_expr a pp_expr b
  | ECons(a, b) -> fprintf fmt "%a :: %a" pp_arg a pp_arg b
  | EAdd(a, b) -> fprintf fmt "%a + %a" pp_expr a pp_expr b
  | ESub(a, b) -> fprintf fmt "%a - %a" pp_expr a pp_expr b
  | EMul(a, b) -> fprintf fmt "%a * %a" pp_expr a pp_expr b
  | EDiv(a, b) -> fprintf fmt "%a / %a" pp_expr a pp_expr b
  | EMod(a, b) -> fprintf fmt "%a mod %a" pp_expr a pp_expr b

  | ENeq(a, b) -> fprintf fmt "%a <> %a" pp_expr a pp_expr b
  | EEq(a, b) -> fprintf fmt "%a == %a" pp_expr a pp_expr b
  | ELt(a, b) -> fprintf fmt "%a < %a" pp_expr a pp_expr b
  | ELte(a, b) -> fprintf fmt "%a <= %a" pp_expr a pp_expr b
  | EGt(a, b) -> fprintf fmt "%a > %a" pp_expr a pp_expr b
  | EGte(a, b) -> fprintf fmt "%a >= %a" pp_expr a pp_expr b

  | EIf(c, e1, e2) -> 
    fprintf fmt "if (%a) then (%a) else (%a)" pp_expr c pp_expr e1 pp_expr e2
  | ELet(i, r, t, e, e2) -> 
    fprintf fmt "let %s%s = (%a) in (%a)" (if r then "rec " else "") i pp_expr e pp_expr e2
  | EFun(p, ret, e) -> 
    let rec ps v = match v with | [] -> "" | (x,_)::xl -> x ^ " " ^ (ps xl) in
    fprintf fmt "fun %s-> (%a)" (ps p) pp_expr e

and pp_arg fmt e =
  if is_atomic e then pp_expr fmt e else fprintf fmt "(%a)" pp_expr e

let pp_ast fmt ast = 
  let rec pp_s fmt def =
    match def with 
    | DType(i, gl, t) ->
      let params = match gl with
        | [] -> ""
        | [v] -> "'" ^ v ^ " "
        | vs -> "(" ^ String.concat ", " (List.map (fun v -> "'" ^ v) vs) ^ ") "
      in
      fprintf fmt "type %s%s = %a\n" params i pp_type t
    | DImport(_) -> raise (CompilerError "gen_ml: not implemented: DImport")
    | DImportFrom(_) -> raise (CompilerError "gen_ml: not implemented: DImportFrom")
    | DDef(i, r, None, e) -> fprintf fmt "let %s = %a\n" i pp_expr e
    | DDef(i, r, Some(t), e) -> fprintf fmt "let %s: %a = %a\n" i pp_type t pp_expr e
  in
  (pp_list "" pp_s) fmt ast

let emit_ml ast = 
  pp_ast sfmt ast;
  sget ()
