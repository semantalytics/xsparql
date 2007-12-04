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

# todo: ground input variables? how?
def build_sparql_query(i, sparqlep, pfx, vars, from_iri, graphpattern, solutionmodifier):
    prefix = '\nlet ' + query_aux(i) + ' := fn:concat("' + sparqlep + '", fn:encode-for-uri( fn:concat("'

    global scoped_variables

    # build the SPARQL query
    query = '\n'.join([ 'prefix %s: <%s>' % (ns,uri) for (ns,uri) in pfx ]) + '\n' + \
            'select ' + ' '.join(vars) + ' from ' + from_iri + ' where { '

    for t in graphpattern:
        if t[0] in scoped_variables: query += '", ' + t[0] + ', " '
        else:                        query += t[0] + ' '
        query += t[1] + ' '
        if t[2] in scoped_variables: query += '", ' + t[2] + ', " . '
        else:                        query += t[2] + ' . '

    query += '} ' + solutionmodifier

    scoped_variables.update(vars)

    return prefix + query + '" )))\n'



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
scoped_variables = set()

_forcounter = 0


# generator function, keeps track of incrementing the for-counter
def build(vars, from_iri, graphpattern, solutionmodifier):
    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1
    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces,
                             vars, from_iri, graphpattern, solutionmodifier)
    yield build_for_loop(_forcounter)
    yield build_aux_variables(_forcounter, vars)
