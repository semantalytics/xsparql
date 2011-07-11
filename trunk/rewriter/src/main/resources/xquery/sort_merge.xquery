(:


    Copyright (C) 2011, NUI Galway.
    All rights reserved.

    The software in this package is published under the terms of the BSD style license a copy of which has been included
    with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
    http://www.deri.ie/publications/tools/bsd_license.txt

    Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
    NUI Galway.

:)
module namespace _sort_merge =  "http://xsparql.deri.org/demo/xquery/sort_merge.xquery" ;

import module namespace _xsparql = "http://xsparql.deri.org/demo/xquery/xsparql.xquery" 
                                    at "http://xsparql.deri.org/demo/xquery/xsparql.xquery";

declare namespace _sparql_results =  "http://www.w3.org/2005/sparql-results#";

declare default element namespace "http://www.w3.org/2005/sparql-results#";


(: INTERNAL FUNCTIONS :)


(: create the union of two solutions :)
declare function _sort_merge:set_union($elem1, $elem2, $attribute) {
  <result>{
(:    if ($elem1[1] instance of element()) then :)
      $elem1//_sparql_results:binding (:else:)
(:        <binding name="{$attribute}">{_xsparql:_binding_term($elem1)}</binding>:),
     for $e2 in $elem2//_sparql_results:binding
     where $e2[@name != $attribute] (: this is limited to one join var :)
     return $e2}</result>
};

(: order a sequence (XQuery forClause) or a sequence of SPARQL result elements :)
declare function _sort_merge:sort($elem, $attribute) {
(:    if ($elem[1] instance of element()) then:)
        for $item in $elem
        order by $item//_sparql_results:binding[@name=$attribute] ascending
        return $item
(:    else
        for $item in $elem
        order by $item ascending
        return $item:)
};


(: function to merge one value with right side, does one extra comparision :)
declare function _sort_merge:merge_right($left_elem, $right, $right_it, $attribute) {
(:  let $l_id := if ($left_elem instance of element()) then $left_elem//_sparql_results:binding[@name = $attribute] else $left_elem:)
  let $l_id := $left_elem//_sparql_results:binding[@name = $attribute]
  let $r_id := $right[$right_it]//_sparql_results:binding[@name = $attribute]
  return 
    if (fn:not(empty($r_id)) and $l_id eq $r_id) then
      (_sort_merge:set_union($left_elem, $right[$right_it], $attribute), 
       _sort_merge:merge_right($left_elem, $right, $right_it+1, $attribute))
    else ()
};


(: Recursive function to merge two SPARQL results
 :
 : $left  left side SPARQL result
 : $left_it iterator for the current element number of the left side
 : $right right side SPARQL result
 : $right_it iterator for the current element number of the right side
 : $attribute join attribute
 : $merge
 : $left_outer true if it should be a left outer join
 :)
 declare function _sort_merge:merge ( $left, $left_it, $right, $right_it, $attribute, $merge, $left_outer) {

  if (empty($left[$left_it]) or empty($right[$right_it])) then
    (: at the end of one of the SPARQL results, return the current merge result :)
    $merge
  else
    (: there are still SPARQL results to merge :)
(:  let $l_id := if ($left[$left_it] instance of element()) then $left[$left_it]//_sparql_results:binding[@name=$attribute] else $left[$left_it]:)
    let $l_id := $left[$left_it]//_sparql_results:binding[@name=$attribute]/*/text()
    let $r_id := $right[$right_it]//_sparql_results:binding[@name=$attribute]/*/text()
  
    return 
      if ($l_id eq $r_id) then (: successfull comparison, perform the join :)
          _sort_merge:merge($left, $left_it + 1, 
                           $right, $right_it, $attribute, 
                           (_sort_merge:merge_right($left[$left_it], $right, $right_it, $attribute), $merge), $left_outer)
      else 
        if ($l_id le $r_id) then (: if key of left list is smaller than key of right list, increase iterator of left list :)
          if($left_outer) then (: if it's a left outer join, add the "tuple" anyway :)
            _sort_merge:merge($left, $left_it + 1, $right, $right_it, $attribute, ($left[$left_it], $merge), $left_outer)
          else
            _sort_merge:merge($left, $left_it + 1, $right, $right_it, $attribute, $merge, $left_outer)
        else  (: if key of right list is smaller than key of left list, increase iterator of right list :)
          _sort_merge:merge($left, $left_it, $right, $right_it + 1, $attribute, $merge, $left_outer)
};


(: PUBLIC FUNCTIONS :)


(: public sort-merge function
 :
 : $left       left side join candidates (e.g. SPARQL results)
 : $right      right side join candidates (e.g. SPARQL results)
 : $attribute  join attribute
 : $left_outer true if it should be a left outer join
 :)
declare function _sort_merge:sort_merge($left, $right, $attribute, $left_outer) {

  (: first sort both join candidates :)
  let $sort_left := _sort_merge:sort($left, $attribute) 
  let $sort_right := _sort_merge:sort($right, $attribute)
  
  (: then merge them together :)
  return
    _sort_merge:merge($sort_left, 1, $sort_right, 1, $attribute, (), $left_outer)
};

(: public sort-merge function
 :
 : $left       left side join candidates (e.g. SPARQL results)
 : $right      right side join candidates (e.g. SPARQL results)
 : $attribute  join attribute
 :)
declare function _sort_merge:sort_merge($left, $right, $attribute) {
  (: perform an inner join :)
  _sort_merge:sort_merge($left, $right, $attribute, fn:false())
};
