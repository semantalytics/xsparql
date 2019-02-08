/**
 *
 * Copyright (C) 2011, NUI Galway.
 * Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, 
 * Vienna University of Technology
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * The names of the COPYRIGHT HOLDERS AND CONTRIBUTORS may not be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * Created on 09 February 2011 by Reasoning and Querying Unit (URQ), 
 * Digital Enterprise Research Institute (DERI) on behalf of NUI Galway.
 * 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
 * on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
 * University of Technology,  Nuno Lopes on behalf of NUI Galway.
 *
 */ 
 
package org.sourceforge.xsparql.rewriter;

import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenSource;

import java.util.Stack;

/**
 * Lexer for XSPARQL generated by JFlex
 */
%%

/* -----------------Options and Declarations Section----------------- */

/*
   The name of the class JFlex will create will be Lexer.
   Will write the code to the file Lexer.java.
*/
%class XSPARQLLexer

/* Make methods private */
%apiprivate

// ANTLR
%implements TokenSource
%type Token

/*
  The current line number can be accessed with the variable yyline
  and the current column number with the variable yycolumn.
*/
%line
%column

/* Use unicode */
%unicode

/*
  Declarations

  Code between %{ and %}, both of which must be at the beginning of a
  line, will be copied letter to letter into the lexer class source.
  Here you declare member variables and functions that are used inside
  scanner actions.
*/
%{

  private boolean debug = false;
  private static final java.util.Map<Integer, String> stateMap = new java.util.HashMap<>();
  private Stack<Integer> stateStack = new Stack<>();
  private static final String[] stateFieldNames = new String[] {
            "YYINITIAL",
            "xmlStartTag",
            "xmlEndTag",
            "xmlElementContents",
            "cdata",
            "SPARQL",
            "SPARQL_PRE_WHERE",
            "SPARQL_WHERE",
            "SPARQL_PRE_CONSTRUCT",
            "SPARQL_CONSTRUCT",
            "SPARQL_VALUES",
            "XQueryComment"
  };

  static {

         for (int i = 0; i < stateFieldNames.length - 1; i++) {
            try {
                final java.lang.reflect.Field field = org.sourceforge.xsparql.rewriter.XSPARQLLexer.class.getDeclaredField(stateFieldNames[i]);
                field.setAccessible(true);
                stateMap.put(field.getInt(null), stateFieldNames[i]);
            } catch(IllegalAccessException e) {
                System.out.println(e);
            } catch(NoSuchFieldException e) {
                System.out.println("Unable to find state mapping for state " + stateFieldNames[i]);
            }
         }
  }

  public void setDebug(final boolean debug) {
    this.debug = debug;
  }

  // implements antlr.TokenSource

  /* (non-Javadoc)
	 * @see org.antlr.runtime.TokenSource#nextToken()
	 */
  public Token nextToken() {
    try {
      return yylex();
    } catch (java.io.IOException e) {
      System.err.println("Lexer: Unable to get next token: " + e.getMessage());
      return Token.EOF_TOKEN;
    }
  }
  
  /* (non-Javadoc)
	 * @see org.antlr.runtime.TokenSource#getSourceName()
	 */
	public String getSourceName() {
	  return "JFlex lexer - unknown source";
 	}

   /*
    * Push current state to stack and change to state
    *
    * @param state The state to switch to
    */
   private void pushStateAndSwitch(final int state) {
      stateStack.push(yystate());
      if(this.debug) {
         System.out.println("Push state => " + getStateName(state));
      }
      switchState(state);
   }

   /*
    * Pop stack state and switch to that state
    */
   private void popState() {
      final int state = stateStack.pop().intValue();
      if(this.debug) {
         System.out.println("Pop state <= " + getStateName(state));
      }
      switchState(state);
   }

   /*
    * Switch to another state without any stack interaction
    */
   private void switchState(final int state) {
      if(this.debug) {
         System.out.println("Switch state => " + getStateName(state));
      }
      yybegin(state);
   }

   /*
    * Get the name of a state, like getTokenName
    */
   private static String getStateName(final int state) {
           return stateMap.getOrDefault(state, "UNKNOWN STATE");
   }

    private int getLine() {
        return this.yyline + 1;
    }

    private int getColumn() {
        return this.yycolumn;
    }

    private Token symbol(final int type, final String text) {
        final CommonToken token = new CommonToken(type, text);
        token.setLine(getLine());
        token.setCharPositionInLine(getColumn());

        if(this.debug) {
           System.out.println("Line " + (yyline + 1) + ", Col " + (yycolumn + 1) + " in state " + getStateName(yystate()) + ": " + XSPARQL.tokenNames[type] + " \"" + text + "\"");
        }
        return token;
    }

    private Token symbol(final int type) {
        final CommonToken token = new CommonToken(type, yytext());
        token.setLine(getLine());
        token.setCharPositionInLine(getColumn());

        if(this.debug) {
           System.out.println("Line " + (yyline + 1) + ", Col " + (yycolumn + 1) + " in state " + getStateName(yystate()) + ": " + XSPARQL.tokenNames[type]);
        }
        return token;
    }

%}


/* -----------------Macro Declarations Section----------------- */

/* inclusive states */
%states xmlStartTag
%states xmlEndTag

/* exclusive states */
%xstates xmlElementContents
%xstates cdata

// state after a "prefix", "from" or "endpoint"
%xstates SPARQL

// state will be entered immediately after a SPARQL where
%xstates SPARQL_PRE_WHERE

// state will be entered after "where {"
%xstates SPARQL_WHERE

// state will be entered immediately after a construct
%xstates SPARQL_PRE_CONSTRUCT

// state will be entered after "construct {"
%xstates SPARQL_CONSTRUCT

// state will be entered after "values"
%xstates SPARQL_VALUES

%xstates XQueryComment

/*
  Macro Declarations

  These declarations are regular expressions that will be used latter
  in the Lexical Rules Section.
*/

/* SPARQL11 https://www.w3.org/TR/sparql11-query/ */

/* A line terminator is a \r (carriage return), \n (line feed), or \r\n. */
LineTerminator    = \r|\n|\r\n

/* White space is a line terminator, space, tab, or line feed. */

/* SPARQL11 [162] */
WhiteSpace = {LineTerminator} | [ \t\f]

/* SPARQL11 [164] */
PN_CHARS_BASE = [A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD]

/* SPARQL11 [165] */
PN_CHARS_U = {PN_CHARS_BASE} | _

/* SPARQL11 [167] */
PN_CHARS = {PN_CHARS_U} | - | {digit} | \u00B7 | [\u0300-\u036F] | [\u203F-\u2040]

/* SPARQL11 [168] */
PN_PREFIX = {PN_CHARS_BASE} (({PN_CHARS}|\.)* {PN_CHARS})?

/* SPARQL11 [169] */
PN_LOCAL = ( {PN_CHARS_U} | [0-9] ) (({PN_CHARS}|\.)* {PN_CHARS})?

/* SPARQL11 [139] */
/* TODO not sure if this is correct */
iri = < ([^<>\"\{\}\|\^`\\])* >

/* SPARQL11 [144] */
var = [\$][a-zA-Z]([a-zA-Z0-9\_\-\.]*[a-zA-Z0-9\_\-]+)?

/* SPARQL11 [166] */
/* included in definition of var */
/* VARNAME */

digit = [0-9]

%%

<YYINITIAL, xmlElementContents, SPARQL_CONSTRUCT, xmlStartTag> 
{

  \</{WhiteSpace}    { return symbol(XSPARQL.LESSTHAN, yytext()); }

  \<         { pushStateAndSwitch(xmlStartTag);
               return symbol(XSPARQL.LESSTHAN, yytext()); }

}

<SPARQL_WHERE> 
{
"bind"       		{ return symbol(XSPARQL.BIND, yytext()); }
  
  \<         { return symbol(XSPARQL.LESSTHAN, yytext()); }

}

<YYINITIAL, xmlElementContents, SPARQL_WHERE, SPARQL_VALUES, SPARQL_CONSTRUCT, xmlStartTag> 
{

\/         { return symbol(XSPARQL.SLASH, yytext()); }
//\/\/     { return symbol(XSPARQL.SLASHSLASH, yytext()); }
\[         { return symbol(XSPARQL.LBRACKET, yytext()); }
\]         { return symbol(XSPARQL.RBRACKET, yytext()); }
\(         { return symbol(XSPARQL.LPAR, yytext()); }
\)         { return symbol(XSPARQL.RPAR, yytext()); }
\;         { return symbol(XSPARQL.SEMICOLON, yytext()); }
\"(\"\"|[^\"])*\" { return symbol(XSPARQL.QSTRING, yytext().substring(1, yytext().length()-1).replaceAll("\"", "\"\"")); }
\'(\'\'|[^\'])*\' { return symbol(XSPARQL.QSTRING, yytext().replaceAll("'''", "\"\"\"").substring(1, yytext().length()-1).replaceAll("\"", "\"\"")); }
{digit}+     { return symbol(XSPARQL.INTEGER, yytext()); }
/*"."{digit}+  { return symbol(XSPARQL.DECIMAL, yytext()); }*/
/*[0-9]+"."[0-9]*  { return symbol(XSPARQL.DECIMAL, yytext()); }*/
/*("e"|"E")[0-9]+  { return symbol(XSPARQL.EXPONENT, yytext()); }*/
/*[0-9]+\.[0-9]*[eE][\+\-]?[0-9]+  { return symbol(XSPARQL.DOUBLET, yytext()); }*/
/*"."[0-9]+[eE][\+\-]?[0-9]+  { return symbol(XSPARQL.DOUBLET, yytext()); }*/
/*[0-9]+("e"|"E")(\+|\-)?[0-9]+  { return symbol(XSPARQL.DOUBLET, yytext()); }*/
\.         { return symbol(XSPARQL.DOT, yytext()); }
@          { return symbol(XSPARQL.AT , yytext()); }
\^       { return symbol(XSPARQL.CARET, yytext()); }
//\^\^       { return symbol(XSPARQL.CARETCARET, yytext()); }
\:\=       { return symbol(XSPARQL.ASSIGN, yytext()); }
\:         { return symbol(XSPARQL.COLON, yytext()); }
\:\:       { return symbol(XSPARQL.COLONCOLON, yytext()); }
\,         { return symbol(XSPARQL.COMMA, yytext()); }
\=         { return symbol(XSPARQL.EQUALS, yytext()); }
\*         { return symbol(XSPARQL.STAR, yytext()); }
\.\.       { return symbol(XSPARQL.DOTDOT, yytext()); }
\+         { return symbol(XSPARQL.PLUS, yytext()); }
\-         { return symbol(XSPARQL.MINUS, yytext()); }
\|         { return symbol(XSPARQL.UNIONSYMBOL, yytext()); }
&&         { return symbol(XSPARQL.ANDSYMBOL, yytext()); }
\|\|       { return symbol(XSPARQL.ORSYMBOL, yytext()); }
\?         { return symbol(XSPARQL.QUESTIONMARK, yytext()); }
\<\<       { return symbol(XSPARQL.LESSTHANLESSTHAN, yytext()); }
\>\=       { return symbol(XSPARQL.GREATERTHANEQUALS, yytext()); }
\<\=       { return symbol(XSPARQL.LESSTHANEQUALS, yytext()); }
\!\=       { return symbol(XSPARQL.HAFENEQUALS, yytext()); }
\!         { return symbol(XSPARQL.NOT, yytext()); }

}

<YYINITIAL, xmlElementContents, SPARQL_WHERE, SPARQL_CONSTRUCT, SPARQL_VALUES> 
{

/* keywords */

"a"                      { return symbol(XSPARQL.A, yytext()); }
"is"                     { return symbol(XSPARQL.IS, yytext()); }
"eq"                     { return symbol(XSPARQL.EQ, yytext()); }
"ne"                     { return symbol(XSPARQL.NE, yytext()); }
"lt"                     { return symbol(XSPARQL.LT, yytext()); }
"ge"                     { return symbol(XSPARQL.GE, yytext()); }
"le"                     { return symbol(XSPARQL.LE, yytext()); }
"gt"                     { return symbol(XSPARQL.GT, yytext()); }
"for"                    { return symbol(XSPARQL.FOR, yytext()); }
"endpoint"               { pushStateAndSwitch(SPARQL); return symbol(XSPARQL.ENDPOINT, yytext()); }
"from"                   { pushStateAndSwitch(SPARQL); return symbol(XSPARQL.FROM, yytext()); }
"limit"                  { return symbol(XSPARQL.LIMIT, yytext()); }
"offset"                 { return symbol(XSPARQL.OFFSET, yytext()); }
"distinct"               { return symbol(XSPARQL.DISTINCT, yytext()); }
"reduced" 	             { return symbol(XSPARQL.REDUCED, yytext()); }
"group"                  { return symbol(XSPARQL.GROUP, yytext()); }
"having"                 { return symbol(XSPARQL.HAVING, yytext()); }
"let"                    { return symbol(XSPARQL.LET, yytext()); }
"order"                  { return symbol(XSPARQL.ORDER, yytext()); }
"by"                     { return symbol(XSPARQL.BY, yytext()); }
"at"                     { return symbol(XSPARQL.AT, yytext()); }
"in"                     { return symbol(XSPARQL.IN, yytext()); }
"as"                     { return symbol(XSPARQL.AS, yytext()); }
"descending"             { return symbol(XSPARQL.DESCENDING, yytext()); }
"ascending"              { return symbol(XSPARQL.ASCENDING, yytext()); }
"stable"                 { return symbol(XSPARQL.STABLE, yytext()); }
"row"                    { return symbol(XSPARQL.ROW, yytext()); }
"if"                     { return symbol(XSPARQL.IF, yytext()); }
"then"                   { return symbol(XSPARQL.THEN, yytext()); }
"else"                   { return symbol(XSPARQL.ELSE, yytext()); }
"return"                 { return symbol(XSPARQL.RETURN, yytext()); }
"construct"              { pushStateAndSwitch(SPARQL_PRE_CONSTRUCT); return symbol(XSPARQL.CONSTRUCT, yytext()); }
"where"/{WhiteSpace}*\{  { pushStateAndSwitch(SPARQL_PRE_WHERE); return symbol(XSPARQL.WHERE, yytext()); }
"where"                  { return symbol(XSPARQL.WHERE, yytext()); }
"greatest"               { return symbol(XSPARQL.GREATEST, yytext()); }
"least"                  { return symbol(XSPARQL.LEAST, yytext()); }
"collation"              { return symbol(XSPARQL.COLLATION, yytext()); }
"ordered"                { return symbol(XSPARQL.ORDERED, yytext()); }
"unordered"              { return symbol(XSPARQL.UNORDERED, yytext()); }
"declare"                { return symbol(XSPARQL.DECLARE, yytext()); }
"namespace"              { return symbol(XSPARQL.NAMESPACE, yytext()); }
"default"                { return symbol(XSPARQL.DEFAULT, yytext()); }
"element"                { return symbol(XSPARQL.ELEMENT, yytext()); }
"option"                 { return symbol(XSPARQL.OPTION, yytext()); }
"function"               { return symbol(XSPARQL.FUNCTION, yytext()); }
"base-uri"               { return symbol(XSPARQL.BASEURI, yytext()); }
"prefix"                 { pushStateAndSwitch(SPARQL); return symbol(XSPARQL.PREFIX, yytext()); }
"base"                   { pushStateAndSwitch(SPARQL); return symbol(XSPARQL.BASE, yytext()); }
"and"                    { return symbol(XSPARQL.AND, yytext()); }
"or"                     { return symbol(XSPARQL.OR, yytext()); }
"to"                     { return symbol(XSPARQL.TO, yytext()); }
"div"                    { return symbol(XSPARQL.DIV, yytext()); }
"idiv"                   { return symbol(XSPARQL.IDIV, yytext()); }
"mod"                    { return symbol(XSPARQL.MOD, yytext()); }
"union"                  { return symbol(XSPARQL.UNION, yytext()); }
"intersect"              { return symbol(XSPARQL.INTERSECT, yytext()); }
"except"                 { return symbol(XSPARQL.EXCEPT, yytext()); }
"instance"               { return symbol(XSPARQL.INSTANCE, yytext()); }
"treat"                  { return symbol(XSPARQL.TREAT, yytext()); }
"castable"               { return symbol(XSPARQL.CASTABLE, yytext()); }
"cast"                   { return symbol(XSPARQL.CAST, yytext()); }
"of"                     { return symbol(XSPARQL.OF, yytext()); }
"empty-sequence"         { return symbol(XSPARQL.EMPTYSEQUENCE, yytext()); }
"item"                   { return symbol(XSPARQL.ITEM, yytext()); }
"node"                   { return symbol(XSPARQL.NODE, yytext()); }
"document-node"          { return symbol(XSPARQL.DOCUMENTNODE, yytext()); }
/* "text"                   { return symbol(XSPARQL.TEXT, yytext()); } */
"comment"                { return symbol(XSPARQL.COMMENT, yytext()); }
"processing-instruction" { return symbol(XSPARQL.PROCESSINGINSTRUCTION, yytext()); }
"schema-attribute"       { return symbol(XSPARQL.SCHEMAATTRIBUTE, yytext()); }
"schema-element"         { return symbol(XSPARQL.SCHEMAELEMENT, yytext()); }
"document"               { return symbol(XSPARQL.DOCUMENT, yytext()); }
"optional"               { return symbol(XSPARQL.OPTIONAL, yytext()); }
"filter"                 { return symbol(XSPARQL.FILTER, yytext()); }
"str"                    { return symbol(XSPARQL.STR, yytext()); }
"lang"                   { return symbol(XSPARQL.LANG, yytext()); }
"langmatches"            { return symbol(XSPARQL.LANGMATCHES, yytext()); }
"datatype"               { return symbol(XSPARQL.DATATYPE, yytext()); }
"bound"                  { return symbol(XSPARQL.BOUND, yytext()); }
"isiri"                  { return symbol(XSPARQL.ISIRI, yytext()); }
"isuri"                  { return symbol(XSPARQL.ISURI, yytext()); }
"isblank"                { return symbol(XSPARQL.ISBLANK, yytext()); }
"isliteral"              { return symbol(XSPARQL.ISLITERAL, yytext()); }
"regex"                  { return symbol(XSPARQL.REGEX, yytext()); }
"true"                   { return symbol(XSPARQL.TRUE, yytext()); }
"false"                  { return symbol(XSPARQL.FALSE, yytext()); }
"graph"                  { return symbol(XSPARQL.GRAPH, yytext()); }

"count"                  { return symbol(XSPARQL.COUNT, yytext()); }
"sum"                  	 { return symbol(XSPARQL.SUM, yytext()); }
"max"                  	 { return symbol(XSPARQL.MAX, yytext()); }
"min"                  	 { return symbol(XSPARQL.MIN, yytext()); }
"avg"                  	 { return symbol(XSPARQL.AVG, yytext()); }
"sample"               	 { return symbol(XSPARQL.SAMPLE, yytext()); }
"group_concat"         	 { return symbol(XSPARQL.GROUP_CONCAT, yytext()); }
"separator"         	 { return symbol(XSPARQL.SEPARATOR, yytext()); }

/*SPARQL 1.1*/
"select"	 		{ return symbol(XSPARQL.SELECT, yytext()); }
"exists"	 		{ return symbol(XSPARQL.EXISTS, yytext()); }
"not"		 		{ return symbol(XSPARQL.NOTKW, yytext()); }
"minus"		 		{ return symbol(XSPARQL.MINUS, yytext()); }
"service"	 		{ return symbol(XSPARQL.SERVICE, yytext()); }
"silent"	 		{ return symbol(XSPARQL.SILENT, yytext()); }
"values"	 		{ pushStateAndSwitch(SPARQL_VALUES);
					  return symbol(XSPARQL.VALUES, yytext()); }
"undef"		 		{ return symbol(XSPARQL.UNDEF, yytext()); }

"substr"	 		{ return symbol(XSPARQL.SUBSTR, yytext()); }
"replace"	 		{ return symbol(XSPARQL.REPLACE, yytext()); }
"iri"		 		{ return symbol(XSPARQL.IRI, yytext()); }
"uri"		 		{ return symbol(XSPARQL.URI, yytext()); }
"bnode"		 		{ return symbol(XSPARQL.BNODE, yytext()); }
"abs"		 		{ return symbol(XSPARQL.ABS, yytext()); }
"ceil"		 		{ return symbol(XSPARQL.CEIL, yytext()); }
"floor"		 		{ return symbol(XSPARQL.FLOOR, yytext()); }
"round"		 		{ return symbol(XSPARQL.ROUND, yytext()); }
"concat"			{ return symbol(XSPARQL.CONCAT, yytext()); }
"strlen"			{ return symbol(XSPARQL.STRLEN, yytext()); }
"ucase"		 		{ return symbol(XSPARQL.UCASE, yytext()); }
"lcase"		 		{ return symbol(XSPARQL.LCASE, yytext()); }
"encode_for_uri"	{ return symbol(XSPARQL.ENCODE_FOR_URI, yytext()); }
"contains"			{ return symbol(XSPARQL.CONTAINS, yytext()); }
"strstarts"	 		{ return symbol(XSPARQL.STRSTARTS, yytext()); }
"strends"	 		{ return symbol(XSPARQL.STRENDS, yytext()); }
"strbefore"	 		{ return symbol(XSPARQL.STRBEFORE, yytext()); }
"strafter"	 		{ return symbol(XSPARQL.STRAFTER, yytext()); }
"isnumeric"	 		{ return symbol(XSPARQL.ISNUMERIC, yytext()); }
"year"		 		{ return symbol(XSPARQL.YEAR, yytext()); }
"month"		 		{ return symbol(XSPARQL.MONTH, yytext()); }
"day"		 		{ return symbol(XSPARQL.DAY, yytext()); }
"hours"		 		{ return symbol(XSPARQL.HOURS, yytext()); }
"minutes"	 		{ return symbol(XSPARQL.MINUTES, yytext()); }
"seconds"	 		{ return symbol(XSPARQL.SECONDS, yytext()); }
"timezone"	 		{ return symbol(XSPARQL.TIMEZONE, yytext()); }
"tz"		 		{ return symbol(XSPARQL.TZ, yytext()); }
"now"		 		{ return symbol(XSPARQL.NOW, yytext()); }
"uuid"		 		{ return symbol(XSPARQL.UID, yytext()); }
"struuid"	 		{ return symbol(XSPARQL.STRUUID, yytext()); }
"md5"		 		{ return symbol(XSPARQL.MD5, yytext()); }
"sha1"		 		{ return symbol(XSPARQL.SHA1, yytext()); }
"sha256"	 		{ return symbol(XSPARQL.SHA256, yytext()); }
"sha384"	 		{ return symbol(XSPARQL.SHA384, yytext()); }
"sha512"	 		{ return symbol(XSPARQL.SHA512, yytext()); }
"coalesce"	 		{ return symbol(XSPARQL.COALESCE, yytext()); }
"if"	 			{ return symbol(XSPARQL.IF, yytext()); }
"strlang"	 		{ return symbol(XSPARQL.STRLANG, yytext()); }
"strdt"	 			{ return symbol(XSPARQL.STRDT, yytext()); }
"sameterm"	 		{ return symbol(XSPARQL.SAME_TERM, yytext()); }

}

<YYINITIAL, xmlElementContents> 
{

"child"                  { return symbol(XSPARQL.CHILD, yytext()); }
"descendant"             { return symbol(XSPARQL.DESCENDANT, yytext()); }
"attribute"              { return symbol(XSPARQL.ATTRIBUTE, yytext()); }
"self"                   { return symbol(XSPARQL.SELF, yytext()); }
"descendant-or-self"     { return symbol(XSPARQL.DESCENDANTORSELF, yytext()); }
"following-sibling"      { return symbol(XSPARQL.FOLLOWINGSIBLING, yytext()); }
"following"              { return symbol(XSPARQL.FOLLOWING, yytext()); }
"parent"                 { return symbol(XSPARQL.PARENT, yytext()); }
"ancestor"               { return symbol(XSPARQL.ANCESTOR, yytext()); }
"preceding-sibling"      { return symbol(XSPARQL.PRECEDINGSIBLING, yytext()); }
"preceding"              { return symbol(XSPARQL.PRECEDING, yytext()); }
"ancestor-or-self"       { return symbol(XSPARQL.ANCESTORORSELF, yytext()); }

"boundary-space"         { return symbol(XSPARQL.BOUNDARYSPACE, yytext()); }
"strip"                  { return symbol(XSPARQL.STRIP, yytext()); }
"variable"               { return symbol(XSPARQL.VARIABLE, yytext()); }
"import"                 { return symbol(XSPARQL.IMPORT, yytext()); }
"no-preserve"            { return symbol(XSPARQL.NOPRESERVE, yytext()); }
"preserve"               { return symbol(XSPARQL.PRESERVE, yytext()); }
"construction"           { return symbol(XSPARQL.CONSTRUCTION, yytext()); }
"module"                 { return symbol(XSPARQL.MODULE, yytext()); }
"inherit"                { return symbol(XSPARQL.INHERIT, yytext()); }
"no-inherit"             { return symbol(XSPARQL.NOINHERIT, yytext()); }
"schema"                 { return symbol(XSPARQL.SCHEMA, yytext()); }
"import"                 { return symbol(XSPARQL.IMPORT, yytext()); }
"empty"                  { return symbol(XSPARQL.EMPTY, yytext()); }
"external"               { return symbol(XSPARQL.EXTERNAL, yytext()); }
"ordering"               { return symbol(XSPARQL.ORDERING, yytext()); }
"copy-namespaces"        { return symbol(XSPARQL.COPYNAMESPACES, yytext()); }
"xquery"                 { return symbol(XSPARQL.XQUERY, yytext()); }
"version"                { return symbol(XSPARQL.VERSION, yytext()); }
"encoding"               { return symbol(XSPARQL.ENCODING, yytext()); }
"lax"                    { return symbol(XSPARQL.LAX, yytext()); }
"case"                   { return symbol(XSPARQL.CASE, yytext()); }
"every"                  { return symbol(XSPARQL.EVERY, yytext()); }
"typeswitch"             { return symbol(XSPARQL.TYPESWITCH, yytext()); }
"satisfies"              { return symbol(XSPARQL.SATISFIES, yytext()); }
"validate"               { return symbol(XSPARQL.VALIDATE, yytext()); }
"some"                   { return symbol(XSPARQL.SOME, yytext()); }
"strict"                 { return symbol(XSPARQL.STRICT, yytext()); }

}

<YYINITIAL, xmlElementContents, SPARQL_WHERE, SPARQL_CONSTRUCT, SPARQL_VALUES> 
{

"asc"                    { return symbol(XSPARQL.ASC, yytext()); }
"desc"                   { return symbol(XSPARQL.DESC, yytext()); }

}


/* -----------------Lexer rules Section----------------- */


<YYINITIAL, SPARQL_WHERE, SPARQL_CONSTRUCT, SPARQL_VALUES, xmlStartTag, xmlEndTag> 
{

  _:{PN_PREFIX}  { return symbol(XSPARQL.BLANK_NODE_LABEL, yytext()); }

  _:({PN_PREFIX})?/\{ { return symbol(XSPARQL.BNODE_CONSTRUCT, yytext()); }

  {PN_PREFIX}?:{PN_LOCAL} { return symbol(XSPARQL.PNAME_LN, yytext()); }
  
  {PN_PREFIX}?:/[^\:\{] { return symbol(XSPARQL.PNAME_NS, yytext()); }

  {PN_PREFIX}    { return symbol(XSPARQL.NCNAME, yytext()); }

}

<YYINITIAL, xmlElementContents, SPARQL_WHERE, SPARQL_CONSTRUCT, SPARQL_VALUES>
   {var}          { return symbol(XSPARQL.VAR, yytext()); }

<YYINITIAL, xmlElementContents, xmlStartTag, XQueryComment>
   "(:"           { pushStateAndSwitch(XQueryComment); }

<XQueryComment>  {
   [^(\(\:)(\:\))]* { /* skip XQueryComment */ }

   [:\(\)]        { /* skip XQueryComment */ }

   ":)"           { popState(); }
}


<YYINITIAL, xmlElementContents>
   <\/            { switchState(xmlEndTag);
                    return symbol(XSPARQL.ENDELM, yytext()); }


<YYINITIAL, xmlElementContents>
   \>             { return symbol(XSPARQL.GREATERTHAN, yytext()); }


<YYINITIAL, xmlStartTag, xmlEndTag, xmlElementContents, SPARQL_CONSTRUCT, SPARQL_WHERE, SPARQL_VALUES>
   \}             { popState();
                    return symbol(XSPARQL.RCURLY, yytext()); }


<YYINITIAL, xmlStartTag, xmlEndTag, xmlElementContents>
   \{             { pushStateAndSwitch(YYINITIAL);
                    return symbol(XSPARQL.LCURLY, yytext()); }



<YYINITIAL, xmlStartTag, xmlEndTag, xmlElementContents, SPARQL_CONSTRUCT, SPARQL_WHERE, SPARQL_VALUES> {

   \#.*           { /* ignore comments */ }

   \}>            { popState();
                    return symbol(XSPARQL.RCURLYGREATERTHAN, yytext());}
}


<xmlStartTag> {

   \>             { switchState(xmlElementContents);
                    return symbol(XSPARQL.GREATERTHAN, yytext()); }

   \/\>           { popState();
                    return symbol(XSPARQL.ENDTAG, yytext()); }
}


<xmlEndTag> {

   \>             { popState();
                    return symbol(XSPARQL.GREATERTHAN, yytext()); }
}


<xmlElementContents> {

   "<![CDATA["    { pushStateAndSwitch(cdata);
                    return symbol(XSPARQL.CDATASTART, yytext()); }



   [^\{\}\<(\(\:)]+ { return symbol(XSPARQL.NCNAMEELM, yytext()); }

}


<cdata> {
/*   (.|\n|\t|\r)*\]\]> { popState();*/
   (.|[^]|\n|\t|\r)*\]\]> { popState();
                    return symbol(XSPARQL.CDATAELMEND, yytext()); }
}

/* ------------------------- WHITESPACE ------------------------------------- */


<xmlStartTag, xmlElementContents, xmlEndTag>
   {WhiteSpace}+  { return symbol(XSPARQL.WHITESPACE, yytext()); }


<YYINITIAL, SPARQL, SPARQL_PRE_WHERE, SPARQL_PRE_CONSTRUCT, SPARQL_WHERE, SPARQL_CONSTRUCT, SPARQL_VALUES>
   {WhiteSpace}+  { /* skip whitespace */ }


/* ------------------------- SPARQL ----------------------------------------- */

<SPARQL> {

   {iri}          {  popState(); return symbol(XSPARQL.IRIREF, yytext().substring(1, yytext().length()-1)); }

   //{PN_PREFIX}?:/[^\:\{] { return symbol(XSPARQL.PNAME_NS, yytext()); }
   {PN_PREFIX}?:/[^\:\{] { return symbol(XSPARQL.PNAME_NS, yytext()); }

   "named"        { return symbol(XSPARQL.NAMED, yytext()); }

   \)            { popState(); return symbol(XSPARQL.RPAR, yytext()); }  // hack to allow from in XPath expressions
   \}            { popState(); return symbol(XSPARQL.RCURLY, yytext()); }  // hack to allow from in XPath expressions

   {PN_PREFIX}    {  popState(); return symbol(XSPARQL.NCNAME, yytext()); }

}

<SPARQL, SPARQL_WHERE, SPARQL_CONSTRUCT, SPARQL_VALUES>
   {var}          { popState(); return symbol(XSPARQL.VAR, yytext()); }

<SPARQL_PRE_WHERE>
   \{             { switchState(SPARQL_WHERE); return symbol(XSPARQL.LCURLY, yytext()); }


<SPARQL_PRE_CONSTRUCT>{
   \{             { switchState(SPARQL_CONSTRUCT); return symbol(XSPARQL.LCURLY, yytext()); }
   "where"        { switchState(SPARQL_PRE_WHERE); return symbol(XSPARQL.WHERE, yytext()); }
}

<SPARQL_WHERE> {
   {iri}          { return symbol(XSPARQL.IRIREF, yytext()); }

   \{             { pushStateAndSwitch(SPARQL_WHERE); return symbol(XSPARQL.LCURLY, yytext()); }

   \>             { return symbol(XSPARQL.GREATERTHAN, yytext()); }
}

<SPARQL_VALUES> {
   {iri}          { return symbol(XSPARQL.IRIREF, yytext()); }
   \{             { return symbol(XSPARQL.LCURLY, yytext()); }
   
   \}            { popState(); return symbol(XSPARQL.RCURLY, yytext()); }  // hack to allow from in XPath expressions
}

<SPARQL_CONSTRUCT> {
   {iri}   { return symbol(XSPARQL.IRIREF, yytext()); }

   \{             { pushStateAndSwitch(YYINITIAL);
                    return symbol(XSPARQL.LCURLY, yytext()); }

   "<{"           { pushStateAndSwitch(YYINITIAL);
                    return symbol(XSPARQL.LESSTHANLCURLY,yytext()); }
}


/* No token was found for the input so through an error.  Print out an
   Illegal character message with the illegal character that was found. */
<YYINITIAL, xmlStartTag, xmlEndTag, xmlElementContents, SPARQL, SPARQL_PRE_WHERE, SPARQL_WHERE, SPARQL_PRE_CONSTRUCT, SPARQL_CONSTRUCT, SPARQL_VALUES, XQueryComment, XQueryComment>
   [^]            { throw new Error("Illegal character <" + (yyline+1) + ":" + (yycolumn+1) + ">  \""+yytext()+"\""); }

