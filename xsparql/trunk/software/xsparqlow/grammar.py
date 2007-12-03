#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Thomas Krennwallner <tkren@kr.tuwien.ac.at>
#



import ply.lex as lex
import ply.yacc as yacc
import sys
import re

# our rewriting functions
import rewriter


#
# the XSPARQL grammar
#


#
# ply lexer
#

tokens = (
    'FOR', 'FROM', 'WHERE', 'ORDER', 'BY',
    'VAR', 'IRIREF', 'LCURLY', 'RCURLY', 'NCNAME', 'QSTRING'
    )

states = [
   ('pattern','exclusive')
]

literals = '.:^@'

t_ANY_VAR       = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-]*'
t_ANY_IRIREF    = r'\<([^<>\'\{\}\|\^`\x00-\x20])*\>'

t_FOR       = r'\bfor'
t_FROM      = r'\bfrom'
t_ORDER     = r'\border'
t_BY        = r'\bby'

def t_WHERE(t):
    r'\bwhere'
    t.lexer.begin('pattern')
    return t

t_pattern_LCURLY  = r'{'
t_pattern_QSTRING = r'\"[^\"]*\"'
t_pattern_NCNAME  = r'\w[\w\-\.]*'

def t_pattern_RCURLY(t):
    r'}'
    t.lexer.begin('INITIAL')
    return t


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


def p_sparqlfor(p):
    '''sparqlfor : FOR sparqlvars FROM IRIREF WHERE graphpattern
                 | FOR sparqlvars FROM IRIREF WHERE graphpattern ORDER BY VAR'''
    if len(p) == 7:
        p[0] = ''.join([ r  for r in rewriter.build(p[2], p[4], p[6], '') ])
    else:
        p[0] = ''.join([ r  for r in rewriter.build(p[2], p[4], p[6], p[9]) ])


def p_sparqlvars(p):
    '''sparqlvars : VAR sparqlvars
                  | VAR'''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = p[2] + [ p[1] ]


def p_graphpattern(p):
    '''graphpattern : LCURLY triples RCURLY'''
    p[0] = p[2]


def p_triples_0(p):
    '''triples : '''
    p[0] = []

def p_triples_1(p):
    '''triples : triple
               | triple '.' '''
    p[0] = [ p[1] ]
    
def p_triples_2(p):
    '''triples : triple '.' triples'''
    p[0] = [ p[1] ] + p[3]


def p_triple(p):
    '''triple : term term term'''
    p[0] = ( p[1], p[2], p[3] )


def p_term(p):
    '''term : VAR
            | IRIREF
            | literal'''
    p[0] = p[1]


def p_literal(p):
    '''literal : qname
               | QSTRING '@' NCNAME
               | QSTRING '^' '^' IRIREF'''
    p[0] = ''.join(p[1:])


def p_qname(p):
    '''qname : NCNAME
             | NCNAME ':' NCNAME'''
    p[0] = ''.join(p[1:])


# Error rule for syntax errors -> ignore them gracefully by throwing a SyntaxError
def p_error(p):
    raise SyntaxError


# Build the parser
yacc.yacc(debug=0)



#
# main part of the XSPARQL lowering rewriter
#

def rewrite(s):
    '''Rewrite s using our XSPARQL grammar. If we find a syntax error,
    we bail out and return the original input.'''
    
    try:
        result = yacc.parse(s)

        if result:
            return result + '\n'
        else:
            return ''
        
    except SyntaxError:
        return s



## def rewrite(s):
##     lexer = lex.lex()
##     lexer.input(s)
##     while 1:
##         tok = lexer.token()
##         if not tok: break
##         print tok

##     sys.exit(0)