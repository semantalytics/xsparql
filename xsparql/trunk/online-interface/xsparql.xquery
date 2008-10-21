module namespace _xsparql =  "http://xsparql.deri.org/xsparql.xquery" ;


declare function _xsparql:_rdf_term($NType as xs:string, $V as xs:string) as xs:string 
{ 
  let $rdf_term := 
      if($NType = "_sparql_result:literal" or $NType = "literal") 
      then fn:concat("""",$V,"""") 
      else if ($NType = "_sparql_result:bnode" or $NType = "bnode") 
           then fn:concat("_:", $V) 
           else if ($NType = "_sparql_result:uri" or $NType = "uri") 
                then fn:concat("<", $V, ">") 
                else "" 
  return $rdf_term  
};


declare function _xsparql:_empty($rdf_Predicate as xs:string,  $rdf_Object as xs:string) as xs:string 
{ 
  let $output :=  
      if( 
          _xsparql:_validPredicate("", $rdf_Predicate) and
	  _xsparql:_validObject("", $rdf_Object)
        )
	then  fn:concat($rdf_Predicate,  $rdf_Object) 
	else " "
  return $output 
}; 

declare function _xsparql:_validBNode($NType as xs:string, $V as xs:string) as xs:boolean
{
 let $result := 
     if ($NType = "_sparql_result:bnode" or $NType = "bnode")
     then fn:true() 
     else if (fn:matches($V, "^_:[a-z]([a-z|0-9|_])*$", "i"))
          then fn:true() 
          else fn:false()
  return $result
};


declare function _xsparql:_validUri($NType as xs:string, $V as xs:string) as xs:boolean
{
  let $result :=
      if ($NType = "_sparql_result:uri" or $NType = "uri")
      then fn:true()
      else if (
                fn:matches($V, "^<[^>]*>$", "i" )       
(:                fn:matches($V, "^<[^<>""\ {}|\^`]*>$", "i" ) :)
              )
           then fn:true()
           else fn:false()
  return $result
};


declare function _xsparql:_validLiteral($NType as xs:string, $V as xs:string) as xs:boolean
{
  let $result := 
      if ($NType = "_sparql_result:literal" or $NType = "literal")
      then fn:true()
      else if (
                fn:starts-with($V, """") and 
                fn:ends-with($V, """")
              )
           then fn:true() 
           else fn:false()
  return $result
};


declare function _xsparql:_validSubject($NType as xs:string, $V as xs:string) as xs:boolean
{ 
  let $return := 
      if ( _xsparql:_validBNode($NType, $V) or _xsparql:_validUri($NType, $V) ) 
      then fn:true() 
      else fn:false()
  return $return 
};

declare function _xsparql:_validPredicate($NType as xs:string, $V as xs:string) as xs:boolean
{ 
  let $return := 
      if ( _xsparql:_validUri($NType, $V) ) 
      then fn:true() 
      else fn:false()
  return $return 
};

declare function _xsparql:_validObject($NType as xs:string, $V as xs:string) as xs:boolean
{ 
  let $return := 
      if ( 
           _xsparql:_validBNode($NType, $V) or 
           _xsparql:_validUri($NType, $V) or 
           _xsparql:_validLiteral($NType, $V)
         ) 
      then fn:true() 
      else fn:false()
 return $return 
}; 

declare function _xsparql:_removeEmpty($result as xs:string) as xs:string
{
  let $output := 
        fn:replace($result, "^( )*\[( )*\]( )*\.", "", 'm')

  let $output := 
        fn:replace($output, ";( )*\.", " .", 'm')

  return $output

};
