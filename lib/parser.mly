%{
	open Pt_loc 
%}

%token EOF, NEWLINE, INDENT, DEDENT

%token LBRACE, RBRACE, LPAR, RPAR, COMMA, COLON, SEMICOLON, PIPE, EQ, DOT, LSPAR, RSPAR, EOL
%token IF, THEN, ELSE, MATCH, CASE, CONS, PLUSPLUS
%token <string> IDEN

%token PIPEGT, IO, LAMBDA, APP, APEX, TYPE
%token UNIT, COMMENT
%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <bytes> BYTES
%token TRUE, FALSE

%token PLUS, MINUS, MUL, DIV, MOD, APPEND, MERGE
%token OR, AND, NOT
%token LTE, LT, GT, GTE, EQEQ, NEQ
%token UNDERSCORE, FROM, IMPORT, DEF, REC

%start <Ast.t> program
%%

program: dl=list(defs) EOF { dl }

expr:
| UNIT          		{ loce $startpos $endpos @@ Ast.EUnit }
| i=IDEN        		{ loce $startpos $endpos @@ Ast.EVal (i) }

| x=STRING      		{ loce $startpos $endpos @@ Ast.EStr (x) }
| x=BYTES       		{ loce $startpos $endpos @@ Ast.EBytes (x) }
// | x=FLOAT         { loce $startpos $endpos @@ Ast.EFloat (x) }

| x=INT         		{ loce $startpos $endpos @@ Ast.EInt (x) }
| a=expr PLUS b=expr	{ loce $startpos $endpos @@ Ast.EAdd (a, b) }
| a=expr MINUS b=expr	{ loce $startpos $endpos @@ Ast.ESub (a, b) }
| a=expr MUL b=expr		{ loce $startpos $endpos @@ Ast.EMul (a, b) }
| a=expr DIV b=expr		{ loce $startpos $endpos @@ Ast.EDiv (a, b) }
| a=expr MOD b=expr		{ loce $startpos $endpos @@ Ast.EMod (a, b) }

| TRUE          		{ loce $startpos $endpos @@ Ast.EBool (true) }
| FALSE         		{ loce $startpos $endpos @@ Ast.EBool (false) }
| NOT a=expr        	{ loce $startpos $endpos @@ Ast.ENot (a) }
| a=expr AND b=expr		{ loce $startpos $endpos @@ Ast.EAnd (a, b) }
| a=expr OR b=expr		{ loce $startpos $endpos @@ Ast.EOr (a, b) }


| i=IDEN EQ e=expr NEWLINE e2=expr 	
						{ loce $startpos $endpos @@ Ast.ELet (i, None, e, e2) }
| i=IDEN COLON t=typeexpr EQ e=expr NEWLINE e2=expr	
						{ loce $startpos $endpos @@ Ast.ELet (i, Some(t), e, e2) }

| DEF i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON e=block NEWLINE e2=expr
						{loce $startpos $endpos @@ Ast.ELet (i, None, Ast.EFun(false, p, r, e), e2)}
| DEF REC i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON e=block NEWLINE e2=expr
						{loce $startpos $endpos @@ Ast.ELet (i, None, Ast.EFun(true, p, r, e), e2)}

param:
| i=IDEN                    { (i, None) }
| i=IDEN COLON t=typeexpr   { (i, Some(t)) }

params: 
| p=separated_nonempty_list(COMMA, param)   { p }

block:
| NEWLINE INDENT e=expr DEDENT   { e }
| e=expr                         { e }

typeexpr:
| t=IDEN       { Ast.TBase (t) }
| APEX t=IDEN  { Ast.TAnon (t) }


defs:
| TYPE i=IDEN EQ t=typeexpr      { locd $startpos $endpos @@ Ast.DType(i, t) }
| DEF i=IDEN EQ e=expr           { locd $startpos $endpos @@ Ast.DDef(i, e) }
| DEF i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON body=block
                                 { locd $startpos $endpos @@ Ast.DDef(i, loce $startpos $endpos @@ Ast.EFun(false, p, r, body)) }
| DEF REC i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON body=block
                                 { locd $startpos $endpos @@ Ast.DDef(i, loce $startpos $endpos @@ Ast.EFun(true, p, r, body)) }
| IMPORT i=IDEN                  { locd $startpos $endpos @@ Ast.DImport(i) }
| FROM m=IDEN IMPORT xs=separated_nonempty_list(COMMA, IDEN)
                                 { locd $startpos $endpos @@ Ast.DImportFrom(xs, m) }

