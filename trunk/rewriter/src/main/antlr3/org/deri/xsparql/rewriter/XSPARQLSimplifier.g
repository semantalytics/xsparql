/**
 *
 * Copyright (C) 2011, NUI Galway.
 * All rights reserved.
 *
 * The software in this package is published under the terms of the BSD style license a copy of which has been included
 * with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
 * http://xsparql.deri.ie/license/bsd_license.txt
 *
 * Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
 * NUI Galway.
 */
tree grammar XSPARQLSimplifier;

options {
  tokenVocab=XSPARQLRewriter;
  output=AST;
  backtrack=true;
  ASTLabelType=CommonTree;
  rewrite=true;
  filter=true;

  superClass=AbstractMyTreeRewriter;
}

tokens {

  REWRITEVNODE;
  REWRITEVNODE1;
  DELETEVNODE;
  COMMENT;
  T_QSTRING;
  
  NOTHING;

  // Lexer tokens
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
  T_XML_CONTENTS;
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
  
  T_SQL_FOR;
  T_SQL_FROM;
  T_TABLE;
  T_VAR;
  ENDPOINT;
  DECIMAL;
  ROW;
  T_UNOPTIMIZED_FUNCTION_CALL;
}

@header {
  package org.deri.xsparql.rewriter;

  import java.util.logging.Logger;
  import java.util.Collection;
  import java.util.ArrayList;
}

@members {
  private static final Logger logger = Logger.getLogger(XSPARQLSimplifier.class.getClass().getName());

  private String nodeFunction;


  /**
   * set the XQuery evaluation engine
   */
  public void setEngine(String xqueryEngine, String sparqlmethod) {
   if (xqueryEngine.equals("qexo") && sparqlmethod.equals("arq")) {
      this.nodeFunction = "_java:resultNode";
    } else {
      this.nodeFunction = "_xsparql:_resultNode";
    }
  }



protected String format(String relation) {
  logger.info("format: "+relation);
  if (relation.matches(".*\\..*")) {
    logger.info("format-true");
    String[] split = relation.split("\\.");
    logger.info("format-true: "+split.length);
    return new String("\"\"" + split[0] +"\"\".\"\"" + split[1] +"\"\"") ;
  } else {
    logger.info("format-false");
    return relation;
  }
}

}

// TOP DOWN RULES

topdown
  : varrewrite
  | singleconcat
  | markunoptimized
  ;

varrewrite
@init {
  String varName = "";
}
  :  ^(r=REWRITEVNODE v=VAR) { varName=Helper.removeLeading($v.text, "$"); }
  -> ^(T_FLWOR[$v.token,"i'm a stupid flworExpr"] // avoid "Can't set single child to a list"
       COMMENT["SPARQL variable " + $v.text + " from " + $v.line + ":" + $v.pos]
       ^(T_LET[$v.token,"LET"] 
          VAR[$v.token, "\$" + varName ]
         ^(T_FUNCTION_CALL
            NCNAME[nodeFunction]
           ^(T_PARAMS
              VAR[$r.text]
              QSTRING[varName]
            )
          )
        )
     )
  // sql variable list, no comma separator
  | ^(T_VAR q=QSTRING VAR) 
  -> QSTRING[" "+format($q.text)+" AS \"\"" + $q.text +"\"\" "]
  // sql variable list, comma separator
  | ^(T_VAR c=COMMA q=QSTRING VAR) 
  -> QSTRING[$c.text+" "+format($q.text)+" AS \"\"" + $q.text +"\"\" "] 
  |  ^(r=REWRITEVNODE ^(T_VAR COMMA? q=QSTRING v=VAR)) { varName = Helper.removeLeading($v.text, "$"); }
  -> ^(T_FLWOR[$q.token,"i'm a stupid flworExpr"] // avoid "Can't set single child to a list"
       COMMENT["SPARQL variable " + $q.text + " from " + $q.line + ":" + $q.pos]
       ^(T_LET[$q.token,"LET"] 
          VAR[$q.token, "\$" + varName]
         ^(T_FUNCTION_CALL
            NCNAME["_xsparql:_sqlResultNode"]
           ^(T_PARAMS
              VAR[$r.text]
              QSTRING
            )
          )
        )
     )
  |  ^(r=REWRITEVNODE LPAR ^(T_FUNCTION_CALL n=NCNAME ^(T_PARAMS ^(XPATH v=VAR))) AS v2=VAR RPAR) {varName=Helper.removeLeading($v2.text, "$");}
  -> ^(T_FLWOR[$v2.token,"i'm a stupid flworExpr"] // avoid "Can't set single child to a list"
       COMMENT["SPARQL variable " + $v.text + " from " + $v.line + ":" + $v.pos]
       ^(T_LET[$v2.token,"LET"] 
          VAR[$v2.token, "\$" + varName ]
         ^(T_FUNCTION_CALL
            NCNAME[nodeFunction]
           ^(T_PARAMS
              VAR[$r.text]
              QSTRING[varName]
            )
          )
        )
     )
  |  ^(r=REWRITEVNODE q=NOTHING)
  -> COMMENT[$q.token, "dependent variable " + $q.text]
//   |  ^(r=REWRITEVNODE q=DELETEVNODE)
//   -> COMMENT[$q.token, "deleted node"]
  |  DELETEVNODE
  -> DELETEVNODE // should actually delete
  | ^(REWRITEVNODE1 v=VAR)
  -> QSTRING[$v.token, $v.text + " "]
  | ^(REWRITEVNODE1 vv=NOTHING)
  -> QSTRING[$vv.token, " "]
  | ^(REWRITEVNODE1 LPAR ^(T_FUNCTION_CALL n=NCNAME ^(T_PARAMS ^(XPATH v=VAR))) AS v2=VAR RPAR)
  -> QSTRING[$n.token, "(" + $n.text + "(" + $v.text + ") AS " + $v2.text + ")"]
  // SQL variable assigments, take only column name
  ;

singleconcat
  : ^(T_FUNCTION_CALL f=NCNAME ^(T_PARAMS QSTRING))
  -> {$f.text.equals("fn:concat")}? QSTRING
  -> ^(T_FUNCTION_CALL $f ^(T_PARAMS QSTRING))
  ;
  
// appearantly this is not working realiably: for some concats this rule never fires
// it is not clear what the reason is for this
// try for example: foaf_lowering.xsparql or sioc2rss.xsparql
markunoptimized 
  : ^(t=T_FUNCTION_CALL f=NCNAME params=.)
  -> {$f.text.equals("fn:concat")}? ^(T_UNOPTIMIZED_FUNCTION_CALL $f $params)
  -> ^($t $f $params)
  ;


// BOTTOM UP RULES

bottomup
  : staticconcat // switch off if it loops infinitely
  ;

staticconcat
  : ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS VAR? q+=qstringandfunctioncall* q2=QSTRING q3=QSTRING rest+=.*)) // merge two QSTRINGs into one
  -> ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS VAR? $q* QSTRING[$q2.token, $q2.text + $q3.text] $rest*))
  | ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS VAR? q+=qstringandfunctioncall+ q1=QSTRING?)) // is fully optimised now
  -> ^(T_FUNCTION_CALL NCNAME ^(T_PARAMS VAR? $q+ $q1?))
  | ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS VAR q1=QSTRING)) // is fully optimised now
  -> ^(T_FUNCTION_CALL NCNAME ^(T_PARAMS VAR $q1))
  | ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS QSTRING)) // omit needless function call, same as singleconcat
  -> QSTRING
  ;
  
qstringandfunctioncall
	: QSTRING ^(T_FUNCTION_CALL p+=.+)
	-> QSTRING ^(T_FUNCTION_CALL $p+)
	;
