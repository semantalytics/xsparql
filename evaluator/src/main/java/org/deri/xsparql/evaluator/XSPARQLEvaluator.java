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
package org.deri.xsparql.evaluator;

import java.io.*;
import java.util.HashMap;
import java.util.Map;

import org.deri.xquery.*;
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
  private XQueryEngine xqueryEngine = XQueryEngine.SAXONHE;
  private Map<String, String> externalVars = new HashMap<String, String>();

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
  public void evaluate(Reader is, Writer out) throws IOException, Exception {
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
    xqueryEval = xqueryEngine.getXQueryEvaluator();
    xqueryEval.setExternalVariables(externalVars);
    return xqueryEval.evaluate(xquery);
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
    xqueryEval.evaluate(query, out);
  }

  public void setXQueryEngine(XQueryEngine xee) {
    this.xqueryEngine = xee;
  }

}
