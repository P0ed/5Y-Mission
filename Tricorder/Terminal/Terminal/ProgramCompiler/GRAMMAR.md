#Grammar:
```
 typeDecl		→ ":" id "=" typeExpr ;
 typeExpr		→ id ( int )* ;
 varDecl		→ "[" id ":" typeExpr "=" expression ;
 statement		→ expression | typeDecl | varDecl ;
 expression		→ assignment ;
 assignment		→ call ( "#" call )* ;
 call			→ equality ( "=" equality )* ;
 equality    	→ comparison ( ( "!=" | "==" ) comparison )* ;
 comparison  	→ term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
 term        	→ factor ( ( "-" | "+" ) factor )* ;
 factor      	→ unary ( ( "/" | "*" ) unary )* ;
 unary       	→ ( "!" | "-" ) unary | primary ;
 primary     	→ id | int | str | "(" expression ")" | lambda ;
```
