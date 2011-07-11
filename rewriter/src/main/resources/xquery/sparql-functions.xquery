
module namespace sparql =  "http://xsparql.deri.org/demo/xquery/sparql-functions.xquery" ;

import module namespace _xsparql = "http://xsparql.deri.org/demo/xquery/xsparql.xquery" 
                                at "http://xsparql.deri.org/demo/xquery/xsparql.xquery";


declare namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#";

(: Determine if valid Blank node, uri or literal respectively, by checking if
   the parameter is an instance of the required type :)

declare function sparql:isBNode($NType as item()) as xs:boolean
{
  if ($NType instance of element()) then
      fn:name($NType) eq "bnode" or fn:name($NType) eq "_sparql_result:bnode" or fn:name($NType) eq "{http://www.w3.org/2005/sparql-results#}:bnode"
  else fn:false()
};

declare function sparql:isURI($NType as item()) as xs:boolean
{
  if ($NType instance of element()) then
    (:fn:resolve-QName("_sparql_result:uri", $NType) eq fn:node-name($NType):)
    fn:name($NType) eq "uri" or fn:name($NType) eq "_sparql_result:uri" or fn:name($NType) eq "{http://www.w3.org/2005/sparql-results#}:uri"
  else fn:false()
};

declare function sparql:isLiteral($NType as item()) as xs:boolean
{
  if ($NType instance of element()) then
    (:fn:resolve-QName("_sparql_result:literal", $NType) eq fn:node-name($NType):)
    fn:name($NType) eq "literal" or fn:name($NType) eq "_sparql_result:literal" or fn:name($NType) eq "{http://www.w3.org/2005/sparql-results#}:literal"
  else fn:false()
};


declare function sparql:skolem ($term as item() ) {
   sparql:skolem ($term, "http://xsparql.deri.org/skolem#")
};

declare function sparql:skolem ($term as item(), $prefix as xs:string) {
  if(sparql:isBNode($term)) then _xsparql:_rdf_term(fn:concat($prefix, $term)) else $term
};

declare function sparql:skolemise ($terms as item()*, $prefix as xs:string) {
  for $item in $terms return sparql:skolem($item, $prefix)
};


declare function sparql:skolemiseGraph ($graph as xs:string ) {
   sparql:skolemiseGraph ($graph, "http://xsparql.deri.org/skolem#")
};

declare function sparql:skolemiseGraph($graph, $prefix) {
_xsparql:turtleGraphToURI( "",   _xsparql:_serialize( (
  let $_aux_results0 := _xsparql:_sparqlQuery( fn:concat( "SELECT $p $s $o from ", 
                                                        _xsparql:_rdf_term( _xsparql:_binding_term( $graph ) ), 
                                                        "where  { $s $p $o . } " ) )
for $_aux_result0 at $_aux_result0_pos in _xsparql:_sparqlResultsFromNode( $_aux_results0 )

let $p := _xsparql:_resultNode( $_aux_result0, "p" )
let $s := _xsparql:_resultNode( $_aux_result0, "s" )
let $o := _xsparql:_resultNode( $_aux_result0, "o" )

return 
  _xsparql:_serialize( (let $_rdf0 := _xsparql:_binding_term( sparql:skolem( $s, $prefix ) )
  return 
    if (_xsparql:_validSubject( _xsparql:_binding_term( sparql:skolem( $s, $prefix ) ) )) then
      (let $_rdf1 := _xsparql:_binding_term( sparql:skolem( $p, $prefix ) )
      return 
        if (_xsparql:_validPredicate( $_rdf1 )) then
          (let $_rdf2 := _xsparql:_binding_term( sparql:skolem( $o, $prefix ) )
          return 
            if (_xsparql:_validObject( $_rdf2 )) then
              (_xsparql:_rdf_term($_rdf0), " ", _xsparql:_rdf_term($_rdf1), " ", _xsparql:_rdf_term( $_rdf2 ), " .&#xA;")
            else "")
        else "")
    else "") )
 ))
)
};

declare function sparql:createURI ($uri as item()?) {
  if($uri) then
  _xsparql:_binding("_sparql_result:uri",  $uri, "", "")
  else ()
};

declare function sparql:createBNode ($label as item()?) {
  if($label) then
  _xsparql:_binding("_sparql_result:bnode",  $label, "", "")
  else ()
};

declare function sparql:createLiteral ($label as xs:string, $lang as xs:string, $type as xs:string) {
  _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
};

declare function sparql:createLiteral ($label as item()?) {
  if($label) then
    _xsparql:_binding("_sparql_result:literal",  $label, "", "")
  else ()
};

(: try to determine the type of term from the input:)
declare function sparql:createTerm($term as item()?) {
  if($term) then
    _xsparql:_binding_term($term)
  else ()
};


(: get the value of a column from an SQLResult :)
declare function sparql:value($result as item()?, $var as xs:string) {
  (: data($result//SQLbinding[@label=$var]) :)
  data($result//*[name() = $var])
};


(: dump the sequence of strings as an XML element, rewriting can be improved:)
declare function sparql:dumpRow($values as node()*) {
  for $v in $values
  return $v
};

