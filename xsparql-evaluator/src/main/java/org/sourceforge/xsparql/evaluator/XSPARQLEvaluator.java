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
package org.sourceforge.xsparql.evaluator;

import java.io.BufferedReader;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.net.URL;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.xml.transform.Source;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.sourceforge.xsparql.rewriter.XSPARQLProcessor;
import org.sourceforge.xsparql.sparql.binder.StaticSparqlFunctionBinder;
import org.sourceforge.xsparql.sql.SQLQuery;
import org.sourceforge.xsparql.xquery.XQueryEvaluator;

/**
 * Class to evaluate an XSPARQL query. Either use the <code>evaluate</code>
 * methods or use the <code>XSPARQLProcessor.process</code> and the
 * <code>evaluateRewritten</code> method.
 */
public final class XSPARQLEvaluator {

	private static final Logger logger = LogManager.getLogger(XSPARQLEvaluator.class);

	private SQLQuery sqlQuery = null;
	private XSPARQLProcessor xsparqlProc;
	private XQueryEvaluator xqueryEval;

	/**
	 * Path to Jena TDB database
	 */
//	private String TDBLocation = System.getProperty("user.home")
//			+ "/.xsparql/TDB";

//	public String getTDBLocation() {
//		return TDBLocation;
//	}
//
//	public void setTDBLocation(String tDBLocation) {
//		TDBLocation = tDBLocation;
//	}
//
	/**
	 * Directory containing the TDB database
	 */
//	private File tdbDir = null;
	private XQueryEngine xqueryEngine = XQueryEngine.SAXONHE;
	private Map<String, String> externalVars = new HashMap<String, String>();
	private Source source;
	private String queryFilename;

	private Set<URL> defaultGraphs = new HashSet<URL>();
	private Set<URL> namedGraphs = new HashSet<URL>();

//	/**
//	 * @return
//	 */
//	public File getTdbDir() {
//		return tdbDir;
//	}
//
//	/**
//	 * @param tdbDir
//	 */
//	public void setTdbDir(File tdbDir) {
//		this.tdbDir = tdbDir;
//	}

	/**
	 * Creates a new <code>XSPARQLEvaluator</code> instance.
	 *
	 */
	public XSPARQLEvaluator() {
		super();
		xsparqlProc = new XSPARQLProcessor();
		xqueryEngine = XQueryEngine.SAXONHE;
	}

	public Set<URL> getDefaultGraphs() {
		return defaultGraphs;
	}

	public void addDefaultGraph(final URL graph) {
		this.defaultGraphs.add(graph);
	}

	public void addDefaultGraphs(final Collection<URL> graphs) {
		this.defaultGraphs.addAll(graphs);
	}

	public Set<URL> getNamedGraphs() {
		return namedGraphs;
	}

	public void addNamedGraph(final URL namedGraph) {
		this.namedGraphs.add(namedGraph);
	}

	public void addNamedGraphs(final Collection<URL> namedGraphs) {
		this.namedGraphs.addAll(namedGraphs);
	}

	/**
	 * @param xqueryExternalVars
	 */
	public void setXqueryExternalVars(final Map<String, String> xqueryExternalVars) {
		this.externalVars = xqueryExternalVars;
	}

	public void addXQueryExternalVar(final String key, final String value) {
		this.externalVars.put(key, value);
	}

	/**
	 * The input stream <code>is</code> is processed as containing an XSPARQL
	 * query, the XQuery is evaluated and the result is output to the stream
	 * <code>out</code>.
	 * 
	 * @param is XSPARQL query
	 * @param out a <code>PrintStream</code> value
	 * @exception Exception
	 */
	public void evaluate(final Reader is, final Writer out) throws Exception {
		xsparqlProc.setQueryFilename(this.queryFilename);
		final String xquery = xsparqlProc.process(is);
		logger.debug("XQuery: {}", xquery);
		this.evaluateRewrittenQuery(new BufferedReader(new StringReader(xquery)), out);
	}

	/**
	 * The query <code>query</code> is processed as containing an XSPARQL query,
	 * the query is then evaluated using the external variable mappings (variable
	 * name, variable value) in <code>args</code>. The evaluation result is then
	 * returned as String.
	 * 
	 * @param query XSPARQL query
	 * @return query evaluation result
	 * @throws Exception
	 */
	public String evaluate(Reader query) throws Exception {
		Writer os = new StringWriter();
		this.evaluate(query, os);
		return os.toString();
	}

	/**
	 * @param xquery Rewritten XSPARQL query
	 * @throws Exception
	 */
	public String evaluateRewrittenQuery(final String xquery) throws Exception {
		StringWriter sw = new StringWriter();
		this.evaluateRewrittenQuery(new StringReader(xquery), sw);

		return sw.toString();
	}

	/**
	 * @param query Rewritten XSPARQL query
	 * @param out Evaluation result
	 * @throws Exception
	 */
	public void evaluateRewrittenQuery(final Reader query, final Writer out) throws Exception {

		xqueryEval = xqueryEngine.getXQueryEvaluator();
		xqueryEval.setExternalVariables(externalVars);
		xqueryEval.setSource(source);
		xqueryEval.setOutputMethod(xsparqlProc.getOutputMethod());
		xqueryEval.setDBconnection(sqlQuery);
		xqueryEval.setDataset(defaultGraphs, namedGraphs, StaticSparqlFunctionBinder.getInstance().getDatasetManager());
		xqueryEval.evaluate(query, out);
	}

	public void setXQueryEngine(final XQueryEngine xee) {
		this.xqueryEngine = xee;
	}

	public void setSource(final Source source) {
		this.source = source;
	}

	public void setQueryFilename(final String filename) {
		this.queryFilename = filename;
	}

	public void setDBconnection(final SQLQuery q) {
		this.sqlQuery = q;
	}

}
