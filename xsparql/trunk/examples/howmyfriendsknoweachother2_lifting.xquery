declare namespace foaf="http://xmlns.com/foaf/0.1/";
for $knows at $knows_count in doc("howmyFriendsknoweachother.xml")//knows,
    $nameA at $nameA_count in $knows/Person[1]/@name,
    $nameB at $nameB_count in $knows/Person[2]/@name
return
<turtle> 
_:a_{$knows_count}{$nameA_count}{$nameB_count} foaf:name "{data($nameA)}". 
_:a_{$knows_count}{$nameA_count}{$nameB_count} a foaf:Person.
_:a_{$knows_count}{$nameA_count}{$nameB_count} foaf:knows _:b_{$knows_count}{$nameA_count}{$nameB_count}.
_:b_{$knows_count}{$nameA_count}{$nameB_count} foaf:name "{data($nameB)}".
_:b_{$knows_count}{$nameA_count}{$nameB_count} a foaf:Person.
</turtle>
