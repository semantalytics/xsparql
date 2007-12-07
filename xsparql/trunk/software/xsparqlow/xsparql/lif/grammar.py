# -*- coding: utf-8 -*-
#
#
# xsparqlow -- XSPARQL Liftinging Rewriter
#
# Copyright (C) 2007  
#
# This file is part of xsparqlift.
#
# xsparqlift is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# xsparqlift is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with xsparqlift.  If not, see <http://www.gnu.org/licenses/>.
#
#


import ply.lex as lex
import ply.yacc as yacc
import sys
import re

# our rewriting functions
import rewriter


#
# the XSPARQL Lifting grammar (very incomplete)
#


#
# ply lexer
#

tokens = (
    'FOR', 'LET', 'WHERE', 'ORDER', 'BY', 'IN', 'AS', 'RETURN', 'CONSTRUCT', 'STABLE', 'ASCENDING', 'DESCENDING',
    'VAR', 'IRIREF', 'INTEGER', 'LCURLY', 'RCURLY', 'NCNAME', 'QSTRING', 'IF', 'THEN', 'ELSE',
    'DOT', 'AT', 'CARROT', 'COLON', 'ATS', 'COMMA', 'EQUALS', 'GREATEST', 'LEAST', 'EMPTY', 'COLLECTION',
    'SLASH', 'LBRACKET', 'RBRACKET', 'LPAR', 'RPAR', 'SEMICOLON', 'CHILD', 'DESCENDANT', 'ATTRIBUTE', 'SELF',
    'DESCENDANT-OR-SELF', 'FOLLOWING-SIBLING', 'FOLLOWING'
    )

states = [
   ('pattern','exclusive')
]

t_FOR       = r'\bfor'
t_LET       = r'\blet'
t_ORDER     = r'\border'
t_BY        = r'\bby'
t_ATS        = r'\bat'
t_IN        = r'\bin'
t_AS        = r'\bas'
t_DESCENDING     = r'\bdescending'
t_ASCENDING    = r'\bascending'
t_STABLE     = r'\bstable'
t_IF    = r'\bif'
t_THEN    = r'\bthen'
t_ELSE    = r'\belse'
#t_TYPESWITCH = r'\btypeswitch'
t_RETURN = r'\breturn'
t_WHERE = r'\bwhere'
t_GREATEST = r'\bgreatest'
t_LEAST = r'\bleast'
t_EMPTY = r'\bempty'
t_COLLECTION = r'\bcollection'
T_CHILD = r'\bchild'
T_DESCENDANT = r'\bdescendant'
T_ATTRIBUTE = r'\battribute'
T_SELF = r'\bself'
T_DESCENDANT-OR-SELF = r'\bdescendant-or-self'
T_FOLLOWING-SIBLING = r'\bfollowing-sibling'
T_FOLLOWING = r'\bfollowing'

reserved = {
   'for' : 'FOR',
   'let' : 'LET',
   'order' : 'ORDER',
   'by' : 'BY',
   'at' : 'AT',
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
   'where' : 'WHERE',
   'greatest' : 'GREATEST',
   'least' : 'LEAST',
   'empty' : 'EMPTY',
   'collection' : 'COLLECTION',
   'child' : 'CHILD'
   'descendant' : 'DESCENDANT'
   'attribute' : 'ATTRIBUTE'
   'self' : 'SELF'
   'descendant-or-self' : 'DESCENDANT-OR-SELF'
   'following-sibling' : 'FOLLOWING-SIBLING'
   'following' : 'FOLLOWING'
}


def t_NCNAME(t):
    r'\w[\w\-\.]*'
    t.type = reserved.get(t.value,'NCNAME')
    return t


t_ANY_SLASH = r'/'
t_ANY_LBRACKET = r'\['
t_ANY_RBRACKET = r'\]'
t_ANY_LPAR = r'\('
t_ANY_RPAR = r'\)'
t_ANY_SEMICOLON = r';'

t_ANY_QSTRING = r'\"[^\"]*\"'

def t_CONSTRUCT(t):
    r'\bconstruct'
    t.lexer.start(pattern)
    return t

t_INITIAL_LCURLY  = r'{'
t_pattern_LCURLY  = r'{'

t_INITIAL_RCURLY = r'}'

def t_pattern_RCURLY(t):
    r'}'
    t.lexer.end(pattern)
    return t




t_ANY_VAR       = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-]*'
t_ANY_IRIREF    = r'\<([^<>\'\{\}\|\^`\x00-\x20])*\>'
t_ANY_INTEGER   = r'[0-9]+'
t_ANY_DOT       = r'\.' # PLY 2.2 does not like . to be a literal
t_ANY_AT        = r'@'
t_ANY_CARROT    = r'\^'
t_ANY_COLON     = r'\:'
t_ANY_COMMA     = r'\,'
t_ANY_EQUALS    = r'='




# Ignored characters
t_ANY_ignore = " \t"

def t_ANY_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")

def t_ANY_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)


    
# Build the lexer
lex.lex(debug=0, reflags=re.IGNORECASE)


#
# ply parser
#

## first come, first serve

def p_queryBody(p):
    '''queryBody : expSingle
                 | expSingle queryBodies'''
    if len(p) == 2: p[0] = p[1] 
    else:          p[0] = p[1] + p[2] + [ p[3] ]
 

def p_queryBodies(p):
    '''queryBodies : COMMA queryBody
                   | empty'''
    p[0] = ' '.join(p[1:])


def p_empty(p):
    '''empty : '''
    p[0] = ''
    

def p_expSingle(p):
    '''expSingle : flworExpr
                 | empty
                 | orExpr'''
    p[0] = p[1]
    
    
def p_flworExpr(p):
    '''flworExpr : forletClauses RETURN expSingle
                 | forletClauses whereClause RETURN expSingle
                 | forletClauses orderByClause RETURN expSingle
                 | forletClauses whereClause orderByClause RETURN expSingle
                 | forletClauses CONSTRUCT graphpattern
                 | forletClauses whereClause CONSTRUCT graphpattern
                 | forletClauses orderByClause CONSTRUCT graphpattern
                 | forletClauses whereClause orderByClause CONSTRUCT graphpattern'''
    p[0] = ' '.join(p[1:])


def p_forletClauses(p):
    '''forletClauses : forClause
                     | letClause
                     | forClause forletClauses
                     | letClause forletClauses'''
    p[0] = ' '.join(p[1:])


def p_forClause(p):
    '''forClause : FOR VAR IN expSingle forClauses
                 | FOR VAR typeDeclaration IN expSingle forClauses
                 | FOR VAR positionVar IN expSingle forClauses
                 | FOR VAR typeDeclaration positionVar IN expSingle forClauses'''
    p[0] = ' '.join(p[1:])


def p_forClauses(p):
    '''forClauses : COMMA forClause
                  | empty'''
    p[0] = ' '.join(p[1:])
    

def p_letClause(p):
    '''letClause : LET VAR COLON EQUALS expSingle letClauses
                 | LET VAR typeDeclaration COLON EQUALS expSingle letClauses
                 | LET VAR positionVar COLON EQUALS expSingle letClauses
                 | LET VAR typeDeclaration positionVar COLON EQUALS expSingle letClauses'''
    p[0] = ' '.join(p[1:])



def p_letClauses(p):
    '''letClauses : COMMA letClause
                  | empty'''
    p[0] = ' '.join(p[1:])
    
def p_typeDeclaration(p):
    '''typeDeclaration : empty'''
    p[0] = p[1] 

def p_positionVar(p):
    '''positionVar : ATS VAR'''
    p[0] = ' '.join(p[1:])


def p_graphpattern(p):
    '''graphpattern : LCURLY triples RCURLY'''
    p[0] = p[2]


def p_orderByClause(p):
    '''orderByClause : ORDER BY orderSpecList
                     | STABLE ORDER BY orderSpecList'''
    p[0] = ' '.join(p[1:])
    
def p_orderSpecList(p):
    '''orderSpecList : orderSpec'''      
    p[0] = ' '.join(p[1:])

def p_orderSpec(p):
    '''orderSpec : COMMA orderSpecList
                 | expSingle orderModifier
                 | empty'''
    p[0] = ' '.join(p[1:])

def p_orderModifier(p):
    '''orderModifier :  ASCENDING EMPTY GREATEST
                     |  DESCENDING EMPTY GREATEST
                     |  ASCENDING EMPTY LEAST
                     |  DESCENDING EMPTY LEAST 
                     |  ASCENDING EMPTY GREATEST COLLECTION IRIREF
                     |  DESCENDING EMPTY GREATEST COLLECTION IRIREF
                     |  ASCENDING EMPTY LEAST COLLECTION IRIREF
                     |  DESCENDING EMPTY LEAST COLLECTION IRIREF
                     |  ASCENDING
                     |  DESCENDING
                     |  EMPTY GREATEST
                     |  EMPTY LEAST
                     |  EMPTY GREATEST COLLECTION IRIREF
                     |  EMPTY LEAST COLLECTION IRIREF
                     |  COLLECTION IRIREF
                     |  empty'''
    p[0] = ' '.join(p[1:])

def p_whereClause(p):
    '''whereClause : WHERE expSingle '''
    p[0] = ' '.join(p[1:])
    


def p_orExpr(p):
    '''orExpr : pathExpr'''
    p[0] = p[1]


def p_pathExpr(p):
    '''pathExpr : SLASH
                | SLASH relativePathExpr
                | SLASH SLASH relativePathExpr
                | relativePathExpr'''
    p[0] = ' '.join(p[1:])


def p_relativePathExpr(p):
    '''relativePathExpr : stepExpr stepExprs'''
    p[0] = ' '.join(p[1:])


def p_stepExpr(p):
    '''stepExpr : filterExpr
                | axisStep'''
    p[0] = ' '.join(p[1:])
    

def p_stepExprs(p):
    '''stepExprs : SLASH stepExpr 
                 | SLASH SLASH stepExpr 
                 | empty'''
    p[0] = ''.join(p[1:])

def p_axisStep(p):
    '''axisStep : reverseStep predicateList
                | forwardStep predicateList'''

def p_forwardStep(p):
    '''forwardStep : forwardAxis nodeTest
                   | abbrevForwardStep'''

def p_forwardAxis(p):
    '''forwardAxis : forwardAxis nodeTest
                   | abbrevForwardStep'''    

def p_reverseStep(p):
    '''reverseStep : reverseStep predicateList
                | forwardStep predicateList'''
    
    
def p_filterExpr(p):
    '''filterExpr : '''

def p_triples_0(p):
    '''triples : '''
    p[0] = []

def p_triples_1(p):
    '''triples : triple
               | triple DOT'''
    p[0] = [ p[1] ]
    
def p_triples_2(p):
    '''triples : triple DOT triples'''
    p[0] = [ p[1] ] + p[3]


def p_triple(p):
    '''triple : term term term'''
    p[0] = ( p[1], p[2], p[3] )


def p_term(p):
    '''term : VAR
            | IRIREF
            | literal
            | expSingle'''
    p[0] = p[1]


def p_literal(p):
    '''literal : qname
               | INTEGER
               | QSTRING AT NCNAME
               | QSTRING CARROT CARROT IRIREF'''
    p[0] = ''.join(p[1:])


def p_qname(p):
    '''qname : NCNAME
             | NCNAME COLON NCNAME'''
    p[0] = ''.join(p[1:])


# Error rule for syntax errors -> ignore them gracefully by throwing a SyntaxError
def p_error(p):
    print 'Syntax error at ', p
    raise SyntaxError


# Build the parser
yacc.yacc(debug=0)



#
# main part of the XSPARQL lowering rewriter
#

def rewrite(s):
    '''Rewrite s using our XSPARQL grammar. If we find a syntax error,
       we bail out and return the original input.'''
    
#    try:
    result = yacc.parse(s)

    if result:
        return result + '\n'
    else:
        return ''
        
#    except SyntaxError:
#        return s
#


#def rewrite(s):
#    lexer = lex.lex()
 #   lexer.input(s)
#    while 1:
#        tok = lexer.token()
#        if not tok: break
#        print tok#
#
#    sys.exit(0)


import sys

if __name__ == "__main__":
    instring = ''.join(sys.stdin.readlines())
    rewrite(instring)
