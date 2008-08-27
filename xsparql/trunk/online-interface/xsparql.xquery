module namespace xsparql =  "http://xsparql.deri.org/xsparql.xquery" ;


declare function xsparql:rdf_term($NType as xs:string, $V as xs:string) as xs:string 
{ 
  let $rdf_term := 
      if($NType = "sparql_result:literal" or $NType = "literal") 
      then fn:concat("""",$V,"""") 
      else if ($NType = "sparql_result:bnode" or $NType = "bnode") 
           then fn:concat("_:", $V) 
           else if ($NType = "sparql_result:uri" or $NType = "uri") 
                then fn:concat("<", $V, ">") 
                else "" 
  return $rdf_term  
};


declare function xsparql:empty($rdf_Predicate as xs:string,  $rdf_Object as xs:string) as xs:string 
{ 
  let $output :=  
      if( 
          fn:substring($rdf_Predicate, 0, 3) = "_:" or 
          substring($rdf_Predicate, 0, 2) = """ or  
          substring(
                    $rdf_Predicate, 
                    fn:string-length($rdf_Predicate), 
                    fn:string-length($rdf_Predicate)
                   )   = """ 
        )
        then   " " 
        else  fn:concat($rdf_Predicate,  $rdf_Object) 
  return $output 
}; 

declare function xsparql:validBNode($NType as xs:string, $V as xs:string) as xs:boolean
{
 let $result := 
     if ($NType = "sparql_result:bnode" or $NType = "bnode")
     then fn:true() 
     else if (fn:substring($V, 0, 3) = "_:") 
          then fn:true() 
          else fn:false()
  return $result
};


declare function xsparql:validUri($NType as xs:string, $V as xs:string) as xs:boolean
{
  let $result :=
      if ($NType = "sparql_result:uri" or $NType = "uri")
      then fn:true()
      else if (
                fn:substring($V, 1, 1) = "<" and
                fn:substring($V, fn:string-length($V), fn:string-length($V)) = ">" and
                fn:not( fn:contains($V, "<" ) )  and
                fn:not( fn:contains($V, ">" ) )  and
                fn:not( fn:contains($V, """" ) ) and
                fn:not( fn:contains($V, " " ) )  and
                fn:not( fn:contains($V, "{" ) )  and
                fn:not( fn:contains($V, "}" ) )  and
                fn:not( fn:contains($V, "|" ) )  and
		fn:not( fn:contains($V, "\" ) )  and
		fn:not( fn:contains($V, "^" ) )  and
                fn:not( fn:contains($V, "`" ) )
              )
           then fn:true()
           else fn:false()
  return $result
};


declare function xsparql:validLiteral($NType as xs:string, $V as xs:string) as xs:boolean
{
  let $result := 
      if ($NType = "sparql_result:literal" or $NType = "literal")
      then fn:true()
      else if (
                fn:substring($V, 1, 1) = """" and 
                fn:substring($V, fn:string-length($V), fn:string-length($V)) = """"
              ) 
           then fn:true() 
           else fn:false()
  return $result
};


declare function xsparql:validSubject($NType as xs:string, $V as xs:string) as xs:boolean
{ 
  let $return := 
      if ( xsparql:validBNode($NType, $V) or xsparql:validUri($NType, $V) ) 
      then fn:true() 
      else fn:false()
  return $return 
};

declare function xsparql:validPredicate($NType as xs:string, $V as xs:string) as xs:boolean
{ 
  let $return := 
      if ( xsparql:validUri($NType, $V) ) 
      then fn:true() 
      else fn:false()
  return $return 
};

declare function xsparql:validObject($NType as xs:string, $V as xs:string) as xs:boolean
{ 
  let $return := 
      if ( 
           xsparql:validBNode($NType, $V) or 
           xsparql:validUri($NType, $V) or 
           xsparql:validLiteral($NType, $V)
         ) 
      then fn:true() 
      else fn:false()
 return $return 
}; 
