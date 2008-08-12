# -*- coding: utf-8 -*-
#
#
# xsparql -- XSPARQL Rewriter
#
# Copyright (C) 2007,2008  Thomas Krennwallner  <tkren@kr.tuwien.ac.at>
#               2007,2008  Waseem Akthar  <waseem.akthar@deri.org>
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


import ply.lex as lex
import ply.yacc as yacc
import sys
import re

# our rewriting functions
import lifrewriter
import lowrewriter


#
# XSPARQL Grammar begin
#

# =======================================================================
# ply lexer
# =======================================================================


# lexer tokens
tokens = (
    'FOR', 'FROM', 'LET', 'WHERE', 'ORDER', 'BY', 'IN', 'AS', 'RETURN', 'CONSTRUCT', 'STABLE', 'ASCENDING', 'DESCENDING',
    'VAR', 'IRIREF', 'INTEGER', 'LCURLY', 'RCURLY', 'NCNAME', 'NCNAME_COLON', 'QSTRING', 'IF', 'THEN', 'ELSE', 'LIMIT', 'OFFSET',
    'DOT', 'AT', 'CARROT', 'COLON', 'ATS', 'COMMA', 'EQUALS', 'GREATEST', 'LEAST', 'COLLATION',
    'SLASH', 'LBRACKET', 'RBRACKET', 'LPAR', 'RPAR', 'SEMICOLON', 'CHILD', 'DESCENDANT', 'ATTRIBUTE', 'SELF', 'IS', 'EQ',
    'DESCENDANTORSELF', 'FOLLOWINGSIBLING', 'FOLLOWING', 'PARENT', 'ANCESTOR', 'PRECEDINGSIBLING', 'PRECEDING', 'NE', 'LT',
    'ANCESTORORSELF', 'STAR', 'ORDERED', 'UNORDERED', 'DOTDOT', 'SLASHSLASH', 'COLONCOLON', 'UNDERSCORE', 'ITEM', 'LE', 'GE',
    'DECLARE', 'NAMESPACE', 'DEFAULT', 'ELEMENT', 'FUNCTION', 'BASEURI', 'LESSTHAN', 'GREATERTHAN', 'GT',
    'PREFIX', 'BASE', 'AND', 'OR', 'TO', 'PLUS', 'MINUS', 'DIV', 'IDIV', 'MOD', 'UNION', 'INTERSECT',
    'EXCEPT', 'INSTANCE', 'TREAT', 'CASTABLE', 'CAST', 'OF', 'UNIONSYMBOL', 'QUESTIONMARK', 'EMPTYSEQUENCE',
    'LESSTHANLESSTHAN', 'GREATERTHANEQUALS', 'LESSTHANEQUALS', 'HAFENEQUALS', 'NODE', 'DOCUMENTNODE',
    'TEXT', 'COMMENT', 'PROCESSINGINSTRUCTION', 'SCHEMAATTRIBUTE', 'SCHEMAELEMENT', 'DOCUMENT',
    'NAMED'#, 'OPTIONAL'

##     'CHEX', 'OTHERHEXI', 'LAX', 'SMALLU', 'GREATERTHANGREATERTHAN', 'STRICT', 'STRI', 'BACKSLASH', 'BIGU',
##     'OTHERHEXII', 'HEXII', 'DOUBLEQUOTS', 'SINGLEQUOTS', 'BACKSLASHGT', 'HEXI', 'HAFEN',
    )

# reserved keywords
reserved = {
   'is' : 'IS',
   'eq' : 'EQ',
   'ne' : 'NE',
   'lt' : 'LT',
   'ge' : 'GE',
   'le' : 'LE',
   'gt' : 'GT',
   'for' : 'FOR',
   'from' : 'FROM',
   'limit' : 'LIMIT',
   'offset' : 'OFFSET',
   'let' : 'LET',
   'order' : 'ORDER',
   'by' : 'BY',
   'at' : 'ATS',
   'in' : 'IN',
   'as' : 'AS',
   'descending' : 'DESCENDING',
   'ascending' : 'ASCENDING',
   'stable' : 'STABLE',
   'if' : 'IF',
   'then' : 'THEN',
   'else' : 'ELSE',
   'typeswitch' : 'TYPESWITCH',
   'return' : 'RETURN',
   'construct' : 'CONSTRUCT',
   'where' : 'WHERE',
   'greatest' : 'GREATEST',
   'least' : 'LEAST',
   'collation' : 'COLLATION',
   'child' : 'CHILD',
   'descendant' : 'DESCENDANT',
   'attribute' : 'ATTRIBUTE',
   'self' : 'SELF',
   'descendant-or-self' : 'DESCSENDANTORSELF',
   'following-sibling' : 'FOLLOWINGSIBLING',
   'following' : 'FOLLOWING',
   'parent' : 'PARENT',
   'ancestor' : 'ANCESTOR',
   'preceding-sibling' : 'PRECEDINGSIBLING',
   'preceding' : 'PRECEDING',
   'ancestor-or-self' : 'ANCESTORORSELF',
   'ordered' : 'ORDERED',
   'unordered' : 'UNORDERED',
   'declare' : 'DECLARE',
   'namespace' : 'NAMESPACE',
   'default' : 'DEFAULT',
   'element' : 'ELEMENT',
   'function' : 'FUNCTION',
   'base-uri' : 'BASEURI',
   'prefix' : 'PREFIX',
   'base' :'BASE',
   '_' : 'UNDERSCORE',
   'and' : 'AND',
   'or' : 'OR',
   'to' : 'TO',
   'div' : 'DIV',
   'idiv' : 'IDIV',
   'mod' : 'MOD',
   'union' : 'UNION',
   'intersect' : 'INTERSECT',
   'except' : 'EXCEPT',
   'instance' : 'INSTANCE',
   'treat' : 'TREAT',
   'castable' : 'CASTABLE',
   'cast' : 'CAST',
   'of' : 'OF',
   'lax' : 'LAX',
   'strict' : 'STRICT',
   'empty-sequence' : 'EMPTYSEQUENCE',
   'item' : 'ITEM',
   'node' : 'NODE',
   'document-node' : 'DOCUMENTNODE',
   'text' : 'TEXT',
   'comment' : 'COMMENT',
   'processing-instruction' : 'PROCESSINGINSTRUCTION',
   'schema-attribute' : 'SCHEMAATTRIBUTE',
   'schema-element' : 'SCHEMAELEMENT',
   'document' : 'DOCUMENT',
   'named' : 'NAMED',
   'optional' : 'OPTIONAL'
}

# lexer states
states = [
   ('pattern','exclusive'),
   ('iri','inclusive'),
   ('comments','exclusive')
]

precedence = (
    ('left', 'SLASH'),
    ('right', 'ORDER'),
)



from ply.lex import TOKEN
# ncname =          r'[a-zA-Z_][\w\-]*'
ncname =               r'[a-zA-Z_][A-Za-z0-9\.\-_]*'
ncname_colon =         r'(' + ncname + ')( |\t)*:'


@TOKEN(ncname_colon)
def t_INITIAL_pattern_iri_NCNAME_COLON(t):
    return t

# takes care of keywords and IRIs
@TOKEN(ncname)
def t_INITIAL_pattern_iri_NCNAME(t):
    # an NCNAME cannot start with a digit: http://www.w3.org/TR/REC-xml-names/#NT-NCName
    t.type = reserved.get(t.value,'NCNAME')
    if t.type == 'PREFIX' or t.type == 'BASE' or t.type == 'FROM':
	t.lexer.begin('iri')
    return t


t_INITIAL_pattern_iri_SLASH = r'/'
t_INITIAL_pattern_iri_SLASHSLASH = r'//'
t_INITIAL_pattern_iri_LBRACKET = r'\['
t_INITIAL_pattern_iri_RBRACKET = r'\]'
t_INITIAL_pattern_iri_LPAR = r'\('
t_INITIAL_pattern_iri_RPAR = r'\)'
t_INITIAL_pattern_iri_SEMICOLON = r';'
t_INITIAL_pattern_iri_QSTRING = r'\"[^\"]*\"'


t_LCURLY  = r'{'
t_RCURLY = r'}'


t_INITIAL_pattern_iri_VAR = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-]*'
t_INITIAL_pattern_iri_INTEGER   = r'[0-9]+'
t_INITIAL_pattern_iri_DOT       = r'\.' # PLY 2.2 does not like . to be a literal
t_INITIAL_pattern_iri_AT        = r'@'
t_INITIAL_pattern_iri_CARROT    = r'\^'
t_INITIAL_pattern_iri_COLON     = r'\:'
t_INITIAL_pattern_iri_COLONCOLON = r'\:\:'
t_INITIAL_pattern_iri_COMMA     = r'\,'
t_INITIAL_pattern_iri_EQUALS    = r'='
t_INITIAL_pattern_iri_STAR    = r'\*'
t_INITIAL_pattern_iri_DOTDOT    = r'\.\.'
t_INITIAL_pattern_iri_LESSTHAN = r'<'
t_INITIAL_pattern_iri_GREATERTHAN = r'>'
t_INITIAL_pattern_iri_PLUS = r'\+'
t_INITIAL_pattern_iri_MINUS = r'\-'
t_INITIAL_pattern_iri_UNIONSYMBOL = r'\|'
t_INITIAL_pattern_iri_QUESTIONMARK = r'\?'
t_INITIAL_pattern_iri_LESSTHANLESSTHAN = r'\<\<'
t_INITIAL_pattern_iri_GREATERTHANEQUALS = r'\>\='
t_INITIAL_pattern_iri_LESSTHANEQUALS = r'\<\='
t_INITIAL_pattern_iri_HAFENEQUALS = r'\!\='



curly_brackets = 0

# WHERE token starts the pattern state
def t_WHERE(t):
    r'\bwhere'
    t.lexer.begin('pattern')
    return t

def t_pattern_LCURLY(t):
    r'{'
    global curly_brackets
    curly_brackets += 1
    return t

# RCURLY token ends the pattern state iff curly_brackets counter gets 0
def t_pattern_RCURLY(t):
    r'}'
    global curly_brackets
    curly_brackets -= 1
    if curly_brackets == 0: t.lexer.begin('INITIAL')
    return t

t_pattern_QSTRING = r'\"[^\"]*\"'
t_pattern_NCNAME  = r'\w[\w\-\.]*'


# in iri state, we can match IRIs
t_iri_IRIREF    = r'\<([^<>\'\{\}\|\^`\x00-\x20])*'

# GREATERTHAN token ends the iri state
def t_iri_GREATERTHAN(t):
    r'>'
    t.lexer.begin('INITIAL')



## ------------------------------ 2.6 Comments
# http://www.w3.org/TR/xquery/#comments

# Comment        ::=  "(:" (CommentContents | Comment)* ":)"
# CommentContents        ::=  (Char+ - (Char* ('(:' | ':)') Char*))

comment_level = 0

# when it finds the begining of a comment switches to the 'comment'
# state and adds the comment level by one
def t_INITIAL_comments_SCOM(t):
    r'\(:\ '
    t.lexer.begin('comments')
    global comment_level
    comment_level += 1
    pass

# END_COMMENT token ends the pattern state iff comment_level counter
# gets 0
def t_ANY_ECOM(t):
    r'\ :\)'
    global comment_level
    comment_level -= 1
    if comment_level == 0: t.lexer.begin('INITIAL')
    pass

# Ignored characters for 'comment' state
t_comments_ignore = r".*"

# illegal characters will end up here
def t_comments_error(t):
    t.lexer.skip(1)


## -------------

# Ignored characters
t_INITIAL_pattern_iri_ignore = " \t"

# newlines increase line numbers (and will be ignored)
def t_ANY_newline(t):
    r'(\r?\n)+'
    t.lexer.lineno += t.value.count("\n")


# illegal characters will end up here
def t_INITIAL_pattern_iri_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)



# Build the lexer
lex.lex(debug=0, reflags=re.IGNORECASE)




# =======================================================================
# ply parser
# =======================================================================


# namespace list
namespaces = []
decl_var_ns = ''
count = 0
nsFlag = False

## --------------------------------------------------------- main

## first come, first serve
def p_mainModule(p):
    '''mainModule : prolog queryBody'''
    p[0] = ''.join(p[1:])


## --------------------------------------------------------- prolog

def p_prolog(p):
    '''prolog : xqueryNS prolog
	      | sparqlNS prolog
	      | empty'''
    p[0] = ''.join(p[1:])


def p_xqueryNS(p):
    '''xqueryNS : DECLARE xqueryNSs SEMICOLON'''
    p[0] = ' '.join(p[1:])


def p_xqueryNSs(p):
    '''xqueryNSs : defaultNamespaceDecl
		 | namespaceDecl
		 | baseURIDecl'''
    p[0] = ' '.join(p[1:])


def p_sparqlNS(p):
    '''sparqlNS : directive  '''
    p[0] = ''.join(p[1:])


def p_directive(p):
    '''directive : prefixID
		 | sbase'''
    p[0] = ''.join(p[1:])


def p_prefixID(p):
    '''prefixID : PREFIX prefixIDs'''
    p[0] = ''


def p_prefixIDs(p):
    '''prefixIDs :  NCNAME_COLON IRIREF
		 |  COLON IRIREF'''
    global count
    global decl_var_ns

    count += 1

    prefix = p[1]
    url = ''.join(p[2])

    col = ''
    nsTag = 'prefix'
    decl_var_ns += lowrewriter.declare_namespaces(nsTag, col, prefix, url, count)
    p[0] = ''




def p_sbase(p):
    '''sbase : BASE IRIREF'''
    global count
    global decl_var_ns

    count += 1
    prefix = ''
    url = ''.join(p[2])
    col = ''
    nsTag = 'base'
    decl_var_ns += lowrewriter.declare_namespaces(nsTag, col, prefix, url, count)
    p[0] = ''



def p_defaultNamespaceDecl(p):
    '''defaultNamespaceDecl :  DEFAULT defaultNamespaceDecls'''
    p[0] = ' '.join(p[1:])


def p_defaultNamespaceDecls(p):
    '''defaultNamespaceDecls :  ELEMENT NAMESPACE QSTRING
			     |  FUNCTION NAMESPACE QSTRING'''
    global namespaces
    global count
    global decl_var_ns
    namespaces.append(('prefix', '',':', p[3]))
    count += 1
    prefix = ''
    nsTag = 'prefix'
    col = ':'
    url = ''.join(p[3])
    decl_var_ns += lowrewriter.declare_namespaces(nsTag, col, prefix, url, count)
    p[0] = ' '.join(p[1:])


def p_namespaceDecl(p):
    '''namespaceDecl : NAMESPACE NCNAME EQUALS QSTRING'''
    global namespaces
    global count
    global decl_var_ns

    count += 1
    namespaces.append(('prefix', p[2], ':', p[4]))
    prefix = ''.join(p[2])
    url = ''.join(p[4])
    col = ':'
    nsTag = 'prefix'
    decl_var_ns += lowrewriter.declare_namespaces(nsTag, col, prefix, url, count)

    p[0] = ' '.join(p[1:])


def p_baseURIDecl(p):
    '''baseURIDecl  : BASEURI QSTRING'''
    global namespaces
    global count
    global decl_var_ns
    namespaces.append(('base', '', '', p[2]))
    count += 1
    prefix = ''
    col = ''
    nsTag = 'base'
    url = ''.join(p[3])
    decl_var_ns += lowrewriter.declare_namespaces(nsTag, col, prefix, url, count)
    p[0] = ' '.join(p[1:])


## --------------------------------------------------------- queryBody
# xqilla and saxon behave differently in NodeType variables, it seems
# like name($x_Node/*) does not work as intended
def p_queryBody(p):
    '''queryBody : expr'''
    global nsFlag
    prefix = 'declare namespace sparql_result = "http://www.w3.org/2005/sparql-results#"; \n'
    decl_func = '\ndeclare function local:rdf_term($NType as xs:string, $V as xs:string) as xs:string \n'
    decl_func += '{ let $rdf_term := if($NType = "sparql_result:literal" or $NType = "literal") then fn:concat("""",$V,"""") \n'
    decl_func += '  else if ($NType = "sparql_result:bnode" or $NType = "bnode") then fn:concat("_:", $V) \n'
    decl_func += '  else if ($NType = "sparql_result:uri" or $NType = "uri") then fn:concat("<", $V, ">") \n'
    decl_func += '  else "" \n'
    decl_func += '  return $rdf_term  };\n\n'
    decl_func += 'declare function local:empty($rdf_Predicate as xs:string,  $rdf_Object as xs:string) as xs:string \n'
    decl_func += '{ let $output :=  if( fn:substring($rdf_Predicate, 0, 3) = "_:" or substring($rdf_Predicate, 0, 2) = """ or  \n'
    decl_func += '  substring($rdf_Predicate, fn:string-length($rdf_Predicate), fn:string-length($rdf_Predicate))   = """ ) then   " " \n'
    decl_func += '  else  fn:concat($rdf_Predicate,  $rdf_Object) \n'
    decl_func += '  return $output }; \n\n'

    nsVars = lowrewriter.cnv_lst_str(lowrewriter.dec_var, True)
    if nsVars != '' and nsFlag:
	p[0] = '\n ' + prefix + decl_var_ns + decl_func + '\n fn:concat( ' + nsVars + ', "\n" ),\n' + p[1]
    else:
	p[0] = '\n ' + prefix + decl_var_ns + decl_func + p[1]

## ------------------------------ Expressions

def p_expr(p):
     '''expr : expr COMMA exprSingle
	     | exprSingle'''
     if len(p) == 2:
	 p[0] = ''.join(p[1][0])
     else:
	 p[0] = ''.join(p[1]+' '+p[2]+' '+p[3][0])


def p_enclosedExpr(p):
    '''enclosedExpr : LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_exprSingle(p):
    '''exprSingle : flworExpr
		  | constructQuery
		  | orExpr
		  | ifExpr'''
    p[0] = p[1]


## ------------------------------ constructQuery / SPARQL

def p_constructQuery(p):
    '''constructQuery : CONSTRUCT constructTemplate datasetClauses whereSPARQLClause solutionmodifier'''
    global nsFlag
    nsFlag = True
    p[0] = (''.join([ r  for r in lowrewriter.buildConstruct(p[2], p[3], p[4], p[5]) ]), [], [])


def p_datasetClauses(p): # list of (from, iri) tuples
    '''datasetClauses : datasetClauses datasetClause
		      | empty'''
    if len(p) == 3:
	p[0] = p[1] + [ p[2] ]
    else: # empty
	p[0] = []


def p_datasetClause(p):
    '''datasetClause : FROM IRIREF
		     | FROM NAMED IRIREF'''
    if len(p) == 4: # from named
	p[0] = (p[1] + ' ' + p[2], p[3])
    elif len(p) == 3: # from
	p[0] = (p[1], p[2])


def p_whereSPARQLClause(p):
    '''whereSPARQLClause : WHERE constructTemplate'''
    p[0] = p[2]


## ---------------------------------------------------- ifExpr

def p_ifExpr(p):
    '''ifExpr : IF LPAR expr RPAR THEN exprSingle ELSE exprSingle'''
    p[0] = (p[1]+' '+p[2]+' '+p[3]+' '+p[4]+' '+p[5]+' '+p[6][0]+' '+p[7]+' '+p[8][0], [], [])


## ---------------------------------------------------- flworExpr / Xquery
# http://www.w3.org/TR/xquery/#prod-xquery-FLWORExpr

def p_flworExpr0(p):
    '''flworExpr : flworExprs CONSTRUCT constructTemplate'''
    global nsFlag
    nsFlag = True
    p[0] = (''.join([ r  for r in lifrewriter.build_rewrite_query(p[1][0], p[2], p[3], p[1][2], p[1][1])]), p[1][2], p[1][2])

def p_flworExpr1(p):
    '''flworExpr : flworExprs RETURN exprSingle'''
    p[0] = ( p[1][0] + ' '+p[2]+' '+p[3][0], p[1][1], p[1][2] )




def p_flworExprs(p):
    '''flworExprs : forletClauses
		  | forletClauses whereClause
		  | forletClauses orderByClause
		  | forletClauses whereClause orderByClause'''
    if len(p) == 2:
	p[0] = ( p[1][0], p[1][1], p[1][2] )
    else:
	p[0] = ( p[1][0] + '\n'.join(p[2:]), p[1][1], p[1][2] )


# todo: collect variables in let, and build up triples of (expr, variables in scope, position variables in scope)


def p_forletClauses0(p):
    '''forletClauses : forClause'''
    p[0] = ( p[1][0] , p[1][1], p[1][2]  )

def p_forletClauses1(p):
    '''forletClauses : letClause'''
    p[0] = ( p[1][0] , [], p[1][2]  ) # FIXME: add bound and position variables # @todo: check if OK!
#    p[0] = ( p[1][0] , p[1][1], p[1][2]  ) # FIXME: add bound and position variables

def p_forletClauses2(p):
    '''forletClauses : sparqlForClause'''
    p[0] = ( p[1][0] , p[1][1], p[1][2]  ) # FIXME: add bound and position variables

def p_forletClauses3(p):
    '''forletClauses : forletClauses forClause
		     | forletClauses letClause
		     | forletClauses sparqlForClause'''
    p[0] = ( p[1][0] + p[2][0], p[1][1] + p[2][1], p[1][2] + p[2][2] )


# 8 shift/reduce

#                       | FOR sparqlvars datasetClauses  WHERE constructTemplate letClause solutionmodifier
def p_sparqlForClause(p):
    '''sparqlForClause : FOR sparqlvars datasetClauses WHERE constructTemplate solutionmodifier'''
    if len(p) == 7:
	p[0] = (''.join([ r  for r in lowrewriter.build(p[2][1], p[3], p[5], p[6]) ]), p[2][1], p[2][2] )
    else:
	p[0] = (''.join([ r  for r in lowrewriter.build(p[2][1], p[3], p[5], p[7]) ])+' '+str(p[6][0])+'  \n  ', p[2][1], p[2][2] )



def p_sparqlvars(p):
    '''sparqlvars : VAR sparqlvars
		  | VAR
		  | STAR'''
    if len(p) == 3:
	p[0] = (p[1] + ' ' + p[2][0], [ p[1] ] + p[2][1], [] )
    else:
	p[0] = ( p[1] , [ p[1] ] , [])



def p_forClause(p):
    '''forClause : FOR forVars'''
    p[0] = (p[1] + ' ' + p[2][0], p[2][1], p[2][2] )



def p_forVars0(p):
    '''forVars : forVars COMMA forVar'''
    p[0] = ( p[1][0] + p[2] + ' \n ' + p[3][0] , p[1][1] + [ p[3][1] ], p[1][2] + [ p[3][2] ] )

def p_forVars1(p):
    '''forVars : forVar'''
    p[0] = ( p[1][0], [ p[1][1] ] , [ p[1][2] ] )



def p_forVar(p):
    '''forVar : VAR typeDeclaration positionVar IN exprSingle'''
    if len(p[3][1]) == 0:
	 p[0] = ( p[1] + ' at ' + p[1] + '_Pos ' + p[2] + ' ' + p[4] + ' ' + p[5][0], p[1], p[1] + '_Pos' )
    else:
	p[0] = (p[1] + ' ' + p[2] + ' ' + p[3][0] + ' ' + p[4] + ' ' + p[5][0], p[1], p[3][1] )



def p_letClause(p):
    '''letClause : LET letVars'''
    p[0] = ('\n' + p[1] + ' ' + p[2][0], p[2][1], p[2][2] )



def p_letVars(p):
    '''letVars : letVars COMMA letVar
	       | letVar'''
    if len(p) == 2:
	p[0] = ( p[1][0], [ p[1][1] ] , [ p[1][2] ] )
    else:
	p[0] = ( p[1][0] + p[2] + ' \n ' + p[3][0] , p[1][1] + [ p[3][1] ], p[1][2] + [ p[3][2] ] )



def p_letVar(p):
    '''letVar : VAR typeDeclaration COLON EQUALS exprSingle'''
    p[0] = (p[1] + ' ' + p[2] + ' ' + p[3] + p[4] + ' ' + p[5][0],  p[1], [])



####################



def p_constructor(p):
    '''constructor : directConstructor
		   | computedConstructor'''
    p[0] = ' '.join(p[1:])


def p_computedConstructor(p):
    '''computedConstructor : compDocConstructor
			   | compElemConstructor
			   | compAttrConstructor
			   | compTextConstructor
			   | compCommentConstructor
			   | compPIConstructor'''
    p[0] = ' '.join(p[1:])


def p_compDocConstructor(p):
    '''compDocConstructor : DOCUMENT LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_compElemConstructor(p):
    '''compElemConstructor : ELEMENT qname LCURLY contentExpr RCURLY
			   | ELEMENT LCURLY expr RCURLY LCURLY contentExpr RCURLY
			   | ELEMENT qname LCURLY RCURLY
			   | ELEMENT LCURLY expr RCURLY LCURLY RCURLY'''
    p[0] = ' '.join(p[1:])


def p_contentExpr(p):
    '''contentExpr : expr'''
    p[0] = ' '.join(p[1:])


def p_compAttrConstructor(p):
    '''compAttrConstructor : ATTRIBUTE qname LCURLY expr RCURLY
			   | ATTRIBUTE LCURLY expr RCURLY LCURLY expr RCURLY
			   | ATTRIBUTE qname LCURLY RCURLY
			   | ATTRIBUTE LCURLY expr RCURLY LCURLY RCURLY'''
    p[0] = ' '.join(p[1:])


def p_compTextConstructor(p):
    '''compTextConstructor : TEXT LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_compCommentConstructor(p):
    '''compCommentConstructor : COMMENT LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_compPIConstructor(p):
    '''compPIConstructor : PROCESSINGINSTRUCTION NCNAME LCURLY expr RCURLY
			 | PROCESSINGINSTRUCTION LCURLY expr RCURLY LCURLY expr RCURLY
			 | PROCESSINGINSTRUCTION NCNAME LCURLY RCURLY
			 | PROCESSINGINSTRUCTION LCURLY expr RCURLY LCURLY RCURLY'''
    p[0] = ' '.join(p[1:])


# shift/reduce
# @todo: is this recursion allowed in XQuery? example: fdwlm.xsparql
# directConstructor directElemConstructor
#			 |
def p_directConstructor(p):
    '''directConstructor : directElemConstructor'''
    p[0] = ' '.join(p[1:])

# [96]    DirElemConstructor    ::=    "<" QName DirAttributeList ("/>" | (">" DirElemContent* "</" QName S? ">"))
def p_directElemConstructor(p):
    '''directElemConstructor : LESSTHAN NCNAME directAttributeList SLASH GREATERTHAN
			     | LESSTHAN NCNAME directAttributeList GREATERTHAN directElemContentProcessing LESSTHAN SLASH NCNAME GREATERTHAN'''
    p[0] = ''.join(p[1:])


def p_directElemContentProcessing(p):
    '''directElemContentProcessing : directElemContentProcessing directElemContent
				   | empty'''
    p[0] = ''.join(p[1:])


def p_directElemContent(p):
    '''directElemContent : directConstructor
			 | enclosedExpr'''
    p[0] = ''.join(p[1:])


def p_directAttributeList(p):
    '''directAttributeList : directAttribute directAttributeList
			   | empty'''
    if len(p) == 3:
        p[0] = ' ' + ''.join(p[1:])
    else:
        p[0] = ''


def p_directAttribute(p):
    '''directAttribute :  qname EQUALS directAttributeValue'''
    p[0] = ' '.join(p[1:])


def p_directAttributeValue(p):
    '''directAttributeValue :  attributeValueContent '''
    p[0] = ''.join(p[1:])


def p_attributeValueContent(p):
    '''attributeValueContent : enclosedExpr
			     | QSTRING'''
    p[0] = ''.join(p[1:])



## ------------------------------ solutionmodifier


def p_solutionmodifier(p):
    '''solutionmodifier : orderclause limitoffsetclause
			| orderclause
			| limitoffsetclause
			| empty'''
    p[0] = ' '.join(p[1:])


def p_limitoffsetclause(p):
    '''limitoffsetclause : limitclause
			 | offsetclause
			 | limitclause offsetclause
			 | offsetclause limitclause'''
    p[0] = ' '.join(p[1:])


def p_orderclause(p):
    '''orderclause : ORDER BY VAR'''
    p[0] = ' '.join(p[1:])

def p_limitclause(p):
    '''limitclause : LIMIT INTEGER'''
    p[0] = ' '.join(p[1:])


def p_offsetclause(p):
    '''offsetclause : OFFSET INTEGER'''
    p[0] = ' '.join(p[1:])


def p_typeDeclaration(p):
    '''typeDeclaration : empty'''
    p[0] = p[1]


def p_positionVar(p):
    '''positionVar : ATS VAR
		   | empty'''
    if len(p) == 3:
	p[0] = (' '.join(p[1:]), p[2])
    else:
	p[0] = ('', '')

# shift/reduce (solved by precedence)
def p_orderByClause(p):
    '''orderByClause : ORDER BY orderSpecList
		     | STABLE ORDER BY orderSpecList'''
    p[0] = ' '.join(p[1:])


def p_orderSpecList(p):
    '''orderSpecList : orderSpecList COMMA orderSpec
		     | orderSpec'''
    p[0] = ' '.join(p[1:])


def p_orderSpec(p):
    '''orderSpec : exprSingle orderDirection emptyHandling
		 | exprSingle orderDirection emptyHandling COLLATION uriliteral'''
#    p[0] = ' '.join(p[1:])
    p[0] = p[1][0] + ' '.join(p[2:])


def p_orderDirection(p):
    '''orderDirection : ASCENDING
		      | DESCENDING
		      | empty'''
    p[0] = p[1]


# @todo EMPTY clashes with fn:empty...
## def p_emptyHandling(p):
##     '''emptyHandling : EMPTY GREATEST
##                      | EMPTY LEAST
##                      | empty'''
##     p[0] = ' '.join(p[1:])
def p_emptyHandling(p):
    '''emptyHandling : GREATEST
		     | LEAST
		     | empty'''
    p[0] = ' '.join(p[1:])


def p_whereClause(p):
    '''whereClause : WHERE exprSingle '''
    p[0] = ''.join('\n'+p[1]+' '+p[2][0])


##def p_orExpr(p):
##    '''orExpr : pathExpr'''
##    p[0] = p[1]


## ------------------------------ orExpr

def p_orExpr(p):
    '''orExpr : andExpr orAndExpr'''
    p[0] = (p[1] +' ' +p[2], [], [])


def p_orAndExpr(p):
    '''orAndExpr : OR orAndExpress
		 | empty'''
    p[0] = ' '.join(p[1:])


def p_orAndExpress(p):
    '''orAndExpress : andExpr orAndExpr'''
    p[0] = ''.join(p[1:])


def p_andExpr(p):
    '''andExpr : comparisonExpr andCompExpr'''
    p[0] = ''.join(p[1:])


def p_andCompExpr(p):
    '''andCompExpr : AND andCompExpress
		   | empty'''
    p[0] = ' '.join(p[1:])


def p_andCompExpress(p):
    '''andCompExpress : comparisonExpr andCompExpr'''
    p[0] = ''.join(p[1:])


def p_comparisonExpr(p):
    '''comparisonExpr : rangeExpr rangeExpress'''
    p[0] = ''.join(p[1:])


def p_rangeExpress(p):
    '''rangeExpress : valueComp rangeExpr
		    | generalComp rangeExpr
		    | nodeComp rangeExpr
		    | empty'''
    p[0] = ''.join(p[1:])


def p_valueComp(p):
    '''valueComp : EQ
		 | NE
		 | LT
		 | LE
		 | GT
		 | GE'''
    p[0] = ''.join(p[1:])


def p_generalComp(p):
    '''generalComp : EQUALS
		   | LESSTHAN
		   | GREATERTHAN
		   | LESSTHANEQUALS
		   | GREATERTHANEQUALS
		   | HAFENEQUALS'''
    p[0] = ''.join(p[1:])


def p_nodeComp(p):
    '''nodeComp : LESSTHANLESSTHAN
		| GREATERTHAN GREATERTHAN
		| IS'''
    p[0] = ''.join(p[1:])


def p_rangeExpr(p):
    '''rangeExpr : additiveExpr rangeAddiExpr'''
    p[0] = ' '.join(p[1:])


def p_rangeAddiExpr(p):
    '''rangeAddiExpr : TO additiveExpr
		   | empty'''
    p[0] = ' '.join(p[1:])


def p_additiveExpr(p):
    '''additiveExpr : multiplicativeExpr addiMultiExpr'''
    p[0] = ''.join(p[1:])


def p_addiMultiExpr(p):
    '''addiMultiExpr : PLUS addiMultiExpress
		     | MINUS addiMultiExpress
		     | empty'''
    p[0] = ''.join(p[1:])


def p_addiMultiExpress(p):
    '''addiMultiExpress : multiplicativeExpr addiMultiExpr'''
    p[0] = ''.join(p[1:])


def p_multiplicativeExpr(p):
    '''multiplicativeExpr : unionExpr multiUnionExpr'''
    p[0] = ''.join(p[1:])


def p_multiUnionExpr(p):
    '''multiUnionExpr : STAR multiUnionExpress
		      | DIV multiUnionExpress
		      | IDIV multiUnionExpress
		      | MOD multiUnionExpress
		      | empty'''
    p[0] = ''.join(p[1:])


def p_multiUnionExpress(p):
    '''multiUnionExpress : unionExpr multiUnionExpr'''
    p[0] = ''.join(p[1:])


def p_unionExpr(p):
    '''unionExpr : intersectExceptionExpr uniIntersectExcExpr'''
    p[0] = ''.join(p[1:])


def p_uniIntersectExcExpr(p):
    '''uniIntersectExcExpr : UNION uniIntersectExcExpress
			   | UNIONSYMBOL uniIntersectExcExpress
			   | empty'''
    p[0] = ''.join(p[1:])


def p_uniIntersectExcExpress(p):
    '''uniIntersectExcExpress : intersectExceptionExpr uniIntersectExcExpr'''
    p[0] = ''.join(p[1:])


def p_intersectExceptionExpr(p):
    '''intersectExceptionExpr : intanceOfExpr interInstanceOfExpr'''
    p[0] = ''.join(p[1:])


def p_interInstanceOfExpr(p):
    '''interInstanceOfExpr : INTERSECT interInstanceOfExpress
			   | EXCEPT interInstanceOfExpress
			   | empty'''
    p[0] = ''.join(p[1:])


def p_interInstanceOfExpress(p):
    '''interInstanceOfExpress : intanceOfExpr interInstanceOfExpr'''
    p[0] = ''.join(p[1:])


def p_intanceOfExpr(p):
    '''intanceOfExpr : treatExpr instanceTreatExpr'''
    p[0] = ''.join(p[1:])


def p_instanceTreatExpr(p):
    '''instanceTreatExpr : INSTANCE OF sequenceType
			 | empty'''
    p[0] = ''.join(p[1:])


def p_treatExpr(p):
    '''treatExpr : castableExpr treatCastableExpr'''
    p[0] = ''.join(p[1:])


def p_treatCastableExpr(p):
    '''treatCastableExpr : TREAT AS sequenceType
			 | empty'''
    p[0] = ''.join(p[1:])


def p_castableExpr(p):
    '''castableExpr : castExpr castableCastExpr'''
    p[0] = ''.join(p[1:])


def p_castableCastExpr(p):
    '''castableCastExpr : CASTABLE AS singleType
			| empty'''
    p[0] = ''.join(p[1:])


def p_castExpr(p):
    '''castExpr : unaryExpr castUnaryExpr'''
    p[0] = ''.join(p[1:])


def p_castUnaryExpr(p):
    '''castUnaryExpr : CAST AS singleType
		     | empty'''
    p[0] = ''.join(p[1:])


def p_unaryExpr(p):
    '''unaryExpr : MINUS valueExpr
		 | PLUS valueExpr
		 | valueExpr'''
    p[0] = ''.join(p[1:])


def p_valueExpr(p):
    '''valueExpr : pathExpr'''
    p[0] = ''.join(p[1:])


def p_sequenceType(p):
    '''sequenceType : EMPTYSEQUENCE LPAR RPAR
		    | itemType occurrenceIndicator'''
    p[0] = ''.join(p[1:])


def p_occurrenceIndicator(p):
    '''occurrenceIndicator : STAR
			   | PLUS
			   | QUESTIONMARK'''
    p[0] = ''.join(p[1:])


def p_itemType(p):
    '''itemType : ITEM LPAR RPAR
		| atomicType
		| kindTest'''
    p[0] = ''.join(p[1:])


def p_kindTest(p):
    '''kindTest : documentTest
		| elementTest
		| attributeTest
		| schemaElementTest
		| schemaAttributeTest
		| piTest
		| commentTest
		| textTest
		| anyKindTest'''
    p[0] = ''.join(p[1:])


def p_anyKindTest(p):
    '''anyKindTest : NODE LPAR RPAR'''
    p[0] = ''.join(p[1:])


def p_documentTest(p):
    '''documentTest : DOCUMENTNODE LPAR documentTests RPAR'''
    p[0] = ''.join(p[1:])


def p_documentTests(p):
    '''documentTests : elementTest
		     | schemaElementTest
		     | empty'''
    p[0] = ''.join(p[1:])


def p_textTest(p):
    '''textTest : TEXT LPAR RPAR'''
    p[0] = ''.join(p[1:])


def p_commentTest(p):
    '''commentTest : COMMENT LPAR RPAR'''
    p[0] = ''.join(p[1:])


def p_piTest(p):
    '''piTest : PROCESSINGINSTRUCTION LPAR piTests RPAR'''
    p[0] = ''.join(p[1:])


def p_piTests(p):
    '''piTests : NCNAME
	       | QSTRING
	       | empty'''
    p[0] = ''.join(p[1:])


def p_attributeTest(p):
    '''attributeTest : ATTRIBUTE LPAR attributeTests RPAR'''
    p[0] = ''.join(p[1:])


def p_attributeTests(p):
    '''attributeTests : attributeNameOrWildcard COMMA typeName
		      | attributeNameOrWildcard
		      | empty'''
    p[0] = ''.join(p[1:])


def p_attributeNameOrWildcard(p):
    '''attributeNameOrWildcard : attributeName
			       | STAR'''
    p[0] = ''.join(p[1:])


def p_schemaAttributeTest(p):
    '''schemaAttributeTest : SCHEMAATTRIBUTE LPAR attributeDeclaration RPAR'''
    p[0] = ''.join(p[1:])


def p_attributeDeclaration(p):
    '''attributeDeclaration : attributeName'''
    p[0] = ''.join(p[1:])


def p_elementTest(p):
    '''elementTest : ELEMENT LPAR elementTests RPAR '''
    p[0] = ''.join(p[1:])


def p_elementTests(p):
    '''elementTests : elementNameOrWildcard COMMA typeName QUESTIONMARK
		    | elementNameOrWildcard COMMA typeName
		    | elementNameOrWildcard
		    | empty'''
    p[0] = ''.join(p[1:])


def p_elementNameOrWildcard(p):
    '''elementNameOrWildcard : elementName
			     | STAR'''
    p[0] = ''.join(p[1:])


def p_schemaElementTest(p):
    '''schemaElementTest : SCHEMAELEMENT LPAR elementDeclaration RPAR'''
    p[0] = ''.join(p[1:])


def p_elementDeclaration(p):
    '''elementDeclaration : elementName'''
    p[0] = ''.join(p[1:])


def p_attributeName(p):
    '''attributeName : qname'''
    p[0] = ''.join(p[1:])


def p_elementName(p):
    '''elementName : qname'''
    p[0] = ''.join(p[1:])


def p_typeName(p):
    '''typeName : qname'''
    p[0] = ''.join(p[1:])


def p_singleType(p):
    '''singleType : atomicType QUESTIONMARK
		  | atomicType'''
    p[0] = ''.join(p[1:])


def p_atomicType(p):
    '''atomicType : qname'''
    p[0] = ''.join(p[1:])


def p_pathExpr(p):
    '''pathExpr : SLASH
		| SLASH relativePathExpr
		| SLASHSLASH relativePathExpr
		| relativePathExpr'''
    p[0] = ''.join(p[1:])


def p_relativePathExpr(p):
    '''relativePathExpr : relativePathExpr SLASH stepExpr
			| relativePathExpr SLASHSLASH stepExpr
			| stepExpr'''
    p[0] = ''.join(p[1:])


def p_stepExpr(p):
    '''stepExpr : filterExpr
		| axisStep'''
    p[0] = ' '.join(p[1:])


def p_axisStep(p):
    '''axisStep : reverseStep predicateList
		| forwardStep predicateList'''
    p[0] = ''.join(p[1:])


def p_forwardStep(p):
    '''forwardStep : forwardAxis nodeTest
		   | abbrevForwardStep'''
    p[0] = ''.join(p[1:])


def p_forwardAxis(p):
    '''forwardAxis : CHILD COLONCOLON
		   | DESCENDANT COLONCOLON
		   | ATTRIBUTE COLONCOLON
		   | SELF COLONCOLON
		   | DESCENDANTORSELF COLONCOLON
		   | FOLLOWINGSIBLING COLONCOLON
		   | FOLLOWING COLONCOLON'''
    p[0] = ''.join(p[1:])


def p_reverseStep(p):
    '''reverseStep : reverseAxis nodeTest
		   | abbrevReverseStep'''
    p[0] = ''.join(p[1:])


def p_reverseAxis(p):
    '''reverseAxis : PARENT COLONCOLON
		   | ANCESTOR COLONCOLON
		   | PRECEDINGSIBLING COLONCOLON
		   | PRECEDING COLONCOLON
		   | ANCESTORORSELF COLONCOLON'''
    p[0] = ''.join(p[1:])


def p_abbrevForwardStep(p):
    '''abbrevForwardStep : AT nodeTest
			 | nodeTest'''
    p[0] = ''.join(p[1:])


def p_abbrevReverseStep(p):
    '''abbrevReverseStep : DOTDOT'''
    p[0] = ''.join(p[1:])


def p_nodeTest(p):
    '''nodeTest : kindTest
		| nameTest'''
    p[0] = p[1]


def p_nameTest(p):
    '''nameTest : qname
		| wildCard'''
    p[0] = p[1]


def p_wildCard(p):
    '''wildCard : STAR
		| NCNAME_COLON STAR
		| STAR COLON NCNAME'''
    p[0] = ''.join(p[1:])


def p_filterExpr(p):
    '''filterExpr : primaryExpr predicateList'''
    p[0] = ''.join(p[1:])


def p_predicateList(p):
    '''predicateList : predicate
		     | empty'''
    p[0] = p[1]


def p_predicate(p):
    '''predicate : LBRACKET expr RBRACKET'''
    p[0] = ''.join(p[1:])


def p_primaryExpr(p):
    '''primaryExpr : VAR
		   | literal
		   | parenthesizedExpr
		   | contextItemExpr
		   | functionCall
		   | orderedExpr
		   | unorderedExpr
		   | constructor'''
    p[0] = p[1]


def p_uriliteral(p):
    '''uriliteral : stringliteral'''
    p[0] = p[1]


def p_literal(p):
    '''literal : numericliteral
	       | stringliteral'''
    p[0] = p[1]


def p_numericliteral(p):
    '''numericliteral : INTEGER'''
    p[0] = p[1]


def p_stringliteral(p):
    '''stringliteral : QSTRING'''
    p[0] = p[1]


def p_parenthesizedExpr(p):
    '''parenthesizedExpr : LPAR expr RPAR
			 | LPAR RPAR'''
    p[0] = ''.join(p[1:])


def p_contextItemExpr(p):
    '''contextItemExpr : DOT'''
    p[0] = p[1]


def p_orderedExpr(p):
    '''orderedExpr : ORDERED LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_unorderedExpr(p):
    '''unorderedExpr : UNORDERED LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_functionCall(p):
    '''functionCall : qname LPAR exprSingles RPAR'''
    p[0] = ''.join(p[1:])


def p_exprSingles(p):
    '''exprSingles : exprSingle exprSingleses'''
    p[0] = ''.join(p[1][0]+' '+p[2])


def p_exprSingleses(p):
    '''exprSingleses : COMMA exprSingles
		     | empty'''
    p[0] = ' '.join(p[1:])



## ---------------------------------------------------------- constructTemplate / SPARQL
## http://www.w3.org/TR/rdf-sparql-query/#rConstructTemplate

def p_constructTemplate(p):
    '''constructTemplate : LCURLY constructTriples RCURLY'''
    p[0] = p[2]



def p_statements(p):
    '''constructTriples : lifttriples DOT constructTriples
			| lifttriples
			| empty'''
    if len(p) == 4:
	p[0] = [ p[1] ] +  p[3]
    elif len(p) == 2 and len(p[1]):
	p[0] = [ p[1] ]
    else:
	p[0] = []


def p_lifttriples(p):
    '''lifttriples : subject predicateObjectList '''
    p[0] = (p[1], p[2])


def p_subject0(p):
    '''subject : resource'''
    p[0] = [ p[1] ]


# shift/reduce with bnodeWithExpr
def p_subject1(p):
    '''subject : blank
	       | enclosedExpr'''
    p[0] = p[1]


def p_predicateObjectList(p):
    '''predicateObjectList : verbObjectLists
			   | empty'''
    p[0] = p[1]


def p_verbObjectLists(p):
    '''verbObjectLists : verb objectList SEMICOLON verbObjectLists
		       | verb objectList SEMICOLON
		       | verb objectList'''
    if len(p) == 5:
	p[0] = [ ( p[1], p[2] ) ] + p[4]
    else:
	p[0] = [ ( p[1], p[2] ) ]


def p_objectList(p):
    '''objectList : object COMMA objectList
		  | object'''
    if len(p) == 4:
	p[0] = [ p[1] ] + p[3]
    else:
	p[0] = [ p[1] ]


# shift/reduce with bnodeWithExpr
def p_object(p):
    '''object : resource
	      | blank
	      | rdfliteral
	      | enclosedExpr'''
    p[0] = p[1]


def p_verb(p):
    '''verb : rdfPredicate
	    | enclosedExpr'''
    p[0] = p[1]


def p_rdfPredicate(p):
    '''rdfPredicate : resource'''
    p[0] = p[1]



def p_resource(p):
    '''resource : qname
		| VAR
		| IRIREF'''
    #@todo do we have to map '?' to '$'??
    if p[1].startswith('?'):  # translate SPARQL vars "?Var" to "$Var"
	p[0] = '$' + p[1][1:]
    else:
	p[0] = p[1]

def p_blank(p):
    '''blank : bnode
	     | LBRACKET predicateObjectList RBRACKET'''
    if len(p) == 2: # bnodeWithExpr
	p[0] = [ p[1] ]
    else: # non-empty bracketedExpr
	p[0] = [ p[1] ] + p[2]



def p_bnode(p):
    '''bnode : UNDERSCORE COLON NCNAME'''
    p[0] = ''.join(p[1:])


def p_rdfliteral(p):
    '''rdfliteral : INTEGER
		  | QSTRING
		  | QSTRING AT NCNAME
		  | QSTRING CARROT CARROT IRIREF'''
    p[0] = ''.join(p[1:])




def p_qname(p):
    '''qname : prefixedName
	     | unprefixedName'''
    p[0] = ''.join(p[1:])


def p_unprefixedName(p):
    '''unprefixedName : localPart'''
    p[0] = ''.join(p[1:])

def p_prefixedName(p):
    '''prefixedName : prefix localPart'''
    p[0] = ''.join(p[1:])

def p_prefix(p):
    '''prefix : NCNAME_COLON
	      | COLON'''
    p[0] = ''.join(p[1:])

def p_localPart(p):
    '''localPart : NCNAME'''
    p[0] = ''.join(p[1:])




## ------------------------------ empty rule

def p_empty(p):
    '''empty : '''
    p[0] = ''



#
# XSPARQL Grammar end
#


def p_error(p):
    '''Error rule for syntax errors -> ignore them gracefully by
    throwing a SyntaxError.'''
    print 'Syntax error at ', p
    raise SyntaxError



def generate_parser():
    '''called at build time'''
    yacc.yacc(tabmodule = 'parsetab', outputdir = './xsparql')


def get_parser():
    '''called in rewrite to read the installed parser'''
    return yacc.yacc(debug = 0, tabmodule = 'xsparql.parsetab', write_tables = 0)



# ---------------------------- initial function
def rewrite(s):
    '''Rewrite s using our XSPARQL grammar. If we find a syntax error,
       we bail out and return the original input.'''

    try:
	parser = get_parser()

	# parse s, and get rewritten string back
	result = parser.parse(s)

	if result:
	   return result + '\n'
	else:
	   return ''

    except SyntaxError:
	sys.exit(1)



def reLexer(s):
    lexer = lex.lex()
    lexer.input(s)
    while 1:
	 tok = lexer.token()
	 if not tok: break
	 print tok

    sys.exit(0)



if __name__ == "__main__":
    instring = ''.join(sys.stdin.readlines())
    output = rewrite(instring)
    print output
