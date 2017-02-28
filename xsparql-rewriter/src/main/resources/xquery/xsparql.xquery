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
(:import schema namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#" at "sparql.xsd";:)

declare namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#";

declare function _xsparql:atomic-type 
  ( $values as xs:anyAtomicType* )  as xs:string* {
       
 for $val in $values
 return
 (if ($val instance of xs:untypedAtomic) then 'xs:untypedAtomic'
 else if ($val instance of xs:anyURI) then 'xs:anyURI'
 else if ($val instance of xs:ENTITY) then 'xs:ENTITY'
 else if ($val instance of xs:ID) then 'xs:ID'
 else if ($val instance of xs:NMTOKEN) then 'xs:NMTOKEN'
 else if ($val instance of xs:language) then 'xs:language'
 else if ($val instance of xs:NCName) then 'xs:NCName'
 else if ($val instance of xs:Name) then 'xs:Name'
 else if ($val instance of xs:token) then 'xs:token'
 else if ($val instance of xs:normalizedString)
         then 'xs:normalizedString'
 else if ($val instance of xs:string) then 'xs:string'
 else if ($val instance of xs:QName) then 'xs:QName'
 else if ($val instance of xs:boolean) then 'xs:boolean'
 else if ($val instance of xs:base64Binary) then 'xs:base64Binary'
 else if ($val instance of xs:hexBinary) then 'xs:hexBinary'
 else if ($val instance of xs:byte) then 'xs:byte'
 else if ($val instance of xs:short) then 'xs:short'
 else if ($val instance of xs:int) then 'xs:int'
 else if ($val instance of xs:long) then 'xs:long'
 else if ($val instance of xs:unsignedByte) then 'xs:unsignedByte'
 else if ($val instance of xs:unsignedShort) then 'xs:unsignedShort'
 else if ($val instance of xs:unsignedInt) then 'xs:unsignedInt'
 else if ($val instance of xs:unsignedLong) then 'xs:unsignedLong'
 else if ($val instance of xs:positiveInteger)
         then 'xs:positiveInteger'
 else if ($val instance of xs:nonNegativeInteger)
         then 'xs:nonNegativeInteger'
 else if ($val instance of xs:negativeInteger)
         then 'xs:negativeInteger'
 else if ($val instance of xs:nonPositiveInteger)
         then 'xs:nonPositiveInteger'
 else if ($val instance of xs:integer) then 'xs:integer'
 else if ($val instance of xs:decimal) then 'xs:decimal'
 else if ($val instance of xs:float) then 'xs:float'
 else if ($val instance of xs:double) then 'xs:double'
 else if ($val instance of xs:date) then 'xs:date'
 else if ($val instance of xs:time) then 'xs:time'
 else if ($val instance of xs:dateTime) then 'xs:dateTime'
 else if ($val instance of xs:dayTimeDuration)
         then 'xs:dayTimeDuration'
 else if ($val instance of xs:yearMonthDuration)
         then 'xs:yearMonthDuration'
 else if ($val instance of xs:duration) then 'xs:duration'
 else if ($val instance of xs:gMonth) then 'xs:gMonth'
 else if ($val instance of xs:gYear) then 'xs:gYear'
 else if ($val instance of xs:gYearMonth) then 'xs:gYearMonth'
 else if ($val instance of xs:gDay) then 'xs:gDay'
 else if ($val instance of xs:gMonthDay) then 'xs:gMonthDay'
 else 'unknown')
 } ;

(: Determine if valid Blank node, uri or literal respectively, by checking if
   the parameter is an instance of the required type :)

declare function _xsparql:_validBNode($NType as item()?) as xs:boolean
{
  if ($NType instance of element()) then
(:    fn:resolve-QName("_sparql_result:bnode", $NType) eq fn:node-name($NType):)
      fn:name($NType) eq "bnode" or fn:name($NType) eq "_sparql_result:bnode" or fn:name($NType) eq "{http://www.w3.org/2005/sparql-results#}:bnode"
  else fn:false()
};

declare function _xsparql:_validUri($NType as item()?) as xs:boolean
{
  if ($NType instance of element()) then
    fn:name($NType) eq "uri" or fn:name($NType) eq "_sparql_result:uri" or fn:name($NType) eq "{http://www.w3.org/2005/sparql-results#}:uri"
  else fn:false()
};

declare function _xsparql:_validLiteral($NType as item()?) as xs:boolean
{
  if ($NType instance of element()) then
    (:fn:resolve-QName("_sparql_result:literal", $NType) eq fn:node-name($NType):)
    fn:name($NType) eq "literal" or fn:name($NType) eq "_sparql_result:literal" or fn:name($NType) eq "{http://www.w3.org/2005/sparql-results#}:literal"
  else fn:false()
};

declare function _xsparql:_validSubject($NType as item()?) as xs:boolean
{ 
    _xsparql:_validBNode($NType) or _xsparql:_validUri($NType)
};

declare function _xsparql:_validPredicate($NType as item()?) as xs:boolean
{ 
_xsparql:_validUri($NType) or fn:matches(data($NType), "^a$") 
};

declare function _xsparql:_validObject($NType as item()?) as xs:boolean
{ 
  fn:not(empty($NType)) and 
  (_xsparql:_validBNode($NType) or 
  _xsparql:_validUri($NType) or 
  _xsparql:_validLiteral($NType))
}; 


declare function _xsparql:_validSparqlBinding($NType as item()?) as xs:boolean
{ 
_xsparql:_validUri($NType) or _xsparql:_validBNode($NType) or _xsparql:_validLiteral($NType) 
};

 
declare function _xsparql:_typeData (  $items as item()* ) as item()* {
  for $item in $items
  return
   if (_xsparql:_validUri($item) or _xsparql:_validLiteral($item) or _xsparql:_validBNode($item) or _xsparql:_validSQLTerm($item)) then
     fn:data($item)
   else $item
};


(: ------------------------------------------------------------------------------- :)
(: serialisation of an XML element maintaining the XML structrure :)
declare function _xsparql:_serialize-attributes (  $n as item()*  ) as xs:string 
{
  if(fn:empty($n)) 
    then ""
  else fn:concat(" ", 
                 fn:node-name($n[1]), "=""", fn:data($n[1]), """", 
                 _xsparql:_serialize-attributes( fn:subsequence( $n, 2 ) ) 
          ) 
};

declare function _xsparql:_serialize (  $n as item()* ) as xs:string {
  let $r :=
    for $item in $n
    return 
    if (_xsparql:_validUri($item) or _xsparql:_validLiteral($item) or _xsparql:_validBNode($item)) 
    then _xsparql:_rdf_term($item)
    else if ($item instance of element()) 
        then fn:concat("<", fn:name($item), _xsparql:_serialize-attributes($item/@*), ">",
                           _xsparql:_serialize($item/child::node()),
                           "</", fn:name($item), ">"
                        )
      else fn:string($item)

  return fn:string-join($r,'')
};



(: ------------------------------------------------------------------------------- :)
(: returns the RDF representation of the $Node, according to it's type :)
declare function _xsparql:_rdf_term($Node as item()) as xs:string
{
    if (_xsparql:_validBNode($Node)) then
            fn:concat("_:", data($Node), "")
    else if (_xsparql:_validUri($Node)) 
        (: then if (fn:starts-with($Node, "tel:") or fn:starts-with($Node, "https://") or fn:starts-with($Node, "http://") or fn:starts-with($Node, "mailto:") or fn:starts-with($Node, "file:") or fn:not(fn:contains($Node, ":"))) then
               fn:concat("<", data($Node), ">")
               else data($Node) :)
            then fn:concat("<", data($Node), ">")
         else if (_xsparql:_validLiteral($Node)) 
            then
                let $DT := data($Node/@datatype)
                let $L := data($Node/@xml:lang) 
      return
                  if ($DT eq "rdf:XMLLiteral") then _xsparql:_serialize(("""""""", $Node/child::node(), """""""","^^", $DT,""))
                  else
                (: uncomment to create a simple literal for numbers :)
                let $value := (: if(fn:matches(data($Node), "^[0-9]+(\.[0-9]+)?$") and fn:empty($DT)) then data($Node) else  :)
                  let $d := fn:replace(fn:data($Node), "\\", "\\\\")
                  return if (fn:contains($d, "&#xD;")  or fn:matches($d, "\n")) then fn:concat("""""""", fn:replace($d, """","\\"""), """""""")
                    else if (fn:contains($d, """")) then fn:concat("""", fn:replace($d, """","\\"""), """")
                      else fn:concat("""", $d, """")

                return fn:concat($value, if($L) then fn:concat("@", $L) else "", 
                                     if($DT) then 
                                       if (fn:starts-with($DT, "http://")) then fn:concat("^^<", $DT,">") else fn:concat("^^", $DT,"")
                                     else () 
                     )
            else $Node
};


(: returns an element of a SPARQL type.  Used for conversion of XML elements when outputing RDF. 
   Determines the RDF type according to the XML type :)
declare function _xsparql:_binding_term($prefix as xs:string,
                                        $Node as item()*, 
                                        $lang as xs:string?, 
                                        $type as xs:string?) as item()
{
  if (_xsparql:_validSparqlBinding($Node)) then $Node
  else 
  if(fn:empty($Node)) then "" else
    let $label := if(fn:compare($prefix, "")=0)   (: change to if($prefix) :)
      then $Node
      else fn:concat($prefix, data($Node))
     let $lang := if ($Node instance of element() and fn:exists($Node/@xml:lang) and fn:compare($lang,"")=0) then $Node/@xml:lang/string()
                  else $lang
    return
      typeswitch ($label)
        case $e as xs:integer
        	return _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
        case $e as xs:anyURI
        	return _xsparql:_binding("_sparql_result:uri",  $label, "", "")
        default
          return if (fn:matches(xs:string($label), "^_:[a-z]([a-z|0-9|_])*$", "i")) 
            then _xsparql:_binding("_sparql_result:bnode",  fn:substring($label,3), "", "")
            (: attempt to detect if it is a prefixed URI. :)
            (:else if (fn:matches(xs:string($Node), "^([a-zA-Z]*):([a-zA-Z0-9_\-\.@]+)$")) :)
            (: else if (fn:starts-with(xs:string($Node), "https://") or fn:starts-with(xs:string($Node), "http://") or fn:starts-with(xs:string($Node), "mailto:") or fn:starts-with(xs:string($Node), "file:")) :)
            (: then _xsparql:_binding("_sparql_result:uri",  $label, "", "") :)
            else _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
};


declare function _xsparql:_binding_term($Node as item()*) as item()
{
  _xsparql:_binding_term("", $Node, "", "")
};


(: Creates an element of RDF type :)
declare function _xsparql:_binding($node as xs:string, 
                                   $value as item()*, 
                                   $lang as xs:string?,
                                   $type as xs:string?) as item() {

    let $langAtt := if ($lang and string-length($lang) > 0) then attribute xml:lang { $lang } else ()
    let $typeAtt := if ($type and string-length($type) > 0) then attribute datatype { $type } 
                        else if (fn:matches(_xsparql:atomic-type($value), 'xs:string') or
								 fn:matches(_xsparql:atomic-type($value), 'xs:untypedAtomic')) then ()
                        else ( attribute datatype { _xsparql:atomic-type($value) } )
    return
        element {$node} { 
        $langAtt,
        $typeAtt,
        $value 
    }
  };


(: Converts an RDF type element to XML.  To be used in a return clause :)
declare function _xsparql:_xml_term($Node as item()*) as item()*
{
  if (_xsparql:_validUri($Node) or _xsparql:_validLiteral($Node) or _xsparql:_validBNode($Node)) 
  then fn:data($Node)
  else $Node
};


declare function _xsparql:_validSQLTerm($NType as item()) as xs:boolean
{
  if ($NType instance of element()) then
      fn:name($NType) eq "SQLbinding" 
  else fn:false()
};


(: returns an element of SQL type.  :)
declare function _xsparql:_sql_binding_term($Node as xs:anyAtomicType?) as item()
{
  let $d := fn:data($Node)
  (: return typeswitch ($d) :)
  (:       case $e as xs:string :)
        	return fn:concat("'",$d,"'")
        (: default :)
        (:   return $d :)
};


(: ------------------------------------------------------------------------------- :)
(: returns the sequence of results from the SQL XML results format :)
declare function _xsparql:_sqlResults ( $doc as item()* )  {
  $doc/sql/results/result
};

(: returns the value of a variable from SQL XML results  :)
declare function _xsparql:_sqlResultNode($xml as item()?, $var as xs:string) {
  $xml//*[@name = $var or @label = $var or @name = fn:concat("""", $var, """") or @label = fn:concat("""", $var, """")] 
  (: element {"SQLbinding"} {$xml//*[name() = $var]} :)
};


(: ------------------------------------------------------------------------------- :)
(: retrieves the value of variable $var from the SPARQL XML results format :)
declare function _xsparql:_resultNode($xml as item()?, $var as xs:string) {
  $xml/_sparql_result:binding[@name = $var]/*
};


(: returns the sequence of results from the SPARQL XML results format :)
declare function _xsparql:_sparqlResults ( $uri as xs:string )  {
    let $doc := ( doc($uri) )//_sparql_result:sparql
    return $doc/_sparql_result:results/_sparql_result:result
};


declare function _xsparql:_sparqlResultsFromNode ( $xml as item()* )  {
    let $doc := ( $xml )//_sparql_result:sparql
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
  fn:replace(fn:concat($endpoint, fn:encode-for-uri($query)),"%0A", "%20")
};

(:~ Retrieve the SPARQL XML results from the default endpoint of <b>$query</b>
 :
 : @param $query The SPARQL query
 : @return SPARQL results in SPARQL results XML format
 :)
declare function _xsparql:_sparql ( $query as item()* )  {
    _xsparql:_sparql ("http://localhost:2020/sparql?query=", $query)
};
