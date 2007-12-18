# -*- coding: utf-8 -*-
#
#
# xsparqlow -- XSPARQL Lowering Rewriter
#
# Copyright (C) 2007  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#
# This file is part of xsparqlow.
#
# xsparqlow is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# xsparqlow is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with xsparqlow.  If not, see <http://www.gnu.org/licenses/>.
#
#


#
# auxiliary variable names
#

def query_aux(i):
    return '$aux' + str(i)

def query_result_aux(i):
    return '$aux_result' + str(i)

def var_node(var):
    return var + '_Node'

def var_nodetype(var):
    return var + '_NodeType'

def var_rdfterm(var):
    return var + '_RDFTerm'




#
# rewriting functions
#

def declare_namespaces(ns):
  global namespace 
  namespace = ''
  namespace = ns
  
  print ns
  return namespace
    

# todo: ground input variables? how?
def build_sparql_query(i, sparqlep, pfx, vars, from_iri, graphpattern, solutionmodifier):
    prefix = 'declare namespace sparql = "http://www.w3.org/2005/sparql-result"; \n'
    prefix += '\nlet ' + query_aux(i) + ' := fn:concat("' + sparqlep + '", fn:encode-for-uri( fn:concat("'
    #print namespace
    global scoped_variables

    # build the SPARQL query
    query = '\n'.join([ 'prefix %s: <%s>' % (ns,uri) for (ns,uri) in pfx ]) + ' ' + \
            'select ' + ' '.join(vars) + ' from ' + from_iri + ' where { '
    ret = ''
    for s, polist in graphpattern:
        ret +=  build_subject(s) + build_predicate(polist) + '.  '
##        if t[0] in scoped_variables: query += '", ' + t[0] + ', " '
##        else:                        query += t[0] + ' '
##        query += t[1] + ' '
##        if t[2] in scoped_variables: query += '", ' + t[2] + ', " . '
##        else:                        query += t[2] + ' . '

    query += ret + '} ' + solutionmodifier

    scoped_variables.update(vars)

    return prefix + query + '", "" )))\n'



def build_for_loop(i, var):
##    variable = ''
##    if len(var) == 1 and isinstance(var[0][0], list) :
##        variable = var[0][0] 
##    elif len(var) == 1 and isinstance(var[0], list): # blank node or object
##        variable = var[0] 
    
    return 'for ' + query_result_aux(i) + ' in doc(' + query_aux(i) + ')//sparql:result\n'


def build_aux_variables(i, vars):
    ret = ''
    
    for v in vars:
        ret += '\tlet ' + var_node(v) + ' := (' + query_result_aux(i) + '/sparql:binding[@name = "' + v[1:] + '"])\n'
        ret += '\tlet ' + var_nodetype(v) + ' := name(' + var_node(v) + '/*)\n'
        ret += '\tlet ' + v + ' := data(' + var_node(v) + '/*)\n'
        ret += '\tlet ' + var_rdfterm(v) + ' := fn:concat(\n' + \
               '\t\tif (' + var_nodetype(v) + ' = "literal") then """"\n' + \
               '\t\telse if (' + var_nodetype(v) + ' = "bnode") then "_:"\n' + \
               '\t\telse if (' + var_nodetype(v) + ' = "uri") then "<"\n' + \
               '\t\telse "",\n' + \
               '\t\t' + v + ',\n' + \
               '\t\tif (' + var_nodetype(v) + ' = "literal") then """"\n' + \
               '\t\telse if (' + var_nodetype(v) + ' = "uri") then ">"\n' + \
               '\t\telse ""\n\t)\n'
        
    return ret




sparql_endpoint = 'http://localhost:2020/sparql?query='
namespaces = []
scoped_variables = set()

_forcounter = 0


# generator function, keeps track of incrementing the for-counter
def build(vars, from_iri, graphpattern, solutionmodifier):
    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1
    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces,
                             vars, from_iri, graphpattern, solutionmodifier)
    yield build_for_loop(_forcounter, vars)
    yield build_aux_variables(_forcounter, vars)




def build_subject(s):

    #print 'sub:', s


    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
        return build_bnode(s[0][0]) 
    elif len(s) == 1 and isinstance(s[0], str): # blank node or object
        return build_bnode(s[0]) 
    elif len(s) == 1 and isinstance(s[0], list): # blank node or object
        return build_predicate(s[0])
    elif len(s) == 0: # single blank node
        return '[]'
    else: # polist
        return '[ ' + build_predicate([ s[0] ]) + ' ; ' + build_predicate(s[1:]) + ' ]\n '



def build_predicate(p):

   # print 'prd:', p

    if len(p) == 1:
        b = p[0][0]
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}') 
            return ' '+ b + ' ' + build_object(p[0][1])+ ' '
        else:
             return ' '+ b + ' ' + build_object(p[0][1])+ ' '
    elif len(p) == 0:
        return ''
    else:
        return '[ ' + build_predicate([ p[0] ]) + '; ' + build_predicate([ p[1] ]) + ' ]\n '


def build_object(o):

  #  print 'obj:', o

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
        return  build_bnode(o[0][0])
    elif len(o) == 1 and isinstance(o[0], str):
        return  build_bnode(o[0]) 
    elif len(o) == 1 and isinstance(o[0], list):
        return build_predicate(o[0])
    elif len(o) == 0:
        return '[]'
    else:
        return '[ ' + build_predicate([ o[0] ]) + ' ";", ' + build_predicate(o[1:]) + ' ]\n '


def build_bnode(b):
    if b >= 2 and b[0] == '_' and b[1] == ':':
        global var
        v = ''
        for i in var:
            v += ' data('+str(i[0:])+ ') '
        return ''+ b + '_' + v
    else:
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}') 
            return ' '+ b + ' '
        else:
            return ' '+ b + ' '