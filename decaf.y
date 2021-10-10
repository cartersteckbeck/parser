/* These are the tokens.
   By convention (in CS 310) they have numbers starting with 260. Take care that
   this list exactly matches the array of strings declared in token.cc. These tokens are only used for multi-character tokens. Single-character tokens
   map to their characters directly.
*/
// if(yytext.size() > 31)
//                  lex_error("Identifier %s too long", yytext);
//              else
%token T_VOID 260 "void"
%token T_INT 261 "int"
%token T_DOUBLE 262 "double"
%token T_BOOL 263 "bool"
%token T_STRING 264 "string"
%token T_CLASS 265 "class"
%token T_INTERFACE 266 "interface"
%token T_NULL 267 "null"
%token T_THIS 268 "this"
%token T_EXTENDS 269 "extends"
%token T_IMPLEMENTS 270 "implements"
%token T_FOR 271 "for"
%token T_WHILE 272 "while"
%token T_IF 273 "if"
%token T_ELSE 274 "else"
%token T_RETURN 275 "return"
%token T_BREAK 276 "break"
%token T_NEW 277 "New"
%token T_NEWARRAY 278 "NewArray"
%token T_PRINT 279 "Print"
%token T_READINTEGER 280 "ReadInteger"
%token T_READLINE 281 "ReadLine"
%token T_LE 282 "<="
%token T_GE 283 ">="
%token T_EQ 284 "=="
%token T_NEQ 285 "!="
%token T_AND 286 "&&"
%token T_OR 287 "||"
%token T_ARRAY 288 "[]"
%token T_DBLLITERAL 289
%token T_INTLITERAL 290
%token T_BOOLLITERAL 291
%token T_IDENTIFIER 292
%token T_TYPEIDENTIFIER 293
%token T_STRINGLITERAL 294

%{
#include "parsetree.h"
#define YYSTYPE parse_tree *
int yylex();
extern bool semantic_checks; // defined in the compiler main file.

/* We need this to see syntax errors. */
int yyerror(char const *s)
{
   std::cout << "line " << current_line << ": ";
   std::cout << s << std::endl;
   // exit at the first error.
   exit(1);
}

%}

%define parse.error verbose

%%

/* Debugging hint: if you want to test part of the grammar in isolation,
* change this line rather than using the %start directive from yacc/bison.
* (Crucially, this line sets the "top" variable.)
*/
pgm: program {top = $$ = $1; }

/* Language grammar follows:
*/

/* This is a stub. We are not discussing parsing yet. */
program: decl {$$ = $1; }

decl: /* empty */ {$$ = new parse_tree("program"); }
      | decl varDecl {$1->add_child($2); $$ = $1; }
      | decl funcDecl {$1->add_child($2); $$ = $1; }


/* Variable Declarations */
varDecl: variable ';'

variable: type identifier {$$ = new parse_tree("variable", 2, $type, $identifier); }

type: usertype | primtype | arraytype

usertype: typeidentifier {$$ = new parse_tree("usertype", 1, $typeidentifier); }

primtype: string {$$ = new parse_tree("primtype", 1, $string); }
        | int {$$ = new parse_tree("primtype", 1, $int); }
        | double {$$ = new parse_tree("primtype", 1, $double); }
        | bool {$$ = new parse_tree("primtype", 1, $bool); }

arraytype: usertype array[a1] {$$ = new parse_tree("arraytype", 1, $usertype); }
         | primtype array[a2] {$$ = new parse_tree("arraytype", 1, $primtype); }


/* Function Declarations */
funcDecl: type identifier[i1] '(' formals[f1] ')' stmtblock[s1] {$$ = new parse_tree("functiondecl", 4, $type, $i1, $f1, $s1); }
        | void identifier[i2] '(' formals[f2] ')' stmtblock[s2] {$$ = new parse_tree("functiondecl", 4, $void, $i2, $f2, $s2); }

formals: /* empty */ {$$ = new parse_tree("formals"); }
       | formals[f1] variable[v1] {$f1->add_child($v1); $$ = $1; }
       | formals[f2] variable[v2] ',' {$f2->add_child($v2); $$ = $1; }

varDeclStar: /* empty */ {$$ = new parse_tree("vardecls");}
           | varDeclStar varDecl {$1->add_child($2); $$ = $1; }

stmtStar: /* empty */ {$$ = new parse_tree("stmts");}
        | stmtStar stmt {$1->add_child($2); $$ = $1; }

stmtblock: '{' varDeclStar[v] stmtStar[s] '}' {$$ = new parse_tree("stmtblock", 2, $v, $s);}

stmt: break ';' {$$ = new parse_tree("break", 1, $break); }
    // | ';'
    | expr ';'

/* Expressions */

Lval: identifier
    | expr '.' identifier[i]  {$$ = new parse_tree("fieldaccess", 2, $expr, $i);}
    | expr[a] '[' expr[b] ']' {$$ = new parse_tree("aref", 2, $a, $b);}

expr: Lval '=' expr1 {$$ = new parse_tree("binop", 3, $Lval, new parse_tree("="), $expr1);}

expr1: expr2
     | expr1[inner] or expr2 {$$ = new parse_tree("binop", 3, $inner, $or, $expr2);}

expr2: expr3
     | expr2[inner] and expr3 {$$ = new parse_tree("binop", 3, $inner, $and, $expr3);}

expr3: expr4
     | expr3[inner] eq expr4 {$$ = new parse_tree("binop", 3, $inner, $eq, $expr4);}
     | expr3[inner] neq expr4 {$$ = new parse_tree("binop", 3, $inner, $neq, $expr4);}

expr4: expr5
     | expr4[inner] '<' expr5 {$$ = new parse_tree("binop", 3, $inner, new parse_tree("<"), $expr5);}
     | expr4[inner] '>' expr5 {$$ = new parse_tree("binop", 3, $inner, new parse_tree(">"), $expr5);}
     | expr4[inner] le expr5 {$$ = new parse_tree("binop", 3, $inner, $le, $expr5);}
     | expr4[inner] ge expr5 {$$ = new parse_tree("binop", 3, $inner, $ge, $expr5);}

expr5: expr6
     | expr5[inner] '+' expr6 {$$ = new parse_tree("binop", 3, $inner, new parse_tree("+"), $expr6);}
     | expr5[inner] '-' expr6 {$$ = new parse_tree("binop", 3, $inner, new parse_tree("-"), $expr6);}

expr6: expr7
     | expr6[inner] '*' expr7 {$$ = new parse_tree("binop", 3, $inner, new parse_tree("*"), $expr7);}
     | expr6[inner] '/' expr7 {$$ = new parse_tree("binop", 3, $inner, new parse_tree("/"), $expr7);}
     | expr6[inner] '%' expr7 {$$ = new parse_tree("binop", 3, $inner, new parse_tree("%"), $expr7);}

expr7: expr8
     | '!' expr8 {$$ = new parse_tree("uop", 2, new parse_tree("!"), $expr8);}
     | '-' expr8 {$$ = new parse_tree("uop", 2, new parse_tree("-"), $expr8);}

expr8: expr9
| expr8[inner] '[' expr9 ']' {$$ = new parse_tree("aref", 2, $inner, $expr9);}
| expr8[inner] '.' expr9 {$$ = new parse_tree("fieldaccess", 2, $inner, $expr9);}

expr9: identifier
     | constant
     | this
     | call
     | '(' expr ')' { $$ = $expr; }
     | readint '(' ')'
     | readline '(' ')'
     | new '(' identifier ')'
     | newarray '(' expr ',' type ')'

call: identifier '(' actuals ')'
    | expr '.' identifier '(' actuals ')'

actuals: /* empty */
       | actuals expr
       | actuals expr ','

constant: intlit
        | dbllit
        | boollit
        | stringlit
        | null



/* TERMINAL PRODUCTIONS */
typeidentifier: T_TYPEIDENTIFIER { $$ = new parse_tree(mytok); }
identifier: T_IDENTIFIER { $$ = new parse_tree(mytok); }
string: T_STRING { $$ = new parse_tree(mytok); }
int: T_INT { $$ = new parse_tree(mytok); }
double: T_DOUBLE { $$ = new parse_tree(mytok); }
bool: T_BOOL { $$ = new parse_tree(mytok); }
array: T_ARRAY { $$ = new parse_tree(mytok); }
void: T_VOID { $$ = new parse_tree(mytok); }
break: T_BREAK { $$ = new parse_tree(mytok); }
this: T_THIS { $$ = new parse_tree(mytok); }
le: T_LE { $$ = new parse_tree(mytok); }
ge: T_GE { $$ = new parse_tree(mytok); }
eq: T_EQ { $$ = new parse_tree(mytok); }
neq: T_NEQ { $$ = new parse_tree(mytok); }
and: T_AND { $$ = new parse_tree(mytok); }
or: T_OR { $$ = new parse_tree(mytok); }
readint: T_READINTEGER { $$ = new parse_tree(mytok); }
new: T_NEW { $$ = new parse_tree(mytok); }
newarray: T_NEWARRAY { $$ = new parse_tree(mytok); }
intlit: T_INTLITERAL { $$ = new parse_tree(mytok); }
dbllit: T_DBLLITERAL { $$ = new parse_tree(mytok); }
boollit: T_BOOLLITERAL { $$ = new parse_tree(mytok); }
stringlit: T_STRINGLITERAL { $$ = new parse_tree(mytok); }
null: T_NULL { $$ = new parse_tree(mytok); }
readline: T_READLINE { $$ = new parse_tree(mytok); }

%%
