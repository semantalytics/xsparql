# -*- coding: utf-8 -*-
#
# xsparql -- XSPARQL Rewriter
#
# Copyright (C) 2007, 2008  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#               2007, 2008  Waseem Akhtar  <waseem.akhtar@deri.org>
#
# This file is part of xsparql.
#
# xsparql is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# xsparql is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with xsparql. If not, see
# <http://www.gnu.org/licenses/>.
#
#


#
# auxiliary variable names
#

import re

#@todo why?
import lowrewriter
import debug

#
# rewriting functions
#

var_p = ''
var = ''
count = 1  # counter for temporary variables (used in the valid* functions)
cond_separator = ''


def build_rewrite_query(forletExpr, modifiers, construct, graphpattern, variable_p, variable):

    global var
    global var_p

    if '*' in variable:
	var = lowrewriter.variables
    else:
	var = variable

    var_p = variable_p

#    debug.debug('var', var, 'var_p', var_p)

    let, ret = build_triples(graphpattern, [], [])

    return '\n  ' + forletExpr + ' \n\n' + let + '\n' + modifiers  + '\n\n  return ( ' + ret + ' )'



def build_triples(gp, variable_p, variable ):

#    debug.debug('-------- build_triples', gp)

    ret = ''
    space = ''
    if variable_p != []:
	global var_p
	var_p = variable_p
    if variable != []:
	global var
	var = variable

    let = ''
    cond = ''

    firstelement = True
    for s, polist in gp:
	global cond_separator
	cond_separator = ''  # diferent for each triple?

	if not firstelement:
	    ret += ','
	    firstelement = False
	if isinstance(s, str):
	    s = s.lstrip('{')
	    s = s.rstrip('}')
	    ret += '\n' + s + ','
	else:
	    let_subject, cond_subject, subject = build_subject(s)
	    let_po, cond_po, po = build_predicate(polist)
	    let = let + let_subject + let_po
	    if (cond_subject + cond_po == ''):
		ret += 'fn:concat( \n\t\t '+ subject + po + '".&#xA;"\n\t\t)'
	    else:
		ret +=  '\n\t if (' + cond_subject + cond_po + ') then \n\t fn:concat( \n\t\t '+ subject + po + '".&#xA;"\n\t\t) \n else "" ,'

    return let, ret.rstrip(',')



def build_subject(s):

#     debug.debug('------- build_subject', s)

    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
	return build_bnode('validSubject', s[0][0])
    elif len(s) == 1 and isinstance(s[0], str): # blank node or subject
	return build_bnode('validSubject', s[0])
    elif len(s) == 1 and isinstance(s[0], list): # blank node
	return build_predicate(s[0])
    elif len(s) == 0: # single blank node
	return '', '', '[]'
    else: # polist
	if s[0] == '[': # first member is an opening bnode bracket
	    let1, cond1, ret1 = build_predicate([ s[1] ])
	    let2, cond2, ret2 =  build_predicate(s[2:])
	    return let1 + let2, cond1 + cond2, '"[", ' + ret1 + ' ";",\n\t\t' + ret2 + ' "]",\n '
	else:
	    let1, cond1, ret1 = build_predicate([ s[0] ])
	    let2, cond2, ret2 = build_predicate(s[1:])
	    return let1 + let2, cond1 + cond2, ' ' + ret1 + ' ";",\n\t\t' + ret2 + ' \n '



def build_predicate(p):

#    debug.debug('------- build_predicate', p, len(p))

    if len(p) == 1:
	b = p[0][0]
	if len(b) >= 2 and b[0] == '{' and b[-1] == '}' :
	    strip = str(b).lstrip('{')
	    b = strip.rstrip('}')

	    let, cond, ret = build_object(p[0][1])
	    return let, cond,  ' '+ b + ',  ' + ret + ' '
	elif len(b) >= 2 and ( b[0] == '$'or b[0] == '?'):
	     if b[0] == '?':
		 b = b.lstrip('?')
		 b = '$'+ b
	     if listSearch(b):
		 let, cond, ret = build_object(p[0][1])
		 return let, cond, '  local:empty( '+ b + '_RDFTerm,  concat(' + ret + '"" )),'
	     else:
		 let, cond, ret = build_object(p[0][1])
		 return let, cond, '  local:empty( '+ b + ',  concat(' + ret + ' "")),'
	else:
	     if len(b) >= 2:
		 if(b[0] != '_' and b[1] != ':'):
		     let, cond, ret = build_object(p[0][1])
		     return let, cond, ' "  '+ b + '  ",  ' + ret + ' '
	     else:
		 let, cond, ret = build_object(p[0][1])
		 return let, cond, ' " '+ b + '  ", ' + ret + ' '
    elif len(p) == 0:
	return '','',''
    else:
	d =  p
	if d[0] == '[' :
	    d.remove('[')
	    let1, cond1, ret1 = build_predicate([ d[0] ])
	    let2, cond2, ret2 =  build_predicate([ d[1] ])
	    return let1 + let2, cond1 + cond2, '"[", ' + ret1 + '";", \n\t\t' + ret2 + ' "]",\n'
	else:
	    let1, cond1, ret1 = build_predicate([ d[0] ])
	    let2, cond2, ret2 =  build_predicate([ d[1] ])
	    return let1 + let2, cond1 + cond2, ' ' + ret1 + ' ";", \n\t\t' + ret2 + ' \n'



def build_object(o):

#    debug.debug('------- build_object', o)

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
	d =  o[0]
	if d[0] == '[' :
	    d.remove('[')
	    let, cond, ret = build_predicate(d)
	    return let, cond, '"[", ' + ret + ' "]",\n'
	else:
	    return  build_bnode('validObject', o[0][0])
    elif len(o) == 1 and isinstance(o[0], str):
	return  build_bnode('validObject', o[0])

    elif len(o) == 1 and isinstance(o[0], list):
	return build_predicate(o[0])

    elif len(o) == 0:
	return "", "", '[]'
    else:
	let1, cond1, ret1 = build_object( [ o[0] ])
	let2, cond2, ret2 =  build_object( o[1:] )
	return let1 + let2, cond1 + cond2, '"[", ' + ret1 + ' ",", \n\t\t' + ret2 + ' "]",\n'



def build_bnode(type, b):

#    debug.debug('----- build_bnode', b)

    if b >= 2 and b[0] == '<' and b[-1] == '>':  # iri literal
	bIri =  b[1:-1].split('{')
	iri = bIri[0]
	iri = bIri[1].rstrip('}')
	let,cond,ret = genLetCondReturn(type,  [ '"<" ,', iri , ', ">"'] )
	return let,cond,'    '+ ret + '  ,  '

    elif b >= 2 and b[0] == '_' and b[1] == ':':  # bnode
	global var_p
	v = ''
	for i in var_p:
	    v += ' data('+str(i[0:])+ '),'
	if b.find('{') == -1 and b.find('}') == -1: #without enclosed {}
	    return "", "" , '"  '+ b + '_", ' + v
	else:
	    bExpr =  b.split('{')
	    bNode = bExpr[0]
	    expr = bExpr[1].rstrip('}')

	    let,cond,ret = genLetCondReturn(type, ['"' , bNode  ,  '",  data(', expr, ')'] )
	    return let,cond, ret +', '
    else:
	if b >= 2 and b[0] == '{' and b[-1] == '}' :  # literal? concatenate " and "
	    strip = str(b).lstrip('{')
	    b = strip.rstrip('}')

	    let,cond,ret = genLetCondReturn(type,  [' \'"\',  ', b,  ',  \'"\'' ])
	    return let,cond, ret + ', '

	elif b >= 2 and (b[0] == '$' or b[0] == '?'):  # var: return $+..
	    if b[0] == '?':
		b = b.lstrip('?')
		b = '$'+ b + ''

	    let,cond,ret = genLetCondReturn(type,  [ b ])
	    return let,cond, ret + ', '
	else:
	    return "", "", '  "  '+ b + '  ",  '



def listSearch(list_val):
    global var
#    debug.debug('lifrewriter.listSearch: ', '\''+list_val.strip()+'\'',var,list_val.strip() in var)
    return list_val.strip() in var


def genLetCondReturn(type, value):
    global count
    global cond_separator

    if len(value) == 1:
	# do something
	var = value[0].strip()
	if listSearch(var): var = var + '_RDFTerm'
	let = ''
    else:
	var = '$' + type + `count`
	count = count + 1
	value_all = ''
	for s in value:
	    if listSearch(s): s = s.strip() + '_RDFTerm'
	    value_all = value_all + s

	let =  'let '+ var +' := fn:concat(' +  value_all +') \n'



    if listSearch(var):
	rdftype = var + '_NodeType'
	var = var + '_RDFTerm'
    else:
	rdftype = '""'


    cond = cond_separator + 'local:'+type + '( ' + rdftype + ',  '+var+'  )'

    cond_separator = '\n\t\t and '

    return let, cond, var
