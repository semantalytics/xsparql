declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
let $persons := //*[@name or ../knows]
return
<rdf:RDF>
 {
 for $p in $persons
 let $n := if( $p[@name] ) then $p/@name else $p
 let $id := count($p/preceding::*)+count($p/ancestor::*)
 where 
   not(exists($p/following::*[@name = $n or data(.)=$n]))
 return
 <foaf:Person rdf:nodeId="b{$id}">
   <foaf:name>{ data($n) }</foaf:name>
    {
    for $k in $persons
    let $kn := if( $k[@name] ) then $k/@name else $k
    let $kid := count($k/preceding::*)+count($k/ancestor::*)
    where 
      $kn = data(//*[@name=$n]/knows) and  
      not(exists($kn/../following::*[@name = $kn or data(.)=$kn]))
    return 
    <foaf:knows><foaf:Person rdf:nodeID="b{$kid}"/></foaf:knows>
    }
   </foaf:Person>
}
</rdf:RDF>