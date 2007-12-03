#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Thomas Krennwallner <tkren@kr.tuwien.ac.at>
#

import urllib

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

# todo: ground input variables? how?
def build_sparql_query(i, sparqlep, pfx, vars, frm, where, orderby):
    prefix = '\nlet ' + query_aux(i) + ' := "' + sparqlep

    # build the SPARQL query
    query = '\n'.join([ 'prefix %s: <%s>' % (ns,uri) for (ns,uri) in pfx ]) + '\n'
    query += 'select ' + ' '.join(vars)
    query += ' from ' + frm
    query += ' where ' + where
    if len(orderby): query += ' order by ' + orderby

    return prefix + urllib.quote(query) + '"\n'



def build_for_loop(i):
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

_forcounter = 0


# generator function, keeps track of incrementing the for-counter
def build(vars, frm, where, orderby):
    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1
    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces, vars, frm, where, orderby)
    yield build_for_loop(_forcounter)
    yield build_aux_variables(_forcounter, vars)
