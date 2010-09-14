declare namespace foaf="http://xmlns.com/foaf/0.1/";

"@prefix foaf: &#60;http://xmlns.com/foaf/0.1/&#62; .&#xA;",
for $knows in doc("howmyFriendsknoweachother.xml")//knows,
    $nameA in $knows/Person[1]/@name,
    $nameB in $knows/Person[2]/@name
return
 fn:concat(
   "[foaf:name """, data($nameA), """; a foaf:Person] ",
   "foaf:knows [foaf:name """, data($nameB), """; a foaf:Person]. &#xA;"
 )
