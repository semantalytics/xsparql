(:

  Copyright (C) 2011, NUI Galway.
  Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, 
  Vienna University of Technology
  All rights reserved.
 
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The names of the COPYRIGHT HOLDERS AND CONTRIBUTORS may not be used
      to endorse or promote products derived from this software without
      specific prior written permission.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  OF SUCH DAMAGE.
 
  Created on 09 February 2011 by Reasoning and Querying Unit (URQ), 
  Digital Enterprise Research Institute (DERI) on behalf of NUI Galway.
  20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
  on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
  University of Technology,  Nuno Lopes on behalf of NUI Galway.
 

:)
module namespace _xsparql =  "http://xsparql.deri.org/demo/xquery/xsparql.xquery" ;


(: import schema namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#" at "http://www.w3.org/2005/sparql-results#result.xsd"; :)
import schema namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#" at "sparql.xsd";

declare function _xsparql:_validBNode($NType as item()) as xs:boolean
{
  $NType instance of schema-element(_sparql_result:bnode)
};

declare function _xsparql:_validUri($NType as item()) as xs:boolean
{
  $NType instance of schema-element(_sparql_result:uri)
};

declare function _xsparql:_validLiteral($NType as item()) as xs:boolean
{
  if ($NType instance of schema-element(_sparql_result:literal))
    then fn:true()
  else fn:false()
};

declare function _xsparql:_validSubject($NType as item()) as xs:boolean
{ 
if ( _xsparql:_validBNode($NType) or _xsparql:_validUri($NType) ) 
  then fn:true() 
else fn:false()
};

declare function _xsparql:_validPredicate($NType as item()) as xs:boolean
{ 
_xsparql:_validUri($NType) or fn:matches(data($NType), "^a$") 
};

declare function _xsparql:_validObject($NType as item()) as xs:boolean
{ 
  _xsparql:_validBNode($NType) or 
  _xsparql:_validUri($NType) or 
  _xsparql:_validLiteral($NType)
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
      case $Node as schema-element(_sparql_result:uri)
        return _xsparql:_rdf_term($Node)
      case $Node as schema-element(_sparql_result:bnode)
        return _xsparql:_rdf_term($Node)
      case $Node as schema-element(_sparql_result:literal)
        return _xsparql:_rdf_term($Node)
      case $e as element()
        return fn:concat("<", fn:name($e), _xsparql:_serialize-attributes($e/@*), ">",
                           _xsparql:_serialize($e/child::node()),
                           "</", fn:name($e), ">"
                        )
      default
        return fn:string($item)

  return fn:string-join($r,'')
};

declare function _xsparql:_rdf_term($Node as item()) as xs:string
{
  if ($Node instance of xs:anyAtomicType) then $Node 
    else

    typeswitch($Node) 
        case $e as schema-element(_sparql_result:bnode)
            return fn:concat("_:", data($e), "")
        case $e as schema-element(_sparql_result:uri)
            return fn:concat("<", data($e), ">")
        case $e as schema-element(_sparql_result:literal)
            return
                let $DT := data($e/@datatype)
                let $L := data($e/@xml:lang) 
                let $value := if(data($e) instance of xs:integer and fn:empty($DT)) then data($e) else fn:concat("""", data($e), """")
                return fn:concat($value, if($L) then fn:concat("@", $L) else "", 
                                     if($DT) then fn:concat("^^<", $DT,">") else () 
                     )
            default 
            return ""
};


declare function _xsparql:_binding_term($prefix as xs:string,
                                        $Node as xs:anyAtomicType, 
                                        $lang as xs:string, 
                                        $type as xs:string) as item()
{

  let $label := if(fn:compare($prefix, "")=0) 
    then $Node
  else fn:concat($prefix, data($Node))
  return
  typeswitch ($label)
    case $e as xs:integer
    return _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
    case $e as xs:anyURI
    return _xsparql:_binding("_sparql_result:uri",  $label, "", "")
    default
    return if (fn:matches($label, "^_:[a-z]([a-z|0-9|_])*$", "i"))
      then _xsparql:_binding("_sparql_result:bnode",  fn:substring($label,3), "", "")
      else if (fn:matches($Node, "^([a-zA-Z]*):(.+)$")) 
        then _xsparql:_binding("_sparql_result:uri",  $label, "", "")
        else _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
};


declare function _xsparql:_binding_term($Node as xs:anyAtomicType) as item()
{
  _xsparql:_binding_term("", $Node, "", "")
};


declare function _xsparql:_binding($node as xs:string, 
                                   $value as xs:anyAtomicType, 
                                   $lang as xs:string,
                                   $type as xs:string) as item() {

    let $langAtt := if (string-length($lang) > 0) then attribute xml:lang { $lang } else ()
    let $typeAtt := if (string-length($type) > 0) then attribute datatype { $type } else ()
    return 
    validate { 
        element {$node} { 
        $langAtt,
        $typeAtt,
        $value 
        }
    }
  };


declare function _xsparql:_xml_term($Node as item()*) as item()*
{
  typeswitch ($Node)
    case schema-element(_sparql_result:uri)
    return fn:data($Node)
    case schema-element(_sparql_result:bnode)
    return fn:data($Node)
    case schema-element(_sparql_result:literal)
    return fn:data($Node)
    default
    return $Node
};




declare function _xsparql:_resultNode($xml as item(), $var as xs:string) {
  let $node := $xml/_sparql_result:binding[@name = $var]/*
  return $node
};


declare function _xsparql:_sparqlResults ( $uri as xs:string )  {
    let $doc := ( validate { fn:trace(doc($uri),"SPARQL Results") } )//schema-element(_sparql_result:sparql)
    return $doc/_sparql_result:results/_sparql_result:result
};

(:~ Retrieve, from the specified endpoint the SPARQL XML results
 :  file corresponding to the query
 :
 : @param $endpoint The SPARQL endpoint 
 : @param $query The SPARQL query
 : @return SPARQL results in SPaRQL results XML format
 :)
declare function _xsparql:_sparql ( $endpoint as xs:string, $query as item()* )  {
  _xsparql:_serialize(
    ($endpoint, fn:encode-for-uri(fn:trace(_xsparql:_serialize(($query)),"SPARQL Query")))
            )
};

(:~ Retrieve the SPARQL XML results from the default endpoint of <b>$query</b>
 :
 : @param $query The SPARQL query
 : @return SPARQL results in SPARQL results XML format
 :)
declare function _xsparql:_sparql ( $query as item()* )  {
    _xsparql:_sparql ("http://localhost:2020/sparql?query=", $query)
};
