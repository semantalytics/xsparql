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
package org.deri.xsparql.rewriter;

import java.util.logging.Logger;

/**
 * class used to store configuration options.
 * 
 * 
 * Created: Thu Sep 30 11:54:42 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class Configuration {

  private static Logger logger = Logger.getLogger(Configuration.class
      .getClass().getName());

  /**
   * Parse in debug mode
   */
  public static boolean debug = false;

  /**
   * Lexer in debug mode
   */
  public static boolean debuglexer = false;

  /**
   * Show debug information
   */
  public static boolean verbose = false;

  /**
   * use validating XQuery engine
   */
  public static boolean validatingXQuery = false;

  /**
   * Print AST?
   */
  public static boolean ast = false;

  /**
   * True if AST pictures should be generated
   */
  public static boolean dot = false;

  /**
   * method to be used to perform SPARQL queries. By default requires a Joseki
   * endpoint
   */
  public static String SPARQLmethod = "arq";

  /**
   * XQuery engine to be used for evaluation/code production.
   */
  public static String xqueryEngine = "saxon-he";

  /**
   * Create a debug version of the query
   */
  public static boolean debugVersion;

  /**
   * SPARQL endpoint uri
   */
  public static String endpointURI;

  public static boolean warnIfNestedConstruct = false;

  /**
   * Specify the output method Saxon uses for serialisation of the output
   */
  private static String outputMethod = null;

  // --------------------------------------------------- ACCESS Methods

  /**
   * Parse in debug mode
   */
  public static boolean debug() {
    return debug;
  }

  /**
   * Show debug information
   */
  public static boolean verbose() {
    return verbose;
  }

  /**
   * Lexer in debug mode
   */
  public static boolean debuglexer() {
    return debuglexer;
  }

  /**
   * use validating XQuery engine
   */
  public static boolean validatingXQuery() {
    return validatingXQuery;
  }

  /**
   * Print AST?
   */
  public static boolean printAst() {
    return ast;
  }

  /**
   * True if AST pictures should be generated
   */
  public static boolean printDot() {
    return dot;
  }

  /**
   * method to be used to perform SPARQL queries. By default requires a Joseki
   * endpoint
   */
  public static String SPARQLmethod() {
    return SPARQLmethod;
  }

  /**
   * XQuery engine to be used for evaluation/code production.
   */
  public static String xqueryEngine() {
    return xqueryEngine;
  }

  /**
   * Create a debug version of the query
   */
  public static boolean debugVersion() {
    return debugVersion;
  }

  /**
   * SPARQL endpoint uri
   */
  public static String endpointURI() {
    return endpointURI;
  }

  public static boolean warnIfNestedConstruct() {
    return warnIfNestedConstruct;
  }

  public static void setValidating(boolean validating) {
    validatingXQuery = validating;
  }

  public static void setXQueryEngine(String engine) {
    xqueryEngine = engine;
  }

  public static String printParams() {
    final int sbSize = 1000;
    final String variableSeparator = "  ";
    final StringBuffer sb = new StringBuffer(sbSize);

    sb.append("logger=").append(logger);
    sb.append(variableSeparator);
    sb.append("debug=").append(debug);
    sb.append(variableSeparator);
    sb.append("debuglexer=").append(debuglexer);
    sb.append(variableSeparator);
    sb.append("verbose=").append(verbose);
    sb.append(variableSeparator);
    sb.append("validatingXQuery=").append(validatingXQuery);
    sb.append(variableSeparator);
    sb.append("ast=").append(ast);
    sb.append(variableSeparator);
    sb.append("dot=").append(dot);
    sb.append(variableSeparator);
    sb.append("outputFile=");
    sb.append(variableSeparator);
    sb.append("SPARQLmethod=").append(SPARQLmethod);
    sb.append(variableSeparator);
    sb.append("xqueryEngine=").append(xqueryEngine);
    sb.append(variableSeparator);
    sb.append("debugVersion=").append(debugVersion);
    sb.append(variableSeparator);
    sb.append("endpointURI=").append(endpointURI);
    sb.append(variableSeparator);
    sb.append("warnIfNestedConstruct=").append(warnIfNestedConstruct);

    return sb.toString();
  }

  /**
   * Set the current output method
   */
  public static void setOutputMethod(String method) {

    outputMethod = method;
  }

  /**
   * @return current output method
   */
  public static String getOutputMethod() {

    return outputMethod;
  }

}
