/**
 *
 * Copyright (C) 2011, NUI Galway.
 * Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, Vienna University of Technology 
 * All rights reserved.
 *
 * The software in this package is published under the terms of the BSD style license a copy of which has been included
 * with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
 * http://xsparql.deri.ie/license/bsd_license.txt
 *
 * Created on 09 February 2011 by Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
 * NUI Galway.
 * 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio on behalf of Politecnico di Milano,  Stefan 
 * Bischof on behalf of Vienna University of Technology,  Nuno Lopes on behalf of NUI Galway.
 * 
 */
parser grammar XSPARQL;

options {
  output=AST;
//  k=2;
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
  DISTINCT;GROUP;HAVING;ENDPOINT;ROW;DOUBLET;

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

  T_SQL_FOR;
  T_SQL_WHERE;
  T_SQL_FROM;
  T_VAR;
  T_TABLE;

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
  REDUCED;
  EXPONENT;

  //SPARQL 1.1 keywords
  SELECT;
  COUNT;
  AVG;
  MAX;
  MIN;
  SUM;
  SAMPLE;
  GROUP_CONCAT;
  SEPARATOR;

  BIND;
  EXISTS;
  NOTKW;
  MINUS;
  SERVICE;
  SILENT;
  UNDEF;
  VALUES;

  SUBSTR;
  REPLACE;
  IRI;
  URI;
  BNODE;
  RAND;
  ABS;
  CEIL;
  FLOOR;
  ROUND;
  CONCAT;
  STRLEN;

  UCASE;
  LCASE;
  ENCODE_FOR_URI;
  CONTAINS;
  STRSTARTS;
  STRENDS;
  STRBEFORE;
  STRAFTER;

  ISNUMERIC;
  YEAR;
  MONTH;
  DAY;
  HOURS;
  MINUTES;
  SECONDS;
  TIMEZONE;
  TZ;
  NOW;
  UID;
  STRUUID;
  MD5;

  SHA1;
  SHA256;
  SHA384;
  SHA512;
  COALESCE;
  IF;
  STRLANG;
  STRDT;
  SAME_TERM;
  ISNUMERIC;

    
  T_SUBSELECT;
  
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
  package org.sourceforge.xsparql.rewriter;

  import java.util.Set;
  import java.util.HashSet;
  import java.util.Stack;
}


@members {

  public static boolean graphoutput = false;
  public static boolean sparqlnamespaces = false;
  private boolean debug = false;

  public void setDebug(boolean debug) {
    this.debug = debug;
  }
  
  private String outputmethod = null;
  private void setOutputMethod(String outputmethod) {
    this.outputmethod = outputmethod;
  }
  
  public String getOutputMethod() {
    return outputmethod;
  }

  /**
  * Prints current method name preceeded by a number of spaces dependant on the depth of the parse tree.
  * Doesn't do anything if not in debug mode
  * If used by all parser methods the result output is the parse tree.
  */
  private void trace() {
    if(this.debug) {
      final StackTraceElement[] stack = Thread.currentThread().getStackTrace();
      final StringBuffer sb = new StringBuffer();

      // add a number of spaces dependant on the current depth of the parse tree
      for(int i = 0; i < stack.length; i ++) {
        sb.append(' ');
      }

      sb.append(stack[2].getMethodName());

      sb.append(" - ");
      sb.append(getCurrentInputSymbol(input));
      System.out.println(sb);
    }
  }

  private Set<String> wherevariables = new HashSet<String>();
  private boolean inwhere = false;
  private Stack<Boolean> subQueryInScopeVars = new Stack<Boolean>();

  /**
  * Returns a tree from a stringSet
  */
  private static CommonTree createTree(final Set<String> s) {
    final org.antlr.runtime.tree.CommonTree ret = new org.antlr.runtime.tree.CommonTree();
    
    for(final String st : s) {
      ret.addChild(new CommonTree(new CommonToken(VAR, st)));
    }

    return ret;
  }
}


/* ------------------------------------------------------------------------- */
/* XQuery                                                                    */
/* ------------------------------------------------------------------------- */


// $<XQuery

/* XQuery10 https://www.w3.org/TR/2010/REC-xquery-20101214/ */
/* XQuery30 https://www.w3.org/TR/xquery-30/#terminal-symbols */

/* XQuery10 [1] Module ::= VersionDecl? (LibraryModule | MainModule) */
/* XQuery30 [1] Module ::= VersionDecl? (LibraryModule | MainModule) */
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
  ( ASSIGN exprSingle             -> ^(T_VARIABLE_DECL          VAR ^(T_TYPE typeDeclaration?) exprSingle)
  | EXTERNAL (ASSIGN exprSingle)? -> ^(T_EXTERNAL_VARIABLE_DECL VAR ^(T_TYPE typeDeclaration?) exprSingle?)
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

/* XQuery10 [30] QueryBody ::= Expr */
/* XQuery30 [38] QueryBody ::= Expr */
queryBody
@init{trace();}
  : exprSingle (COMMA exprSingle)* -> ^(T_QUERY_BODY ^(T_BODY_PART exprSingle)+ T_EPILOGUE)
  ;

/* XQuery10 [31]  */
expr
@init {trace();}
  : exprSingle (COMMA! exprSingle)*;

/* XQuery10 [32] ExprSingle ::=	FLWORExpr | QuantifiedExpr | TypeswitchExpr | IfExpr | OrExpr */
/* XQuery30 [40] ExprSingle ::= FLWORExpr | QuantifiedExpr | TypeswitchExpr | IfExpr | OrExpr | SwitchExpr | TryCatchExpr */
exprSingle
@init{trace();}
  : flworExpr
  | quantifiedExpr
  | typeSwitchExpr
  | ifExpr
  | orExpr
  | constructQuery // INSERT NONSTANDARD
  ;

/* XQuery [33] */
flworExpr
@init {trace();}
  : forletClause (
            (
                c=CONSTRUCT constructTemplate {sparqlnamespaces = true; graphoutput=true; this.setOutputMethod("text"); } 
             |  r=RETURN exprSingle 
		        )
		        -> ^(T_FLWOR forletClause
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
  : FOR! 
    ( 
      (sparqlForClause)=> sparqlForClause
    | (sqlForClause)=> sqlForClause
    | (xqueryForClause whereClause? orderByClause?)=> xqueryForClause whereClause? orderByClause?
    )
  | letClause whereClause? orderByClause?
  ;

// RDB -----------------------------------------------------------------

sqlForClause
@init {trace(); }
  : DISTINCT? (s=STAR | sv=sqlVarOrFunctionList | r=ROW v=VAR) relationClause sqlWhereClause?
  -> ^(T_SQL_FOR DISTINCT? $s? $sv? $r? $v?) relationClause sqlWhereClause? 
  ;

sqlVarOrFunctionList
  : sqlVarOrFunction[false] (COMMA! sqlVarOrFunction[true])* 
  ;
   
sqlVarOrFunction[boolean addComma]
@init {
  trace();
  CommonTree comma = (CommonTree) adaptor.nil() ;
  if(addComma)  { 
    comma = new CommonTree(new CommonToken(COMMA,",")); 
   } 
  }
  : qname (AS VAR)? 
    -> ^(T_VAR { comma } qname VAR?)
  | LPAR functionCall AS VAR RPAR
    -> {comma} LPAR functionCall AS VAR RPAR
  | VAR
    //-> ^(T_VAR { comma } NCNAME[$v.text] $v)
;


relationClause
@init {trace();}
  : FROM rdbSourceSelector (COMMA rdbSourceSelector)*
  -> ^(T_SQL_FROM rdbSourceSelector (COMMA rdbSourceSelector)*)
  
  | FROM qname LPAR rdbSourceSelectorFunctionParams? RPAR
  -> ^(T_SQL_FROM ^(T_FUNCTION_CALL qname ^(T_PARAMS rdbSourceSelectorFunctionParams?)))
  ;

rdbSourceSelectorFunctionParams
  : rdbSourceSelector (COMMA rdbSourceSelector)*
  | QSTRING
//  | VAR
  ;
  
rdbSourceSelector
@init {trace();}
  : n=relationSchemaName a=relationAlias? 
  -> ^(T_TABLE $n $a?) 
//  | VAR
//  -> ^(T_TABLE VAR) 
  ;


relationSchemaName
  : (relationAlias DOT)? relationAlias  
  ;


relationAlias
  : qname | VAR  
  ;


sqlWhereClause
@init {trace(); }
  : WHERE^ sqlWhereSpecList
  ;
  
  
sqlWhereSpecList   
 : sqlAttrSpecList (sqlBooleanOp sqlAttrSpecList)*
 ;
 
sqlAttrSpecList
  : sqlAttrSpec generalComp sqlAttrSpec
  | LPAR sqlWhereSpecList RPAR
  ;
  
sqlBooleanOp
  : AND | OR
  ;

sqlAttrSpec
  : qname
  | VAR
  | literal
  | enclosedExpr
  ;

//ComparisonOp    ::=  "=" \(\mid\) "!=" \(\mid\) "!=" \(\mid\) "<" \(\mid\) "<=" \(\mid\) ">" \(\mid\) "=>"
  
  

// END RDB -----------------------------------------------------------------



/* XSPARQL [33b] */
sparqlForClause
@init {trace(); wherevariables = new HashSet<String>();}
@after {inwhere=false; }
//  :  distinctOrReduced? sparqlVarOrFunction+ datasetClause* endpointClause? sWhereClause solutionmodifier valuesClause { sparqlnamespaces = true; } 
//  -> ^(T_SPARQL_FOR distinctOrReduced? sparqlVarOrFunction+)  datasetClause* endpointClause? sWhereClause solutionmodifier? valuesClause?
//  |  distinctOrReduced? STAR datasetClause* endpointClause? sWhereClause solutionmodifier valuesClause { sparqlnamespaces = true; } 
//  -> ^(T_SPARQL_FOR distinctOrReduced? {createTree(wherevariables)}) datasetClause* endpointClause? sWhereClause solutionmodifier? valuesClause?
  :  DISTINCT? sparqlVarOrFunction+ datasetClause* endpointClause? sWhereClause solutionmodifier valuesClause { sparqlnamespaces = true; } 
  -> ^(T_SPARQL_FOR DISTINCT? sparqlVarOrFunction+)  datasetClause* endpointClause? sWhereClause solutionmodifier? valuesClause?
  |  DISTINCT? STAR datasetClause* endpointClause? sWhereClause solutionmodifier valuesClause { sparqlnamespaces = true; } 
  -> ^(T_SPARQL_FOR DISTINCT? {createTree(wherevariables)}) datasetClause* endpointClause? sWhereClause solutionmodifier? valuesClause?
  ;
  
distinctOrReduced
  : DISTINCT
  | REDUCED
  ;

endpointClause
@init {trace();}
  : ENDPOINT sourceSelector
  ; 

sparqlVarOrFunction
@init {trace();}
  : v=VAR {if(inwhere) {wherevariables.add($v.text);}}
//  | LPAR functionCall AS VAR RPAR
  | LPAR expression AS v=VAR RPAR {if(inwhere) {wherevariables.add($v.text);}}
  ;


/* XQuery [34] */
xqueryForClause
@init {trace();}
  :  singleForClause (COMMA! singleForClause)*
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
  : WHERE exprSingle -> ^(T_WHERE ^(WHERE exprSingle))
  ;

/* XQuery [38] */
orderByClause
@init {trace();}
  : o=ORDER BY orderSpecList -> ^(T_ORDER  ^(T_ORDER_BY[$o] orderSpecList))
  | o=STABLE ORDER BY orderSpecList -> ^(T_ORDER ^(T_STABLE_ORDER_BY[$o] orderSpecList))
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

/* XQuery10 [42] QuantifiedExpr ::= ("some" | "every") "$" VarName TypeDeclaration? "in" ExprSingle ("," "$" VarName TypeDeclaration? "in" ExprSingle)* "satisfies" ExprSingle */
/* XQuery30 [70] QuantifiedExpr ::= ("some" | "every") "$" VarName TypeDeclaration? "in" ExprSingle ("," "$" VarName TypeDeclaration? "in" ExprSingle)* "satisfies" ExprSingle */
quantifiedExpr
@init {trace();}
  : (op=SOME | op=EVERY) v1=VAR t1=typeDeclaration? IN e1=exprSingle
  (COMMA v2=VAR t2=typeDeclaration? IN e2=exprSingle)* SATISFIES er=exprSingle
  -> ^($op ^(T_VAR $v1 ^(T_TYPE $t1)? ^(IN $e1))
  (^(T_VAR $v2 ^(T_TYPE $t2)? ^(IN $e2)))* ^(SATISFIES $er))
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
options {
  backtrack=true;
}
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
  : QUESTIONMARK// | PLUS | STAR
  ;

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

// $<SPARQL 1.1

/* SPARQL 1.1 [1] */
// QueryUnit   ::=   Query
// root SPARQL rule -> not needed in XSPARQL

/* SPARQL 1.1 [2] */
// Query    ::=   Prologue ( SelectQuery | ConstructQuery | DescribeQuery | AskQuery ) ValuesClause
// not needed in XSPARQL

/* SPARQL 1.1 [3] */
// UpdateUnit    ::=   Update
// not needed in XSPARQL

/* SPARQL 1.1 [4] */
// STANDARD: move to XQuery prolog
//prologue : baseDecl? prefixDecl*;

/* SPARQL 1.1 [5] */
baseDecl
@init {trace();}
  : BASE i=IRIREF 
  -> ^(T_NAMESPACE BASE $i); // TODO not default, base

/* SPARQL 1.1 [6] */
prefixDecl
@init {trace();}
  : PREFIX p=PNAME_NS i=IRIREF
  -> {$p.text.equals(":")}? ^(T_NAMESPACE DEFAULT QSTRING[$i])
  -> ^(T_NAMESPACE PNAME_NS[$p,$p.text.replace(':',' ').trim()] QSTRING[$i])
  ;

/* SPARQL 1.1 [7] */
// Select is not supported in XSPARQL
//selectQuery : ...


/* SPARQL 1.1 [8] */
/* SubSelect ::= SelectClause WhereClause SolutionModifier ValuesClause */
subSelect
@init {trace();}
@after {if(state.backtracking==0){ subQueryInScopeVars.pop(); } }
  : selectClause sWhereClause solutionmodifier valuesClause
  -> ^(T_SUBSELECT selectClause sWhereClause solutionmodifier? valuesClause?)
  ;
  
/* SPARQL 1.1 [9] */
/* SelectClause	  ::=  	'SELECT' ( 'DISTINCT' | 'REDUCED' )? ( ( Var | ( '(' Expression 'AS' Var ')' ) )+ | '*' ) */
selectClause
@init {trace(); }
@after {}
  : SELECT^ (DISTINCT|REDUCED)? sparqlVarOrFunction+ {subQueryInScopeVars.push(false);}
  | SELECT^ (DISTINCT|REDUCED)? STAR {if(subQueryInScopeVars.empty() || subQueryInScopeVars.peek()) subQueryInScopeVars.push(true); else subQueryInScopeVars.push(false);}
  ;
  
/* SPARQL 1.1 [10] */
constructQuery
@init {trace(); wherevariables = new HashSet<String>();}
  : c=CONSTRUCT constructTemplate datasetClause* sWhereClause solutionmodifier //valuesClause
  { graphoutput = true;sparqlnamespaces=true;  this.setOutputMethod("text");}
  -> ^(T_FLWOR[$c] ^(T_SPARQL_FOR[$c] {createTree(wherevariables)}) datasetClause* sWhereClause solutionmodifier? ^(T_CONSTRUCT[$c] constructTemplate))
  | c=CONSTRUCT w=WHERE LCURLY t=triplesTemplate  RCURLY solutionmodifier
  { graphoutput = true;sparqlnamespaces=true;  this.setOutputMethod("text");}
  -> ^(T_FLWOR[$c] ^(T_SPARQL_FOR[$c] {createTree(wherevariables)}) ^(T_SPARQL_WHERE[$w] $t) solutionmodifier? ^(T_CONSTRUCT[$c] $t))
  ;

/* SPARQL 1.1 [11] */
// Describe is not supported in XSPARQL
//describeQuery : ...

/* SPARQL 1.1 [12] */
// Ask is not supported in XSPARQL
//askQuery : ...

/* SPARQL 1.1 [13] */
datasetClause
@init {trace();}
  : FROM^ (defaultGraphClause | namedGraphClause )
  ;

/* SPARQL 1.1 [14] */
defaultGraphClause
@init {trace();}
  : sourceSelector
  ;

/* SPARQL 1.1 [15] */
namedGraphClause
@init {trace();}
  : NAMED sourceSelector
  ;

/* SPARQL 1.1 [16] */
sourceSelector
@init {trace();}
  : IRIREF | VAR
  ;

/* SPARQL 1.1 [17] */
// name clash with XQuery whereClause
sWhereClause
@init {trace(); inwhere=true;}

  : w=WHERE/*?*/ groupGraphPattern // NONSTANDARD: WHERE keyword is mandatory here
  -> ^(T_SPARQL_WHERE[$w] groupGraphPattern?)
  ;

/* SPARQL 1.1 [18] */
solutionmodifier
@init {trace();}
  : // ORIGINAL: orderclause? limitoffsetclause?
//    (ORDER BY VAR) => orderclause limitoffsetclauses?
    groupBy? having? ((orderclause) => orderclause)? limitoffsetclauses?
//  | groupBy? having? limitoffsetclauses?
  ;

/* SPARQL 1.1 [19] */
groupBy 
@init {trace();}
  : GROUP BY groupByCondition+ -> ^(T_GROUP_BY groupByCondition+)
  ;
  
/* SPARQL 1.1 [20] */
groupByCondition
@init {trace();}
  : builtInCall
  | sFunctionCall
  | LPAR expression (AS VAR)? RPAR
  | VAR
  ;

/* SPARQL 1.1 [21] */
having
@init {trace();}
//  : HAVING LPAR exprSingle RPAR -> ^(T_HAVING exprSingle)
  : HAVING havingCondition+ -> ^(T_HAVING havingCondition+)
  ;

/* SPARQL 1.1 [22] */
havingCondition
@init {trace();}
  : constraint
  ;

/* SPARQL 1.1 [23] */
orderclause
@init {trace();}
  : ORDER BY orderCondition+ -> ^(T_ORDER_BY orderCondition+)
  ;

/* SPARQL 1.1 [24] */
orderCondition
@init {trace();}
  : (ASC | DESC) brackettedExpression
//  | NCNAME brackettedExpression
  | constraint
  | VAR
  ;

/* SPARQL 1.1 [25] */
limitoffsetclauses
@init {trace();}
  : limitclause offsetclause?
  | offsetclause limitclause?
  ;
  
/* SPARQL 1.1 [26] */
limitclause
@init {trace();}
  : LIMIT^ INTEGER
  ;

/* SPARQL 1.1 [27] */
offsetclause
@init {trace();}
  : OFFSET^ INTEGER
  ;

/* SPARQL 1.1 [28] */
valuesClause
@init {trace();}
  : (VALUES^ dataBlock)?
  ;

/* SPARQL 1.1 [28->51] */
// SPARQL 1.1 Update -> not needed in XSPARQL

/* SPARQL 1.1 [52] */
/* 	TriplesTemplate	  ::=  	TriplesSameSubject ( '.' TriplesTemplate? )? */
triplesTemplate
@init {trace(); inwhere=true;}
  : triplesSameSubject ( DOT! triplesTemplate? )?
  ;

/* SPARQL 1.1 [53] */
/* GroupGraphPattern ::= '{' ( SubSelect | GroupGraphPatternSub ) '}' */
groupGraphPattern
@init {trace();}
  : LCURLY! (subSelect | groupGraphPatternSub) RCURLY!
  ;

/* SPARQL 1.1 [54] */
/* GroupGraphPatternSub ::= TriplesBlock? ( GraphPatternNotTriples '.'? TriplesBlock? )* */
groupGraphPatternSub
@init {trace();}
  : triplesBlock? (( graphPatternNotTriples | filter) DOT!? triplesBlock? )*
  ;
  //TODO why is filter included here????

/* SPARQL 1.1 [55] */
/* TriplesBlock ::= TriplesSameSubjectPath ( '.' TriplesBlock? )? */
triplesBlock
@init {trace();}
  : triplesSameSubjectPath ( DOT! triplesBlock? )?
  ;

/* SPARQL1.1 [56] */
/* GraphPatternNotTriples ::= GroupOrUnionGraphPattern | OptionalGraphPattern | MinusGraphPattern | GraphGraphPattern | ServiceGraphPattern | Filter | Bind | InlineData */
graphPatternNotTriples
@init {trace();}
  : groupOrUnionGraphPattern
  | optionalGraphPattern
  | minusGraphPattern
  | graphGraphPattern
  | serviceGraphPattern
  | bind
  | inlineData
  ;

/* SPARQL 1.1 [57] */
optionalGraphPattern
@init {trace();}
  : OPTIONAL^ groupGraphPattern
  ;

/* SPARQL 1.1 [58] */
graphGraphPattern
@init {trace();}
  : GRAPH^ varOrIRIref groupGraphPattern
  ;
  
/* SPARQL 1.1 [59] */
serviceGraphPattern
@init {trace();}
  : SERVICE^ SILENT? varOrIRIref groupGraphPattern
  ;
  
/* SPARQL 1.1 [60] */
bind
@init{trace();}
  : BIND^ LPAR expression AS v=VAR RPAR {if(inwhere) { if(subQueryInScopeVars.empty()) wherevariables.add($v.text); else if(subQueryInScopeVars.peek()) wherevariables.add($v.text);}}
  ;
  
/* SPARQL 1.1 [61] */
inlineData
@init {trace();}
  : VALUES^ dataBlock
  ;
  
/* SPARQL 1.1 [62] */
dataBlock
@init {trace();}
  : inlineDataOneVar
  | inlineDataFull
  ;
  
/* SPARQL 1.1 [63] */
inlineDataOneVar
@init {trace();}
  : VAR LCURLY dataBlockValue* RCURLY
  ;

/* SPARQL 1.1 [64] */
inlineDataFull
@init {trace();}
  : (nil | LPAR VAR+ RPAR) LCURLY (LPAR dataBlockValue+ RPAR | nil)* RCURLY
  ;

/* SPARQL 1.1 [65] */
dataBlockValue
@init {trace();}
  : sparqlPrefixedName
  | IRIREF
  | rdfLiteral
  | numericliteral
  | booleanLiteral
  | UNDEF
  ;

/* SPARQL 1.1 [66] */
/* 	MinusGraphPattern ::= 'MINUS' GroupGraphPattern */
minusGraphPattern
@init {trace();}
  : MINUS^ groupGraphPattern
  ;

/* SPARQL11 [67] */
/* GroupOrUnionGraphPattern	  ::=  	GroupGraphPattern ( 'UNION' GroupGraphPattern )* */
groupOrUnionGraphPattern
@init {trace();}
  : (groupGraphPattern -> groupGraphPattern)
  ((UNION groupGraphPattern)+ -> ^(UNION ^(T_UNION $groupOrUnionGraphPattern) ^(T_UNION groupGraphPattern)+))?
  ;

/* SPARQL 1.1 [68] */
/* Filter ::= 'FILTER' Constraint */
filter
@init {trace();}
  : FILTER^ constraint
  ;

/* SPARQL 1.1 [69] */
/* Constraint ::= BrackettedExpression | BuiltInCall | FunctionCall */
constraint
@init {trace();}
  : brackettedExpression
  | builtInCall
  | sFunctionCall
  ;

/* SPARQL 1.1 [70] */
/* FunctionCall ::= iri ArgList */
sFunctionCall
@init {trace();}
  : iRIref arglist
  ;

/* SPARQL 1.1 [71] */
/*  ArgList ::= NIL | '(' 'DISTINCT'? Expression ( ',' Expression )* ')' */
/* TODO Check this appears to be missing NIL and distinct */
arglist
@init {trace();}
  : LPAR! (expression (COMMA! expression)*)? RPAR!
  ;

/* SPARQL 1.1 [72] */
/* ExpressionList ::= NIL | '(' Expression ( ',' Expression )* ')'  */
expressionList
@init{trace();}
  : nil
  | LPAR expression (COMMA expression)* RPAR
  ;

/* SPARQL 1.1 [73] */
/* ConstructTemplate ::= '{' ConstructTriples? '}' */
constructTemplate
@init {trace();}
  : LCURLY! constructTriples? RCURLY!
  ;

/* SPARQL 1.1 [74] */
/* ConstructTriples ::= TriplesSameSubject ( '.' ConstructTriples? )? */
constructTriples
@init {trace();}
  : (triplesSameSubject_) => triplesSameSubject_ (DOT! constructTriples?)?
  | enclosedExpr (DOT! constructTriples)?
  ;

/* SPARQL 1.1 [75] */
/* TriplesSameSubject ::= VarOrTerm PropertyListNotEmpty | TriplesNode PropertyList */
triplesSameSubject @init {trace();}
  : subject propertyListNotEmpty -> ^(T_SUBJECT subject propertyListNotEmpty)
  | triplesNode propertyListNotEmpty? -> ^(T_SUBJECT triplesNode propertyListNotEmpty?)
  ;

triplesSameSubject_ @init {trace();}
  : subject_ propertyListNotEmpty_ -> ^(T_SUBJECT subject_ propertyListNotEmpty_)
  | triplesNode_ propertyListNotEmpty_? // inline propertyList because of EmptyRewriteException
  -> ^(T_SUBJECT triplesNode_ propertyListNotEmpty_?)
  ;

/* SPARQL 1.1 [76] */
/* PropertyList	  ::=  	PropertyListNotEmpty? */

/* SPARQL 1.1 [77] */
propertyListNotEmpty @init {trace();}
  : verb objectList (SEMICOLON (verb objectList)? )*
  -> ^(T_VERB verb objectList)+
  ;

/* SPARQL 1.1 [77] */
/* PropertyListNotEmpty	  ::=  	Verb ObjectList ( ';' ( Verb ObjectList )? )* */
propertyListNotEmpty_ @init {trace();}
  : verb_ objectList_ (SEMICOLON (verb_ objectList_)?)*
  -> ^(T_VERB verb_ objectList_)+
  ;


// propertyList_ @init {trace();}
//   : propertyListNotEmpty_?
//   ;

/* SPARQL 1.1 [78] */
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


/* SPARQL 1.1 [79] */
objectList @init {trace();}
  : object (COMMA object)*
  -> ^(T_OBJECT object)+
  ;

objectList_ @init {trace();}
  : object_ (COMMA object_)*
  -> ^(T_OBJECT object_)+
  ;

/* SPARQL 1.1 [80] */
//object  : graphNode;

object @init {trace();}
//  : graphNode
  : resource
  | blank
  | rdfLiteral
  | sNumericLiteral
  | triplesNode
  | literalConstruct
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
    graphNode_ quad? 
  ;
  
quad
@init{trace();}
  : (iri) => iri 
  | (literal_) => literal_
  ; 

literal_
@init{trace();}
  :  literalConstruct
  |  rdfLiteral
  ;

/* SPARQL 1.1 [81] */
//  : varOrTerm propertyListPathNotEmpty
//  | triplesNodePath propertyListPathNotEmpty?
triplesSameSubjectPath
@init{trace();}
  : subject propertyListPathNotEmpty
  -> ^(T_SUBJECT subject propertyListPathNotEmpty)
  | triplesNodePath propertyListPathNotEmpty?
  -> ^(T_SUBJECT triplesNodePath propertyListPathNotEmpty?)
  ;

/* SPARQL 1.1 [82] */
//propertyListPath

/* SPARQL 1.1 [83] */
propertyListPathNotEmpty 
@init{trace();}
//  : (verbPath | verbSimple) objectListPath ( SEMICOLON ((verbPath | verbSimple ) objectList)?)*
  : vp objectListPath propertyListPathNotEmptySub*
  -> ^(T_VERB vp objectListPath) propertyListPathNotEmptySub*
  ;

propertyListPathNotEmptySub  
  : SEMICOLON (vp objectList)? -> ^(T_VERB vp objectList)?
  ;
  
vp
  : (verbPath | verbSimple) 
  ;
  
/* SPARQL 1.1 [84] */
verbPath 
@init{trace();}
  : path
  ;
  
/* SPARQL 1.1 [85] */
verbSimple 
@init{trace();}
  : v=VAR {if(inwhere) { if(subQueryInScopeVars.empty()) wherevariables.add($v.text); else if(subQueryInScopeVars.peek()) wherevariables.add($v.text);}}
  ;
  
/* SPARQL 1.1 [86] */
objectListPath
@init{trace();}
  : objectPath (COMMA objectPath)*
  -> ^(T_OBJECT objectPath)+
  ;
  
/* SPARQL 1.1 [87] */
objectPath
@init{trace();}
  : graphNodePath
  ;
  
/* SPARQL 1.1 [88] */
path
@init{trace();}
  : pathAlternative
  ;
  
/* SPARQL 1.1 [89] */
pathAlternative
@init{trace();}
  : pathSequence (UNIONSYMBOL pathSequence)*
  ;

/* SPARQL 1.1 [90] */
pathSequence
@init{trace();}
  : pathEltOrInverse (SLASH pathEltOrInverse)* 
  ;

/* SPARQL 1.1 [91] */
pathElt
@init{trace();}
//  : pathPrimary pathMod?
  : pathPrimary
  | (pathPrimary pathMod) => pathPrimary pathMod
  ;

/* SPARQL 1.1 [92] */
pathEltOrInverse
@init{trace();}
  : pathElt 
  | CARET pathElt
  ;
  
/* SPARQL 1.1 [93] */
pathMod
@init{trace();}
  : QUESTIONMARK
  | STAR
  | PLUS
  ;
  
/* SPARQL 1.1 [94] */
pathPrimary
@init{trace();}
  : iRIref
  | A
  | NOT pathNegatedPropertySet
  | LPAR path RPAR
  ;
  
/* SPARQL 1.1 [95] */
pathNegatedPropertySet
@init{trace();}
  : pathOneInPropertySet
  | LPAR (pathOneInPropertySet (UNIONSYMBOL pathOneInPropertySet)*)? RPAR
  ;

/* SPARQL 1.1 [96] */
pathOneInPropertySet
@init{trace();}
  : iRIref
  | A
  | CARET (iRIref | A)
  ;
  
/* SPARQL 1.1 [98] */
triplesNode @init {trace();}
  : collection
  | blankNodePropertyList
  ;

triplesNode_ @init {trace();}
  : collection_
  | blankNodePropertyList_
  ;

/* SPARQL 1.1 [99] */
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

/* SPARQL 1.1 [100] */
triplesNodePath
@init {trace();}
  : collectionPath
  | blanckNodePropertyListPath
  ;

/* SPARQL 1.1 [101] */
blanckNodePropertyListPath
@init {trace();}
  : LBRACKET propertyListPathNotEmpty RBRACKET
  ->  T_ANON_BLANK propertyListPathNotEmpty
  ;

/* SPARQL 1.1 [102] */
collection
@init {trace();}
  : LPAR graphNode+ RPAR
  ;

collection_
@init {trace();}
  : LPAR graphNode_+ RPAR
  ;

/* SPARQL 1.1 [103] */
collectionPath
@init {trace();}
  : LPAR graphNodePath+ RPAR
  ;

/* SPARQL 1.1 [104] */
graphNode
@init {trace();}
  : varOrTerm | triplesNode
  ;

graphNode_
@init {trace();}
  : varOrTerm_ | triplesNode_
  ;

/* SPARQL 1.1 [105] */
graphNodePath
@init {trace();}
  : v=VAR {if(inwhere) { if(subQueryInScopeVars.empty()) wherevariables.add($v.text); else if(subQueryInScopeVars.peek()) wherevariables.add($v.text);}}
  | graphTerm
  | triplesNodePath
  ;

/* SPARQL 1.1 [106] */
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

/* SPARQL 1.1 [107] */
varOrIRIref
@init {trace();}
  : v=VAR {if(inwhere) { if(subQueryInScopeVars.empty()) wherevariables.add($v.text); else if(subQueryInScopeVars.peek()) wherevariables.add($v.text);}}
  | iRIref
  ;

varOrIRIref_
@init {trace();}
  : VAR
  | iRIref
  | iriConstruct
  ;

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

/* SPARQL 1.1 [108] */
//var  : VAR;

/* SPARQL 1.1 [109] */
graphTerm
  : iRIref
  | rdfLiteral
  | sNumericLiteral
  | booleanLiteral
  | blankNode
  | nil
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

blankConstruct
@init{trace();}
  : BNODE_CONSTRUCT enclosedExpr
  ;

/* SPARQL 1.1 [110] */
expression
@init{trace();}
  : conditionalOrExpression
  ;

/* SPARQL 1.1 [111] */
conditionalOrExpression
@init{trace();}
  : conditionalAndExpression (ORSYMBOL^ conditionalAndExpression)*
  ;

/* SPARQL 1.1 [112] */
conditionalAndExpression
@init{trace();}
  : valueLogical (ANDSYMBOL^ valueLogical)*
  ;

/* SPARQL 1.1 [113] */
valueLogical
@init{trace();}
  : relationalExpression
  ;

/* SPARQL 1.1 [114] */
relationalExpression
@init{trace();}
  : numericExpression (((EQUALS | HAFENEQUALS | LESSTHAN | GREATERTHAN | LESSTHANEQUALS | GREATERTHANEQUALS)^ numericExpression) | ((IN | NOTKW IN)^ expressionList))?
  ;

/* SPARQL 1.1 [115] */
numericExpression
@init{trace();}
  : additiveExpression
  ;

/* SPARQL 1.1 [116] */
additiveExpression
@init{trace();}
  : multiplicativeExpression
     ( PLUS^ multiplicativeExpression
     | MINUS^ multiplicativeExpression
//     | numericLiteralPositive
//     | numericLiteralNegative
     )*
  ;

/* SPARQL 1.1 [117] */
multiplicativeExpression
@init{trace();}
  : unaryExpression (STAR^ unaryExpression | SLASH^ unaryExpression )*
  ;

/* SPARQL 1.1 [118] */
unaryExpression
@init{trace();}
  : NOT primaryExpression
  | (PLUS primaryExpression) => PLUS primaryExpression
  | (MINUS primaryExpression) => MINUS primaryExpression
  | primaryExpression
  ;

/* SPARQL 1.1 [119] */
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

/* SPARQL 1.1 [120] */
brackettedExpression
@init{trace();}
  : LPAR expression RPAR
  ;

/* SPARQL 1.1 [121] */
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
  //SPARQL 1.1 builtin calls
  | IRI LPAR expression RPAR
  | URI LPAR expression RPAR
  | BNODE (LPAR expression RPAR | nil)
  | RAND nil
  | ABS LPAR expression RPAR
  | CEIL LPAR expression RPAR
  | FLOOR LPAR expression RPAR
  | ROUND LPAR expression RPAR
  | CONCAT expressionList
  | substringExpression
  | STRLEN LPAR expression RPAR
  | strReplaceExpression
  | UCASE LPAR expression RPAR
  | LCASE LPAR expression RPAR
  | ENCODE_FOR_URI LPAR expression RPAR
  | CONTAINS LPAR expression COMMA expression RPAR
  | STRSTARTS LPAR expression COMMA expression RPAR
  | STRENDS LPAR expression COMMA expression RPAR
  | STRBEFORE LPAR expression COMMA expression RPAR
  | STRAFTER LPAR expression COMMA expression RPAR
  | YEAR LPAR expression RPAR
  | MONTH LPAR expression RPAR
  | DAY LPAR expression RPAR
  | HOURS LPAR expression RPAR
  | MINUTES LPAR expression RPAR
  | SECONDS LPAR expression RPAR
  | TIMEZONE LPAR expression RPAR
  | TZ LPAR expression RPAR
  | NOW nil
  | UID nil
  | STRUUID nil
  | MD5 LPAR expression RPAR
  | SHA1 LPAR expression RPAR
  | SHA256 LPAR expression RPAR
  | SHA384 LPAR expression RPAR
  | SHA512 LPAR expression RPAR
  | COALESCE expressionList
  | IF LPAR expression COMMA expression COMMA expression RPAR
  | STRLANG LPAR expression COMMA expression RPAR
  | STRDT LPAR expression COMMA expression RPAR
  | SAME_TERM LPAR expression COMMA expression RPAR
  | ISNUMERIC LPAR expression RPAR
  | aggregate
  | existsFunc
  | notExistsFunc
  ;
  
/* SPARQL 1.1 [122] */
regexExpression
@init{trace();}
  : REGEX LPAR expression COMMA expression (COMMA  expression)? RPAR
  ;
  
/* SPARQL 1.1 [123] */
substringExpression
@init{trace();}
  : SUBSTR LPAR expression COMMA expression (COMMA expression)? RPAR
  ;
  
/* SPARQL 1.1 [124] */
strReplaceExpression
@init{trace();}
  : REPLACE LPAR expression COMMA expression COMMA expression (COMMA expression)? RPAR
  ;

/* SPARQL 1.1 [125] */
existsFunc
@init{trace();}
  : EXISTS groupGraphPattern
  ;
  
/* SPARQL 1.1 [126] */
notExistsFunc
@init{trace();}
  : NOTKW^ EXISTS groupGraphPattern
  ;
  
/* SPARQL 1.1 [127] */
aggregate
@init{trace();}
  : COUNT LPAR DISTINCT? (STAR|expression) RPAR
  | SUM LPAR DISTINCT? expression RPAR
  | MIN LPAR DISTINCT? expression RPAR
  | MAX LPAR DISTINCT? expression RPAR
  | AVG LPAR DISTINCT? expression RPAR
  | SAMPLE LPAR DISTINCT? expression RPAR
  | GROUP_CONCAT LPAR DISTINCT? expression (SEMICOLON SEPARATOR EQUALS string)? RPAR
  ;

/* SPARQL 1.1 [128] */
iRIrefOrFunction
@init{trace();}
  : iRIref arglist? -> ^(T_FUNCTION_CALL iRIref ^(T_PARAMS arglist?))
  ;

/* SPARQL 1.1 [129] */
// doesn't look like the original one
rdfLiteral
@init{trace();}
  : QSTRING ( AT NCNAME | CARET CARET ( IRIREF |  PNAME_LN) )?
  ;

/* SPARQL 1.1 [130] */
//numericLiteral  : numericlitaralUnsigned | numericLiteralPositive | numericLiteralNegative;
sNumericLiteral  
@init{trace();}
  : (PLUS|MINUS)? INTEGER
  | (PLUS|MINUS)? DECIMAL
  | (PLUS|MINUS)? DOUBLET
  ;
  
/* SPARQL 1.1 [131] */
//numericLiteralunsigned  : INTEGER | DECIMAL | DOUBLE;

/* SPARQL 1.1 [132] */
//numericLiteralPositive  : INTEGER_POSITIVE | DECIMAL_POSITIVE | DOUBLE_POSITIVE;

/* SPARQL 1.1 [133] */
//numericLiteralNegative  : INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE;

/* SPARQL [65] */
booleanLiteral
@init{trace();}
  : TRUE
  | FALSE
  ;

/* SPARQL [66] */
string
@init{trace();}
  : QSTRING 
//  : STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2;
  ;

/* SPARQL 1.1 [136] */
iRIref
@init{trace();}
  : IRIREF
  | prefixedName
  ;

/* SPARQL 1.1 [137] */
prefixedName
@init{trace();}
  : PNAME_LN 
  | PNAME_NS
  ;

/* SPARQL 1.1 [138] */
blankNode
  : blank
  ;

blank
@init{trace();}
  : bnode
  | LBRACKET RBRACKET -> T_EMPTY_ANON_BLANK
  ;
  
/* SPARQL 1.1 [161] */
nil
@init{trace();}
  : LPAR RPAR
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
  | v=VAR {if(inwhere) { if(subQueryInScopeVars.empty()) wherevariables.add($v.text); else if(subQueryInScopeVars.peek()) wherevariables.add($v.text);}}
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
  | COUNT
  | MAX
  | MIN
  | AVG
  | SUM
  | SAMPLE 
  | NOTKW
  | EXISTS
  ;

keyword
@init {trace();}
  : ITEM
  | TO
  | FROM
  | COMMENT
  | ROW
  | NODE
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

