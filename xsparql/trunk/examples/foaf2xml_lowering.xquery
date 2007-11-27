declare namespace foaf="http://xmlns.com/foaf/0.1/";

let $aux_str1 := 
       fn:concat("http://localhost/sparqlendpoint?query=",
           fn:encode-for-uri("SELECT $Person, $Name 
                              FROM <foaf.rdf> 
                              WHERE { $Person name $Name } 
                              ORDER BY $Name"))
let $aux_result1 := doc($aux_str1)
for $Person in $aux_result1/XPATHFOREXTRACINGBINDINGSOF$Person, 
    $Name in $aux_result1/XPATHFOREXTRACINGBINDINGSOF$Name
return 
 <Person name="{$Name}">
   {
    let $aux_str1 :=
          fn:concat("http://localhost/sparqlendpoint?query=",
             fn:encode-for-uri(
                fn:concat("SELECT $FName FROM <foaf.rdf> WHERE { ",
                          {$Person},
                          " knows $Friend . ",
                          {$Person},
                          " name ",
                          {$Name},". 
                          $Friend name $Fname. }"))
    let $aux_result2 := doc($aux_str2)
    for $FName in $aux_result2/XPATHFOREXTRACINGBINDINGSOF$FName
    return <knows>{$FName}</knows> 
    }
</Person>

