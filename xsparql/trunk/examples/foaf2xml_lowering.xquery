declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace sparql_res="http://www.w3.org/2005/sparql-results#";
let $aux_str1 := 
       fn:concat("http://localhost:2020/sparql?query=",
           fn:encode-for-uri("PREFIX foaf: <http://xmlns.com/foaf/0.1/> SELECT $Person $Name FROM <file:examples/foaf.rdfxml> WHERE { $Person foaf:name $Name } ORDER BY $Name"))
for $aux_result1 in doc($aux_str1)//sparql_res:result

let $Person_Node := ($aux_result1/sparql_res:binding[@name="Person"]) 
let $Person_NodeType := name($Person_Node/*)
let $Person := data($Person_Node/*) 
let $Person_RDFTerm :=  fn:concat(
                          if( $Person_NodeType = "literal") 
                          then """"
                          else(if( $Person_NodeType = "bnode") 
                          then "_:"
                          else(if( $Person_NodeType = "uri") 
                          then "<"
                          else "")),
                          $Person,
                          if( $Person_NodeType = "literal") 
                          then """"
                          else(if( $Person_NodeType = "uri") 
                          then ">"
                          else ""))  
let $Name_Node := ($aux_result1/sparql_res:binding[@name="Name"])
let $Name_NodeType := name($Name_Node/*)
let $Name := data($Name_Node/*) 
let $Name_RDFTerm :=  fn:concat(
                          if( $Name_NodeType = "literal") 
                          then """"
                          else(if( $Name_NodeType = "bnode") 
                          then "_:"
                          else(if( $Name_NodeType = "uri") 
                          then "<"
                          else "")),
                          $Name,
                          if( $Name_NodeType = "literal") 
                          then """"
                          else(if( $Name_NodeType = "uri") 
                          then ">"
                          else ""))  
return 
 <Person name="{$Name}">
   {
    let $aux_str2 :=
          fn:concat("http://localhost:2020/sparql?query=",
             fn:encode-for-uri(
                fn:concat("PREFIX foaf: <http://xmlns.com/foaf/0.1/> SELECT $FName FROM <file:examples/foaf.rdfxml> WHERE { ",
                          $Person_RDFTerm,
                          " foaf:knows $Friend . ",
                          $Person_RDFTerm,
                          " foaf:name ",
                          $Name_RDFTerm,
                          ". $Friend foaf:name $FName. }")))
    for $aux_result2 in doc($aux_str2)//sparql_res:result
    let $FName_Node := ($aux_result2/sparql_res:binding[@name="FName"]) 
    let $FName_NodeType := name($FName_Node/*)
    let $FName := data($FName_Node/*) 
    let $FName_RDFTerm :=  fn:concat(
                          if( $FName_NodeType = "literal") 
                          then """"
                          else(if( $FName_NodeType = "bnode") 
                          then "_:"
                          else(if( $FName_NodeType = "uri") 
                          then "<"
                          else "")),
                          $Person,
                          if( $FName_NodeType = "literal") 
                          then """"
                          else(if( $FName_NodeType = "uri") 
                          then ">"
                          else ""))  
 return <knows>{$FName}</knows> }
</Person>

