
 declare namespace sparql_result = "http://www.w3.org/2005/sparql-results#"; 

declare function local:rdf_term($NType as xs:string, $V as xs:string) as xs:string 
{ let $rdf_term := if($NType = "sparql_result:literal" or $NType = "literal") then fn:concat("""",$V,"""") 
  else if ($NType = "sparql_result:bnode" or $NType = "bnode") then fn:concat("_:", $V) 
  else if ($NType = "sparql_result:uri" or $NType = "uri") then fn:concat("<", $V, ">") 
  else "" 
  return $rdf_term  };

declare function local:empty($rdf_Predicate as xs:string,  $rdf_Object as xs:string) as xs:string 
{ let $output :=  if( fn:substring($rdf_Predicate, 0, 3) = "_:" or substring($rdf_Predicate, 0, 2) = """ or  
  substring($rdf_Predicate, fn:string-length($rdf_Predicate), fn:string-length($rdf_Predicate))   = """ ) then   " " 
  else  fn:concat($rdf_Predicate,  $rdf_Object) 
  return $output }; 

for $x at $x_Pos  in (1 to 3 )   return text { string($x   )   }   , 
let $y  := for $z at $z_Pos  in (4 to 9 )   return <foo >{ $z   }</foo>   return $y  
