for $x in ( 1 to 3 )
return string($x) ,
let $y := for $z in ( 4 to 9 )
return <foo> {$z}</foo>
return $y
