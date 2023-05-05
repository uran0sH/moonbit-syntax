%{
(* Copyright International Digital Economy Academy, all rights reserved *)
open Parser_util
%}

%token <char> CHAR
%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <string> LIDENT
%token <string> UIDENT
%token <string > COMMENT
%token NEWLINE
%token <string> INFIX1
%token LT "<"
%token GT ">"
%token <string> INFIX2
%token <string> INFIX3
%token <string> INFIX4

%token EOF
%token FALSE
%token TRUE
%token IMPORT          "import"
%token BREAK           "break"
%token CONTINUE        "continue" 
%token STRUCT          "struct"
%token ENUM            "enum" 
%token EQUAL           "=" 
%token EQUALEQUAL      "==" 
%token LPAREN          "(" 
%token RPAREN          ")"
%token STAR            "*" 
%token COMMA          "," 
%token MINUS           "-" 
%token MINUSDOT        "-." 
%token <string>DOT_LIDENT            
%token <string>COLONCOLON_UIDENT
%token COLON           ":" 
%token SEMI           
%token LBRACKET        "[" 
%token <string> PLUS           "+" 
%token <string> PLUSDOT        "+." 
%token RBRACKET       "]" 

%token UNDERSCORE      "_" 
%token BAR             "|" 

%token LBRACE          "{"
%token RBRACE          "}" 
%token AMPERSAND       "&" 
%token AMPERAMPER     "&&" 
%token BARBAR          "||" 
%token <string>PACKAGE_NAME
/* Keywords */

%token AS              "as" 
%token ELSE            "else" 
%token FN            "fn"
%token TOPLEVEL_FN   "func"
%token IF             "if" 
%token LET            "let"
%token VAR            "var" 
%token MATCH          "match" 
%token MUTABLE        "mut" 
%token OR             "or" 
%token TYPE            "type" 
%token FAT_ARROW     "=>" 
%token SLASH          "/"
%token WHILE           "while" 

%nonassoc "as"
%right "|"

%right OR BARBAR
%right AMPERSAND AMPERAMPER


%left INFIX1 "<"  ">" EQUALEQUAL 
%left INFIX2 PLUS PLUSDOT MINUS MINUSDOT
%left INFIX3 STAR SLASH
%right INFIX4
%nonassoc prec_unary_minus
%start    structure


%type <Syntax.impls> structure
%type <Compact.semi_expr_prop > statement_expr
%%


non_empty_list_commas( X):
  | x = X ioption(",") {}
  | x = X "," xs = non_empty_list_commas( X) {}

%inline list_commas( X):
  | x = ioption(non_empty_list_commas( X)) {}

non_empty_list_semis(X):
  x = X; ioption(SEMI)
    {}
| x = X; SEMI; xs = non_empty_list_semis(X)
    {}

%inline list_semis(X): x= option(non_empty_list_semis(X)) {}

%inline id(x): x {}
%inline opt_annot: option(":" t=type_ {}) {}
%inline parameters : delimited("(",separated_list(",",id(b=binder t=opt_annot {})), ")") {}

fun_header:
  "func"
    f=binder
    /* TODO: move the quants before self */
    quants=option(delimited("<",separated_nonempty_list(",",UIDENT), ">"))
    ps=option(parameters)
    ts=opt_annot
    {}


%inline block_expr: "{" ls=list_semis(statement_expr) "}" {}
%inline error_block: error {}
val_header : mut=id("let" {}| "var"{}) binder=binder t=opt_annot {}
structure : list_semis(structure_item) EOF {}
structure_item:
  | type_header=type_header components=type_def {}
  | val_header=val_header  "=" expr = expr {}
  | t=fun_header body=block_expr {}
type_header: "type" tycon=LIDENT params=option(delimited("<", separated_nonempty_list(",",UIDENT) ,">") ) {}    


qual_ident:
  | i=LIDENT {}
  | ps=PACKAGE_NAME id = DOT_LIDENT {}



%inline semi_expr_semi_opt: ls=non_empty_list_semis(statement_expr)  {}

statement_expr:
  | a=expr  {}
  | var=var "=" e=expr {}  
  | record=simple_expr  name=DOT_LIDENT "=" field=expr
    {}     
  | obj=simple_expr  "[" ind=expr "]" "=" value=expr {}
  | "break" {}
  | "continue" {}  
  | "let" pat=pattern ty=opt_annot "=" expr=expr
    {}
  | "var" binder=binder ty=opt_annot "=" expr=expr 
    {}           
  | "fn" name=LIDENT params=parameters ty=opt_annot block = block_expr
    {}

 if_expr:
   | "if"  b=infix_expr ifso=block_expr "else" ifnot=block_expr
   | "if"  b=infix_expr ifso=block_expr "else" ifnot=if_expr  {}
   | "if"  b=infix_expr ifso=block_expr {}
   | "if" b=infix_expr ifso=error_block {}

while_expr:
  | "while" cond=infix_expr b=block_expr
    {}
  | "while" cond=infix_expr b=error_block  
    {}

match_expr:
  | "match" e=infix_expr "{" "|"?  mat=separated_nonempty_list("|", pattern "=>" semi_expr_semi_opt {})  "}"  {}
  | "match" e=infix_expr "{""}" {}
  | "match" e=infix_expr error {}
  
expr:
  | infix_expr 
  | match_expr      
  | if_expr 
  | while_expr {}


infix_expr:
  | op=id(PLUS {} |PLUSDOT{}) e=expr %prec prec_unary_minus {}
  | op=id(MINUS{}|MINUSDOT{}) e=expr %prec prec_unary_minus {}
  | simple_expr  {}
  | expr infixop expr {}


simple_expr:
  | "{" fs=list_commas( l=label ":" e=expr {}) "}" {}
  // | "fn"  parameters "=>" atomic_expr
  // | "{" non_empty_list_semis(statement_expr)"}" {}  
  | "{" x=semi_expr_semi_opt "}" {}  
  | "fn" ps=parameters f = block_expr  {}
  | e = atomic_expr {}
  | "_" {}
  | v=var {}
  | c=constr {}
  // | constr_longident_expr {} 
  | obj=simple_expr  "[" index=expr "]" {}
  | f=simple_expr "(" args=list_commas(expr) ")" {}
  | record=simple_expr  name=DOT_LIDENT {}
  | "("  bs=list_commas(expr) ")" {}  
  | "(" expr ":" type_ ")" {}
  | "[" es = list_commas(expr) "]" {}  

%inline label:
  name = LIDENT {}
%inline binder:
  name = LIDENT {}
%inline var:
  name = qual_ident {}

%inline atomic_expr:
  | TRUE {}
  | FALSE {}
  | CHAR {}
  | INT {}
  | FLOAT {}
  | STRING {}


 %inline infixop:
  | INFIX4
  | INFIX3  
  | INFIX2
  | INFIX1 {}
  | "<" {}
  | ">" {}
  | STAR {}
  | SLASH {}
  | PLUS {}
  | PLUSDOT  {}
  | MINUS {}
  | MINUSDOT {}  
  | EQUALEQUAL {}
  | AMPERSAND {}
  | AMPERAMPER {}
  | OR {}
  | BARBAR {}

%inline constr:
  | name = UIDENT {}
  /* TODO: two tokens or one token here? */
  | type_name=LIDENT constr_name=COLONCOLON_UIDENT
    {}

pattern:
  | simple_pattern {}
  | b=binder "as" p=pattern {}
  | pattern "|" pattern {}
  

simple_pattern:
  | TRUE {}
  | FALSE {}
  | CHAR {}
  | INT {}
  | FLOAT {}
  | STRING {}
  | UNDERSCORE {}
  | b=binder  {}
  | constr=constr ps=option("(" t=separated_nonempty_list(",",pattern) ")" {}){}
  | "(" pattern ")" {}
  | "(" p = pattern "," ps=separated_nonempty_list(",",pattern) ")"  {}     
  | "(" pattern ":" type_ ")" {}
  // | "#" "[" pat = pat_list "]" {}
  | "[" lst=separated_list(",",pattern) "]" {}
  | "{" p=separated_list(",", l=label ":" p=pattern {}) "}" {}
  
type_:
  | "(" t=type_ "," ts=separated_nonempty_list(",", type_)")" {}
  | "(" t=type_ "," ts=separated_nonempty_list(",",type_) ")" "=>" rty=type_ {}
  | "(" ")" "=>" rty=type_ {}
  | "(" t=type_ ")" rty=option("=>" t2=type_{})
      {} 
  | UIDENT {}  
  // | "(" type_ ")" {}
  | id=qual_ident params=option(delimited("<" ,separated_nonempty_list(",",type_), ">"))  {}
  | "_" {}
/* type declaration */


type_def:
  | /* empty */ {}
  | "struct" "{" fs=list_semis(record_decl_field) "}"  {}
  | "enum" "{" fs=list_semis(id=UIDENT opt=option("("  ts=separated_nonempty_list(",",type_)")"{}) {}) "}" {}

record_decl_field:
  | mutflag = option("mut") name=LIDENT ":" ty=type_ {}