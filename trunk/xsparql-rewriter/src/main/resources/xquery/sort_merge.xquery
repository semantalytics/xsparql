(:

  Copyright (C) 2011, NUI Galway.
  Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, 
  Vienna University of Technology
  All rights reserved.
 
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The names of the COPYRIGHT HOLDERS AND CONTRIBUTORS may not be used
      to endorse or promote products derived from this software without
      specific prior written permission.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  OF SUCH DAMAGE.
 
  Created on 09 February 2011 by Reasoning and Querying Unit (URQ), 
  Digital Enterprise Research Institute (DERI) on behalf of NUI Galway.
  20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
  on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
  University of Technology,  Nuno Lopes on behalf of NUI Galway.
 

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
