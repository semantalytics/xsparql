#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Thomas Krennwallner <tkren@kr.tuwien.ac.at>
#


sparql_endpoint = 'http://localhost:2020/sparql?query='

def query_aux(i):
    return '$aux' + str(i)

def query_result_aux(i):
    return '$aux_result' + str(i)

def var_node(var):
    return var + '_Node'

def var_nodetype(var):
    return var + '_NodeType'

def var_rdfterm(var):
    return var + '_RDFTerm'


# todo: escape double quotes
def build_sparql_query(i, pfx, vars, frm, where, orderby):
    res = 'let ' + query_aux(i) + ' := fn:concat("' + sparql_endpoint + '", fn:encode-for-uri("'
    for p in pfx: res += 'PREFIX ' + p[0] + ': <' + p[1] + '>\n'
    res += 'SELECT '
    for v in vars: res += v + ' '
    res += '\nFROM ' + frm
    res += '\n' + where
    if len(orderby): res += '\n' + orderby
    res += '"))\n'
    return res



def build_for_loop(i):
    return 'for ' + query_result_aux(i) + ' in doc(' + query_aux(i) + ')//sparql:result\n'


def build_aux_variables(i, vars):
    ret = ''
    
    for v in vars:
        ret += '\tlet ' + var_node(v) + ' := (' + query_result_aux(i) + '/sparql:binding[@name = "' + v[1:] + '"])\n'
        ret += '\tlet ' + var_nodetype(v) + ' := name(' + var_node(v) + '/*)\n'
        ret += '\tlet ' + v + ' := data(' + var_node(v) + '/*)\n'
        ret += '\tlet ' + var_rdfterm(v) + ' := fn_concat(\n' + \
               '\t\tif(' + var_nodetype(v) + ' = "literal") then "\\""\n' + \
               '\t\telse if(' + var_nodetype(v) + ' = "bnode") then "_:"\n' + \
               '\t\telse if(' + var_nodetype(v) + ' = "uri") then "<"\n' + \
               '\t\telse "",\n\t\t' + v + ',\n' + \
               '\t\tif(' + var_nodetype(v) + ' = "literal") then "\\""\n' + \
               '\t\telse if(' + var_nodetype(v) + ' = "uri") then ">"\n\t)\n'
        
    return ret




#
# xquery grammar
#



tokens = (
    'FOR','FROM','IN','LET','WHERE','ORDERBY','RETURN',
    'VAR', 'QNAME', 'IRI', 'QSTRING', 'DECLAREAS'
    )

# Literals.  Should be placed in module given to lex()
literals = [ '.', ',', '<' , '>' , '/' , '=', '{', '}' ]


# Tokens

t_VAR          = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
t_QNAME        = r'[a-zA-Z\_][a-zA-Z0-9\_\-\.]*:[a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
t_IRI          = r'[a-zA-Z\_][a-zA-Z0-9\_\-\.]*:\/\/[a-zA-Z\/][a-zA-Z0-9\_\-\.\/\&\?\%\#]*'
t_QSTRING      = r'(\"[^\"]\")|(\'[^\']\‘)'
t_DECLAREAS    = r':='

t_FOR          = r'[Ff][Oo][Rr]'
t_FROM         = r'[Ff][Rr][Oo][Mm]'
t_IN           = r'[Ii][Nn]'
t_LET          = r'[Ll][Ee][Tt]'
t_WHERE        = r'[Ww][Hh][Ee][Rr][Ee]'
t_ORDERBY      = r'[Oo][Rr][Dd][Ee][Rr][\ \n\t][Bb][Yy]'
t_RETURN       = r'[Rr][Ee][Tt][Uu][Rr][Nn]'


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


# Yacc example

import ply.yacc as yacc
import string


def p_querybody(p):
    '''querybody : expr'''
    p[0] = string.join(p[1:])

def p_expr(p):
    '''expr : exprsingle
            | exprsingle ',' exprsingles'''
    p[0] = string.join(p[1:])

def p_exprsingles(p):
    '''exprsingles : exprsingle
                   | exprsingle ',' exprsingles'''
    p[0] = string.join(p[1:])

def p_exprsingle(p):
    '''exprsingle : constructor
                  | flwor
                  | primaryexpr'''
    p[0] = string.join(p[1:])


def p_primaryexpr(p):
    '''primaryexpr : VAR'''
    p[0] = string.join(p[1:])

def p_constructor(p):
    'constructor : directconstructor'
    p[0] = p[1]

def p_directconstructor(p):
    'directconstructor : direlemconstructor'
    p[0] = p[1]

def p_direlemconstructor(p):
    '''direlemconstructor : '<' QNAME '/' '>'
                          | '<' QNAME dirattributelist '/' '>'
                          | '<' QNAME '>' '<' '/' QNAME '>'
                          | '<' QNAME dirattributelist '>' '<' '/' QNAME '>'
                          | '<' QNAME '>' direlemcontent '<' '/' QNAME '>'
                          | '<' QNAME dirattributelist '>' direlemcontent '<' '/' QNAME '>' '''
    p[0] = string.join(p[1:])

def p_dirattributelist(p):
    '''dirattributelist : QNAME '=' QSTRING
                        | QNAME '=' QSTRING dirattributelist'''
    p[0] = string.join(p[1:])


def p_direlemcontent(p):
    '''direlemcontent : directconstructor
                      | commoncontent'''
    p[0] = string.join(p[1:])

def p_commoncontent(p):
    '''commoncontent : enclosedexpr'''
    p[0] = string.join(p[1:])

def p_enclosedexpr(p):
    '''enclosedexpr : '{' expr '}' '''
    p[0] = string.join(p[1:])


## def p_exprsingle_3(p):
##     'exprsingle : empty'
##     p[0] = ''



# FLWORExpr ::= (ForClause | LetClause)+ WhereClause? OrderByClause? "return" ExprSingle

def p_flwor_0(p):
    '''flwor : sparqlforclause FROM iri sparqlwhereclause RETURN exprsingle'''
    p[0] = build_sparql_query(0, [('foaf','http://xmlns.com/foaf')], p[1], p[3], p[4], "") + \
           build_for_loop(0) + \
           build_aux_variables(0, p[1]) + \
           string.join(p[5:])
    
def p_flwor_1(p):
    '''flwor : sparqlforclause FROM iri sparqlwhereclause orderbyclause RETURN exprsingle'''
    p[0] = build_sparql_query(0, [('foaf','http://xmlns.com/foaf')], p[1], p[3], p[4], p[5]) + \
           build_for_loop(0) + \
           build_aux_variables(0, p[1]) + \
           string.join(p[6:])
           
    

def p_iri(p):
    '''iri : '<' QNAME '>'
           | '<' IRI '>' '''
    p[0] = '<' + p[2] + '>'

def p_flwor_2(p):
    '''flwor : flclauses RETURN exprsingle
             | flclauses whereclause RETURN exprsingle
             | flclauses whereclause orderbyclause RETURN exprsingle'''
    p[0] = string.join(p[1:])


def p_empty(p):
    'empty : '
    pass

def p_flclauses(p):
    '''flclauses : forclause flclauses
                 | letclause flclauses
                 | forclause empty
                 | letclause empty'''
    p[0] = string.join(p[1:])


## def p_typedeclaration(p):
##     '''typedeclaration : AS '''


def p_letclause(p):
    '''letclause : LET VAR DECLAREAS exprsingle
                 | LET VAR DECLAREAS exprsingle ',' letvars'''
    p[0] = string.join(p[1:])
    
   
def p_letvars(p):
    '''letvars : VAR DECLAREAS exprsingle
               | VAR DECLAREAS exprsingle ',' letvars'''
    p[0] = string.join(p[1:])




def p_forclause(p):
    '''forclause : FOR VAR IN exprsingle
                 | FOR VAR IN exprsingle ',' forvars'''
    p[0] = string.join(p[1:])


def p_forvars(p):
    '''forvars : VAR IN exprsingle
               | VAR IN exprsingle ',' forvars'''
    p[0] = string.join(p[1:])


def p_whereclause(p):
    '''whereclause : WHERE exprsingle'''
    p[0] = string.join(p[1:])


def p_sparqlforclause(p):
    '''sparqlforclause : FOR sparqlvars'''
    p[0] = p[2]

def p_sparqlvars(p):
    '''sparqlvars : VAR sparqlvars
                  | VAR'''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = p[2] + [ p[1] ]

def p_sparqlwhereclause(p):
    'sparqlwhereclause : WHERE graphpattern'
    p[0] = string.join(p[1:])

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
            | IRI
            | VAR'''
    p[0] = p[1]
    

def p_orderbyclause(p):
    'orderbyclause : ORDERBY VAR'
    p[0] = string.join(p[1:])



# Error rule for syntax errors
def p_error(p):
    print "Syntax error in input " + str(p)

# Build the parser
yacc.yacc(debug=0)

# Use this if you want to build the parser using SLR instead of LALR
# yacc.yacc(method="SLR")

import sys



while 1:
   try:
       s = raw_input('')
   except EOFError:
       break
   if not s: continue
   result = yacc.parse(s)
   if result: sys.stdout.write('declare namespace sparql = "http://www.w3.org/2005/sparql-results#";\n')
   sys.stdout.write(result + '\n')
