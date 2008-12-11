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
import grammar

#
# rewriting functions
#

var_p = ''
var = ''
count = 1  # counter for temporary variables (used in the valid* functions)
inBnode = 0

def build_rewrite_query(forletExpr, modifiers, construct, graphpattern, variable_p, variable):

    global var
    global var_p

    if '*' in variable:
	var = lowrewriter.variables
    else:
	var = variable

    var_p = variable_p

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

	if not firstelement:
	    ret += ','
	    firstelement = False

	if isinstance(s, str) and not s[0] == "[":

	    if polist != '':
		let_subject, cond_subject, subject, suff_subject = build_bnode('_validSubject', s)
		let_po, cond_po, po, suff_po = build_predicate(subject, polist)
		let += let_subject + let_po
		ret +=  '\n\t ' + cond_subject + cond_po + ' \n\t\t '+ po.rstrip(', ') + '\n\t\t \n ' + suff_po + suff_subject + ' ,'
	    else:
		s = s.lstrip('{')
		s = s.rstrip('}')
		ret += '\n' + s + ','

	else:
	    let_subject, cond_subject, subject, suff_subject = build_subject(s)
	    let_po, cond_po, po, suff_po = build_predicate(subject, polist)  # send rewritten subject

	    let = let + let_subject + let_po

	    if (cond_subject + cond_po == ''):
		if isinstance(s, str) and s == "[]":
		    ret += '_xsparql:_removeEmpty( \n\t\t fn:concat( \n\t\t "[]", ' + po.rstrip(', ') +  ', " .&#xA;" \n\t\t) \n\t\t ) '
		elif(s[0] == "["):
		    ret += '_xsparql:_removeEmpty( \n\t\t fn:concat( \n\t\t "[", ' + subject.rstrip(', ') + po.rstrip(', .') + ', " ] .&#xA;" \n\t\t) \n\t\t )'
		else:
#		    ret += 'fn:concat( \n\t\t '+ subject + po.rstrip(', ') + '\n\t\t)'
		    ret += po.rstrip(', ')
	    else:
		ret +=  '\n\t ' + cond_subject + cond_po + ' \n\t\t '+ po.rstrip(', ') + '\n\t\t \n ' + suff_po + suff_subject + ' ,'

    return let, ret.rstrip(',')



def build_subject(s):

#    debug.debug('------- build_subject', s, len(s))

    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
	return build_bnode('_validSubject', s[0][0])
    elif len(s) <= 2 and isinstance(s, str): # blank node or subject
	return build_bnode('_validSubject', s)
    elif len(s) == 1 and isinstance(s[0], str): # blank node or subject
	return build_bnode('_validSubject', s[0])
    elif len(s) == 1 and isinstance(s[0], list): # blank node
	return build_predicate("", s[0])
    elif len(s) == 0: # single blank node
	return '', '', '[]'
    else: # polist
	if s[0] == '[' or s[0] == "[]": # first member is an opening bnode bracket
	    global inBnode
	    inBnode = inBnode + 1

	    let1, cond1, ret1, suff1 = build_predicate("", [ s[1] ])
	    let2, cond2, ret2, suff2 = build_predicate("", s[2:])

	    ret = ret1.rstrip(', ')

	    if not ret2 == "":
		ret += ',\n\t\t' + ret2

	    return let1 + let2, cond1 + cond2,  ret + ' \n ', suff1 +suff2
	else:
	    let1, cond1, ret1, suff1 = build_predicate("", [ s[0] ])
	    let2, cond2, ret2, suff2 = build_predicate("", s[1:])
	    return let1 + let2, cond1 + cond2, ' ' + ret1 + ' "&#59;",\n\t\t' + ret2 + ' \n ', suff1+suff2



def build_predicate(subject, p):

#    debug.debug('------- build_predicate', p, len(p))

    if len(p) == 1:
	b = p[0][0]
	if len(b) >= 2 and b[0] == '{' and b[-1] == '}' :
	    strip = str(b).lstrip('{')
	    b = strip.rstrip('}')

	    let, cond, ret, suff = build_object(subject, b, p[0][1])
	    return let, cond,  ' '+ b + ',  ' + ret + ' ', suff
	elif len(b) >= 2 and ( b[0] == '$'or b[0] == '?'):
	     if b[0] == '?':
		 b = b.lstrip('?')
		 b = '$'+ b

	     if listSearch(b):
		 var = lowrewriter.prefix_var(b) + '_RDFTerm'
	     else:
		 var = b

	     let, cond, ret, suff = build_object(subject, var,  p[0][1])

	     return let, cond, ret, suff
	else:
	     if len(b) >= 2:
		 if(b[0] != '_' and b[1] != ':'):
		     let, cond, ret, suff = build_object(subject, b, p[0][1])
		     return let, "", cond + '  \n\t  ' + ret.rstrip(', ') + '  \n ' + suff, ""
	     else:
		 let, cond, ret,suff = build_object(subject, b, p[0][1])
		 return let, "", cond + '  \n\t ' + ret.rstrip(',')  + ', ' + suff, ""
    elif len(p) == 0:
	return '','','', ''
    else:
	d =  p
	if d[0] == '[' :
	    d.remove('[')
	    let1, cond1, ret1, suff1 = build_predicate(subject, [ d[0] ])
	    let2, cond2, ret2, suff2 = build_predicate(subject, [ d[1] ])
	    return let1 + let2, cond1 + cond2, '"[", ' + ret1 + '"&#59;", \n\t\t' + ret2 + ' "]",\n', suff1+suff2
	else:
	    let1, cond1, ret1, suff1 = build_predicate(subject, [ d[0] ])
	    let2, cond2, ret2, suff2 =  build_predicate(subject, d[1:])
	    return let1 + let2, "", '\n\t ' + cond1 +  ret1.rstrip(', ')  + suff1 +',  \n\t ' +  ret2 , ""



def build_object(subject, predicate, o):

#    debug.debug('------- build_object', o)

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
	d =  o[0]
	if d[0] == '[' :
	    d.remove('[')
	    global inBnode

	    let, cond, ret,suff = build_predicate("", d)
	    # distinguish from nested [] ?
	    if inBnode > 0:
		ret = ' fn:concat( \n\t\t "' + predicate + ' ", ' + '"[", ' + ret.rstrip(', ') + ', " ]" \n\t\t ) \n'
	    else:
		ret = ' fn:concat( \n\t\t ' + subject + ' " ' + predicate + ' ", ' + '"[", ' + ret.rstrip(', ') + ', " ]", " .&#xA;" \n\t\t ) \n'

	    inBnode = inBnode - 1

	    return let, "", cond + ret + suff, ""

	else:
	    let,cond,ret,suff = build_bnode('_validObject', o[0][0])
	    if (subject == "" or subject.strip('\', ') == "[]"):
		return let, cond, ' fn:concat(" ",' + predicate + ', " ", ' + ret.rstrip(', ')  + ', " &#59; ")', suff
	    else:
		return let, "", cond + ' fn:concat( \n\t\t '+ subject + ' " ' + predicate + ' ", ' + ret.rstrip(',')  + '" .&#xA;"\n\t\t)\n'+suff, ""

    elif len(o) == 1 and isinstance(o[0], str):
	let,cond,ret,suff = build_bnode('_validObject', o[0])

	if (subject == "" or subject.strip('\', ') == "[]"):
	    return let, cond, ' fn:concat(" ' + predicate + ' ", ' + ret.rstrip(', ')  + ', "&#59;")', suff
	else:
	    return let, "", cond + ' fn:concat( \n\t\t '+ subject + ' " ' + predicate + ' ", ' + ret.rstrip(',')  + '" .&#xA;"\n\t\t)\n'+suff, ""

    elif len(o) == 1 and isinstance(o[0], list):
	return build_predicate(subject, o[0])

    elif len(o) == 0:
	return "", "", '[]', ""
    else:
	let1, cond1, ret1, suff1 = build_object(subject, predicate,  [ o[0] ])
	let2, cond2, ret2, suff2 =  build_object(subject, predicate,  o[1:] )
	return let1 + let2, "", '\n\t ' + cond1 +  ret1  + suff1 +' , \n\t ' +  ret2  , ""



def build_bnode(type, b):

#    debug.debug('----- build_bnode', b, len(b))

    if b >= 4 and b[0] == '<' and b[1] == '{' and b[-2] == '}' and b[-1] == '>':  # iri literal
	bIri =  b[1:-1].split('{')
	iri = bIri[0]
	iri = bIri[1].rstrip('}')
	let,cond,ret,suff = genLetCondReturn(type,  [ '"<" ,', iri , ', ">"'] )
	return let,cond,'    '+ ret + '  ,  ', suff

    elif b >= 2 and b[0] == '<' and b[-1] == '>':  # iri literal
	let,cond,ret,suff = genLetCondReturn(type,  [ '"'+b+'"' ] )
	return let,cond,'    '+ ret + '  ,  ', suff

    elif b >= 2 and b[0] == '_' and b[1] == ':':  # bnode
	global var_p
	v = ''
	for i in var_p:
            if i != []:    #  @@fix this
                v += ' data('+str(i[0:])+ '),'
	if b.find('{') == -1 and b.find('}') == -1: #without enclosed {}
	    let,cond,ret,suff = genLetCondReturn(type, [ '"', b , '"', ', "_",', v.rstrip(',')] )
	    return let, cond , ret + ', ', suff
	else:
	    bExpr =  b.split('{')
	    bNode = bExpr[0]
	    expr = bExpr[1].rstrip('}')

	    let,cond,ret,suff = genLetCondReturn(type, ['"' , bNode  ,  '",  data(', expr, ')'] )
	    return let,cond, ret +', ', suff
    else:
	if (b >= 2 and b[0] == '{' and b[-1] == '}' and b[1:-1].find('{') == -1 and b[1:-1].find('}') == -1) or (b in grammar.letVars) :  # literal? concatenate " and "
	    strip = str(b).lstrip('{')
	    b = strip.rstrip('}')

	    let,cond,ret, suff = genLetCondReturn(type,  [' \'"\',  ', b,  ',  \'"\'' ])
	    return let,cond, ret + ', ', suff

	elif b >= 2 and (b[0] == '$' or b[0] == '?'):  # var: return $+..
	    if b[0] == '?':
		b = b.lstrip('?')
		b = '$'+ b + ''

	    let,cond,ret,suff = genLetCondReturn(type,  [ b ])
	    return let,cond, ret + ', ', suff

	else:
            pattern = tokenize(b)
            # if the first element (modulo " and ') is the same as the original do not execute the replacement
            if (b >= 2 and (pattern[0].strip('"\'') != b.strip('"\''))):   # literal? concatenate " and "
                let,cond,ret, suff = genLetCondReturn(type,  pattern)
                return let,cond, ret + ', ', suff
            else:
                return "", "", "  '"+ b + "',  ", ""



def listSearch(list_val):
    global var
    return list_val.strip() in var


def genLetCondReturn(type, value):
    global count

    if len(value) == 1:
	# do something
	var = value[0].strip()
	if listSearch(var): var = lowrewriter.prefix_var(var) + '_RDFTerm'
	let = ''
    else:
	var = '$' + type + `count`
	count = count + 1
	value_all = ''
	for s in value:
	    if listSearch(s): s = lowrewriter.prefix_var(s.strip()) + '_RDFTerm'
	    value_all = value_all + s

	let =  'let '+ var +' := fn:concat(' +  value_all +') \n'



    if listSearch(var):
	rdftype = var + '_NodeType'
	var = lowrewriter.prefix_var(var) + '_RDFTerm'
    else:
	rdftype = '""'


    cond = 'if ( _xsparql:'+type + '( ' + rdftype + ',  '+var+'  ) ) then (\n\t\t'
    suffix = ' ) else ""'


    return let, cond, var, suffix



def tokenize(string):

    tokens = re.split('([^{}]*)(?:({)(.*?)(})){1,2}([^{}]*)', string)
    pattern = []
    enclosed = False
    sep = ''

    for tok in tokens:
        if tok == '':
            continue
        elif tok == '{':
            enclosed = True
            continue
        elif tok == '}':
            enclosed = False
            continue
        else: 
            if enclosed:
                pattern.append(sep + tok)
            else:
                pattern.append( sep + "'"+tok+"'")
        
        sep = ', '

    debug. debug(pattern)
    return pattern
