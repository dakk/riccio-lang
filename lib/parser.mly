
%token EOF

%token LBRACE, RBRACE, LPAR, RPAR, COMMA, COLON, SEMICOLON, PIPE, EQ, DOT, LSQUARE, RSQUARE, EOL
%token <string> IDEN

%token UNIT
%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token TRUE, FALSE

%token LTE, LT, GT, GTE, EQEQ, NEQ
%token UNDERSCORE, FROM, IMPORT, DEF, REC

%start <Ast.t option> prog
%%

program: dl=list(defs) EOF { dl }

expr:
| UNIT          { loce $startpos $endpos @@ Ast.EUnit }
| TRUE          { loce $startpos $endpos @@ ASt.EBool (true) }
| FALSE         { loce $startpos $endpos @@ ASt.EBool (false) }
| x=STRING      { loce $startpos $endpos @@ ASt.EString (x) }
| x=BYTES       { loce $startpos $endpos @@ ASt.EBytes (x) }
| x=INT         { loce $startpos $endpos @@ ASt.EInt (x) }

typeexpr:


fundef:
| DEF i=IDEN LPAR RPAR COLON
| DEF REC i=IDEN LPAR RPAR COLON 

typedef:
| TYPE i=IDEN EQ typeexpr EOL

importdef:

valdef:

defs:
| f=fundef      { locd $startpos $endpos f }
| v=valdef      { locd $startpos $endpos v }
| t=typedef     { locd $startpos $endpos t }
| i=importdef   { locd $startpos $endpos i }

