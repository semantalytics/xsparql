let $persons := //*[@name or ../knows]
return
<RDF>
{
for $p in $persons
let $n := if( $p[@name] ) then $p/@name else $p
let $id := count($p/preceding::*)+count($p/ancestor::*)
where not(exists($n/../following::*[@name = $n or data(.)=$n]))
return
<person nodeId="{$id}">
<name>{ data($n) }</name>
{
for $k in $persons
let $kn := if( $k[@name] ) then $k/@name else $k
let $kid := count($k/preceding::*)+count($k/ancestor::*)
where $kn = data(//*[@name=$n]/knows) 
      and not(exists($kn/../following::*[@name = $kn or data(.)=$kn]))
return 
 <knows><Person nodeID="{$kid}"/></knows>}
</person>
}
</RDF>