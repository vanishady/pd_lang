grammar Simple;

tokens { INDENT, DEDENT }

@lexer::header{
from antlr_denter.DenterHelper import DenterHelper
from SimpleParser import SimpleParser
}
@lexer::members {
class SimpleDenter(DenterHelper):
    def __init__(self, lexer, nl_token, indent_token, dedent_token, ignore_eof):
        super().__init__(nl_token, indent_token, dedent_token, ignore_eof)
        self.lexer: SimpleLexer = lexer

    def pull_token(self):
        return super(SimpleLexer, self.lexer).nextToken()

denter = None

def nextToken(self):
    if not self.denter:
        self.denter = self.SimpleDenter(self, self.NL, SimpleParser.INDENT, SimpleParser.DEDENT, True)
    return self.denter.next_token()

}

/*
* parser rules
*/

prog: (INCLUDE ID NL)* PATCH ID NL stmt+ ;

stmt
 : BLOCK ID '{' NL (stmt | subblockstmt)* '}' //block declaration
 | declarationstmt NL
 | connectionstmt NL
 | ifstmt NL
 | forstmt NL
 | BREAK NL
 | CONTINUE NL
 | PASS NL
 | NL
 ;

declarationstmt
 : SINGLE_PARAM '=' (STRING | NUMBER | expr) //parameter setting
 | ID '=' NODETYPE PARAMETERS
 | NODETYPE PARAMETERS //implicit var assignment (autoincrement)
 ;

connectionstmt
 : ('<' ID (',' ID)* '>' | ID) (CONNECT ('<' ID (',' ID)* '>' | ID))+
 | ('<' ID (',' ID)* '>' | ID) (DISCONNECT ('<' ID (',' ID)* '>' | ID))+
 ;


ifstmt
 : IF expr ':' suite (ELIF expr ':' suite)* (ELSE ':' suite)? END
 ;

forstmt
 : FOR INTEGER 'rounds do' ':' NL stmt+ END
 ;

subblockstmt
 : SUBBLOCK ID '{' NL stmt* '}' NL
 ;

suite
 : INDENT stmt+ DEDENT
 ;

expr
 : expr ('*'|'/') expr
 | expr ('+'|'-') expr
 | expr ('**') expr
 | expr ('%') expr
 | expr (EQ | NOT_EQ | '>' | '>=' | '<' | '<=' ) expr
 | expr (AND | OR) expr
 | NUMBER
 | STRING
 | ID
 | L_PAREN expr R_PAREN
 ;

/*
* lexer rules
*/


//keywords

PATCH : 'patch' ;
INCLUDE : 'include' ;
BLOCK : 'block' ;
SUBBLOCK : 'subblock' ;
CONNECT : '::' ;
DISCONNECT : 'disconnect' | ':x' ;
IF : 'if' ;
ELIF : 'elif' ;
ELSE : 'else' ;
FOR : 'for' ;
THISROUND : 'thisround' ;
BREAK : 'break' ;
CONTINUE : 'continue' ;
PASS : 'pass' ;
END : 'end' ;

//punctuation

L_PAREN : '(' ;
R_PAREN : ')' ;
L_CURLY : '{' ;
R_CURLY : '}' ;
L_BRACKET : '[' ;
R_BRACKET : ']' ;
L_ANGLE : '<' ;
R_ANGLE : '>';
EQ : '==' ;
NOT_EQ : '!=' ;
PLUS : '+' ;
MINUS : '-' ;
POW : '**' ;
STAR: '*' ;
DIV : '/' ;
MOD : '%' ;
OR : '||' ;
AND : '&&' ;


NODETYPE
 : 'array'
 | 'coords'
 | 'floatatom'
 | 'symbolatom'
 | 'text'
 | 'message'
 | 'object'
 ;

PARAMETERS : L_PAREN LIST? R_PAREN ;
SINGLE_PARAM : ID '.' ID ;

ID : ID_START ID_CONTINUE* ;
STRING : '\'' LETTER* '\'' ;
NUMBER : INTEGER | FLOAT ;
INTEGER : NON_ZERO_DIGIT DIGIT* | '0'+ ;
FLOAT : INTEGER? '.' INTEGER ;
LIST : (STRING | NUMBER) (',' (STRING | NUMBER))* ;

fragment LETTER : [a-zA-Z] ;
fragment DIGIT : [0-9] ;
fragment NON_ZERO_DIGIT : [1-9] ;
fragment ID_START : '_' | LETTER ;
fragment ID_CONTINUE : LETTER | DIGIT ;

NL: ('\r'? '\n' ' '*);
WS : [ \t]+ -> skip ;
COMMENT : '#' ~[\r\n]* -> skip ;
