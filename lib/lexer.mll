{
  open Parser
  open Lexing

  exception SyntaxError2 of string

  let indent_stack = ref [0]       
  let paren_depth  = ref 0
  let pending       = ref []       
  let bol           = ref true     
  let nl_pending    = ref false    

  let push t = pending := !pending @ [t]

  let err msg = raise (SyntaxError2 msg)

  let adjust width =
    let dedented = ref false in
    let rec down () =
      match !indent_stack with
      | top :: rest when width < top ->
          dedented := true;
          indent_stack := rest;
          push DEDENT;
          down ()
      | top :: _ when width > top && !dedented ->
          err "unindent does not match any outer indentation level"
      | top :: _ when width > top ->
          indent_stack := width :: !indent_stack;
          push INDENT
      | _ -> ()                     (* width = top: same level, nothing to do *)
    in
    down ()
}


let digit  = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']
let iden   = letter (letter | digit | '_')*
let int    = digit digit+ | digit
let float  = digit digit* "." digit+
let blank  = [' ' '\t' '\r']


rule token = parse
  | '\n'
      { Lexing.new_line lexbuf;
        if !paren_depth > 0 then token lexbuf 
        else (bol := true; NEWLINE)
      }

  | blank+ { token lexbuf }

  | "()"       { UNIT }
  | float as f { FLOAT (float_of_string f) }
  | int as i   { match int_of_string_opt i with
                   | Some n -> INT n
                   | None   -> err "integer literal is too large" }


  | "and"    { AND }
  | "case"   { CASE }
  | "def"    { DEF }
  | "else"   { ELSE }
  | "False"  { FALSE }
  | "from"   { FROM }
  | "if"     { IF }
  | "import" { IMPORT }
  | "lambda" { LAMBDA }
  | "match"  { MATCH }
  | "not"    { NOT }
  | "or"     { OR }
  | "rec"    { REC }
  | "then"   { THEN }
  | "True"   { TRUE }
  | "type"   { TYPE }

  | "_"   { UNDERSCORE }
  | "::"  { CONS }
  | "++"  { PLUSPLUS }
  | "'"   { APEX }
  | "|>"  { PIPEGT }
  | "->"  { APP }
  | "|"   { PIPE }
  | "."   { DOT }
  | "{"   { incr paren_depth; LBRACE }
  | "}"   { if !paren_depth > 0 then decr paren_depth; RBRACE }
  | "["   { incr paren_depth; LSPAR }
  | "]"   { if !paren_depth > 0 then decr paren_depth; RSPAR }
  | "("   { incr paren_depth; LPAR }
  | ")"   { if !paren_depth > 0 then decr paren_depth; RPAR }
  | ","   { COMMA }
  | ":"   { COLON }
  | ";"   { SEMICOLON }
  | "+"   { PLUS }
  | "-"   { MINUS }
  | "/"   { DIV }
  | "*"   { MUL }
  | "%"   { MOD }
  | "=="  { EQEQ }
  | "="   { EQ }
  | "!="  { NEQ }
  | "<="  { LTE }
  | ">="  { GTE }
  | ">"   { GT }
  | "<"   { LT }

  | '#'     { comment lexbuf; token lexbuf }
  | "\"\"\"" { comment_multiline lexbuf; token lexbuf }

  | '"'         { read_string (Buffer.create 32) lexbuf }
  | "b\"" as s  (* bytes prefix + string; handled by read_string via app? no: see note below *)
      { let _ = s in err "unreachable: see bytes below" }

  | iden as i  { IDEN i }

  | eof
      { if !paren_depth > 0 then err "unterminated bracket at end of input";
        while (match !indent_stack with [0] -> false | _ -> true) do
          indent_stack := List.tl !indent_stack;
          push DEDENT
        done;
        match !pending with
        | []      -> EOF
        | t :: ts -> pending := ts; t
      }

  | _ as c { err (Format.sprintf "invalid character %C" c) }


and read_string buf = parse
  | '"'                     { STRING (Buffer.contents buf) }
  | '\\' 'n'                { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 't'                { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | '\\' '\\'               { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' '"'                 { Buffer.add_char buf '"';  read_string buf lexbuf }
  | '\\' 'u' ['0'-'9' 'a'-'f' 'A'-'F'] ['0'-'9' 'a'-'f' 'A'-'F'] ['0'-'9' 'a'-'f' 'A'-'F'] ['0'-'9' 'a'-'f' 'A'-'F']
                            { err "unicode escapes are not supported yet" }
  | '\\' ([^ '"' '\\' '\n' 'n' 't' 'u'] as c)
                            { err (Format.sprintf "unknown escape '\\%c' in string literal" c) }
  | '\n'                    { err "unterminated string literal" }
  | eof                     { err "unterminated string literal" }
  | [^ '"' '\\' '\n']+      { Buffer.add_string buf (Lexing.lexeme lexbuf);
                              read_string buf lexbuf }

and comment = parse
  | '\n' { () }                       
  | eof  { () }
  | _    { comment lexbuf }

and comment_multiline = parse
  | "\"\"\"" { () }
  | '\n'     { Lexing.new_line lexbuf; comment_multiline lexbuf }
  | eof      { err "unterminated comment" }
  | _        { comment_multiline lexbuf }

and layout = parse
  | ' '* '\n'               { Lexing.new_line lexbuf; layout lexbuf }

  | ' '* '#' [^ '\n']* '\n' { Lexing.new_line lexbuf; layout lexbuf }
  | ' '* '#' [^ '\n']*     { () }        (* comment-only last line, no newline *)

  | ' '* eof                { () }

  | ' '* '\t'               { err "tab character in indentation (use spaces)" }

  | ' '+                    { adjust (String.length (Lexing.lexeme lexbuf)) }

  | _                       { lexbuf.lex_curr_pos <- lexbuf.lex_start_pos;
                             adjust 0 }

  | eof                     { () }

{

let rec next_token lexbuf =
  match !pending with
  | INDENT :: _ when !nl_pending ->
      nl_pending := false;
      NEWLINE
  | t :: ts ->
      nl_pending := false;
      pending := ts;
      t
  | [] ->
      if !bol then begin
        bol := false;
        layout lexbuf;
        next_token lexbuf
      end
      else begin
        match token lexbuf with
        | NEWLINE -> nl_pending := true; next_token lexbuf
        | t -> t
      end

}