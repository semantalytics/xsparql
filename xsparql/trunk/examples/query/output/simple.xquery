import module namespace local = "http://xsparql.deri.org/xsparql.xquery"
at "http://xsparql.deri.org/xsparql.xquery";

declare namespace sparql_result = "http://www.w3.org/2005/sparql-results#";

for $x at $x_Pos  in (1 to 3 )   return text { string($x   )   }   , 
let $y  := for $z at $z_Pos  in (4 to 9 )   return <foo>{ $z   }</foo>   return $y  
