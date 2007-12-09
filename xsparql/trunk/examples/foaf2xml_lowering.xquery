declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace sparql_res="http://www.w3.org/2005/sparql-results#";
let $aux_query := 
       fn:concat("http://localhost:2020/sparql?query=",
           fn:encode-for-uri(
              fn:concat("PREFIX foaf: <http://xmlns.com/foaf/0.1/> SELECT $Person $Name FROM <file:examples/foaf.rdfxml> WHERE { $Person foaf:name $Name } ORDER BY $Name",
                        "")))
for $aux_result in doc($aux_query)//sparql_res:result
let $Person_Node := ($aux_result/sparql_res:binding[@name="Person"]) 
let $Person_NodeType := name($Person_Node/*)
let $Person := data($Person_Node/*) 
let $Person_RDFTerm :=  if ($Person_NodeType = "literal")    then fn:concat("""", $Person, """")
                        else if ($Person_NodeType = "bnode") then fn:concat("_:", $Person) 
                        else if ($Person_NodeType = "uri")   then fn:concat("<",  $Person, ">")
                        else ""
let $Name_Node := ($aux_result/sparql_res:binding[@name="Name"])
let $Name_NodeType := name($Name_Node/*)
let $Name := data($Name_Node/*) 
let $Name_RDFTerm := if ($Name_NodeType = "literal")    then fn:concat("""", $Name, """")
                     else if ($Name_NodeType = "bnode") then fn:concat("_:", $Name) 
                     else if ($Name_NodeType = "uri")   then fn:concat("<",  $Name, ">")
                     else ""
return 
 <Person name="{$Name}">
   {
    let $aux_query :=
          fn:concat("http://localhost:2020/sparql?query=",
             fn:encode-for-uri(
                fn:concat("PREFIX foaf: <http://xmlns.com/foaf/0.1/> SELECT $FName FROM <file:examples/foaf.rdfxml> WHERE { ",
                          $Person_RDFTerm,
                          " foaf:knows $Friend . ",
                          $Person_RDFTerm,
                          " foaf:name ",
                          $Name_RDFTerm,
                          ". $Friend foaf:name $FName. }")))
    for $aux_result in doc($aux_query)//sparql_res:result
    let $FName_Node := ($aux_result/sparql_res:binding[@name="FName"]) 
    let $FName_NodeType := name($FName_Node/*)
    let $FName := data($FName_Node/*) 
    let $FName_RDFTerm := if ($FName_NodeType = "literal")    then fn:concat("""", $FName, """")
                          else if ($FName_NodeType = "bnode") then fn:concat("_:", $FName) 
                          else if ($FName_NodeType = "uri")   then fn:concat("<",  $FName, ">")
                          else ""
    return <knows>{$FName}</knows>
   }
</Person>

