declare namespace foaf="http://xmlns.com/foaf/0.1/";

"@prefix foaf: &#60;http://xmlns.com/foaf/0.1/&#62; .&#xA;",
for $knows at $knows_count in doc("howmyFriendsknoweachother.xml")//knows,
    $nameA at $nameA_count in $knows/Person[1]/@name,
    $nameB at $nameB_count in $knows/Person[2]/@name
return
  fn:concat(
    "_:a_", $knows_count, $nameA_count, $nameB_count, " foaf:name ", data($nameA), ".&#xA;",
    "_:a_", $knows_count, $nameA_count, $nameB_count, " a foaf:Person.&#xA;",
    "_:a_", $knows_count, $nameA_count, $nameB_count, " foaf:knows _:b_", $knows_count, $nameA_count, $nameB_count, ".&#xA;",
    "_:b_", $knows_count, $nameA_count, $nameB_count, " foaf:name ", data($nameB), ".&#xA;",
    "_:b_", $knows_count, $nameA_count, $nameB_count, " a foaf:Person.&#xA;"
  )
