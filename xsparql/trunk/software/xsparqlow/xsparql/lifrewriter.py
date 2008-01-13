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

import re
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
var = ''
def build_rewrite_query(forletExpr, construct, graphpattern, variable):
    

    global var
    var = variable
    #print graphpattern
    statement = ' ' + build_triples(graphpattern) + ' '
    statement += ')'      

    #print str(graphpattern)+ '\n\n'
    return '\n  '+forletExpr + '\n return \n\t  fn:concat( \n\t\t\n ' + statement


f = False
def build_triples(gp):
    
    global f
    ret = ''
    space = ''
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
            f = True
            ret += '\n' + build_subject(s) + build_predicate(polist) + '".&#xA;",'
    return ret.rstrip(',')


def build_subject(s):

    #print 'sub:', s


    if len(s) == 1 and isinstance(s[0], list) and isinstance(s[0][0], str):
        return build_bnode(s[0][0]) 
    elif len(s) == 1 and isinstance(s[0], str): # blank node or object
        return build_bnode(s[0]) 
    elif len(s) == 1 and isinstance(s[0], list): # blank node or object
        f = False
        return build_predicate(s[0])
    elif len(s) == 0: # single blank node
        return '[]'
    else: # polist
        f = False
        return '"[", ' + build_predicate([ s[0] ]) + ' ";", ' + build_predicate(s[1:]) + ' "]",\n '



def build_predicate(p):

   # print 'prd:', p
    global f
    if len(p) == 1:
        b = p[0][0]
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}') 
            return ' '+ b + ',  ' + build_object(p[0][1])+ ' '
        elif b >= 2 and b[0] == '$':
             return '   '+ b + '  ,  ' + build_object(p[0][1])+ ' '
        else:
             return ' "  '+ b + '  ",  ' + build_object(p[0][1])+ ' '
    elif len(p) == 0:
        return ''
    else:
        #print f
        if f :
            f = False
            return ' ' + build_predicate([ p[0] ]) + ' ";", ' + build_predicate([ p[1] ]) + ' \n '
        else:
            f = False
            return '"[", ' + build_predicate([ p[0] ]) + '";", ' + build_predicate([ p[1] ]) + ' "]",\n '


def build_object(o):

  #  print 'obj:', o

    if len(o) == 1 and isinstance(o[0], list) and isinstance(o[0][0], str):
        return  build_bnode(o[0][0])
    elif len(o) == 1 and isinstance(o[0], str):
        return  build_bnode(o[0]) 
    elif len(o) == 1 and isinstance(o[0], list):
        f = False
        return build_predicate(o[0])
    elif len(o) == 0:
        return '[]'
    else:
        f = False
        return '"[", ' + build_predicate([ o[0] ]) + ' ";", ' + build_predicate(o[1:]) + ' "]",\n '


def build_bnode(b):
    if b >= 2 and b[0] == '_' and b[1] == ':':
        global var
        v = ''
        for i in var:
            v += ' data('+str(i[0:])+ '), '
        if b.find('{') == -1 and b.find('}') == -1:
            return '"'+ b + '_", ' + v
        else:
            bExpr =  b.split('{')
            bNode = bExpr[0]
            expr = bExpr[1].rstrip('}')
            #print expr
            return '"'+ bNode + '_",  data('+expr+'), ' 
    else:
        if b >= 2 and b[0] == '{' and b[-1] == '}' :
            strip = str(b).lstrip('{')
            b = strip.rstrip('}') 
            return ' \'"\',  '+ b + ',  \'"\', '
        elif b >= 2 and b[0] == '$':
            return '   '+ b + '  ,  '
        else:
            return '  "  '+ b + '  ",  '

##        if b.find('"') == 0 and b.find('{') == 1 :
##            rspace = b.lstrip('"{')
##            rspace = rspace.rstrip('}"')
##            return rspace + ', '
##        else:
##            

##    for sub, predList in graphpattern:
##       #print sub[0:]
##       
##       if str(sub[0:]).find('_') == 0 and str(sub[0:]).find(':') == 1:
##           bnode = '"'+str(sub[0:])+ '_", '
##           for i in variable.split():
##                bnode += ' '+i[0:]+'_count,'
##           triples += bnode + ' '
##       else:
##           triples += str(sub[0:])+ ','
##           #triples += predicate_object_list(predList)
##           
##       for pred, objList in predList:
##           #print str(pred[0:])
##           predicate += '"'+str(pred[0:])+'", '
##           #print triples
##           for obj in objList:
##               #print obj[0:]
##
##               if 
##               
##               if str(obj[0:]).find('_') == 0 and str(obj[0:]).find(':') == 1:
##                   bnode = '"'+str(obj[0:])+ '_", '
##                   for i in variable.split():
##                        bnode += ' '+i[0:]+'_count,'
##                   objects += bnode + ' '
##               elif str(obj[0:]).find('"') == 0 and str(obj[0:]).find('{') == 1:
##                   strip = str(obj[0:]).lstrip('"{')
##                   objects += strip.rstrip('}"') + ', '   
##               else:
##                   if len(nestedObj) > 0:
##                       objects = predicate_object_list(nestedObj)
##                   else:
##                       objects = '"'+str(obj[0:]) + '", '
##           
##           statement += triples
##           statement += predicate
##           statement += objects
##           statement += ' ".&#xA;" \n\t\t'
##           predicate = ''
##           objects = ''
##           triples = ''
##    statement += ')'      
##
##    print str(graphpattern)+ '\n\n'
##    return result + '\n '+statement
##   
##       
####    for t in graphpattern.split():
####      bnodepattern = ''
####      if str(t[0:]).find('_') == 0 and str(t[0:]).find(':') == 1:
####          bnode = '"'+str(t[0:])+ '_", '
####          for i in variable.split():
####                bnode += ' '+i[0:]+'_count,'
####                bnodepattern = bnode + ' '
####      elif str(t[0:]).find('{') == 0 or str(t[0:]).find('}') == 0:
####          otherpattern = ' '
####      elif str(t[0:]).find('"') == 0 and str(t[0:]).find('{') == 1:
####          strip = str(t[0:]).lstrip('"{')
####          otherpattern = strip.rstrip('}"') + ', '   
####      elif str(t[0:]).find('.') == 0:
####          otherpattern = ' ".&#xA;", \n'
####      elif str(t[0:]).find('a') == 0:
####          otherpattern = '"a", '    
####      else:
####          otherpattern = '"'+t[0:] + '", '
####      pattern += bnodepattern
####      pattern += otherpattern
####      otherpattern = ''
##   
###print 'waseem'
##    
##   
##                    
##        
##def predicate_object_list(lists):
##     predicate = ''
##     objects = ''
##     statement = ''     
##     for pred, objList in lists[:]:
##           #print str(pred[0:])
##           predicate += '"'+str(pred[0:])+'", '
##           #print triples
##           for obj in objList[:]:
##               #print obj[0:]
##               if str(obj[0:]).find('_') == 0 and str(obj[0:]).find(':') == 1:
##                   bnode = '"'+str(obj[0:])+ '_", '
##                   for i in variable.split():
##                        bnode += ' '+i[0:]+'_count,'
##                   objects += bnode + ' '
##               elif str(obj[0:]).find('"') == 0 and str(obj[0:]).find('{') == 1:
##                   strip = str(obj[0:]).lstrip('"{')
##                   objects += strip.rstrip('}"') + ', '   
##               else:
##                   if str(obj[0:]) != '':
##                       objects = predicate_object_list(obj[0:])
##                   else:
##                       objects = '"'+str(obj[0:]) + '", '                       
##                       
##
##              
##               statement += predicate
##               statement += objects
##               statement += ' ".&#xA;" \n\t\t'
##               predicate = ''
##               objects = ''
##               
##              
##     
##     return statement


