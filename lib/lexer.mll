{
  open Parser
  open Lexing
  open Errors

  let indent_stack = ref [0]       
  let paren_depth  = ref 0
  let pending       = ref []       
  let bol           = ref true     
  let nl_pending    = ref false    

  let push t = pending := !pending @ [t]

  let err msg = raise (LexerError msg)

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
      | _ -> ()
    in
    down ()
}


let digit  = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']
let letter_up = ['A'-'Z']
let iden   = letter (letter | digit | '_')*
let capid  = letter_up (letter | digit | '_')*
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
  | "True"   { TRUE }
  | "type"   { TYPE }

  | "_"   { UNDERSCORE }
  | "::"  { CONS }
  | "++"  { PLUSPLUS }
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

  | '"'         { read_string (fun s -> STRING s) (Buffer.create 32) lexbuf }
  | "b\""       { read_string (fun s -> BYTES (Bytes.of_string s)) (Buffer.create 32) lexbuf }

  | capid as i  { CAPID i }
  | iden as i  { IDEN i }
  | '\'' ['a'-'z'] ['A'-'Z' '0'-'9' '_']* as tv
      { TVAR (String.sub tv 1 (String.length tv - 1)) }

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


and read_string mk buf = parse
  | '"'                     { mk (Buffer.contents buf) }
  | '\\' 'n'                { Buffer.add_char buf '\n'; read_string mk buf lexbuf }
  | '\\' 't'                { Buffer.add_char buf '\t'; read_string mk buf lexbuf }
  | '\\' '\\'               { Buffer.add_char buf '\\'; read_string mk buf lexbuf }
  | '\\' '"'                 { Buffer.add_char buf '"';  read_string mk buf lexbuf }
  | '\\' 'u' ['0'-'9' 'a'-'f' 'A'-'F'] ['0'-'9' 'a'-'f' 'A'-'F'] ['0'-'9' 'a'-'f' 'A'-'F'] ['0'-'9' 'a'-'f' 'A'-'F']
                            { err "unicode escapes are not supported yet" }
  | '\\' ([^ '"' '\\' '\n' 'n' 't' 'u'] as c)
                            { err (Format.sprintf "unknown escape '\\%c' in string literal" c) }
  | '\n'                    { err "unterminated string literal" }
  | eof                     { err "unterminated string literal" }
  | [^ '"' '\\' '\n']+      { Buffer.add_string buf (Lexing.lexeme lexbuf);
                              read_string mk buf lexbuf }

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
  | ' '* '#' [^ '\n']*      { false } 

  | ' '* eof                { false }

  | ' '* '\t'               { err "tab character in indentation (use spaces)" }

  | ' '+                    { adjust (String.length (Lexing.lexeme lexbuf)); true }

  | _                       { lexbuf.lex_curr_pos <- lexbuf.lex_start_pos;
                             adjust 0; true }

  | eof                     { false }

{

let rec next_token lexbuf =
  match !pending with
  | INDENT :: _ when !nl_pending ->
      nl_pending := false;
      NEWLINE                        (* INDENT stays queued, comes next *)
  | t :: ts ->
      nl_pending := false;
      pending := ts;
      t
  | [] ->
      if !bol then begin
        bol := false;
        let real_line = layout lexbuf in
        if real_line && !nl_pending && (match !pending with INDENT :: _ -> false | _ -> true) then begin
          nl_pending := false;
          if List.hd !indent_stack > 0 then begin
            if !pending = [] then pending := [NEWLINE]
            else pending := !pending @ [NEWLINE]
          end
        end;
        next_token lexbuf
      end
      else begin
        match token lexbuf with
        | NEWLINE -> nl_pending := true; next_token lexbuf
        | t -> t
      end

}