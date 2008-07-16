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

#
# rewriting functions
#

# todo: ground input variables? how?
##def build_rewrite_nsDecl(dec, ns, ncname, uriLit):
##   nsdeclare = str(dec)+' '+str(ns)+' '+str(ncname)+' =  '+str(uriLit)+';\n\n'
##   uri = str(uriLit).lstrip('"')
##   uri = uri.rstrip('"')
##   nsdeclare += '"@prefix '+ str(ncname) +': &#60;'+ uri + '&#62; .&#xA;",\n\n'
##   return nsdeclare
##
##def build_rewrite_defaultNSDecl(dec, defau, ele, ns, uriLit):
##   nsdeclare = str(dec)+' '+str(defau)+' '+str(ele)+' '+str(ns)+ ' '+ str(uriLit)+';\n\n'
##   uri = str(uriLit).lstrip('"')
##   uri = uri.rstrip('"')
##   nsdeclare += '"@prefix rdf: &#60;'+ uri + '&#62; .&#xA;",\n\n'
##   return nsdeclare
##
##def build_rewrite_baseURI(dec, base, uriLit):
##   nsdeclare = str(dec)+' '+str(base)+' '+ str(uriLit)+';\n\n'
##   uri = str(uriLit).lstrip('"')
##   uri = uri.rstrip('"')
##   nsdeclare += '"@base &#60;'+ uri + '&#62; .&#xA;",\n\n'
##   return nsdeclare
##

var_p = ''
var = ''

def build_rewrite_query(forletExpr, construct, graphpattern, variable_p, variable):

    global var
    global var_p

    if '*' in variable:
        var = lowrewriter.variables
    else:
        var = variable

    var_p = variable_p

    return '\n  ' + forletExpr + '\n return \n\t  fn:concat( \n\t\t\n ' + build_triples(graphpattern, [], []) + ')'



def build_triples(gp, variable_p, variable ):

    ret = ''
    space = ''
    if variable_p != []:
        global var_p
        var_p = variable_p
    if variable != []:
        global var
        var = variable


    firstelement = True
    for s, polist in gp:
        if not firstelement:
            ret += ','
            firstelement = False
        if isinstance(s, str):
            s = s.lstrip('{')
            s = s.rstrip('}')
            #print s
            ret += '\n' + s + ','
        #print polist
        else:
            ret += '\n' + build_subject(s) + build_predicate(polist) + '".&#xA;",'
    return ret.rstrip(',')


def build_subject(s):

    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
        return build_bnode(s[0][0])
    elif len(s) == 1 and isinstance(s[0], str): # blank node or object
        return build_bnode(s[0])
    elif len(s) == 1 and isinstance(s[0], list): # blank node or object
        return build_predicate(s[0])
    elif len(s) == 0: # single blank node
        return '[]'
    else: # polist
        if s[0] == '[': # first member is an opening bnode bracket
            return '"[", ' + build_predicate([ s[1] ]) + ' ";", ' + build_predicate(s[2:]) + ' "]",\n '
        else:
            return ' ' + build_predicate([ s[0] ]) + ' ";", ' + build_predicate(s[1:]) + ' \n '



def build_predicate(p):

    if len(p) == 1:
        b = p[0][0]
        if len(b) >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}')
            return ' '+ b + ',  ' + build_object(p[0][1])+ ' '
        elif len(b) >= 2 and ( b[0] == '$'or b[0] == '?'):
             if b[0] == '?':
                 b = b.lstrip('?')
                 b = '$'+ b
             if listSearch(b):
                 return '  local:empty( '+ b + '_RDFTerm,  concat(' + build_object(p[0][1])+ '"" )), '
             else:
                 return '  local:empty( '+ b + ',  concat(' + build_object(p[0][1])+ ' "")), '
        else:
             if len(b) >= 2:
                 if(b[0] != '_' and b[1] != ':'):
                      return ' "  '+ b + '  ",  ' + build_object(p[0][1])+ ' '
             else:
                 return ' "  '+ b + '  ",  ' + build_object(p[0][1])+ ' '
    elif len(p) == 0:
        return ''
    else:
        d =  p
        if d[0] == '[' :
            d.remove('[')
            return '"[", ' + build_predicate([ d[0] ]) + '";", ' + build_predicate([ d[1] ]) + ' "]",\n '
        else:
            return ' ' + build_predicate([ d[0] ]) + ' ";", ' + build_predicate([ d[1] ]) + ' \n '



def build_object(o):

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
        d =  o[0]
        if d[0] == '[' :
            d.remove('[')
            return '"[", ' + build_predicate(d) + ' "]",\n '
        else:
            return  build_bnode(o[0][0])
    elif len(o) == 1 and isinstance(o[0], str):

        return  build_bnode(o[0])
    elif len(o) == 1 and isinstance(o[0], list):

        return build_predicate(o[0])
    elif len(o) == 0:
        return '[]'
    else:
        return '"[", ' + build_predicate([ o[0] ]) + ' ";", ' + build_predicate(o[1:]) + ' "]",\n '


def build_bnode(b):
    if b >= 2 and b[0] == '_' and b[1] == ':':
        global var_p
        v = ''
        for i in var_p:
            v += ' data('+str(i[0:])+ '),'
        if b.find('{') == -1 and b.find('}') == -1:
            return '"  '+ b + '_", ' + v
        else:
            bExpr =  b.split('{')
            bNode = bExpr[0]
            expr = bExpr[1].rstrip('}')
            return '"'+ bNode + '",  data('+expr+'), '
    else:
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}')
            return ' \'"\',  '+ b + ',  \'"\', '
        elif b >= 2 and (b[0] == '$' or b[0] == '?'):
            if b[0] == '?':
                b = b.lstrip('?')
                b = '$'+ b + ''
            if listSearch(b):
                return '   '+ b + '_RDFTerm ,  '
            else:
                return '   '+ b + ',  '
        else:
            return '  "  '+ b + '  ",  '



def listSearch(list_val):
    global var
    return list_val in var
