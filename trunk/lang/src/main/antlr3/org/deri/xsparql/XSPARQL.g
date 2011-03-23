/**
 *
 * Copyright (C) 2011, NUI Galway.
 * All rights reserved.
 *
 * The software in this package is published under the terms of the BSD style license a copy of which has been included
 * with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
 * http://www.deri.ie/publications/tools/bsd_license.txt
 *
 * Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
 * NUI Galway.
 */
parser grammar XSPARQL;

options {
  output=AST;
  k=2;
}

tokens {

  // Lexer tokens
//  VAR;ENDELM;INTEGER;DECIMAL;LCURLY;RCURLY;NCNAME;QSTRING;DOT;AT;ASSIGN;CARET;CARETCARET;COLON;COMMA;SLASH; // including decimal produces an error
  VAR;ENDELM;INTEGER;LCURLY;RCURLY;NCNAME;QSTRING;DOT;AT;ASSIGN;CARET;CARETCARET;COLON;COMMA;SLASH;
  LBRACKET;RBRACKET;LPAR;RPAR;SEMICOLON;STAR;DOTDOT;SLASHSLASH;LESSTHAN;GREATERTHAN; PLUS;MINUS;
  UNIONSYMBOL;QUESTIONMARK;LESSTHANLESSTHAN;GREATERTHANEQUALS;LESSTHANEQUALS;HAFENEQUALS;EQUALS;
  COLONCOLON;  BLANK_NODE_LABEL;BNODE_CONSTRUCT;IRI_CONSTRUCT;ASK;DESCRIBE;SELECT;PNAME_NS;PNAME_LN;
  CDATASTART;CDATAELMEND;RCURLYGREATERTHAN;LESSTHANLCURLY;ORSYMBOL;ANDSYMBOL;NOT;WHITESPACE;IRIREF;
  NCNAMEELM;ENDTAG;A;IS;EQ;NE;LT;GE;LE;GT;FOR;FROM;LIMIT;OFFSET;LET;ORDER;BY;ATS;IN;AS;DESCENDING;
  ASCENDING;STABLE;IF;THEN;ELSE;RETURN;CONSTRUCT;WHERE;GREATEST;LEAST;COLLATION;CHILD;DESCENDANT;
  ATTRIBUTE;SELF;DESCENDANTORSELF;FOLLOWINGSIBLING;FOLLOWING;PARENT;ANCESTOR;PRECEDINGSIBLING;PRECEDING;
  ANCESTORORSELF;ORDERED;UNORDERED;DECLARE;NAMESPACE;DEFAULT;ELEMENT;FUNCTION;BASEURI;PREFIX;BASE;AND;OR;
  TO;DIV;IDIV;MOD;UNION;INTERSECT;EXCEPT;INSTANCE;TREAT;CASTABLE;CAST;OF;EMPTYSEQUENCE;ITEM;NODE;DOCUMENTNODE;
  TEXT;COMMENT;PROCESSINGINSTRUCTION;SCHEMAATTRIBUTE;SCHEMAELEMENT;DOCUMENT;NAMED;OPTIONAL;FILTER;STR;LANG;
  LANGMATCHES;DATATYPE;BOUND;ISIRI;ISURI;ISBLANK;ISLITERAL;REGEX;TRUE;FALSE;GRAPH;GREATERTHANGREATERTHAN;
  DISTINCT;GROUP;HAVING;

  // AST tokens
  T_NAMESPACE;
  T_XML_ELEMENT;
  T_XML_CONTENT;
  T_XML_ATTRIBUTE;
  T_FLWOR;
  T_FUNCTION_DECL;
  T_PARAMS;
  T_FORLET;
  T_WHERE;
  T_SPARQL_FOR;
  T_SPARQL_WHERE;
  T_FOR;
  T_LET;
  T_CONSTRUCT;
  T_ORDER;
  T_RETURN;
  T_UNION;

  T_BLANK;
  T_ANON_BLANK;
  T_EMPTY_ANON_BLANK;

  T_SUBJECT;
  T_VERB;
  T_OBJECT;
  T_MAIN;
  T_PAR;

  T_INSTANCEOF;
  T_TYPE;
  T_CASTAS;
  T_CASTABLEAS;
  T_TREATAS;

  T_VARIABLE_DECL;
  T_EXTERNAL_VARIABLE_DECL;
  T_OPTION_DECL;
  T_FUNCTION_CALL;
  T_PARAM;

  T_ORDER_BY;
  T_STABLE_ORDER_BY;

  T_GROUP_BY;
  T_HAVING;

  // XQuery keywords
  BOUNDARYSPACE;
  STRIP;
  VARIABLE;
  IMPORT;
  EXTERNAL;
  NOPRESERVE;
  PRESERVE;
  CONSTRUCTION;
  MODULE;
  INHERIT;
  NOINHERIT;
  SCHEMA;
  EMPTY;
  ORDERING;
  COPYNAMESPACES;
  XQUERY;
  VERSION;
  ENCODING;
  OPTION;
  LAX;
  CASE;
  EVERY;
  TYPESWITCH;
  SATISFIES;
  VALIDATE;
  SOME;
  STRICT;

  // SPARQL keywords
  ASC;
  DESC;

  T_MODULE_DECL;
  T_VERSION;
  T_BOUNDARYSPACE_DECL;
  T_DEFAULT_DECL;
  T_ORDER_DECL;
  T_EMPTY_ORDER_DECL;
  T_DEFAULT_COLLATION_DECL;
  T_BASEURI_DECL;
  T_MODULE_IMPORT;
  T_SCHEMA_IMPORT;

  T_QUERY_BODY;
  T_BODY_PART;

  XPATH;

  T_LITERAL_CONSTRUCT;
  T_IRI_CONSTRUCT;

  T_EPILOGUE;
}

@header {
  package org.deri.xsparql;

  import java.util.Collection;
  import java.util.ArrayList;
  import java.util.Set;
  import java.util.HashSet;
}


@members {

  public static boolean graphoutput = false;

  public static boolean sparqlnamespaces = false;

  /**
  * Prints current method name preceeded by a number of spaces dependant on the depth of the parse tree.
  * Doesn't do anything if not in debug mode
  * If used by all parser methods the result output is the parse tree.
  */
  private void trace() {
    if(Configuration.debug()) {
      StackTraceElement[] stack = Thread.currentThread().getStackTrace();
      StringBuffer sb = new StringBuffer();

      // add a number of spaces dependant on the current depth of the parse tree
      for(int i = 0; i < stack.length; i ++) {
        sb.append(' ');
      }

      sb.append(stack[2].getMethodName());
      // stack[1].getMethodName() would be "trace"

      sb.append(" - ");
      sb.append(getCurrentInputSymbol(input));
      System.out.println(sb);
    }

  }

  private Set<String> wherevariables = new HashSet<String>();
  private boolean inwhere = false;



  /**
  * Returs a tree from a stringSet
  */
  private CommonTree createTree(Set<String> s) {
    org.antlr.runtime.tree.CommonTree ret = new org.antlr.runtime.tree.CommonTree();
    
    for(String st : s) {
      ret.addChild(new CommonTree(new CommonToken(VAR, st)));
    }

    return ret;
  }

}


/* ------------------------------------------------------------------------- */
/* XQuery                                                                    */
/* ------------------------------------------------------------------------- */


// $<XQuery

/* XQuery [1] */
module
@init {trace();}
  :  versionDecl? (libraryModule | mainModule);

/* XQuery [2] */
versionDecl
@init {trace();}
  :  XQUERY VERSION v=stringliteral (ENCODING e=stringliteral)? separator
  -> ^(T_VERSION $v ^(ENCODING $e?))
  ;

/* XQuery [3] */
mainModule
@init {trace();}
  : { graphoutput=false; } prolog queryBody
  -> ^(T_MAIN prolog? queryBody) // if you don't make prolog optional you could get a org.antlr.runtime.tree.RewriteEmptyStreamException during runtime
  ;

/* XQuery [4] */
libraryModule
@init {trace();}
  :  moduleDecl prolog;

/* XQuery [5] */
moduleDecl
@init {trace();}
  :  MODULE NAMESPACE NCNAME EQUALS uriliteral separator
  -> ^(T_MODULE_DECL NCNAME uriliteral)
  ;

/* XQuery [6] */
prolog
@init {trace();}
  :  baseDecl?
     ( ( ( (DECLARE DEFAULT (ELEMENT | FUNCTION))=> defaultNamespaceDecl
         | namespaceDecl
         | setter
         | importa
         ) separator!
       )
       | prefixDecl
     )*
     ( ( varDecl
       | functionDecl
       | optionDecl
       ) separator!
     )*
  ;

/* XQuery [7] */
setter
options {
k=3; // DECLARE DEFAULT is ambiguous
}
@init {trace();}
  : boundarySpaceDecl
  | defaultCollationDecl
  | baseURIDecl
  | constructionDecl
  | orderingModeDecl
  | emptyOrderDecl
  | copyNamespacesDecl
  ;

/* XQuery [8] */
// renamed because of ANTLR keyword clash
importa
@init {trace();}
  : schemaImport | moduleImport
  ;

/* XQuery [9] */
separator
@init {trace();}
  :  SEMICOLON;

/* XQuery [10] */
namespaceDecl
@init {trace();}
  : DECLARE NAMESPACE NCNAME EQUALS QSTRING
  -> ^(T_NAMESPACE NCNAME QSTRING)
  ;

/* XQuery [11] */
boundarySpaceDecl
@init {trace();}
  : DECLARE BOUNDARYSPACE (x=PRESERVE | x=STRIP)
  -> ^(T_BOUNDARYSPACE_DECL $x)
  ;

/* XQuery [12] */
defaultNamespaceDecl
@init {trace();}
  : DECLARE DEFAULT (x=ELEMENT | x=FUNCTION) NAMESPACE QSTRING
  -> ^(T_DEFAULT_DECL $x NAMESPACE QSTRING)
  ;

/* XQuery [13] */
optionDecl
@init {trace();}
  : DECLARE OPTION qname stringliteral
  -> ^(T_OPTION_DECL qname stringliteral)
  ;

/* XQuery [14] */
orderingModeDecl
@init {trace();}
  : DECLARE ORDERING (x=ORDERED | x=UNORDERED)
  -> ^(T_ORDER_DECL $x)
  ;

/* XQuery [15] */
emptyOrderDecl
@init {trace();}
  : DECLARE DEFAULT ORDER EMPTY (x=GREATEST | x=LEAST )
  -> ^(T_EMPTY_ORDER_DECL $x)
  ;

/* XQuery [16] */
copyNamespacesDecl
@init {trace();}
  : DECLARE! COPYNAMESPACES^ preserveMode COMMA! inheritMode
  ;

/* XQuery [17] */
preserveMode
@init {trace();}
  : PRESERVE | NOPRESERVE
  ;

/* XQuery [18] */
inheritMode
@init {trace();}
  : INHERIT | NOINHERIT
  ;

/* XQuery [19] */
defaultCollationDecl
@init {trace();}
  : DECLARE DEFAULT COLLATION uriliteral
  -> ^(T_DEFAULT_COLLATION_DECL uriliteral)
  ;

/* XQuery [20] */
baseURIDecl
@init {trace();}
  : DECLARE BASEURI QSTRING
  -> ^(T_BASEURI_DECL QSTRING)
  ;

/* XQuery [21] */
schemaImport
@init {trace();}
  : IMPORT SCHEMA schemaPrefix? n=uriliteral (AT at+=uriliteral (COMMA at+=uriliteral)*)?
  -> ^(T_SCHEMA_IMPORT ^(SCHEMA schemaPrefix?) $n ^(AT $at*))
  ;

/* XQuery [22] */
schemaPrefix
@init {trace();}
  : NAMESPACE! NCNAME EQUALS!
  | DEFAULT ELEMENT! NAMESPACE!
  ;

/* XQuery [23] */
moduleImport
@init {trace();}
  : IMPORT MODULE (NAMESPACE NCNAME EQUALS)? n=uriliteral (AT x+=uriliteral (COMMA x+=uriliteral)*)?
  -> ^(T_MODULE_IMPORT ^(NAMESPACE NCNAME?) $n ^(AT $x*))
  ;

/* XQuery [24] */
varDecl
@init {trace();}
  : DECLARE VARIABLE VAR typeDeclaration?
  ( ASSIGN exprSingle -> ^(T_VARIABLE_DECL          VAR ^(T_TYPE typeDeclaration?) exprSingle)
  | EXTERNAL          -> ^(T_EXTERNAL_VARIABLE_DECL VAR ^(T_TYPE typeDeclaration?)           )
  )
  ;

/* XQuery [25] */
constructionDecl
@init {trace();}
  : DECLARE CONSTRUCTION (STRIP | PRESERVE)
  ;

/* XQuery [26] */
functionDecl
@init {trace();}
  : d=DECLARE FUNCTION qname LPAR paramList? RPAR (AS sequenceType)? (enclosedExpr | EXTERNAL)
  -> ^(T_FUNCTION_DECL[$d, "FUNCTION_DECL"] qname ^(T_PARAMS paramList?) ^(AS sequenceType)? enclosedExpr?)
  ;

/* XQuery [27] */
paramList
@init {trace();}
  : param (COMMA! param)*
  ;

/* XQuery [28] */
param
@init {trace();}
  : VAR typeDeclaration?
  -> ^(T_PARAM VAR ^(T_TYPE typeDeclaration?))
  ;

/* XQuery [29] */
enclosedExpr
@init {trace();}
  : LCURLY! expr RCURLY!
  ;

enclosedExpr_
@init {trace();}
  : LCURLY expr RCURLY
  ;

/* XQuery [30] */
//queryBody  :  expr;
queryBody
@init{trace();}
  : exprSingle (COMMA exprSingle)*
  -> ^(T_QUERY_BODY ^(T_BODY_PART exprSingle)+ T_EPILOGUE)
  ;

/* XQuery [31] */
expr
@init {trace();}
  : exprSingle (COMMA! exprSingle)*;

/* XQuery [32] */
exprSingle
@init{trace();}
  : flworExpr
  | quantifiedExpr
  | typeSwitchExpr
  | constructQuery // INSERT NONSTANDARD
  | orExpr
  | ifExpr
  ;

/* XQuery [33] */
//flworExpr
//  : forletClause+ whereClause? orderByClause? (c=CONSTRUCT constructTemplate {sparqlnamespaces = true; graphoutput=true;} |  r=RETURN exprSingle )
//  -> ^(T_FLWOR forletClause*
//          ^(T_WHERE whereClause)?
//          ^(T_ORDER orderByClause)?
//          ^(T_CONSTRUCT[$c] constructTemplate)?
//          ^(T_RETURN[$r] exprSingle)?
//      )
//  ;

flworExpr
@init {trace();}
  : forletClause (
        whereClause? orderByClause? (c=CONSTRUCT constructTemplate {sparqlnamespaces = true; graphoutput=true;} |  r=RETURN exprSingle )
        -> ^(T_FLWOR forletClause
                ^(T_WHERE whereClause)?
                ^(T_ORDER orderByClause)?
                ^(T_CONSTRUCT[$c] constructTemplate)?
                ^(T_RETURN[$r] exprSingle)?
            )
      | flworExpr // introduce right associative simple flwor expressions
        -> ^(T_FLWOR forletClause ^(T_RETURN flworExpr))
      )
  ;

// plug sparql for clause in
forletClause
@init {trace();}
  : FOR! ( forClause  | sparqlForClause )
  | letClause
  ;

/* XSPARQL [33b] */
sparqlForClause
@init {trace(); wherevariables = new HashSet<String>();}
  :  DISTINCT? varOrFunction+ datasetClause* sWhereClause solutionmodifier { sparqlnamespaces = true; }
  -> ^(T_SPARQL_FOR DISTINCT? varOrFunction+)  datasetClause* sWhereClause solutionmodifier?
  |  DISTINCT? STAR datasetClause* sWhereClause solutionmodifier { sparqlnamespaces = true; }
  -> ^(T_SPARQL_FOR DISTINCT? {createTree(wherevariables)}) datasetClause* sWhereClause solutionmodifier?
  ;

varOrFunction
  : VAR
  | LPAR functionCall AS VAR RPAR
;


/* XQuery [34] */
forClause
@init {trace();}
  :  {trace();}
  singleForClause (COMMA! singleForClause)*
  ;
// singleForClause extracted for simpler AST generation

singleForClause
@init {trace();}
  :  VAR typeDeclaration? positionalVar? IN exprSingle
  -> ^(T_FOR VAR ^(T_TYPE typeDeclaration)?  ^(AT positionalVar)? ^(IN exprSingle))
  ;

/* XQuery [35] */
positionalVar
@init {trace();}
  : AT! VAR;

/* XQuery [36] */
letClause
@init {trace();}
  : LET! singleLetClause (COMMA! singleLetClause)*;
// singleLetClause extracted for simpler AST generation

singleLetClause
@init {trace();}
  :  {trace();} VAR typeDeclaration? ASSIGN exprSingle
  -> ^(T_LET ^(VAR typeDeclaration?) exprSingle)
  ;

/* XQuery [37] */
whereClause
@init {trace();}
  : WHERE^ exprSingle
  ;

/* XQuery [38] */
orderByClause
@init {trace();}
  : o=ORDER BY orderSpecList -> ^(T_ORDER_BY[$o] orderSpecList)
  | o=STABLE ORDER BY orderSpecList -> ^(T_STABLE_ORDER_BY[$o] orderSpecList)
  ;

/* XQuery [39] */
orderSpecList
@init {trace();}
  : orderSpec (COMMA orderSpec)*
  ;

/* XQuery [40] */
orderSpec
@init {trace();}
  :  exprSingle orderModifier
  ;

/* XQuery [41] */
orderModifier
@init {trace();}
  : (ASCENDING | DESCENDING)? (EMPTY (GREATEST | LEAST))? (COLLATION uriliteral)?
  ;

/* XQuery [42] */
quantifiedExpr
@init {trace();}
  : (SOME^ | EVERY^) VAR typeDeclaration? IN exprSingle
  (COMMA! VAR typeDeclaration? IN exprSingle)* SATISFIES exprSingle
  ;

/* XQuery [43] */
typeSwitchExpr
@init {trace();}
  : TYPESWITCH^ LPAR! expr RPAR! caseClause+ DEFAULT! VAR? RETURN! exprSingle;

/* XQuery [44] */
caseClause
@init {trace();}
  : CASE (VAR AS)? sequenceType RETURN exprSingle;

/* XQuery [45] */
ifExpr
@init {trace();}
  : IF^ LPAR! expr RPAR! THEN! exprSingle ELSE! exprSingle
  ;

/* XQuery [46] */
orExpr
@init {trace();}
  : andExpr (OR^ andExpr)*;

/* XQuery [47] */
andExpr
@init {trace();}
  : (comparisonExpr -> comparisonExpr)
  (AND comparisonExpr -> ^(AND $andExpr comparisonExpr)
  )*
  ;

/* XQuery [48] */
comparisonExpr
@init {trace();}
  :   {trace();} rangeExpr (
             ( valueComp^
             | generalComp^
             | nodeComp^
             )
          rangeExpr)?;

/* XQuery [49] */
rangeExpr
@init {trace();}
  : (additiveExpr -> additiveExpr)
  (TO additiveExpr -> ^(TO $rangeExpr additiveExpr)
  )?
  ;

/* XQuery [50] */
additiveExpr
@init {trace();}
  : (multiplicativeExpr -> multiplicativeExpr)
  ( (op=PLUS | op=MINUS) multiplicativeExpr -> ^($op $additiveExpr multiplicativeExpr)
  )*;

/* XQuery [51] */
multiplicativeExpr
@init {trace();}
  : (unionExpr -> unionExpr)
  ((op=STAR | op=DIV | op=IDIV | op=MOD) unionExpr
   -> ^($op $multiplicativeExpr unionExpr)
  )*
  ;

/* XQuery [52] */
unionExpr
@init {trace();}
  : (intersectExceptExpr -> intersectExceptExpr)
  ( (op=UNION | op=UNIONSYMBOL) intersectExceptExpr
   -> ^($op $unionExpr intersectExceptExpr)
  )*
  ;

/* XQuery [53] */
intersectExceptExpr
@init {trace();}
  : (instanceOfExpr -> instanceOfExpr)
  ((op=INTERSECT | op=EXCEPT) instanceOfExpr
   -> ^($op $intersectExceptExpr instanceOfExpr)
  )*;

/* XQuery [54] */
instanceOfExpr
@init {trace();}
  : (treatExpr -> treatExpr)
  (INSTANCE OF sequenceType -> ^(T_INSTANCEOF $instanceOfExpr sequenceType)
  )?;

/* XQuery [55] */
treatExpr
@init {trace();}
  : (castableExpr -> castableExpr)
  (TREAT AS sequenceType -> ^(T_TREATAS $treatExpr sequenceType)
  )?;

/* XQuery [56] */
castableExpr
@init {trace();}
  : (castExpr -> castExpr)
  (CASTABLE AS singleType -> ^(T_CASTABLEAS $castableExpr singleType)
  )?;

/* XQuery [57] */
castExpr
@init {trace();}
  : (unaryExpr -> unaryExpr)
  (CAST AS singleType -> ^(T_CASTAS $castExpr singleType)
  )?;

/* XQuery [58] */
unaryExpr
@init {trace();}
  : (MINUS | PLUS)* valueExpr;

/* XQuery [59] */
valueExpr
@init {trace();}
  : pathExpr
  | validateExpr
  | extensionExpr
  ;

/* XQuery [60] */
generalComp
@init {trace();}
  :
   EQUALS
  | LESSTHAN
  | GREATERTHAN
  | LESSTHANEQUALS
  | GREATERTHANEQUALS
  | HAFENEQUALS
  ;

/* XQuery [61] */
valueComp
@init {trace();}
  :
  ( EQ
  | NE
  | LT
  | LE
  | GT
  | GE
  );

/* XQuery [62] */
nodeComp
@init {trace();}
  :
  ( LESSTHANLESSTHAN
  | GREATERTHANGREATERTHAN
  | IS
  );

/* XQuery [63] */
validateExpr
@init {trace();}
  : VALIDATE validationMode? LCURLY! expr RCURLY!;

/* XQuery [64] */
validationMode
@init {trace();}
  : (LAX | STRICT);

/* XQuery [65] */
extensionExpr
@init {trace();}
  : //pragma?
  LCURLY! expr? RCURLY!;

/* XQuery [66] */
//pragma : '(#' WHITESPACE  qname (WHITESPACE pragmaContents)? '#)';

/* XQuery [67] */
//pragmaContents : (char* - (char* '#)' char*));

/* XQuery [68] */
pathExpr
@init {trace();}
  : (SLASH SLASH)=> s1=SLASH s2=SLASH relativePathExpr -> ^(XPATH $s1 $s2 relativePathExpr)
  | (SLASH relativePathExpr)=> s3=SLASH relativePathExpr -> ^(XPATH $s3 relativePathExpr)
  | s4=SLASH -> ^(XPATH $s4)
  | relativePathExpr -> ^(XPATH relativePathExpr)
  ;

/* XQuery [69] */
relativePathExpr
@init {trace();}
  : stepExpr (SLASH SLASH? stepExpr)*
  ;

/* XQuery [70] */
stepExpr
@init {trace();}
  : filterExpr
  | axisStep
  ;

/* XQuery [71] */
axisStep
@init {trace();}
  : (reverseStep | forwardStep) predicateList
  ;

/* XQuery [72] */
forwardStep
@init {trace();}
  : forwardAxis nodeTest
  | abbrevForwardStep;

/* XQuery [73] */
forwardAxis
@init {trace();}
  : CHILD COLONCOLON
  | DESCENDANT COLONCOLON
  | ATTRIBUTE COLONCOLON
  | SELF COLONCOLON
  | DESCENDANTORSELF COLONCOLON
  | FOLLOWINGSIBLING COLONCOLON
  | FOLLOWING COLONCOLON;

/* XQuery [74] */
abbrevForwardStep
@init {trace();}
  : AT? nodeTest;

/* XQuery [75] */
reverseStep
@init {trace();}
  : reverseAxis nodeTest
  | abbrevReverseStep;

/* XQuery [76] */
reverseAxis
@init {trace();}
  : PARENT COLONCOLON
  | ANCESTOR COLONCOLON
  | PRECEDINGSIBLING COLONCOLON
  | PRECEDING COLONCOLON
  | ANCESTORORSELF COLONCOLON;

/* XQuery [77] */
abbrevReverseStep
@init {trace();}
  : DOTDOT;

/* XQuery [78] */
nodeTest
@init {trace();}
  : kindTest
  | nameTest
  ;

/* XQuery [79] */
nameTest
@init {trace();}
  : qname
  | wildCard
  ;

/* XQuery [80] */
wildCard
@init {trace();}
  : STAR
  | STAR COLON NCNAME
  | NCNAME COLON STAR
  ;

/* XQuery [81] */
filterExpr
@init {trace();}
  : primaryExpr predicateList;

/* XQuery [82] */
predicateList
@init {trace();}
  : predicate*;

/* XQuery [83] */
predicate
@init {trace();}
  : LBRACKET expr RBRACKET;

/* XQuery [84] */
primaryExpr
@init {trace();}
  : varRef
  | literal
  | parenthesizedExpr
  | contextItemExpr
  | functionCall
  | orderedExpr
  | unorderedExpr
  | constructor;

/* XQuery [85] */
literal
@init {trace();}
  : numericliteral
  | stringliteral;

/* XQuery [86] */
numericliteral
@init {trace();}
  : integerLiteral
  | decimalLiteral
  //|doubleLiteral // TODO
  ;

/* XQuery [87] */
varRef
@init {trace();}
  : VAR;

/* XQuery [88] */
varName
@init {trace();}
  : qname;

/* XQuery [89] */
parenthesizedExpr
@init {trace();}
  : LPAR expr? RPAR -> ^(T_PAR expr?)
  ;

/* XQuery [90] */
contextItemExpr
@init {trace();}
  : DOT;

/* XQuery [91] */
orderedExpr
@init {trace();}
  : ORDERED LCURLY! expr RCURLY!;

/* XQuery [92] */
unorderedExpr
@init {trace();}
  : UNORDERED LCURLY! expr RCURLY!;

/* XQuery [93] */
functionCall
@init {trace();}
  : qname LPAR (exprSingle (COMMA exprSingle)*)? RPAR
  -> ^(T_FUNCTION_CALL qname ^(T_PARAMS exprSingle*))
  ;

/* XQuery [94] */
constructor
@init {trace();}
  : directConstructor
  | computedConstructor
  ;

/* XQuery [95] */
directConstructor
@init {trace();}
  : dirElemConstructor
//  | dirCommentConstructor
//  | dirPIConstructor
  ;

/* XQuery [96] */
dirElemConstructor
@init {trace();}
  :    {trace();} LESSTHAN qname dirAttributeList (ENDTAG| (GREATERTHAN dirElemContent* ENDELM qname WHITESPACE? GREATERTHAN))
  -> ^(T_XML_ELEMENT qname dirAttributeList? ^(T_XML_CONTENT dirElemContent)*)
  ;

/* XQuery [97] */
dirAttributeList
@init {trace();}
  :  (WHITESPACE! dirAttribute?)* ;

dirAttribute
@init {trace();}
  : qname WHITESPACE? EQUALS WHITESPACE? dirAttributeValue
  -> ^(T_XML_ATTRIBUTE qname dirAttributeValue)
  ;

/* XQuery [98] */
dirAttributeValue
@init {trace();}
  : enclosedExpr  // INSERT NONSTANDARD
  | QSTRING
  //TODO add different string formats
  ;

/* XQuery [99] */
//TODO

/* XQuery [100] */
//TODO

/* XQuery [101] */
dirElemContent
@init {trace();}
  : directConstructor
  | commonContent
  | WHITESPACE //
  | NCNAMEELM //
  | cDataSection
  //|elementContentChar
  ;

/* XQuery [102] */
commonContent
@init {trace();}
  : (enclosedExpr_)=> enclosedExpr_
  //| predefinedEntityRef // not used
  //| charRef // not used
  | LCURLY LCURLY
  | RCURLY RCURLY
  ;

/* XQuery [103] */
//dirCommentConstructor // not used

/* XQuery [104] */
//dirCommentContents // not used

/* XQuery [105] */
//dirPIConstructor // not used

/* XQuery [106] */
//dirPIContents // not used

/* XQuery [107] */
cDataSection
@init {trace();}
  : CDATASTART CDATAELMEND;

/* XQuery [108] */
//cDataSectionContents: ... // not used

/* XQuery [109] */
computedConstructor
@init {trace();}
  : compDocConstructor
  | compElemConstructor
  | compAttrConstructor
  | compTextConstructor
  | compCommentConstructor
  | compPIConstructor
  ;

/* XQuery [110] */
compDocConstructor
@init {trace();}
  : DOCUMENT enclosedExpr
  ;

/* XQuery [111] */
compElemConstructor
@init {trace();}
  : ELEMENT ( qname | enclosedExpr_) LCURLY contentExpr? RCURLY
  ;

/* XQuery [112] */
contentExpr
@init {trace();}
  : expr;

/* XQuery [113] */
compAttrConstructor
@init {trace();}
  : ATTRIBUTE (qname | enclosedExpr) LCURLY expr? RCURLY
  ;

/* XQuery [114] */
compTextConstructor
@init {trace();}
  : TEXT enclosedExpr_;

/* XQuery [115] */
compCommentConstructor
@init {trace();}
  : COMMENT enclosedExpr;

/* XQuery [116] */
compPIConstructor
  : PROCESSINGINSTRUCTION ( NCNAME | enclosedExpr) LCURLY expr? RCURLY
  ;

/* XQuery [117] */
singleType
@init {trace();}
  : atomicType QUESTIONMARK?
  ;

/* XQuery [118] */
typeDeclaration
@init {trace();}
  : AS! sequenceType;

/* XQuery [119] */
sequenceType
@init {trace();}
  : EMPTYSEQUENCE LPAR RPAR
  | itemType occurrenceIndicator?;

/* XQuery [120] */
occurrenceIndicator
@init {trace();}
  : kindTest | ITEM LPAR RPAR | atomicType;

/* XQuery [121] */
itemType
@init {trace();}
  : ITEM LPAR RPAR
  | atomicType
  | kindTest;

/* XQuery [122] */
atomicType
@init {trace();}
  : qname;

/* XQuery [123] */
kindTest
@init {trace();}
  : documentTest
  | elementTest
  | attributeTest
  | schemaElementTest
  | schemaAttributeTest
  | piTest
  | commentTest
  | textTest
  | anyKindTest;

/* XQuery [124] */
anyKindTest
@init {trace();}
  : NODE LPAR RPAR;

/* XQuery [125] */
documentTest
@init {trace();}
  : DOCUMENTNODE LPAR (elementTest | schemaElementTest)? RPAR;

/* XQuery [126] */
textTest
@init {trace();}
  : TEXT LPAR RPAR;

/* XQuery [127] */
commentTest
@init {trace();}
  : COMMENT LPAR RPAR;

/* XQuery [128] */
piTest
@init {trace();}
  : PROCESSINGINSTRUCTION LPAR (NCNAME | stringliteral)? RPAR;

/* XQuery [129] */
attributeTest
@init {trace();}
  : ATTRIBUTE LPAR (attributeNameOrWildcard (COMMA typeName)?)? RPAR;

/* XQuery [130] */
attributeNameOrWildcard
@init {trace();}
  : attributeName | STAR;

/* XQuery [131] */
schemaAttributeTest
@init {trace();}
  : SCHEMAATTRIBUTE LPAR attributeDeclaration RPAR;

/* XQuery [132] */
attributeDeclaration
@init {trace();}
  : attributeName;

/* XQuery [133] */
elementTest
@init {trace();}
  : ELEMENT LPAR (elementNameOrWildcard (COMMA typeName QUESTIONMARK?)?)? RPAR;

/* XQuery [134] */
elementNameOrWildcard
@init {trace();}
  : elementName | STAR;

/* XQuery [135] */
schemaElementTest
@init {trace();}
  : SCHEMAELEMENT LPAR elementDeclaration RPAR;

/* XQuery [136] */
elementDeclaration
@init {trace();}
  : elementName;

/* XQuery [137] */
attributeName
@init {trace();}
  : qname;

/* XQuery [138] */
elementName
@init {trace();}
  : qname;

/* XQuery [139] */
typeName
@init {trace();}
  : qname;

/* XQuery [140] */
uriliteral
@init {trace();}
  : stringliteral;

/* TERMINALS */

/* XQuery [141] */
integerLiteral
@init {trace();}
  :  INTEGER;

/* XQuery [142] */
//decimalLiteral  : (DOT digits | digits DOT digits?)
decimalLiteral  : DECIMAL;

/* XQuery [143] */
//doubleLiteral  : (DOT digits | digits (DOT digits?)?) [eE] (PLUS|MINUS)? digits

/* XQuery [144] */
stringliteral
@init {trace();}
  : QSTRING;

/* XQuery [151] */
//XQuery comments are not allowed in XSPARQL

// $>






/* ------------------------------------------------------------------------- */
/* SPARQL                                                                    */
/* ------------------------------------------------------------------------- */

// $<SPARQL

/* SPARQL [1] */
// root SPARQL rule -> not needed in XSPARQL

/* SPARQL [2] */
// STANDARD: move to XQuery prolog
//prologue : baseDecl? prefixDecl*;

/* SPARQL [3] */
baseDecl
@init {trace();}
  : BASE IRIREF -> ^(T_NAMESPACE DEFAULT IRIREF); // TODO not default, base

/* SPARQL [4] */
prefixDecl
@init {trace();}
  : PREFIX p=PNAME_NS i=IRIREF
  -> {$p.text.equals(":")}? ^(T_NAMESPACE DEFAULT QSTRING[$i])
  -> ^(T_NAMESPACE PNAME_NS[$p,$p.text.replace(':',' ').trim()] QSTRING[$i])
  ;

/* SPARQL [5] */
// Select is not supported in XSPARQL
//selectQuery : ...

/* SPARQL [6] */
constructQuery
@init {trace(); wherevariables = new HashSet<String>();}
  : c=CONSTRUCT constructTemplate datasetClause* sWhereClause solutionmodifier
  {graphoutput = true;sparqlnamespaces=true;}
  -> ^(T_FLWOR[$c] ^(T_SPARQL_FOR[$c] {createTree(wherevariables)}) datasetClause* sWhereClause solutionmodifier? ^(T_CONSTRUCT[$c] constructTemplate))
  ;

/* SPARQL [7] */
// Describe is not supported in XSPARQL
//describeQuery : ...

/* SPARQL [8] */
// Ask is not supported in XSPARQL
//askQuery : ...

/* SPARQL [9] */
datasetClause
@init {trace();}
  : FROM^ (defaultGraphClause | namedGraphClause )
  ;

/* SPARQL [10] */
defaultGraphClause
@init {trace();}
  : sourceSelector
  ;

/* SPARQL [11] */
namedGraphClause
@init {trace();}
  : NAMED sourceSelector
  ;

/* SPARQL [12] */
sourceSelector
@init {trace();}
  : IRIREF | VAR
  ;

/* SPARQL [13] */
// name clash with XQuery whereClause
sWhereClause
@init {trace(); inwhere=true;}
@after { inwhere=false; }
  : w=WHERE/*?*/ groupGraphPattern // NONSTANDARD: WHERE keyword is mandatory here
  -> ^(T_SPARQL_WHERE[$w] groupGraphPattern)
  ;

/* SPARQL [14] */
solutionmodifier
@init {trace();}
  : // ORIGINAL: orderclause? limitoffsetclause?
    (ORDER BY VAR) => orderclause limitoffsetclauses?
  | groupBy? having? limitoffsetclauses?
  ;

groupBy 
  : GROUP BY VAR -> ^(T_GROUP_BY VAR)
  ;

having
  : HAVING LPAR exprSingle RPAR -> ^(T_HAVING exprSingle)
  ;

/* SPARQL [15] */
limitoffsetclauses
@init {trace();}
  : limitclause offsetclause?
  | offsetclause limitclause?
  ;

/* SPARQL [16] */
orderclause
@init {trace();}
  : ORDER^ BY! orderCondition
  ;

/* SPARQL [17] */
orderCondition
@init {trace();}
  : (ASC | DESC) brackettedExpression
  | constraint
  | VAR
  ;

/* SPARQL [18] */
limitclause
@init {trace();}
  : LIMIT^ INTEGER
  ;

/* SPARQL [19] */
offsetclause
@init {trace();}
  : OFFSET^ INTEGER
  ;

/* SPARQL [20] */
groupGraphPattern
@init {trace();}
  : LCURLY! triplesBlock? ((graphPatternNotTriples | filter) DOT!? triplesBlock?)* RCURLY!
  ;

/* SPARQL [21] */
triplesBlock
@init {trace();}
  : triplesSameSubject (DOT! triplesBlock?)?
  ;

/* SPARQL [22] */
graphPatternNotTriples
@init {trace();}
  : optionalGraphPattern
  | groupOrUnionGraphPattern
  | graphGraphPattern
  ;

/* SPARQL [23] */
optionalGraphPattern
@init {trace();}
  : OPTIONAL^ groupGraphPattern
  ;

/* SPARQL [24] */
graphGraphPattern
@init {trace();}
  : GRAPH^ varOrIRIref groupGraphPattern
  ;

/* SPARQL [25] */
groupOrUnionGraphPattern
@init {trace();}
  : (groupGraphPattern -> groupGraphPattern) 
    ((UNION groupGraphPattern)+ -> ^(UNION ^(T_UNION $groupOrUnionGraphPattern) ^(T_UNION groupGraphPattern)+))? 
  ;

/* SPARQL [26] */
filter
@init {trace();}
  : FILTER^ constraint
  ;

/* SPARQL [27] */
constraint
@init {trace();}
  : brackettedExpression
  | builtInCall
  | sFunctionCall
  ;

/* SPARQL [28] */
sFunctionCall
@init {trace();}
  : iRIref arglist
  ;

/* SPARQL [29] */
arglist
@init {trace();}
  : LPAR! (expression (COMMA! expression)*)? RPAR!
  ;

/* SPARQL [30] */
constructTemplate
@init {trace();}
  : LCURLY! constructTriples? RCURLY!
  ;

/* SPARQL [31] */
constructTriples
@init {trace();}
  : (triplesSameSubject_) => triplesSameSubject_ (DOT! constructTriples?)?
  | enclosedExpr (DOT! constructTriples)?
  ;

/* SPARQL [32] */
//triplesSameSubject  : varOrTerm propertyListNotEmpty | triplesNode propertyList;

triplesSameSubject @init {trace();}
  : subject propertyListNotEmpty
  -> ^(T_SUBJECT subject propertyListNotEmpty)
  | triplesNode propertyListNotEmpty?
  -> ^(T_SUBJECT triplesNode propertyListNotEmpty?)
  ;

triplesSameSubject_ @init {trace();}
  : subject_ propertyListNotEmpty_
  -> ^(T_SUBJECT subject_ propertyListNotEmpty_)
  | triplesNode_ propertyListNotEmpty_? // inline propertyList because of EmptyRewriteException
  -> ^(T_SUBJECT triplesNode_ propertyListNotEmpty_?)
  ;

/* SPARQL [33] */
propertyListNotEmpty @init {trace();}
  : verb objectList (SEMICOLON (verb objectList)? )*
  -> ^(T_VERB verb objectList)+
  ;

propertyListNotEmpty_ @init {trace();}
  : verb_ objectList_ (SEMICOLON (verb_ objectList_)?)*
  -> ^(T_VERB verb_ objectList_)+
  ;

// /* SPARQL [34] */
// propertyList @init {trace();}
//   : propertyListNotEmpty?
//   ;

// propertyList_ @init {trace();}
//   : propertyListNotEmpty_?
//   ;

/* SPARQL [35] */
objectList @init {trace();}
  : object (COMMA object)*
  -> ^(T_OBJECT object)+
  ;

objectList_ @init {trace();}
  : object_ (COMMA object_)*
  -> ^(T_OBJECT object_)+
  ;

/* SPARQL [36] */
//object  : graphNode;

object @init {trace();}
  : resource
  | blank
  | rdfLiteral
  | sNumericLiteral
  | triplesNode
//  graphNode
  ;

// iriConstruct and literalConstruct start with enclosedExpr
// rdfliteral and literalConstruct start with qstring (CARET|AT)
object_ @init{trace();}
  : /*resource
  | blank
  | (literalConstruct)=> literalConstruct
  | rdfLiteral
  | sNumericLiteral
  | blankConstruct
  | iriConstruct
  | triplesNode_*/
  graphNode_
  ;

/* SPARQL [37] */
//verb  : varOrIRIref | A;

verb @init {trace();}
  : //rdfPredicate
    varOrIRIref
  | A
  ;

verb_ @init {trace();}
  : //rdfPredicate
    varOrIRIref_
  | A
  //| iriConstruct
  ;

/* SPARQL [38] */
triplesNode @init {trace();}
  : collection
  | blankNodePropertyList
  ;

triplesNode_ @init {trace();}
  : collection_
  | blankNodePropertyList_
  ;

/* SPARQL [39] */
blankNodePropertyList
@init {trace();}
  : LBRACKET propertyListNotEmpty RBRACKET
  ->  T_ANON_BLANK propertyListNotEmpty
  ;

blankNodePropertyList_
@init {trace();}
  : LBRACKET propertyListNotEmpty_ RBRACKET
  -> T_ANON_BLANK propertyListNotEmpty_
  ;

/* SPARQL [40] */
collection
@init {trace();}
  : LPAR graphNode+ RPAR
  ;

collection_
@init {trace();}
  : LPAR graphNode_+ RPAR
  ;

/* SPARQL [41] */
graphNode
@init {trace();}
  : varOrTerm | triplesNode
  ;

graphNode_
@init {trace();}
  : varOrTerm_ | triplesNode_
  ;

/* SPARQL [42] */
varOrTerm
@init {trace();}
  : VAR
  | graphTerm
  ;

varOrTerm_
@init {trace();}
  : VAR
   | (iriConstruct)=> iriConstruct
  | (literalConstruct)=> literalConstruct
  | graphTerm_
  ;

/* SPARQL [42a] */
literalConstruct
@init{trace();}
  : (e1=enclosedExpr              -> ^(T_LITERAL_CONSTRUCT $e1))
       ( AT e2=enclosedExpr       -> ^(T_LITERAL_CONSTRUCT $e1 AT $e2)
       | CARET CARET iri          -> ^(T_LITERAL_CONSTRUCT $e1 CARET CARET iri)
       )?
  | INTEGER // NONSTANDARD
       ( AT enclosedExpr          -> ^(T_LITERAL_CONSTRUCT INTEGER AT enclosedExpr)
       | CARET CARET iriConstruct -> ^(T_LITERAL_CONSTRUCT INTEGER CARET CARET iriConstruct)
       )
  | QSTRING // NONSTANDARD
       ( AT enclosedExpr          -> ^(T_LITERAL_CONSTRUCT QSTRING AT enclosedExpr)
       | CARET CARET iriConstruct -> ^(T_LITERAL_CONSTRUCT QSTRING CARET CARET iriConstruct)
       )
  ;

/* SPARQL [43] */
varOrIRIref
@init {trace();}
  : v=VAR {if(inwhere) {wherevariables.add($v.text);}}
  | iRIref
  ;

varOrIRIref_
@init {trace();}
  : VAR
  | iRIref
  | iriConstruct
  ;

/* SPARQL [43a] */
iriConstruct
@init{trace();}
  : LESSTHANLCURLY expr RCURLYGREATERTHAN
  -> ^(T_IRI_CONSTRUCT LESSTHANLCURLY expr RCURLYGREATERTHAN)
  | e1=enclosedExpr
      ( COLON e2=enclosedExpr -> ^(T_IRI_CONSTRUCT $e1 COLON  $e2)
      | COLON? e3=qname       -> ^(T_IRI_CONSTRUCT $e1 COLON? $e3) // NONSTANDARD
      )
  | qname COLON enclosedExpr // NONSTANDARD
  -> ^(T_IRI_CONSTRUCT qname COLON enclosedExpr)
  ;

/* SPARQL [44] */
//var  : VAR;

/* SPARQL [45] */
graphTerm
  : iRIref
  | rdfLiteral
  | sNumericLiteral
  | booleanLiteral
  | blankNode
  //| nil
  ;

graphTerm_
  : iRIref
  | rdfLiteral
  | sNumericLiteral
  | booleanLiteral
  | blankNode
  //| nil
  | blankConstruct
//  | iriConstruct
  ;

/* SPARQL [45a] */
blankConstruct
@init{trace();}
  : BNODE_CONSTRUCT enclosedExpr
  ;

/* SPARQL [46] */
expression
@init{trace();}
  : conditionalOrExpression
  ;

/* SPARQL [47] */
conditionalOrExpression
@init{trace();}
  : conditionalAndExpression (ORSYMBOL^ conditionalAndExpression)*
  ;

/* SPARQL [48] */
conditionalAndExpression
@init{trace();}
  : valueLogical (ANDSYMBOL^ valueLogical)*
  ;

/* SPARQL [49] */
valueLogical
@init{trace();}
  : relationalExpression
  ;

/* SPARQL [50] */
relationalExpression
@init{trace();}
  : numericExpression ((EQUALS | HAFENEQUALS | LESSTHAN | GREATERTHAN | LESSTHANEQUALS | GREATERTHANEQUALS)^ numericExpression)?
  ;

/* SPARQL [51] */
numericExpression
@init{trace();}
  : additiveExpression
  ;

/* SPARQL [52] */
additiveExpression
@init{trace();}
  : multiplicativeExpression
     ( PLUS^ multiplicativeExpression
     | MINUS^ multiplicativeExpression
//     | numericLiteralPositive
//     | numericLiteralNegative
     )*
  ;

/* SPARQL [53] */
multiplicativeExpression
@init{trace();}
  : unaryExpression (STAR^ unaryExpression | SLASH^ unaryExpression )*
  ;

/* SPARQL [54] */
unaryExpression
@init{trace();}
  : NOT primaryExpression
  | PLUS primaryExpression
  | MINUS primaryExpression
  | primaryExpression
  ;

/* SPARQL [55] */
primaryExpression
@init{trace();}
  : brackettedExpression
  | builtInCall
  | iRIrefOrFunction
  | rdfLiteral
  | sNumericLiteral
  | booleanLiteral
  | VAR
  | BLANK_NODE_LABEL // new
  | LBRACKET RBRACKET //new
  ;

/* SPARQL [56] */
brackettedExpression
@init{trace();}
  : LPAR expression RPAR
  ;

/* SPARQL [57] */
builtInCall
@init{trace();}
  : STR LPAR expression RPAR
  | LANG LPAR expression RPAR
  | LANGMATCHES LPAR expression COMMA expression RPAR
  | DATATYPE LPAR expression RPAR
  | BOUND LPAR VAR RPAR
  | ISIRI LPAR expression RPAR
  | ISURI LPAR expression RPAR
  | ISBLANK LPAR expression RPAR
  | ISLITERAL LPAR expression RPAR
  | regexExpression
  ;

/* SPARQL [58] */
regexExpression
@init{trace();}
  : REGEX LPAR expression COMMA expression (COMMA  expression)? RPAR;

/* SPARQL [59] */
iRIrefOrFunction
@init{trace();}
  : iRIref arglist? -> ^(T_FUNCTION_CALL iRIref ^(T_PARAMS arglist?))
  ;

/* SPARQL [60] */
// doesn't look like the original one
rdfLiteral
@init{trace();}
  : QSTRING ( AT qname | CARET CARET ( IRIREF |  PNAME_LN) )?
  ;

/* SPARQL [61] */
//numericLiteral  : numericlitaralUnsigned | numericLiteralPositive | numericLiteralNegative;
sNumericLiteral  : INTEGER;

/* SPARQL [62] */
//numericLiteralunsigned  : INTEGER | DECIMAL | DOUBLE;

/* SPARQL [63] */
//numericLiteralPositive  : INTEGER_POSITIVE | DECIMAL_POSITIVE | DOUBLE_POSITIVE;

/* SPARQL [64] */
//numericLiteralNegative  : INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE;

/* SPARQL [65] */
booleanLiteral
@init{trace();}
  : TRUE
  | FALSE;

/* SPARQL [66] */
string
@init{trace();}
  : QSTRING 
//  : STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2;
  ;

/* SPARQL [67] */
iRIref
@init{trace();}
  : IRIREF
  //| qname
  | prefixedName
  ;

/* SPARQL [68] */
prefixedName
@init{trace();}
  : PNAME_LN | PNAME_NS;

/* SPARQL [69] */
blankNode  : blank
;

blank
@init{trace();}
  : bnode
  | LBRACKET RBRACKET -> T_EMPTY_ANON_BLANK
  ;

// $>







/* ------------------------------------------------------------------------- */
/* Unclassified/XSPARQL                                                      */
/* ------------------------------------------------------------------------- */

// $<XSPARQL











subject_
options {
// since iriConstruct can also start with enclosedExpr:
// use backtracking AND move enclosedExpr after iriConstruct
  backtrack=false;
}
@init{trace();}
  : resource
  | (iriConstruct)=> iriConstruct
  | blank
  | blankConstruct
  | enclosedExpr
  ;

subject
@init{trace();}
  : resource
  | blank
  ;

iri
@init{trace();}
  :  PNAME_LN
  |  IRIREF
  |  iriConstruct
  ;

resource
@init {trace();}
  : sparqlPrefixedName
  | v=VAR {if(inwhere) {wherevariables.add($v.text);}}
  | IRIREF
  ;

rdfPredicate
@init {trace();}
  : resource
  ;

bnode
@init {trace();}
  : BLANK_NODE_LABEL
  ;

sparqlPrefixedName
@init {trace();}
  : PNAME_LN | PNAME_NS
  ;

qname
@init {trace();}
  : prefixedName
  | unprefixedName
  ;

keyword
@init {trace();}
  : ITEM
  | A; // add all the other keywords?

unprefixedName
@init {trace();}
  : localPart
  ;

localPart
@init {trace();}
  : NCNAME
  | keyword
  ;

// $>

