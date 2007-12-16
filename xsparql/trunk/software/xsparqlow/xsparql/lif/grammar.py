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
import lowrewriter


#
# the XSPARQL Lifting grammar (very incomplete)
#


#
# ply lexer
#

tokens = (
    'FOR', 'FROM', 'LET', 'WHERE', 'ORDER', 'BY', 'IN', 'AS', 'RETURN', 'CONSTRUCT', 'STABLE', 'ASCENDING', 'DESCENDING',
    'VAR', 'IRIREF', 'INTEGER', 'LCURLY', 'RCURLY', 'NCNAME', 'QSTRING', 'IF', 'THEN', 'ELSE', 'LIMIT', 'OFFSET',
    'DOT', 'AT', 'CARROT', 'COLON', 'ATS', 'COMMA', 'EQUALS', 'GREATEST', 'LEAST', 'EMPTY', 'COLLATION', 
    'SLASH', 'LBRACKET', 'RBRACKET', 'LPAR', 'RPAR', 'SEMICOLON', 'CHILD', 'DESCENDANT', 'ATTRIBUTE', 'SELF',
    'DESCENDANTORSELF', 'FOLLOWINGSIBLING', 'FOLLOWING', 'PARENT', 'ANCESTOR', 'PRECEDINGSIBLING', 'PRECEDING',
    'ANCESTORORSELF', 'STAR', 'ORDERED', 'UNORDERED', 'DOTDOT', 'SLASHSLASH', 'COLONCOLON', 'UNDERSCORE', 
    'DECLARE', 'NAMESPACE', 'DEFAULT', 'ELEMENT', 'FUNCTION', 'BASEURI', 'LESSTHAN', 'GREATERTHAN', 'SINGLEQUOTS',
    'DOUBLEQUOTS' 
    )

reserved = {
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
   'unordered' : 'UNORDERED',
   'declare' : 'DECLARE',
   'namespace' : 'NAMESPACE',
   'default' : 'DEFAULT',
   'element' : 'ELEMENT',
   'function' : 'FUNCTION',
   'base-uri' : 'BASEURI',
   '_' : 'UNDERSCORE'
}

states = [
   ('pattern','exclusive')
]

def t_ANY_NCNAME(t):
    r'\w[\w\-]*'
    t.type = reserved.get(t.value,'NCNAME')
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

t_LCURLY  = r'{'
t_RCURLY = r'}'


t_ANY_VAR       = r'[\$\?][a-zA-Z\_][a-zA-Z0-9\_\-]*'
#t_ANY_IRIREF    = r'\<([^<>\'\{\}\|\^`\x00-\x20])*\>'
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
t_ANY_LESSTHAN = r'<'
t_ANY_GREATERTHAN = r'>'
t_ANY_SINGLEQUOTS = r'\''
t_ANY_DOUBLEQUOTS = r'"'


t_FOR       = r'\bfor'
t_FROM      = r'\bfrom'
t_ORDER     = r'\border'
t_BY        = r'\bby'
t_LIMIT     = r'\blimit'
t_OFFSET    = r'\boffset'

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

namespaces = []


## first come, first serve
def p_mainModule(p):
    '''mainModule : prolog queryBody'''
    global namespaces
    p[0] = ' '+p[1] + '\n ' + ',\n '.join([ '"@%s %s%s &#60;%s&#62; .&#xA;"' % (pre,ns,co,uri[1:-1]) for (pre,ns,co,uri) in namespaces]) + ',\n' + p[2]
    
def p_prolog(p):
    '''prolog : defaultNamespaceDecl nsDecl
              | namespaceDecl nsDecl
              | baseURIDecl nsDecl
              | empty'''
    
    p[0] = ''.join(p[1:])

def p_nsDecl(p):
    '''nsDecl : SEMICOLON prolog'''
    p[0] = '\n '.join(p[1:])    

def p_defaultNamespaceDecl(p):
    '''defaultNamespaceDecl : DECLARE DEFAULT ELEMENT NAMESPACE QSTRING
                            | DECLARE DEFAULT FUNCTION NAMESPACE QSTRING'''
    global namespaces
    namespaces.append(('prefix', '',':', p[5]))
    p[0] = ' '.join(p[1:])
    #' '.join([ r  for r in rewriter.build_rewrite_defaultNSDecl(p[1], p[2], p[3], p[4], p[5])])
    
def p_namespaceDecl(p):
    '''namespaceDecl : DECLARE NAMESPACE NCNAME EQUALS QSTRING'''
    global namespaces
    namespaces.append(('prefix', p[3], ':', p[5]))
    p[0] = ' '.join(p[1:])
    #' '.join([ r  for r in rewriter.build_rewrite_nsDecl(p[1], p[2], p[3], p[5])])

def p_baseURIDecl(p):
    '''baseURIDecl  : DECLARE BASEURI QSTRING'''
    global namespaces
    namespaces.append(('base', '', '', p[3]))
    p[0] = ' '.join(p[1:])
    #' '.join([ r  for r in rewriter.build_rewrite_baseURI(p[1], p[2], p[3])])
    
def p_queryBody(p):
    '''queryBody : expr'''
    p[0] = '\n '+p[1]

    
def p_expr(p):
     '''expr : expr COMMA exprSingle
             | exprSingle'''
     p[0] = ' '.join(p[1:])
    
def p_enclosedExpr(p):
    '''enclosedExpr : LCURLY expr RCURLY'''
    p[0] = ' '.join(p[1:])


def p_empty(p):
    '''empty : '''
    p[0] = ''
    

def p_exprSingle(p):
    '''exprSingle : flworExpr
                  | orExpr'''
    p[0] = p[1]
    
variable = []    
def p_flworExpr0(p):
    '''flworExpr : flworExprs CONSTRUCT constructTemplate'''
#                 | flworExprs RETURN directConstructor'''
   # print p[3]
    global variable
       
    p[0] = ''.join([ r  for r in rewriter.build_rewrite_query(p[1], p[2], p[3], variable)])


def p_flworExpr1(p):
    '''flworExpr : flworExprs RETURN exprSingle'''
                  # | flworExprs RETURN directConstructor'''
    p[0] = ' '.join(p[1:])


def p_flworExprs(p):
    '''flworExprs : forletClauses
                  | forletClauses whereClause
                  | forletClauses orderByClause
                  | forletClauses whereClause orderByClause'''
    p[0] = ' '.join(p[1:])


# todo: collect variables in let, and build up triples of (expr, variables in scope, position variables in scope)

def p_forletClauses0(p):
    '''forletClauses : forClause'''
    p[0] = p[1][0]


def p_forletClauses1(p):
    '''forletClauses : letClause'''
    p[0] = p[1]



def p_forletClauses2(p):
    '''forletClauses : sparqlForClause'''
    p[0] = p[1]


def p_forletClauses3(p):
    '''forletClauses : forletClauses forClause'''
    p[0] = p[1] + p[2][0]

def p_forletClauses4(p):
    '''forletClauses : forletClauses letClause'''
    p[0] = p[1] + p[2]


def p_forletClauses5(p):
    '''forletClauses : forletClauses sparqlForClause'''
    p[0] = p[1]+ p[2]


def p_sparqlForClause(p):
    '''sparqlForClause : FOR sparqlvars FROM iriRef WHERE constructTemplate solutionmodifier '''
    p[0] = ''.join([ r  for r in lowrewriter.build(p[2], p[4], p[6], p[7]) ])


##def p_groupgraphpattern(p):
##    '''groupgraphpattern : LCURLY RCURLY
##                         | LCURLY triplesBlock RCURLY
##                         | LCURLY triplesBlock triplesBlockes RCURLY'''
##    p[0] = p[2]
##
##def p_triplesBlockes(p):
##    '''triplesBlockes : graphPatternNotTriples 
##                      | filter
##                      | graphPatternNotTriples DOT
##                      | filter DOT
##                      | graphPatternNotTriples triplesBlock
##                      | filter triplesBlocks
##                      | graphPatternNotTriples DOT triplesBlock
##                      | filter DOT triplesBlock'''
##    p[0] = p[2]
##     
##def p_triplesBlock(p):
##    '''triplesBlock : triplesSameSubject
##                    | triplesSameSubject DOT triplesBlocks'''
##    p[0] = p[2]
##
##def p_triplesBlocks(p):
##    '''triplesBlocks : triplesBlock
##                     | empty'''
##    p[0] = p[2]     
##
##def p_triplesSameSubject(p):
##    '''triplesSameSubject : VarOrTerm predicateObjectList
##                          | triplesNode propertyList'''
##    p[0] = p[2]
##
##def p_propertyListNotEmpty(p):
##    '''propertyListNotEmpty : verb objectList
##                          | triplesNode propertyList'''
##    p[0] = p[2]        

def p_iriRef(p):
    '''iriRef : LESSTHAN uri GREATERTHAN'''
    p[0] = ''.join(p[1:])


def p_uri(p):
    '''uri : NCNAME COLON NCNAME
           | NCNAME COLON SLASHSLASH NCNAME SLASH NCNAME
           | NCNAME SLASH NCNAME DOT NCNAME
           | NCNAME DOT NCNAME
           | NCNAME'''
    p[0] = ''.join(p[1:])


def p_sparqlvars(p):
    '''sparqlvars : VAR sparqlvars
                  | VAR'''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = p[2] + [ p[1] ]

#def p_formalReturnClause(p):
#    '''formalReturnClause : RETURN directConstructor'''
#    p[0] = ' '.join(p[1:])

def p_directConstructor(p):
    '''directConstructor : directElemConstructor '''
    p[0] = ' '.join(p[1:])    
    
def p_directElemConstructor(p):
    '''directElemConstructor : LESSTHAN qname attributProcessing'''
    p[0] = ' '.join(p[1:])

def p_attributProcessing(p):
    '''attributProcessing : directAttributeList SLASH GREATERTHAN
                          | directAttributeList GREATERTHAN directElemContentProcessing '''
    p[0] = ' '.join(p[1:])
    
def p_directElemContentProcessing(p):
    '''directElemContentProcessing : directElemContent LESSTHAN SLASH  qname GREATERTHAN '''
    p[0] = ' '.join(p[1:])
    
def p_directElemContent(p):
    '''directElemContent : directConstructor 
                         | enclosedExpr'''
    p[0] = ' '.join(p[1:])

def p_directAttributeList(p):
    '''directAttributeList : directAttribute directAttributeList
                           | empty'''
    p[0] = ' '.join(p[1:])
    
##def p_directAttributeLists(p):
##    '''directAttributeLists :  directAttributeList
##                            | empty'''    
##    p[0] = ' '.join(p[1:])
    
def p_directAttribute(p):
    '''directAttribute :  qname EQUALS directAttributeValue'''
    p[0] = ' '.join(p[1:])    

def p_directAttributeValue(p):
    '''directAttributeValue :  attributeValueContent '''
    p[0] = ' '.join(p[1:])   

def p_attributeValueContent(p):
    '''attributeValueContent : enclosedExpr
                             | QSTRING'''
    p[0] = ' '.join(p[1:])       

##def p_graphpattern(p):
##    '''graphpattern : LCURLY triples RCURLY'''
##    p[0] = p[2]


def p_solutionmodifier(p):
    '''solutionmodifier : ORDER BY VAR
                        | ORDER BY VAR limitoffsetclause
                        | empty'''
    p[0] = ' '.join(p[1:])

def p_limitoffsetclause(p):
    '''limitoffsetclause : limitclause
                         | offsetclause
                         | limitclause offsetclause
                         | offsetclause limitclause'''
    p[0] = ' '.join(p[1:])


def p_limitclause(p):
    '''limitclause : LIMIT INTEGER'''
    p[0] = ' '.join(p[1:])


def p_offsetclause(p):
    '''offsetclause : OFFSET INTEGER'''
    p[0] = ' '.join(p[1:])


##def p_triples_0(p):
##    '''triples : '''
##    p[0] = []

##def p_triples_1(p):
##    '''triples : triple
##               | triple DOT'''
##    p[0] = [ p[1] ]
##    
##def p_triples_2(p):
##    '''triples : triple DOT triples'''
##    p[0] = [ p[1] ] + p[3]
##
##
##def p_triple(p):
##    '''triple : term term term'''
##    p[0] = ( p[1], p[2], p[3] )


##def p_term(p):
##    '''term : VAR
##            | IRIREF
##            | literal
##            | qname'''
##    p[0] = p[1]
    

def p_forClause(p):
    '''forClause : FOR forVars'''
    p[0] = (p[1] + ' ' + p[2][0], p[2][1])


def p_forVars(p):
    '''forVars : forVars COMMA forVar'''
    p[0] = (p[1][0] + p[2]+ ' \n ' + p[3][0] , p[1][1] + [ p[3][1] ])

def p_forVars1(p):
    '''forVars : forVar'''
    p[0] = (p[1][0], [ p[1][1] ])


def p_forVar(p):
    '''forVar : VAR typeDeclaration positionVar IN exprSingle'''
    global variable
    if len(p[3]) == 0:
        p[0] = ( p[1] + ' at ' + p[1] + '_Pos' + ' '.join(p[2:]), p[1] + '_Pos' )
        variable.append(p[1] + '_Pos')
    else:
        p[0] = (' '.join(p[1:]), p[1] )
         

    

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
    global variable
    if len(p) == 3:
       variable.append(p[2]) 
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
                   | unorderedExpr
                   | directConstructor'''
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



def p_constructTemplate(p):
    '''constructTemplate : LCURLY statementsYesNo RCURLY'''
    #p[0] = ' '.join(p[1:])
    p[0] = p[2]

def p_statementsYesNo0(p):
    '''statementsYesNo : statements'''
    p[0] = p[1]

def p_statementsYesNo1(p):
    '''statementsYesNo : empty'''
    p[0] = []

def p_statements(p):
    '''statements : statement  statements
                  | statement  '''
    if len(p) == 2: p[0] = [ p[1] ]
    else:           p[0] = [ p[1] ] + p[2]


def p_statement(p):
    '''statement : lifttriples DOT'''
    p[0] = p[1] 

def p_lifttriples(p):
    '''lifttriples : subject predicateObjectList '''
    p[0] = (p[1], p[2])




def p_subject0(p):
    '''subject : resource'''
    p[0] = [ p[1] ]

def p_subject1(p):
    '''subject : blank
               | enclosedExpr'''
    p[0] = p[1]


def p_predicateObjectList(p):
    '''predicateObjectList : verbObjectLists semicolonYesNo'''
    p[0] = p[1]


def p_semicolonYesNo(p):
    '''semicolonYesNo : SEMICOLON
                      | empty'''
    p[0] = p[1]
    
def p_verbObjectLists(p):
    '''verbObjectLists : verb objectList verbObjectListses '''
    p[0] = [ ( p[1], p[2] ) ] + p[3]
    
    

def p_verbObjectListses(p):
    '''verbObjectListses : SEMICOLON verbObjectLists
                         | empty'''
    #p[0] = p[1]
    if len(p) == 2: p[0] = []
    else :          p[0] = p[2]
    

def p_objectList(p):
    '''objectList : object objectLists'''
    p[0] = [ p[1] ] + p[2]

def p_objectLists(p):
    '''objectLists : COMMA objectList
                   | empty'''
    if len(p) == 2: p[0] = []
    else:           p[0] = p[2]


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
                | VAR 
                | IRIREF'''
    p[0] = p[1]

def p_blank(p):
    '''blank : bnode
             | LBRACKET RBRACKET
             | LBRACKET predicateObjectList RBRACKET'''
    if len(p) == 2:   p[0] = [ p[1] ]
    elif len(p) == 3: p[0] = []
    else:             p[0] = p[2]


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
             | NCNAME qnames'''
    if len(p) == 2: p[0] = p[1]
    else:           p[0] = ''.join(p[1:])
   
def p_qnames(p):
    '''qnames : COLON NCNAME'''
    p[0] = ''.join(p[1:])



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
    output = rewrite(instring)
    print output
    outputfile = open('c:\Documents and Settings\wasakh\My Documents\SaxonB9\XSPARQL\examples\output.xquery', 'w')
    outputfile.write(output)
    outputfile.close()
    print reLexer(instring)
