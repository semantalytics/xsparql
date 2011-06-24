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
tree grammar XQuerySerializer;

options {
  tokenVocab=XSPARQLRewriter;
  ASTLabelType=CommonTree;
  output=template;
}

@header {
  package org.deri.xsparql;
}

// start rule MUST NOT be recursive in ANTLR
root : a=main -> generic(content={$a.st})
  ;

main
  :  ^(T_MAIN mains+=main+)
    -> main(date={new java.util.Date().toString()}, queryBodies={$mains})
  | ^(T_QUERY_BODY mains1+=main+)
    -> queryBody(main={$mains1})
  | ^(T_BODY_PART mains2+=main+)
    -> generic(content={$mains2})
  |  ^(T_NAMESPACE d=main e=main)
    -> namespace(name={$d.st}, value={$e.st})
  |  ^(T_NAMESPACE DEFAULT e=main)
    -> defaultnamespace(value={$e.st})
  |  ^(T_DEFAULT_DECL dd1=main dd2=main dd3=main)
    -> defaultDecl(dd1={$dd1.st}, dd2={$dd2.st}, dd3={$dd3.st})
  |  ^(FROM f=main)
    -> template(a={$f.text}) "from $a$"
  |  ^(T_FLWOR flcs+=main+)
    -> flworExpr(forlets={$flcs})
  |  ^(T_WHERE where=main)
    -> whereExpr(main={$where.st})
  |  ^(FILTER filter+=main*)
    -> filterExpr(main={$filter})
  |  ^(T_ORDER order=main)
    -> generic(content={$order.st})
  |  ^(T_ORDER_BY order1=main)
    -> orderExpr(main={$order1.st})
  |  ^(T_RETURN ret+=main+)
    -> returnExpr(main={$ret})
  |  comment=COMMENT
    -> comment(comment={$comment})
  |  DELETEVNODE   // should not be needed here
    -> 
  |  ^(T_XML_ELEMENT name=main attributes+=xmlAttribute* contents+=main*)
    -> xmlElement(name={$name.st}, attributes={$attributes}, contents={$contents})
  |  ^(T_XML_CONTENT ^(T_XML_CONTENTS c1+=main+))
    -> xmlContents(content={$c1})
  |  ^(T_XML_CONTENT c1+=main+)
    -> xmlContent(content={$c1})
  |  ^(T_VARIABLE_DECL v1=main ^(T_TYPE v2=main?) v3=main?)
    -> varDecl(v1={$v1.st}, v2={$v2.st}, v3={$v3.st})
  |  ^(T_EXTERNAL_VARIABLE_DECL v1=main ^(T_TYPE v2=main?))
    -> externalVarDecl(v1={$v1.st}, v2={$v2.st})
  |  ^(T_PAR e2+=main*)
    -> par(content={$e2})
  |  ^(T_MODULE_IMPORT ^(NAMESPACE mi1=main?) mi2=main ^(AT mi3=main*))
    -> moduleImport(mi1={$mi1.st}, mi2={$mi2.st}, mi3={$mi3.st})
  |  ^(T_SCHEMA_IMPORT ^(NAMESPACE mi1=main?) mi2=main ^(AT mi3=main*))
    -> schemaImport(mi1={$mi1.st}, mi2={$mi2.st}, mi3={$mi3.st})
  |  ^(T_FUNCTION_DECL fname1=main ^(T_PARAMS params+=main*) (^(AS as=main))? definition=main?)
    -> funcDecl(name={$fname1.st}, params={$params}, as={$as.st}, definition={$definition.st})
  |  ^(T_PARAM param=main ^(T_TYPE type=main?))
    -> param(name={$param.st}, type={$type.st})
  |  ^(T_FUNCTION_CALL fname=main ^(T_PARAMS fexpr+=main*))
    -> funcCall(name={$fname.st}, expr={$fexpr})
  |  ^(T_UNOPTIMIZED_FUNCTION_CALL fname=main ^(T_PARAMS fexpr+=main*))
    -> funcCall(name={$fname.st}, expr={$fexpr})
  |  ^(T_FOR a=VAR (^(T_TYPE t=main))? ^(AT c=VAR) ^(IN e3+=main+))
    -> forClause(var={$a.text}, type={$t.st}, at={$c.text}, in={$e3})
  |  ^(T_LET b=main (d1+=main)+)
    -> letClause(var={$b.st}, expr={$d1})
  |  ^(XPATH xp+=main+)
    -> generic(content={$xp})
  |  ^(TO from=main to=main)
    -> rangeExpr(from={$from.st}, to={$to.st})
  |  ^((op=PLUS|op=MINUS|op=STAR|op=DIV|op=IDIV|op=MOD) (p1=main p2=main)?)
    -> infixOpExpr(p1={$p1.st}, p2={$p2.st}, op={$op})
  |  x=XPATH
    -> generic(content={$x.text})
  |  ^(IF cond=main then=main elseExpr=main)
    -> ifExpr(cond={$cond.st}, then={$then.st}, elseExpr={$elseExpr.st})
  |  ^(OR or1=main or2=main)
    -> infixOpExpr(p1={$or1.st}, p2={$or2.st}, op={$OR.text})
  |  ^(AND or1=main or2=main)
    -> infixOpExpr(p1={$or1.st}, p2={$or2.st}, op={$AND.text})
  |  ^(T_OBJECT a5=main)
    -> objectClause(object={$a5.st})
  |  ^(T_TYPE type=main?)
    -> generic(content={$type.st})
  |  ^((op=LT|op=GT|op=LE|op=GE|op=EQUALS|op=GREATERTHAN|op=EQ|op=HAFENEQUALS) eq1=main eq2=main)
    -> infixOpExpr(p1={$eq1.st}, p2={$eq2.st}, op={$op})
  |  q=QSTRING
    -> qstring(qs={$q.text})
  |  ^(T_QSTRING strparts+=main+)
    -> qstring(qs={$strparts})
  |  ^(T_GROUP_BY var=VAR)
    -> group_by(var={$var})
  |  ^(T_HAVING expr+=main+)
    -> having(expr={$expr})
  |  INTEGER
    -> {%{$INTEGER.text}}
  |  DECIMAL
    -> {%{$DECIMAL.text}}
  |  var=VAR
	  -> generic(content={$var.text})
  |  LPAR
    -> {%{$LPAR.text}}
  |  RPAR
    -> {%{$RPAR.text}}
  |  LCURLY
    -> {%{$LCURLY.text}}
  |  RCURLY
    -> {%{$RCURLY.text}}
  |  LBRACKET
    -> {%{$LBRACKET.text}}
  |  RBRACKET
    -> {%{$RBRACKET.text}}
  |  CARET
    -> {%{$CARET.text}}
  |  UNIONSYMBOL
    -> {%{$UNIONSYMBOL.text}}
  |  ADDSYMBOL
    -> {%{$ADDSYMBOL.text}}
  |  ANDSYMBOL
    -> {%{$ANDSYMBOL.text}}
  |  ORSYMBOL
    -> {%{$ORSYMBOL.text}}
  |  ncname=NCNAME
    -> generic(content={$ncname.text})
  |  IRIREF
    -> {%{$IRIREF.text}}
  |  PNAME_LN
    -> {%{$PNAME_LN.text}}
  |  PNAME_NS
    -> {%{$PNAME_NS.text}}
  |  NCNAMEELM
    -> {%{$NCNAMEELM.text}}
  |  A
    -> {%{$A.text}}
  |  SLASH
    -> {%{$SLASH.text}}
  |  AT
    -> {%{$AT.text}}
  |  NOT
    -> {%{$NOT.text}}
  |  ISBLANK
    -> {%{$ISBLANK.text}}
  |  ISIRI
    -> {%{$ISIRI.text}}
  |  ITEM
    -> {%{$ITEM.text}}
  |  LANG
    -> {%{$LANG.text}}
  |  LANGMATCHES
    -> {%{$LANGMATCHES.text}}
  |  COLON
    -> {%{$COLON.text}}
  |  COLONCOLON
    -> {%{$COLONCOLON.text}}
  |  ELEMENT
    -> {%{$ELEMENT.text}}
  |  TEXT
    -> {%{$TEXT.text}}
  |  DOT
    -> {%{$DOT.text}}
  |  DOTDOT
    -> {%{$DOTDOT.text}}
  |  NAMESPACE
    -> {%{$NAMESPACE.text}}
  |  CDATASTART
    -> {%{$CDATASTART.text}}
  |  cd=CDATAELMEND
    -> generic(content={$cd.text})
  | CHILD 
    -> {%{$CHILD.text}}
  | DESCENDANT 
    -> {%{$DESCENDANT.text}}
  | ATTRIBUTE 
    -> {%{$ATTRIBUTE.text}}
  | SELF 
    -> {%{$SELF.text}}
  | DESCENDANTORSELF 
    -> {%{$DESCENDANTORSELF.text}}
  | FOLLOWINGSIBLING 
    -> {%{$FOLLOWINGSIBLING.text}}
  | FOLLOWING 
    -> {%{$FOLLOWING.text}}
  | PARENT 
    -> {%{$PARENT.text}}
  | ANCESTOR 
    -> {%{$ANCESTOR.text}}
  | PRECEDINGSIBLING 
    -> {%{$PRECEDINGSIBLING.text}}
  | PRECEDING 
    -> {%{$PRECEDING.text}}
  | ANCESTORORSELF 
    -> {%{$ANCESTORORSELF.text}}
  | BOUNDARYSPACE 
    -> {%{$BOUNDARYSPACE.text}}
  | STRIP 
    -> {%{$STRIP.text}}
  | VARIABLE 
    -> {%{$VARIABLE.text}}
  | IMPORT 
    -> {%{$IMPORT.text}}
  | EXTERNAL 
    -> {%{$EXTERNAL.text}}
  | NOPRESERVE 
    -> {%{$NOPRESERVE.text}}
  | PRESERVE 
    -> {%{$PRESERVE.text}}
  | CONSTRUCTION 
    -> {%{$CONSTRUCTION.text}}
  | MODULE 
    -> {%{$MODULE.text}}
  | INHERIT 
    -> {%{$INHERIT.text}}
  | NOINHERIT 
    -> {%{$NOINHERIT.text}}
  | SCHEMA 
    -> {%{$SCHEMA.text}}
  | EMPTY 
    -> {%{$EMPTY.text}}
  | ORDERING 
    -> {%{$ORDERING.text}}
  | ASCENDING
    -> {%{$ASCENDING.text}}
  | DESCENDING 
    -> {%{$DESCENDING.text}}
  | COPYNAMESPACES 
    -> {%{$COPYNAMESPACES.text}}
  | XQUERY 
    -> {%{$XQUERY.text}}
  | VERSION 
    -> {%{$VERSION.text}}
  | ENCODING 
    -> {%{$ENCODING.text}}
  | LAX 
    -> {%{$LAX.text}}
  | CASE 
    -> {%{$CASE.text}}
  | EVERY 
    -> {%{$EVERY.text}}
  | TYPESWITCH 
    -> {%{$TYPESWITCH.text}}
  | SATISFIES 
    -> {%{$SATISFIES.text}}
  | VALIDATE 
    -> {%{$VALIDATE.text}}
  | SOME 
    -> {%{$SOME.text}}
  | STRICT 
    -> {%{$STRICT.text}}
  ;

xmlAttribute
  : ^(T_XML_ATTRIBUTE name=NCNAME value=QSTRING)
  -> xmlAttribute(name={$name}, value={$value})
  ;

