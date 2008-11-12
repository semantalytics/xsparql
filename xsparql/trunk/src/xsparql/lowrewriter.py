# -*- coding: utf-8 -*-
#
# xsparql -- XSPARQL Rewriter
#
# Copyright (C) 2007, 2008  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#               2007, 2008  Waseem Akthar  <waseem.akthar@deri.org>
#
# This file is part of xsparql.
#
# xsparql is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# xsparql is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with xsparql. If not, see
# <http://www.gnu.org/licenses/>.
#
#


"""@package xsparql
This is the lowering rewriter for xsparql.
"""



#@todo why
import lifrewriter
import debug
import copy

import grammar
#
# auxiliary variable names
#

def query_aux(i):
    return '$_aux' + str(i)


def var_decl(i):
    return '$_NS'+ str(i)


def query_result_aux(i):
    return '$_aux_result' + str(i)


p_var = []
def position_var(i):
    global p_var
    aux_result = query_result_aux(i) + '_Pos'
    p_var.append(aux_result)
    return aux_result


def prefix_var(var):
    return var[0] + '_' + var[1:]


def var_node(var):
    return prefix_var(var) + '_Node'


def var_nodetype(var):
    return prefix_var(var) + '_NodeType'


def var_rdfterm(var):
    return prefix_var(var) + '_RDFTerm'


def cnv_lst_str(dec_var, flag):
    if len(dec_var) == 0:
	return '""'

    stri = ''
    for i in dec_var:
       if flag :
	   stri += ' "  \n@", '+i[0:] + ', ".",'
       else:
	   stri += '  '+i[0:] + ','
    return stri.rstrip(',')



#
# rewriting functions
#
dec_var = []
def declare_namespaces(nstag, col, pre, uri, i):
  global dec_var
  dec_var.append(var_decl(i))
  uri = uri.lstrip('"')
  uri = uri.lstrip('<')
  uri = uri.rstrip('"')
  uri = uri.rstrip('>')
  return 'declare variable ' + var_decl(i) + ' := "' + nstag + '  ' + pre + col + '  &#60;' + uri + '&#62;";\n'


scopeVar_count = 0


# recursively traverse the groupGraphPatterns
def build_where(typ, pattern):
    if typ == '':
	return build_subject(pattern[0], False) + build_predicate(pattern[1], False) + ' . '
    else:
	query = typ + ' { '
	for tp, gp in pattern: query += build_where(tp, gp)
	return query + ' } '


# @todo ground input variables? how?
def build_sparql_query(i, sparqlep, pfx, vars, from_iri, graphpattern, solutionmodifier, filterpattern):
    global scoped_variables
    global scopeVar_count

    # build the SPARQL prefix
    query = '\n'.join([ 'prefix %s: <%s>' % (ns,uri) for (ns,uri) in pfx ])

    # build (no/multiple) FROM (NAMED)
    # @todo FROM NAMED is missing
    from_iri_str = ''
    for (fn, iri) in from_iri:
        if ( iri[0] == '$' ):
            from_iri_str += fn + ' <", ' + iri + ',"> '
        else:
            from_iri_str += fn + ' ' + iri + '> ' # @todo '>' is ugly

    # build variables (possibly scoped)
    # @todo this is utter crap
    s_vars = ''
    for j in vars:
	if j in scoped_variables:
	    scoped_variables.remove(j)
	else:
	    s_vars += j + ' '
	    scoped_variables += [ j ]

    scopeVar_count = len(vars)

    # build the SPARQL SELECT Varlist, (no/multiple) FROM (NAMED), WHERE
    query += '\n' + 'select ' + s_vars + from_iri_str + ' where { '

    # build graph pattern
    for s, polist in graphpattern:
	query +=  build_subject(s, False) + build_predicate(polist, False) + '. '

    query += build_filter(filterpattern)

    # build the SOLUTION MODIFIERs
    query += '} ' + solutionmodifier

    # return XQuery SPARQL query
    # @todo: fdwlm.xsparql,dawg-testcases
    return '\nlet ' + query_aux(i) + ' := fn:concat("' + sparqlep + \
	     '", fn:encode-for-uri( fn:concat(' + cnv_lst_str(dec_var, False) + ', "' + \
	     query + '")))\n'



def build_for_loop(i, var):
    return 'for ' + query_result_aux(i) + ' at ' + position_var(i) + ' in doc(' + query_aux(i) + ')//_sparql_result:result\n'


def build_aux_variables(i, vars):
    ret = ''

    for v in vars:
	ret += '\tlet ' + var_node(v) + ' := (' + query_result_aux(i) + '/_sparql_result:binding[@name = "' + v[1:] + '"])\n'
	ret += '\tlet ' + var_nodetype(v) + ' := name(' + var_node(v) + '/*)\n'
	ret += '\tlet ' + v + ' := data(' + var_node(v) + '/*)\n'
	ret += '\tlet ' + var_rdfterm(v) + ' :=  _xsparql:_rdf_term(' + var_nodetype(v)+', '+v +' )\n'
    return ret




namespaces = []
scoped_variables = []

_forcounter = 0

def buildConstruct(constGraphpattern, from_iri, graphpattern, solutionmodifier, filterpattern):
    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1

    find_vars(copy.deepcopy(graphpattern))
    find_vars_filter(copy.deepcopy(filterpattern))

    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces,
			     variables, from_iri, graphpattern, solutionmodifier, filterpattern)
    yield build_for_loop(_forcounter, variables)
    yield build_aux_variables(_forcounter, variables)
    yield graphOutput(constGraphpattern)



def graphOutput(constGraphpattern):
    global variables
    let, ret = lifrewriter.build_triples(constGraphpattern, p_var, variables)
#     print '------- graphOutput'
#     print let
#     print ret

    return '\n' + let + '\n return \n\t   \n\t\t\n ' + ret



# generator function, keeps track of incrementing the for-counter
def build(vars, from_iri, graphpattern, solutionmodifier, filterpattern):

    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1

    if len(vars) == 1 and isinstance(vars[0], str) and vars[0] == '*':
	find_vars(graphpattern)
	vars = variables

    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces,
			     vars, from_iri, graphpattern, solutionmodifier, filterpattern)
    yield build_for_loop(_forcounter, vars)
    yield build_aux_variables(_forcounter, vars)


variables = []
def find_vars(p):
    global variables
    for s, polist in p:
	build_subject(s, True)
	build_predicate(polist, True )

    var = []
    if len(variables) == 0:
	return

    temp = variables[0]
    for v in variables:
       n = 0

       for nv in variables:
	  if temp.lstrip('$') == nv.lstrip('?') or temp.lstrip('?') == nv.lstrip('$') or temp == nv :
	      n += 1
	      if n == 2 :
		  var += [temp]
       for j in var:
	   if j != v:
	       temp = v
	   else:
	       temp = ''

    for i in var:
	variables.remove(i)


def find_vars_filter(filter):

    if isinstance(filter, list) and filter[0] == 'graph':
        if filter[1][0] == '$':
            global variables
            variables += [ filter[1] ]

        find_vars(filter[3])
    elif isinstance(filter, list) or isinstance(filter, tuple):
        find_vars_filter(filter[0])




def build_subject(s, f):

    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
	return build_bnode(s[0][0], f)
    elif len(s) == 1 and isinstance(s[0], str): # blank node or object
	return build_bnode(s[0], f)
    elif len(s) == 1 and isinstance(s[0], list): # blank node or object
	return build_predicate(s[0], f)
    elif len(s) == 0: # single blank node
	return '[]'
    else: # polist
	if s[0] == '[': # first member is an opening bnode bracket
            if s[1] == ']':
                return '[  ]\n '
            else:
                return '[ ' + build_predicate([ s[1] ], f) + ' ; ' + build_predicate(s[2:], f) + ' ]\n '
	else:
	    return ' ' + build_predicate([ s[0] ], f) + ' ";", ' + build_predicate(s[1:], f) + ' \n '








def build_predicate(p, f):

    global variables
    if len(p) == 1:
	b = p[0][0]
	if b >= 2 and b[0] == '{' and b[-1] == '}' :
	    strip = str(b).lstrip('{')
	    b = strip.rstrip('}')
	    return ' '+ b + ' ' + build_object(p[0][1], f)+ ' '
	else:

	    if b[0] == '$' or b[0] == '?':
		    if b[0] == '?':
			b = b.lstrip('?')
			b = '$'+ b
		    if f:
			variables += [ b ]
		    if listSearch(b):
			 return '   ", '+ b + '_RDFTerm ," ' + build_object(p[0][1], f)+ ' '
		    else:
			 return '   '+ b + '  ' + build_object(p[0][1], f)+ ' '

            return ' '+ b + ' ' + build_object(p[0][1], f)+ ' '
    elif len(p) == 0:
	return ''
    else:
	d =  p
	if d[0] == '[' :
	    d.remove('[')
	    return '[ ' + build_predicate([ d[0] ], f) + '; ' + build_predicate([ d[1] ], f) + ' ]\n '
	else:
	    return ' ' + build_predicate([ d[0] ], f) + ' ; ' + build_predicate([ d[1] ], f) + ' \n '



def build_object(o, f):

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
	d =  o[0]
	if d[0] == '[' :
	    d.remove('[')
	    return '[ ' + build_predicate(d, f) + ' ]\n '
	else:
	    return  build_bnode(o[0][0], f)
    elif len(o) == 1 and isinstance(o[0], str):
	return  build_bnode(o[0], f)
    elif len(o) == 1 and isinstance(o[0], list):
	return build_predicate(o[0], f)
    elif len(o) == 0:
	return '[]'
    else:
	return '[ ' + build_predicate([ o[0] ], f) + ' ";", ' + build_predicate(o[1:], f) + ' ]\n '


def build_bnode(b, f):
    global variables
    if b >= 2 and b[0] == '_' and b[1] == ':':
	global p_var
	v = ''
	for i in p_var:
	    v += ' data('+str(i[0:])+ ') '
	return ''+ b + '' + v
    else:
	if b >= 2 and b[0] == '{' and b[-1] == '}' :
	    strip = str(b).lstrip('{')
	    b = strip.rstrip('}')
	    return ' '+ b + ' '
	else:

	    if b[0] == '$' or b[0] == '?':
		    if b[0] == '?':
			b = b.lstrip('?')
			b = '$'+ b
		    if f:
			variables += [ b ]
		    if listSearch(b):
			return '    ", '+ prefix_var(b) + '_RDFTerm, "   '
		    else:
                        if(b in grammar.letVars):
                            return '   ", '+ b + ', "  '
                        else:
                            return '   '+ b + '  '
	    return ' '+ b + ' '


def listSearch(list_val):
    global scoped_variables
    global scopeVar_count
    if len(scoped_variables) != scopeVar_count:
	return list_val in scoped_variables[0:len(scoped_variables)-scopeVar_count]
    else:
	return False


def getVar():
    global variables
    return variables


def build_filter(filterpattern):
    res = ''

    for e in filterpattern:
        if isinstance(e, list) or isinstance(e, tuple):  # if it's a list append the flatted list
            res += build_filter(e)
        elif len(e) > 0 and e[0] == '$':        # if its a var check it it is already instanciated
            if(e in grammar.letVars):
                res += '   ", '+ e + ', "  '
            else:
                res += ' ' + e + ' '
        else:                   # append the value
            res += e.replace("\"", "\"\"")

    return res
