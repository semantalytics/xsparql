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
import lifrewriter

#
# auxiliary variable names
#

def query_aux(i):
    return '$aux' + str(i)
def var_decl(i):
    return '$NS_'+ str(i)

p_var = []
def position_var(i):
    global p_var
    p_var.append('$aux_result' + str(i)+ '_Pos ')
   # print p_var
    return ' at  $aux_result' + str(i)+ '_Pos'

def query_result_aux(i):
    return '$aux_result' + str(i)

def var_node(var):
    return var + '_Node'

def var_nodetype(var):
    return var + '_NodeType'

def var_rdfterm(var):
    return var + '_RDFTerm'

def cnv_lst_str(dec_var, flag):
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
  decl_ns = 'declare variable '+var_decl(i) +' := "'+ nstag + '  '+pre + col+'  &#60;'+ uri + '&#62;";\n'
##  decl_ns = 'declare variable '+var_decl(i) +' := "'+ nstag + '  '+pre + col+'  <'+ uri + '>";\n'
  #print url
  return  decl_ns
    

# todo: ground input variables? how?
def build_sparql_query(i, sparqlep, pfx, vars, from_iri, graphpattern, solutionmodifier):
    
    from_iri_str = ' \n'
    for iri in from_iri:
        from_iri_str += 'from ' + iri + '>  \n'    
    
    prefix = ''
    prefix += '\nlet ' + query_aux(i) + ' := fn:concat("' + sparqlep + '", fn:encode-for-uri( fn:concat(' + cnv_lst_str(dec_var, False) + ', "'
    s_vars = ''
    #print vars
    for i in vars:
        s_vars += i + ' '
    global scoped_variables

    # build the SPARQL query
    query = '\n'.join([ 'prefix %s: <%s>' % (ns,uri) for (ns,uri) in pfx ]) + ' ' + \
            'select ' + s_vars +  from_iri_str + ' where { '
    ret = ''
    for s, polist in graphpattern:
        ret +=  build_subject(s, False) + build_predicate(polist, False) + '.  '
    query += ret + '} ' + solutionmodifier

    scoped_variables.update(vars[0])

    return prefix + query + '", "" )))\n'



def build_for_loop(i, var):
##    variable = ''
##    if len(var) == 1 and isinstance(var[0][0], list) :
##        variable = var[0][0] 
##    elif len(var) == 1 and isinstance(var[0], list): # blank node or object
##        variable = var[0] 
        
    return 'for ' + query_result_aux(i) + '  '+position_var(i)+ ' in doc(' + query_aux(i) + ')//sparql_result:result\n'


def build_aux_variables(i, vars):
    ret = ''
    #print vars
    for v in vars:
        #print v
        ret += '\tlet ' + var_node(v) + ' := (' + query_result_aux(i) + '/sparql_result:binding[@name = "' + v[1:] + '"])\n'
        ret += '\tlet ' + var_nodetype(v) + ' := name(' + var_node(v) + '/*)\n'
        ret += '\tlet ' + v + ' := data(' + var_node(v) + '/*)\n'
        ret += '\tlet ' + var_rdfterm(v) + ' :=  local:rdf_term(' + var_nodetype(v)+', '+v +' )\n'\
##               '\t\tif (' + var_nodetype(v) + ' = "literal") then """"\n' + \
##               '\t\telse if (' + var_nodetype(v) + ' = "bnode") then "_:"\n' + \
##               '\t\telse if (' + var_nodetype(v) + ' = "uri") then "<"\n' + \
##               '\t\telse "",\n' + \
##               '\t\t' + v + ',\n' + \
##               '\t\tif (' + var_nodetype(v) + ' = "literal") then """"\n' + \
##               '\t\telse if (' + var_nodetype(v) + ' = "uri") then ">"\n' + \
##               '\t\telse ""\n\t)\n'
        
    return ret




sparql_endpoint = 'http://localhost:2020/sparql?query='
namespaces = []
scoped_variables = set()

_forcounter = 0

def buildConstruct(constGraphpattern, from_iri, graphpattern, solutionmodifier):
    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1
    
   # print constGraphpattern 
    find_vars(graphpattern)
    #print variables
    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces,
                             variables, from_iri, graphpattern, solutionmodifier)
    yield build_for_loop(_forcounter, variables)
    yield build_aux_variables(_forcounter, variables)
    yield graphOutput(constGraphpattern)
    


def graphOutput(constGraphpattern):
    global variables
    #print variables
    statement = ' ' + lifrewriter.build_triples(constGraphpattern, p_var, variables) + ' '
    statement += ')'      
    return '\n return \n\t  fn:concat( \n\t\t\n ' + statement
    
# generator function, keeps track of incrementing the for-counter
def build(vars, from_iri, graphpattern, solutionmodifier):
    global _forcounter, sparql_endpoint, namespaces
    _forcounter += 1

    
    if len(vars) == 1 and isinstance(vars[0], str) and vars[0] == '*':
        find_vars(graphpattern)
        vars = variables
    #print vars
    yield build_sparql_query(_forcounter, sparql_endpoint, namespaces,
                             vars, from_iri, graphpattern, solutionmodifier)
    yield build_for_loop(_forcounter, vars)
    yield build_aux_variables(_forcounter, vars)

variables = []
def find_vars(p):
    global variables
    for s, polist in p:
        build_subject(s, True)
        build_predicate(polist, True )
    
##    for v in variables:    
##        if v[0] == '?':
##            variables.remove(v)
##            v = v.lstrip('?')
##            v = '$'+ v
##            variables.append(v)
    var = []
    temp = variables[0]  
    for v in variables:
       n = 0
       
       for nv in variables:
          #print v  
          if temp.lstrip('$') == nv.lstrip('?') or temp.lstrip('?') == nv.lstrip('$') or temp == nv :
##          if  temp == nv :
              n += 1  
              #print temp  
              if n == 2 :    
                  
                  var += [temp]
       for j in var:
           
           if j != v:
               
               temp = v
           else:
               temp = ''
                 
                 
       
    #print var
    for i in var:
        variables.remove(i)
    #print variables
    


def build_subject(s, f):
    

    #print 'sub:', s


    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
        return build_bnode(s[0][0], f) 
    elif len(s) == 1 and isinstance(s[0], str): # blank node or object
        return build_bnode(s[0], f) 
    elif len(s) == 1 and isinstance(s[0], list): # blank node or object
        return build_predicate(s[0], f)
    elif len(s) == 0: # single blank node
        return '[]'
    else: # polist
        d =  s
        if d[0] == '[' :
            d.remove('[')
            #print d
            return '"[", ' + build_predicate([ d[0] ], f) + ' ";", ' + build_predicate(d[1:], f) + ' "]",\n '
        else:
            return ' ' + build_predicate([ d[0] ], f) + ' ";", ' + build_predicate(d[1:], f) + ' \n '




    



def build_predicate(p, f):

   # print 'prd:', p
    global variables
    if len(p) == 1:
        b = p[0][0]
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}') 
            return ' '+ b + ' ' + build_object(p[0][1], f)+ ' '
        else:
            if f:
                if b[0] == '$' or b[0] == '?':
                    if b[0] == '?':
                        b = b.lstrip('?')
                        b = '$'+ b
                    variables += [ b ]
            return ' '+ b + ' ' + build_object(p[0][1], f)+ ' '
    elif len(p) == 0:
        return ''
    else:
        d =  p
        if d[0] == '[' :
            d.remove('[')
            #print d
            return '"[", ' + build_predicate([ d[0] ], f) + '";", ' + build_predicate([ d[1] ], f) + ' "]",\n '           
        else:
            return ' ' + build_predicate([ d[0] ], f) + ' ";", ' + build_predicate([ d[1] ], f) + ' \n '
       


def build_object(o, f):

  #  print 'obj:', o

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
        d =  o[0]
        if d[0] == '[' :
            d.remove('[')
            #print d
            return '"[", ' + build_predicate(d, f) + ' "]",\n '
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
            #print v
        return ''+ b + '' + v
    else:
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}') 
            return ' '+ b + ' '
        else:
            if f:
                if b[0] == '$' or b[0] == '?':
                    if b[0] == '?':
                        b = b.lstrip('?')
                        b = '$'+ b
                    variables += [ b ]
            return ' '+ b + ' '


def getVar():
    global variables
    return variables
