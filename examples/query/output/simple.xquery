
import module namespace _xsparql = "http://xsparql.deri.org/XSPARQLer/xsparql.xquery"
at "http://xsparql.deri.org/XSPARQLer/xsparql.xquery";

declare namespace _sparql_result = "http://www.w3.org/2005/sparql-results#";

for $x at $_x_Pos  in (1 to 3 )   return text { string($x   )   }   , 
let $y  := for $z at $_z_Pos  in (4 to 9 )   return <foo> { $z   }</foo>  
 return $y  
