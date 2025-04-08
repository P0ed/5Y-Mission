#Grammar:

```
program			→ statement ( ";" statement )* ;
statement		→ expression | typeDecl | varDecl ;
typeDecl		→ ":" id "=" typeExpr ;
varDecl			→ "[" id ":" typeExpr "=" expression ;

typeExpr		→ tupleType ( ">" typeExpr )? ;	
tupleType		→ "(" tupleElem ( "," tupleElem )* ")" | baseType ;
tupleElem		→ id ":" typeExpr | typeExpr ;
baseType		→ id ( int )* ;

expression		→ assignment ;
assignment		→ id "=" assignment | rcall ;
rcall			→ or ( "#" rcall )? ;

or				→ and ( "|" and )* ;
and				→ equality ( "&" equality )* ;
equality    	→ comparison ( ( "!=" | "==" ) comparison )* ;
comparison  	→ term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
term        	→ factor ( ( "-" | "+" ) factor )* ;
factor      	→ composition ( ( "/" | "*" ) composition )* ;
composition		→ control ( "•" composition )* ;
control			→ unary ( "?" control )? ;
unary       	→ ( "*" | "&" | "!" | "-" ) unary | call ;

call			→ primary postfix* ;
postfix			→ "(" expression? ")"
				| "." id
				| "[" expression "]"

primary     	→ id | int | str | lambda | "(" expression ")" ;
lambda			→ "\" id ">" ( expression | "{" program "}" ) ;
```
