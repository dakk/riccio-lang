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
| UNIT          { loce $startpos $endpos @@ Ast.EUnit }
| TRUE          { loce $startpos $endpos @@ Ast.EBool (true) }
| FALSE         { loce $startpos $endpos @@ Ast.EBool (false) }
| x=STRING      { loce $startpos $endpos @@ Ast.EStr (x) }
| x=BYTES       { loce $startpos $endpos @@ Ast.EBytes (x) }
| x=INT         { loce $startpos $endpos @@ Ast.EInt (x) }
| i=IDEN        { loce $startpos $endpos @@ Ast.EVal (i) }


typeexpr:
| t=IDEN       { Ast.TBase (t) }
| APEX t=IDEN  { Ast.TAnon (t) }

param:
| i=IDEN                    { (i, None) }
| i=IDEN COLON t=typeexpr   { (i, Some(t)) }

params: 
| p=separated_nonempty_list(COMMA, param)   { p }

block:
| NEWLINE INDENT xs=list(expr) DEDENT   { xs }
| e=expr                                { [e] }

fundef:
| DEF i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON body=block      {locd $startpos $endpos @@ Ast.DFun(i, p, r, body)}
| DEF REC i=IDEN LPAR p=params RPAR r=option(APP t=typeexpr { t }) COLON body=block  {locd $startpos $endpos @@ Ast.DRecFun(i, p, r, body)}

typedef:
| TYPE i=IDEN EQ t=typeexpr      {locd $startpos $endpos @@ Ast.DType(i, t)}

// importdef:

// valdef:

defs:
// | i=importdef   { locd $startpos $endpos i }
// | v=valdef      { locd $startpos $endpos v }
| f=fundef      { locd $startpos $endpos @@ f }
| t=typedef     { locd $startpos $endpos @@ t }

