#WIP Grammar:

!Needs to be fruther refined, not really a source of truth at the moment

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
 factor      	→ composition ( ( "/" | "*" ) composition )* ;
 composition	→ unary ( "•" unary )* ;
 unary       	→ ( "!" | "-" ) unary | primary ;
 primary     	→ id | int | str | lambda | "(" expression ")" ;
 lambda			→ "\" id ">" expression | compound ;
 compound		→ "{" statement ( ";" statement )* "}"
```
