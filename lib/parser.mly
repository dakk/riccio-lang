%{
	open Pt_loc 
%}

%token EOF, NEWLINE, INDENT, DEDENT

%token LBRACE, RBRACE, LPAR, RPAR, COMMA, COLON, SEMICOLON, PIPE, EQ, DOT, LSPAR, RSPAR, EOL
%token IF, ELSE, MATCH, CASE, CONS, PLUSPLUS
%token <string> IDEN
%token <string> CAPID
%token <string> TVAR

%token PIPEGT, IO, LAMBDA, APP, TYPE
%token COMMENT
%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <bytes> BYTES
%token TRUE, FALSE

%token PLUS, MINUS, MUL, DIV, MOD, APPEND, MERGE
%token OR, AND, NOT
%token LTE, LT, GT, GTE, EQEQ, NEQ
%token UNDERSCORE, FROM, IMPORT, DEF, REC


%left OR
%left AND
%nonassoc NOT
%nonassoc EQEQ NEQ LT LTE GT GTE
%left PLUS MINUS
%left MUL DIV MOD

%start <Ast.t> program
%%

program: dl=list(defs) EOF { dl }

expr:
| LPAR RPAR     		{ loce $startpos $endpos @@ Ast.EUnit }
| i=IDEN        		{ loce $startpos $endpos @@ Ast.EVal (i) }

| x=STRING      		{ loce $startpos $endpos @@ Ast.EStr (x) }
| x=BYTES       		{ loce $startpos $endpos @@ Ast.EBytes (x) }
| x=FLOAT         		{ loce $startpos $endpos @@ Ast.EFloat (x) }
| x=INT         		{ loce $startpos $endpos @@ Ast.EInt (x) }
| e=expr PIPEGT b=expr  { loce $startpos $endpos @@ Ast.EApp (b, [e]) }
| e=expr LPAR pl=separated_list(COMMA, expr) RPAR		
						{ loce $startpos $endpos @@ Ast.EApp (e, match pl with [] -> [Ast.EUnit] | _ -> pl) }
| LPAR xs=separated_nonempty_list(COMMA, expr) RPAR	
						{ loce $startpos $endpos @@ Ast.ETuple (xs) }
| e=expr LSPAR i=expr RSPAR
						{ loce $startpos $endpos @@ Ast.ETupleAccess (e, i) }

| a=expr PLUS b=expr	{ loce $startpos $endpos @@ Ast.EAdd (a, b) }
| a=expr MINUS b=expr	{ loce $startpos $endpos @@ Ast.ESub (a, b) }
| MINUS e=expr          { loce $startpos $endpos @@ Ast.ENeg e }
| a=expr MUL b=expr		{ loce $startpos $endpos @@ Ast.EMul (a, b) }
| a=expr DIV b=expr		{ loce $startpos $endpos @@ Ast.EDiv (a, b) }
| a=expr MOD b=expr		{ loce $startpos $endpos @@ Ast.EMod (a, b) }

| a=expr EQEQ b=expr	{ loce $startpos $endpos @@ Ast.EEq (a, b) }
| a=expr NEQ b=expr		{ loce $startpos $endpos @@ Ast.ENeq (a, b) }
| a=expr GT b=expr		{ loce $startpos $endpos @@ Ast.EGt (a, b) }
| a=expr GTE b=expr		{ loce $startpos $endpos @@ Ast.EGte (a, b) }
| a=expr LT b=expr		{ loce $startpos $endpos @@ Ast.ELt (a, b) }
| a=expr LTE b=expr		{ loce $startpos $endpos @@ Ast.ELte (a, b) }

| TRUE          		{ loce $startpos $endpos @@ Ast.EBool (true) }
| FALSE         		{ loce $startpos $endpos @@ Ast.EBool (false) }
| NOT a=expr        	{ loce $startpos $endpos @@ Ast.ENot (a) }
| a=expr AND b=expr		{ loce $startpos $endpos @@ Ast.EAnd (a, b) }
| a=expr OR b=expr		{ loce $startpos $endpos @@ Ast.EOr (a, b) }

| e1=expr IF c=expr ELSE e2=expr
						{ loce $startpos $endpos @@ Ast.EIf (c, e1, e2) }
| IF c=expr COLON NEWLINE e1=expr NEWLINE ELSE COLON NEWLINE e2=expr
						{ loce $startpos $endpos @@ Ast.EIf (c, e1, e2) }


| i=IDEN EQ e=expr NEWLINE e2=expr 	
						{ loce $startpos $endpos @@ Ast.ELet (i, false, None, e, e2) }
| i=IDEN COLON t=typeexpr EQ e=expr NEWLINE e2=expr	
						{ loce $startpos $endpos @@ Ast.ELet (i, false, Some(t), e, e2) }

| DEF i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON e=block NEWLINE e2=expr
						{ loce $startpos $endpos @@ Ast.ELet (i, false, None, Ast.EFun(p, r, e), e2)}
| DEF REC i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON e=block NEWLINE e2=expr
						{ loce $startpos $endpos @@ Ast.ELet (i, true, None, Ast.EFun(p, r, e), e2)}
| a=expr PIPE b=expr    { loce $startpos $endpos @@ Ast.ERecordUpdate (a, b) }
| LBRACE xs=separated_nonempty_list(COMMA, i=IDEN COLON e=expr {i, e}) RBRACE 
						{ loce $startpos $endpos @@ Ast.ERecord (xs) }
| e=expr DOT i=IDEN		{ loce $startpos $endpos @@ Ast.ERecordAccess (e, i) }


param:
| i=IDEN                    { (i, None) }
| i=IDEN COLON t=typeexpr   { (i, Some(t)) }

params:
|                                           { [("_", Some (Ast.TBase "unit"))] }
| p=separated_nonempty_list(COMMA, param)   { p }

block:
| NEWLINE INDENT e=expr DEDENT  { e }
| e=expr                        { e }


typedef_rhs:
| t=typeexpr                     { t }
| xs=separated_nonempty_list(PIPE, typeexpr_unionelement)
                                 { Ast.TUnion xs }
typeexpr:
| lhs=typeproduct APP rhs=typeexpr
    						{ Ast.TLambda (lhs, rhs) }
| t=typeproduct				{ t }

typeproduct:
| xs=separated_nonempty_list(MUL, typexpr_atom)
    						{ match xs with [t] -> t | _ -> Ast.TTuple xs }

typexpr_atom:
| t=IDEN					{ Ast.TBase t }
| t=TVAR			    	{ Ast.TAnon t }
| LPAR t=typeexpr RPAR  	{ t }
| LBRACE xs=separated_nonempty_list(COMMA, typeexpr_recordelement) RBRACE
    						{ Ast.TRecord xs }
| i=IDEN LSPAR xs=separated_nonempty_list(COMMA, typeexpr) RSPAR
							{ Ast.TGeneric (i, xs)}

typeexpr_unionelement:
| i=CAPID					{ (i, None) }
| i=CAPID LPAR t=typeexpr RPAR	
							{ (i, Some(t)) }

typeexpr_recordelement:
| i=IDEN COLON t=typeexpr   { (i, t) }

defs:
| TYPE i=IDEN EQ t=typedef_rhs   { locd $startpos $endpos @@ Ast.DType(i, [], t) }
| TYPE i=IDEN LSPAR xs=separated_nonempty_list(COMMA, t=TVAR {t}) RSPAR EQ t=typedef_rhs   
								 { locd $startpos $endpos @@ Ast.DType(i, xs, t) }
| i=IDEN EQ e=expr	 		     { locd $startpos $endpos @@ Ast.DDef(i, false, None, e) }
| i=IDEN COLON t=typeexpr  EQ e=expr	 		     
								 { locd $startpos $endpos @@ Ast.DDef(i, false, Some (t), e) }
| DEF i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON body=block
                                 { locd $startpos $endpos @@ Ast.DDef(i, false, None, Ast.EFun(p, r, body)) }
| DEF REC i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON body=block
                                 { locd $startpos $endpos @@ Ast.DDef(i, true, None, Ast.EFun(p, r, body)) }
| IMPORT i=IDEN                  { locd $startpos $endpos @@ Ast.DImport(i) }
| FROM m=IDEN IMPORT xs=separated_nonempty_list(COMMA, IDEN)
                                 { locd $startpos $endpos @@ Ast.DImportFrom(xs, m) }

