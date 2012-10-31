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
package org.deri.xsparql.evaluator;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.Source;

import org.deri.sql.SQLQuery;
import org.deri.xquery.XQueryEvaluator;
import org.deri.xsparql.rewriter.XSPARQLProcessor;

/**
 * Class to evaluate an XSPARQL query. Either use the <code>evaluate</code>
 * methods or use the <code>XSPARQLProcessor.process</code> and the
 * <code>evaluateRewritten</code> method.
 * 
 * 
 * Created: Tue Oct 12 12:42:04 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public final class XSPARQLEvaluator {

  private SQLQuery sqlQuery = null;

  /**
   * 
   */
  private XSPARQLProcessor xsparqlProc;
  /**
   * 
   */
  private XQueryEvaluator xqueryEval;
  /**
   * Path to Jena TDB database
   */
  private String TDBLocation = System.getProperty("user.home")
      + "/.xsparql/TDB";

  public String getTDBLocation() {
    return TDBLocation;
  }

  public void setTDBLocation(String tDBLocation) {
    TDBLocation = tDBLocation;
  }

  /**
   * Directory containing the TDB database
   */
  private File tdbDir = null;
  private XQueryEngine xqueryEngine;
  private Map<String, String> externalVars = new HashMap<String, String>();
  private Source source;
  private String queryFilename;

  /**
   * @return
   */
  public File getTdbDir() {
    return tdbDir;
  }

  /**
   * @param tdbDir
   */
  public void setTdbDir(File tdbDir) {
    this.tdbDir = tdbDir;
  }

  /**
   * @param xqueryExternalVars
   */
  public void setXqueryExternalVars(Map<String, String> xqueryExternalVars) {
    this.externalVars = xqueryExternalVars;
  }

  /**
   * @param xqueryExternalVars
   */
  public void addXQueryExternalVar(String key, String value) {
    this.externalVars.put(key, value);
  }

  /**
   * Creates a new <code>XSPARQLEvaluator</code> instance.
   * 
   */
  public XSPARQLEvaluator() {
    super();
    xsparqlProc = new XSPARQLProcessor();
    xqueryEngine = XQueryEngine.SAXONHE;
  }

  /**
   * The input stream <code>is</code> is processed as containing an XSPARQL
   * query, the XQuery is evaluated and the result is output to the stream
   * <code>out</code>.
   * 
   * @param is
   *          XSPARQL query
   * @param out
   *          a <code>PrintStream</code> value
   * @exception IOException
   *              if an error occurs
   * @exception Exception
   *              if an error occurs
   */
  public void evaluate(Reader is, Writer out) throws Exception {
    xsparqlProc.setQueryFilename(this.queryFilename);
    final String xquery = xsparqlProc.process(is);
    this.evaluateRewrittenQuery(new BufferedReader(new StringReader(xquery)),
        out);
  }

  /**
   * The query <code>query</code> is processed as containing an XSPARQL query,
   * the query is then evaluated using the external variable mappings (variable
   * name, variable value) in <code>args</code>. The evaluation result is then
   * returned as String.
   * 
   * @param query
   *          XSPARQL query
   * @return query evaluation result
   * @throws Exception
   */
  public String evaluate(Reader query) throws Exception {
    Writer os = new StringWriter();
    this.evaluate(query, os);
    return os.toString();
  }

  /**
   * @param xquery
   *          Rewritten XSPARQL query
   * @throws Exception
   */
  public String evaluateRewrittenQuery(final String xquery) throws Exception {
    StringWriter sw = new StringWriter();
    this.evaluateRewrittenQuery(new StringReader(xquery), sw);

    return sw.toString();
  }

  /**
   * @param xquery
   *          Rewritten XSPARQL query
   * @param out
   *          Evaluation result
   * @throws Exception
   */
  public void evaluateRewrittenQuery(Reader query, Writer out) throws Exception {

    xqueryEval = xqueryEngine.getXQueryEvaluator();
    xqueryEval.setExternalVariables(externalVars);
    xqueryEval.setSource(source);
    xqueryEval.setOutputMethod(xsparqlProc.getOutputMethod());
    xqueryEval.setDBconnection(sqlQuery);
    xqueryEval.evaluate(query, out);
  }

  public void setXQueryEngine(XQueryEngine xee) {
    this.xqueryEngine = xee;
  }

  public void setSource(Source source) {
    this.source = source;
  }

  public void setQueryFilename(String filename) {
    this.queryFilename = filename;
  }

  public void setDBconnection(SQLQuery q) {
    this.sqlQuery = q;
  }

}
