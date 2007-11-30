#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Thomas Krennwallner <tkren@kr.tuwien.ac.at>
#


#
# xsparql grammar
#



tokens = (
    'FOR','FROM','WHERE','ORDERBY','RETURN', 'DECLARE', 'NAMESPACE',
    'VAR', 'QNAME', 'IRI', 'QSTRING'
    )

# Literals.  Should be placed in module given to lex()
literals = [ '.',  '<' , '>' , '{', '}', '/', ':', '=' ]


# Tokens

t_VAR          = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
#t_NCNAME       = r'[a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
t_QNAME        = r'[a-zA-Z\_][a-zA-Z0-9\_\-\.]*:[a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
t_IRI          = r'[a-zA-Z\_][a-zA-Z0-9\_\-\.]*:\/\/[a-zA-Z\/][a-zA-Z0-9\_\-\.\/\&\?\%\#]*'
t_QSTRING      = r'(\"[^\"]\")|(\'[^\']\‘)'

t_FOR          = r'[Ff][Oo][Rr]'
t_FROM         = r'[Ff][Rr][Oo][Mm]'
t_WHERE        = r'[Ww][Hh][Ee][Rr][Ee]'
t_ORDERBY      = r'[Oo][Rr][Dd][Ee][Rr][\ \n\t][Bb][Yy]'
t_RETURN       = r'[Rr][Ee][Tt][Uu][Rr][Nn]'
t_DECLARE      = r'[Dd][Ee][Cc][Ll][Aa][Rr][Ee]'
t_NAMESPACE    = r'[Nn][Aa][Mm][Ee][Ss][Pp][Aa][Cc][Ee]'


# Ignored characters
t_ignore = " \t"

def t_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")

def t_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)


# Build the lexer
import ply.lex as lex
lex.lex()


import ply.yacc as yacc
import string
import sys



## first come, first serve

def p_xsparql(p):
    'xsparql : prolog querybody'
    p[0] = string.join(p[1:])

def p_prolog(p):
    'prolog : namespacedecls'
    p[0] = string.join(p[1:])

def p_namespacedecls(p):
    '''namespacedecls : namespacedecl
                      | namespacedecl namespacedecls
                      | empty'''
    p[0] = string.join(p[1:])


def p_namespacedecl(p):
    '''namespacedecl : DECLARE NAMESPACE QSTRING ':' '=' QSTRING '''
    p[0] = string.join(p[1:])

def p_querybody(p):
    '''querybody : flwor'''
    p[0] = string.join(p[1:])


def p_flwor(p):
    '''flwor : sparqlfor RETURN flwor
             | empty'''
    p[0] = string.join(p[1:])


import rewriter

def p_sparqlfor(p):
    '''sparqlfor : FOR sparqlvars FROM iri sparqlwhereclause
                 | FOR sparqlvars FROM iri sparqlwhereclause orderbyclause'''
    if len(p) == 6:
        p[0] = string.join([ r  for r in rewriter.build(p[2], p[4], p[5], '') ])
    else:
        p[0] = string.join([ r  for r in rewriter.build(p[2], p[4], p[5], p[6]) ])


def p_empty(p):
    'empty : '
    p[0] = ''


def p_iri(p):
    '''iri : '<' QNAME '>'
           | '<' IRI '>' '''
    p[0] = '<' + p[2] + '>'


def p_sparqlvars(p):
    '''sparqlvars : VAR sparqlvars
                  | VAR'''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = p[2] + [ p[1] ]

def p_sparqlwhereclause(p):
    'sparqlwhereclause : WHERE graphpattern'
    p[0] = p[2]

def p_graphpattern(p):
    '''graphpattern : '{' triple '.' triples '}'
                    | '{' triple '}' '''
    p[0] = string.join(p[1:])

def p_triples(p):
    '''triples : triple '.' triples
               | triple '''
    p[0] = string.join(p[1:])

def p_triple(p):
    '''triple : term term term'''
    p[0] = string.join(p[1:])

def p_term(p):
    '''term : QNAME
            | iri
            | VAR'''
    p[0] = p[1]
    

def p_orderbyclause(p):
    'orderbyclause : ORDERBY VAR'
    p[0] = p[2]



rubbish_tip = ''

# Error rule for syntax errors -> ignore them gracefully
def p_error(p):
    s = ''
    if p: s = p.value
    # Read ahead looking for the next FOR
    while 1:
        tok = yacc.token()             # Get the next token
        if not tok or tok.type == 'FOR': break
        else: s += tok.value
    yacc.errok()
    # Return FOR to the parser as the next lookahead token
    if tok:
        tok.value = s
        return tok
    else:
##         yacc.errok()
        global rubbish_tip
        rubbish_tip += s



def main(argv=None):
    if argv is None:
        argv = sys.argv

    # Build the parser
    yacc.yacc(debug=0)

    s = string.join(sys.stdin.readlines())
    result = yacc.parse(s)
    if result:
        sys.stdout.write('declare namespace sparql = "http://www.w3.org/2005/sparql-results#";\n')
        sys.stdout.write(result + '\n')
        sys.stdout.write(rubbish_tip + '\n')



if __name__ == "__main__":
    sys.exit(main())



