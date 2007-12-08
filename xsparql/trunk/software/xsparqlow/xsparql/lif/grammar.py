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
    'DOT', 'AT', 'CARROT', 'COLON', 'ATS', 'COMMA', 'EQUALS', 'GREATEST', 'LEAST', 'EMPTY', 'COLLATION',
    'SLASH', 'LBRACKET', 'RBRACKET', 'LPAR', 'RPAR', 'SEMICOLON', 'CHILD', 'DESCENDANT', 'ATTRIBUTE', 'SELF',
    'DESCENDANTORSELF', 'FOLLOWINGSIBLING', 'FOLLOWING', 'PARENT', 'ANCESTOR', 'PRECEDINGSIBLING', 'PRECEDING',
    'ANCESTORORSELF', 'STAR', 'ORDERED', 'UNORDERED', 'DOTDOT', 'SLASHSLASH', 'COLONCOLON', 'UNDERSCORE'
    )

states = [
   ('pattern','exclusive')
]

##t_FOR       = r'\bfor'
##t_LET       = r'\blet'
##t_ORDER     = r'\border'
##t_BY        = r'\bby'
##t_ATS        = r'\bat'
##t_IN        = r'\bin'
##t_AS        = r'\bas'
##t_DESCENDING     = r'\bdescending'
##t_ASCENDING    = r'\bascending'
##t_STABLE     = r'\bstable'
##t_IF    = r'\bif'
##t_THEN    = r'\bthen'
##t_ELSE    = r'\belse'
###t_TYPESWITCH = r'\btypeswitch'
##t_RETURN = r'\breturn'
##t_WHERE = r'\bwhere'
##t_GREATEST = r'\bgreatest'
##t_LEAST = r'\bleast'
##t_EMPTY = r'\bempty'
##t_COLLECTION = r'\bcollection'
##T_CHILD = r'\bchild'
##T_DESCENDANT = r'\bdescendant'
##T_ATTRIBUTE = r'\battribute'
##T_SELF = r'\bself'
##T_DESCENDANTORSELF = r'\bdescendant-or-self'
##T_FOLLOWINGSIBLING = r'\bfollowing-sibling'
##T_FOLLOWING = r'\bfollowing'
##t_PARENT = r'\bparent'
##t_ANCESTOR = r'\bancestor'
##t_PRECEDINGSIBLING = r'\bpreceding-sibling'
##t_PRECEDING = r'\bpreceding'
##t_ANCESTORORSELF = r'\bancestor-or-self'
##t_ORDERED = r'\ordered'
##t_UNORDERED = r'\unordered'

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
   'construct' : 'CONSTRUCT',
   'where' : 'WHERE',
   'greatest' : 'GREATEST',
   'least' : 'LEAST',
   'empty' : 'EMPTY',
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
   'unordered' : 'UNORDERED'
   
}


def t_ANY_NCNAME(t):
    r'\w[\w\-]*'
    if t.value == '_':
        t.type = 'UNDERSCORE'
    else:
        t.type = reserved.get(t.value,'NCNAME')
        if t.type == 'CONSTRUCT':
            t.lexer.begin('pattern')
    return t


t_ANY_SLASH = r'/'
t_ANY_SLASHSLASH = r'//'
t_ANY_LBRACKET = r'\['
t_ANY_RBRACKET = r'\]'
t_ANY_LPAR = r'\('
t_ANY_RPAR = r'\)'
t_ANY_SEMICOLON = r';'

t_ANY_QSTRING = r'\"[^\"]*\"'

##def t_CONSTRUCT(t):
##    r'\bconstruct'
##    t.lexer.start(pattern)
##    return t

t_INITIAL_LCURLY  = r'{'
t_pattern_LCURLY  = r'{'

t_INITIAL_RCURLY = r'}'

def t_pattern_RCURLY(t):
    r'}'
    t.lexer.begin('INITIAL')
    return t




t_ANY_VAR       = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-]*'
t_ANY_IRIREF    = r'\<([^<>\'\{\}\|\^`\x00-\x20])*\>'
t_ANY_INTEGER   = r'[0-9]+'
t_ANY_DOT       = r'\.' # PLY 2.2 does not like . to be a literal
t_ANY_AT        = r'@'
t_ANY_CARROT    = r'\^'
t_ANY_COLON     = r'\:'
t_ANY_COLONCOLON = r'\:\:'
t_ANY_COMMA     = r'\,'
t_ANY_EQUALS    = r'='
t_ANY_STAR    = r'\*'
t_ANY_DOTDOT    = r'\.\.'




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
    '''queryBody : expr'''
    p[0] = p[1]

    
def p_expr(p):
     '''expr : expr COMMA exprSingle
             | exprSingle'''
     p[0] = ' '.join(p[1:])
    
##def p_expres(p):
##    '''expres : COMMA exprSingle
##              | empty'''
##    p[0] = ' '.join(p[1:])


def p_empty(p):
    '''empty : '''
    p[0] = ''
    

def p_exprSingle(p):
    '''exprSingle : flworExpr
                  | orExpr'''
    p[0] = p[1]
    
    
def p_flworExpr(p):
    '''flworExpr : flworExprs RETURN exprSingle
                 | flworExprs CONSTRUCT graphpattern'''
    print p[3]
    p[0] = ' '.join(p[1:2]) + str(p[3])


def p_flworExprs(p):
    '''flworExprs : forletClauses
                  | forletClauses whereClause
                  | forletClauses orderByClause
                  | forletClauses whereClause orderByClause'''
    p[0] = ' '.join(p[1:])


def p_forletClauses(p):
    '''forletClauses : forClause
                     | letClause
                     | forletClauses forClause
                     | forletClauses letClause'''
    p[0] = ' '.join(p[1:])


def p_forClause(p):
    '''forClause : FOR forVars'''
    p[0] = ' '.join(p[1:])


def p_forVars(p):
    '''forVars : forVars COMMA forVar
               | forVar'''
    p[0] = ' '.join(p[1:])


def p_forVar(p):
    '''forVar : VAR typeDeclaration positionVar IN exprSingle'''
    p[0] = ' '.join(p[1:])

    

def p_letClause(p):
    '''letClause : LET letVars'''
    p[0] = ' '.join(p[1:])


def p_letVars(p):
    '''letVars : letVars COMMA letVar
               | letVar'''
    p[0] = ' '.join(p[1:])


def p_letVar(p):
    '''letVar : VAR typeDeclaration COLON EQUALS exprSingle'''
    p[0] = ' '.join(p[1:])

    
def p_typeDeclaration(p):
    '''typeDeclaration : empty'''
    p[0] = p[1] 

def p_positionVar(p):
    '''positionVar : ATS VAR
                   | empty'''
    p[0] = ' '.join(p[1:])

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
    p[0] = ' '.join(p[1:])

def p_orderDirection(p):
    '''orderDirection : ASCENDING
                      | DESCENDING
                      | empty'''
    p[0] = p[1]

def p_emptyHandling(p):
    '''emptyHandling : EMPTY GREATEST
                     | EMPTY LEAST
                     | empty'''
    p[0] = ' '.join(p[1:])
   

def p_whereClause(p):
    '''whereClause : WHERE exprSingle '''
    p[0] = ' '.join(p[1:])
    


def p_orExpr(p):
    '''orExpr : pathExpr'''
    p[0] = p[1]


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
    '''nodeTest : nameTest'''
    p[0] = p[1]

def p_nameTest(p):
    '''nameTest : qname
                | wildCard'''
    p[0] = p[1]

def p_wildCard(p):
    '''wildCard : STAR
                | NCNAME COLON STAR
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
                   | unorderedExpr'''
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
    p[0] = ''.join(p[1:])

def p_exprSingleses(p):
    '''exprSingleses : COMMA exprSingle
                     | empty'''
    p[0] = ' '.join(p[1:])



def p_graphpattern(p):
    '''graphpattern : LCURLY statementsYesNo RCURLY'''
    #p[0] = ' '.join(p[1:])
    p[0] = p[2]

def p_statementsYesNo0(p):
    '''statementsYesNo : statements'''
    p[0] = p[1]

def p_statementsYesNo1(p):
    '''statementsYesNo : empty'''
    p[0] = []

def p_statements(p):
    '''statements : statement statements
                  | statement'''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = [ p[1] ] + p[2]


def p_statement(p):
    '''statement : triples DOT'''
    p[0] = p[1]

def p_triples(p):
    '''triples : subject predicateObjectList'''
    p[0] = (p[1], p[2])

def p_subject(p):
    '''subject : resource
               | blank '''
    p[0] = p[1]

def p_predicateObjectList(p):
    '''predicateObjectList : verbObjectLists semicolonYesNo'''
    p[0] = p[1]


def p_semicolonYesNo(p):
    '''semicolonYesNo : SEMICOLON
                      | empty'''
    p[0] = p[1]
    
def p_verbObjectLists(p):
    '''verbObjectLists : verb objectList verbObjectListses'''
    p[0] = [ ( p[1], p[2] ) ] + p[3]

def p_verbObjectListses(p):
    '''verbObjectListses : SEMICOLON verbObjectLists
                         | empty'''
    if len(p) == 2: p[0] = []
    else :          p[0] = p[2]
    

def p_objectList(p):
    '''objectList : object objectLists'''
    p[0] = [ p[1] ] + p[2]

def p_objectLists(p):
    '''objectLists : COMMA objectList
                   | empty'''
    if len(p) == 2: p[0] = []
    else:           p[0] = p[1]


def p_object(p):
    '''object : resource
              | blank
              | rdfliteral'''
    p[0] = p[1]

def p_verb(p):
    '''verb : rdfPredicate'''
    p[0] = p[1]

def p_rdfPredicate(p):
    '''rdfPredicate : resource'''
    p[0] = p[1]    

##def p_triples_0(p):
##'''triples : '''
##p[0] = []
##
##def p_triples_1(p):
##'''triples : triple'''
##p[0] = [ p[1] ]
##
##def p_triples_2(p):
##'''triples : triples DOT triple'''
##p[0] = p[1] + [ p[3] ]
##
##
##def p_triple(p):
##'''triple : term term term'''
##p[0] = ( p[1], p[2], p[3] )


def p_resource(p):
    '''resource : qname
                | IRIREF'''
    p[0] = p[1]    

def p_blank(p):
    '''blank : bnode
             | LBRACKET RBRACKET
             | LBRACKET predicateObjectList RBRACKET'''
    if len(p) == 2:      p[0] = [ p[1] ]
    elif len(p) == 3: p[0] = []
    else:                p[0] = p[2]


def p_bnode(p):
    '''bnode : UNDERSCORE COLON NCNAME'''
    p[0] = ''.join(p[1:])
    

def p_rdfliteral(p):
    '''rdfliteral : INTEGER
                  | QSTRING
                  | QSTRING AT NCNAME
                  | QSTRING CARROT CARROT IRIREF'''
    if len(p) == 2: p[0] = p[1]
    else:           p[0] = ''.join(p[1:])


def p_qname(p):
    '''qname : NCNAME
             | NCNAME COLON NCNAME'''
    if len(p) == 2: p[0] = p[1]
    else:           p[0] = ''.join(p[1:])


# Error rule for syntax errors -> ignore them gracefully by throwing a SyntaxError
def p_error(p):
    print 'Syntax error at ', p
    raise SyntaxError

# Build the parser
yacc.yacc(debug=1)



# main part of the XSPARQL lowering rewriter
#

def rewrite(s):
    '''Rewrite s using our XSPARQL grammar. If we find a syntax error,
       we bail out and return the original input.'''
    
    try :
        result = yacc.parse(s)

        if result:
           return result + '\n'
        else:
           return ''
        
    except SyntaxError:
       return s



def reLexer(s):
    lexer = lex.lex()
    lexer.input(s)
    while 1:
         tok = lexer.token()
         if not tok: break
         print tok

    sys.exit(0)


import sys

if __name__ == "__main__":
    instring = ''.join(sys.stdin.readlines())
   
    print rewrite(instring)
    #reLexer(instring)
