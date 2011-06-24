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
  T_UNOPTIMIZED_FUNCTION_CALL;
}

@header {
  package org.deri.xsparql;

  import java.util.logging.Logger;
  import java.util.Collection;
  import java.util.ArrayList;
}

@members {
  private static final Logger logger = Logger.getLogger(XSPARQLRewriter.class.getClass().getName());

  private String nodeFunction;


  /**
   * set the XQuery evaluation engine
   */
  public void setEngine() {
    if (Configuration.xqueryEngine().equals("qexo") && Configuration.SPARQLmethod().equals("arq")) {
      this.nodeFunction = "_java:resultNode";
    } else {
      this.nodeFunction = "_xsparql:_resultNode";
    }
  }

}

topdown
  : varrewrite
  | singleconcat
  | markunoptimized
  ;

varrewrite
@init {
  String varName = "";
}
  :  ^(r=REWRITEVNODE v=VAR) {varName=Helper.removeLeading($v.text, "$");}
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
  ;

singleconcat
  : ^(T_FUNCTION_CALL f=NCNAME q=QSTRING)
  -> {$f.text.equals("fn:concat")}? $q
  -> ^(T_FUNCTION_CALL $f $q)
  ;
  
markunoptimized
  : ^(T_FUNCTION_CALL f=NCNAME params=.)
  -> {$f.text.equals("fn:concat")}? ^(T_UNOPTIMIZED_FUNCTION_CALL $f $params)
  -> ^(T_FUNCTION_CALL $f $params)
  ;


bottomup
  : staticconcat // switch of if it loops infinitely
  ;


staticconcat
  : ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS q+=qstringandfunctioncall* q2=QSTRING q3=QSTRING rest+=.*)) // merge two QSTRINGs into one
  -> ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS $q* QSTRING[$q2.token, $q2.text + $q3.text] $rest*))
  | ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS q+=qstringandfunctioncall+ q1=QSTRING?)) // is not unoptimized now
  -> ^(T_FUNCTION_CALL NCNAME ^(T_PARAMS $q+ $q1?))
  | ^(T_UNOPTIMIZED_FUNCTION_CALL NCNAME ^(T_PARAMS q1=QSTRING)) // omit needless function call: string concat on single argument
  -> $q1
  ;
  
qstringandfunctioncall
	: QSTRING ^(T_FUNCTION_CALL p+=.+)
	-> QSTRING ^(T_FUNCTION_CALL $p+)
	;
