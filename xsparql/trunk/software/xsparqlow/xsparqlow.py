
tokens = (
    'FOR','FROM','IN','LET','WHERE','ORDERBY','RETURN',
    'VAR', 'RCURLY', 'LCURLY', 'DOT', 'QNAME', 'ID', 'IRI'
    )


# Tokens

t_VAR          = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
t_LCURLY       = r'{'
t_RCURLY       = r'}'
t_QNAME        = r'[a-zA-Z\_][a-zA-Z0-9\_\-\.]*:[a-zA-Z\_][a-zA-Z0-9\_\-\.]*'
t_IRI          = r'\<([^<>\'\{\}\|\^`\x00-\x20])*\>'
t_ID           = r'[\'\"][^\'\"][\'\"]'
t_DOT          = r'\.'

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


pfx_declarations = [()]
for_variables = []
from_rdf      = ''
in_xpath      = ''
where_pattern = ''
orderby_var   = ''



# Yacc example

import ply.yacc as yacc

# FLWORExpr ::= (ForClause | LetClause)+ WhereClause? OrderByClause? "return" ExprSingle




##     t = ''
##     t += build_sparql_namespace()
##     t += build_sparql_query(0,
##                             [('foaf','http://xmlns.com/foaf')],
##                             p[1],
##                             p[3],
##                             p[4],
##                             p[5]
##                             )
##     t += build_for_loop(0)
##     t += build_aux_variables(0, p[1])
##     p[0] = t
def p_flwor_1(p):
    'flwor : forclause FROM IRI whereclause orderbyclause RETURN exprsingle'
    p[0] = str(p[1]) + p[2] + p[3] + p[4] + p[5] + p[6] + p[7]

   

def p_forclause(p):
    'forclause : FOR vars'
    p[0] = p[2]

def p_vars_1(p):
    'vars : VAR vars'
    p[0] = p[2] + [ p[1] ]

def p_vars_2(p):
    'vars : VAR'
    p[0] = [ p[1] ]



def p_whereclause(p):
    'whereclause : WHERE graphpattern'
    p[0] = p[2]

def p_graphpattern(p):
    'graphpattern : LCURLY triples RCURLY'
    p[0] = '{ ' + p[2] + ' }'

def p_triples_1(p):
    'triples : term term term DOT triples'
    p[0] = p[1] + ' ' + p[2] + ' ' + p[3] + ' . ' + p[4]

def p_triples_2(p):
    'triples : term term term DOT'
    p[0] = p[1] + ' ' + p[2] + ' ' + p[3] + ' . '

def p_triples_3(p):
    'triples : term term term'
    p[0] = p[1] + ' ' + p[2] + ' ' + p[3]


def p_term1(p):
    'term : QNAME'
    p[0] = p[1]

def p_term2(p):
    'term : IRI'
    p[0] = p[1]

def p_term3(p):
    'term : VAR'
    p[0] = p[1]
    

def p_orderbyclause(p):
    'orderbyclause : ORDERBY VAR'
    p[0] = p[2]



## def p_exprsingle_1(p):
##     'exprsingle : IRI flwor IRI'
##     p[0] = p[1] + p[2] + p[3]

def p_exprsingle_2(p):
    'exprsingle : flwor'
    p[0] = p[1]

def p_exprsingle_3(p):
    'exprsingle : '
    p[0] = ''


# Error rule for syntax errors
def p_error(p):
    print "Syntax error in input " + str(p)

# Build the parser
yacc.yacc()

# Use this if you want to build the parser using SLR instead of LALR
# yacc.yacc(method="SLR")

while 1:
   try:
       s = raw_input('')
   except EOFError:
       break
   if not s: continue
   result = yacc.parse(s)
   print result


## import sys

## for line in sys.stdin.readlines():
##     lex.input(line)
##     while True:
##         tok = lex.token()
##         if not tok: break
##         print tok







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


def build_sparql_namespace():
    return 'declare namespace sparql = "http://www.w3.org/2005/sparql-results#";\n'

# todo: escape double quotes
def build_sparql_query(i, pfx, vars, frm, where, orderby):
    res = 'let ' + query_aux(i) + ' := fn:concat("' + sparql_endpoint + '", fn:encode-for-uri("'
    for p in pfx: res += 'PREFIX ' + p[0] + ': <' + p[1] + '>\n'
    res += 'SELECT '
    for v in vars: res += v + ' '
    res += '\nFROM ' + frm
    res += '\nWHERE ' + where
    if len(orderby): res += '\nORDER BY ' + orderby
    res += '"))\n'
    return res


# todo what about INs?
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




## print build_sparql_namespace()
## print build_sparql_query(0,
##                          [('foaf','http://xmlns.com/foaf')],
##                          ['$X','$Y'],
##                          '<http://www.postsubmeta.net/foaf.rdf>',
##                          '{ $X foaf:name $Y }',
##                          '$X'
##                          )
## print build_for_loop(0)
## print build_aux_variables(0, ["$X", "$Y", "$YVAR"])
