#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Thomas Krennwallner <tkren@kr.tuwien.ac.at>
#



import ply.lex as lex
import ply.yacc as yacc
import sys
import string
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
    'VAR', 'IRIREF', 'GRAPHPATTERN'
    )

states = [
   ('pattern','exclusive')
]

t_VAR       = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-]*'
t_IRIREF    = r'\<([^<>\'\{\}\|\^`\x00-\x20])*\>'
t_FOR       = r'\bfor'
t_FROM      = r'\bfrom'
t_ORDER     = r'\border'
t_BY        = r'\bby'

def t_WHERE(t):
    r'\bwhere'
    t.lexer.begin('pattern')
    return t

def t_pattern_GRAPHPATTERN(t):
    r'\{[^\}]*\}'
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
    '''sparqlfor : FOR sparqlvars FROM IRIREF WHERE GRAPHPATTERN
                 | FOR sparqlvars FROM IRIREF WHERE GRAPHPATTERN ORDER BY VAR'''
    if len(p) == 7:
        p[0] = ''.join([ r  for r in rewriter.build(p[2], p[4], p[6], '') ])
    else:
        p[0] = ''.join([ r  for r in rewriter.build(p[2], p[4], p[6], p[9]) ])


def p_sparqlvars(p):
    '''sparqlvars : VAR sparqlvars
                  | VAR'''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = p[2] + [ p[1] ]


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




def main(argv=None):
    '''parse stdin and output the possibly rewritten XSPARQL query'''

    if argv is None:
        argv = sys.argv

    s = ' '.join(sys.stdin.readlines())
    i = m = n = 0

    # search for all the DECLARE NAMESPACE directives and build a list
    # of mappings using re's grouping pattern

    re_namespace = re.compile(r'declare\s+namespace\s+(\w+)\s*=\s*\"([^\"]*)\"\s*;',
                              re.IGNORECASE)

    rewriter.namespaces = re_namespace.findall(s)

    # regexp for FOR and RETURN
    re_for = re.compile('[ \t\n]?FOR[ \t\n]', re.IGNORECASE)
    re_return = re.compile('[ \t\n]RETURN[ \t\n\{]', re.IGNORECASE)

    # always declare the sparql namespace
    sys.stdout.write('declare namespace sparql = "http://www.w3.org/2005/sparql-results#";\n')

    while i < len(s):

        # search for FOR
        for_match = re_for.search(s[i:])

        if for_match:

            # set start position of FOR
            m = i + for_match.start()
            # search for RETURN
            return_match = re_return.search(s[m:])
            # output preceding string
            sys.stdout.write(s[i:m])

            if return_match:

                # set start positition of RETURN
                n = m + return_match.start()
                # and now parse our expression
                sys.stdout.write(rewrite(s[m:n]))
                # restart with new start position
                i = n

            else:

                # no RETURN found: just output trailing part and quit
                sys.stdout.write(s[m:])
                i = len(s)
 
        else:

            # no FOR found: just output trailing part and quit
            sys.stdout.write(s[i:])
            i = len(s)

    return 0


if __name__ == "__main__":
    sys.exit(main())



