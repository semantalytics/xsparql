module namespace _xsparql =  "http://xsparql.deri.org/XSPARQLer/xsparql.xquery" ;

declare namespace _sparql_result = "http://www.w3.org/2005/sparql-results#";

declare function _xsparql:_rdf_term($NType as xs:string, $V as xs:string, $L as xs:string, $DT as xs:string) as xs:string
{
  if($NType = "_sparql_result:literal" or $NType = "literal")
    then fn:concat("""",$V,"""", if($L) then fn:concat("@", $L) else "", 
                                    if($DT) then fn:concat("^^<", $DT,">") else "" 
                     )
       else if ($NType = "_sparql_result:bnode" or $NType = "bnode")
            then fn:concat("_:", $V)
            else if ($NType = "_sparql_result:uri" or $NType = "uri")
                 then fn:concat("<", $V, ">")
                 else ""
};


declare function _xsparql:_empty($rdf_Predicate as xs:string,  $rdf_Object as xs:string) as xs:string 
{ 
      if( 
          _xsparql:_validPredicate("", $rdf_Predicate) and
	  _xsparql:_validObject("", $rdf_Object)
        )
	then  fn:concat($rdf_Predicate,  $rdf_Object) 
	else " "
}; 

declare function _xsparql:_validBNode($NType as xs:string, $V as xs:string) as xs:boolean
{
  if ($NType = "_sparql_result:bnode" or $NType = "bnode")
    then fn:true() 
  else if (fn:matches($V, "^_:[a-z]([a-z|0-9|_])*$", "i"))
    then fn:true() 
  else fn:false()
};


declare function _xsparql:_validUri($NType as xs:string, $V as xs:string) as xs:boolean
{
      if ($NType = "_sparql_result:uri" or $NType = "uri")
      then fn:true()
      else if (
                fn:matches($V, "^<[^>]+:[^>]+>$", "i" ) or
		fn:matches($V, "^([a-zA-Z]*):(.+)$")
(:                fn:matches($V, "^<[^<>""\ {}|\^`]*>$", "i" ) :)
              )
           then fn:true()
           else fn:false()
};


declare function _xsparql:_validLiteral($NType as xs:string, $V as xs:string) as xs:boolean
{
  if ($NType = "_sparql_result:literal" or $NType = "literal")
    then fn:true()
  else if (
    fn:matches($V, "^([0-9]+|""[a-zA-Z0-9,:@\n\r\t. ()+<>/]+""([ ]*(@|\^\^)[ ]*[a-zA-Z0-9:.#/<>]+)?)$", "i")
       )
       then fn:true() 
     else fn:false()
};


declare function _xsparql:_validSubject($NType as xs:string, $V as xs:string) as xs:boolean
{ 
if ( _xsparql:_validBNode($NType, $V) or _xsparql:_validUri($NType, $V) ) 
  then fn:true() 
else fn:false()
};

declare function _xsparql:_validPredicate($NType as xs:string, $V as xs:string) as xs:boolean
{ 
if ( _xsparql:_validUri($NType, $V) or fn:matches($V, "^a$") ) 
  then fn:true() 
else fn:false()
};

declare function _xsparql:_validObject($NType as xs:string, $V as xs:string) as xs:boolean
{ 
if ( 
  _xsparql:_validBNode($NType, $V) or 
  _xsparql:_validUri($NType, $V) or 
  _xsparql:_validLiteral($NType, $V)
) 
then fn:true() 
else fn:false()
}; 

declare function _xsparql:_removeEmpty($result as xs:string) as xs:string
{
  let $output := 
        fn:replace($result, "^( )*\[( )*\]( )*\.", "", 'm')

  let $output := 
        fn:replace($output, ";( )*\.", " .", 'm')

  return $output

};



declare function _xsparql:_serialize-attributes (  $n as item()*  ) as xs:string {
         if(fn:empty($n)) then
              ""
         else 
              fn:concat(" ", 
                        fn:node-name($n[1]), "=""", fn:data($n[1]), """", 
                        _xsparql:_serialize-attributes( fn:subsequence( $n, 2 ) ) 
                       ) 

};


declare function _xsparql:_serialize (  $n as item()* ) as xs:string {
  let $r :=
    for $item in $n
    return typeswitch ($item)
      case $e as element()
        return fn:concat("<", fn:name($e), _xsparql:_serialize-attributes($e/@*), ">",
                           _xsparql:_serialize($e/child::node()),
                           "</", fn:name($e), ">"
                        )
      default
        return fn:string($item)

  return fn:string-join($r,'')
};

(: declare function _xsparql:_serialize (  $n as item()* ) as xs:string { :)
(:     if(fn:empty($n)) then :)
(:           "" :)
(:      else  :)
(:           fn:concat( :)
(:               typeswitch ($n[1]) :)
(:                   case $e as element()  :)
(:                       return fn:concat("<", fn:name($e), _xsparql:_serialize-attributes($e/@*), ">",  :)
(:                                        _xsparql:_serialize($e/child::node()),  :)
(:                                        "</", fn:name($e), ">" :)
(:                                       ) :)
(:                   default :)
(:                       return $n[1], :)
(:               _xsparql:_serialize( fn:subsequence( $n, 2 ) ) :)
(:               ) :)
(: }; :)



declare function _xsparql:_rdf_term($Node as node(), $V as xs:string) as xs:string
{
   let $NType := name($Node/*)
   let $DT := string($Node/*/@datatype)
   let $L := string($Node/*/@lang) 
   let $rdf_term :=
       if($NType = "_sparql_result:literal" or $NType = "literal")
       then fn:concat("""",$V,"""", if($L) then fn:concat("@", $L) else "", 
                                    if($DT) then fn:concat("^^<", $DT,">") else "" 
                     )
       else if ($NType = "_sparql_result:bnode" or $NType = "bnode")
            then fn:concat("_:", $V)
            else if ($NType = "_sparql_result:uri" or $NType = "uri")
                 then fn:concat("<", $V, ">")
                 else ""
   return $rdf_term
};


