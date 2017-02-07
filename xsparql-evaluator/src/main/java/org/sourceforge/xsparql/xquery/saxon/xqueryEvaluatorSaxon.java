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
package org.sourceforge.xsparql.xquery.saxon;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.net.URL;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import javax.xml.transform.Source;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XQueryCompiler;
import net.sf.saxon.s9api.XdmAtomicValue;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sourceforge.xsparql.sparql.DatasetManager;
import org.sourceforge.xsparql.sparql.binder.StaticSparqlFunctionBinder;
import org.sourceforge.xsparql.sql.SQLQuery;
import org.sourceforge.xsparql.xquery.XQueryEvaluator;

/**
 * Evaluate an XQuery using the Saxon API
 * 
 * @author Nuno Lopes
 */
public class xqueryEvaluatorSaxon implements XQueryEvaluator {
	private static final Logger logger = LoggerFactory.getLogger(xqueryEvaluatorSaxon.class);
	
	private Processor proc;

	private XQueryCompiler xqueryComp;

	private Serializer serializer;

	private Source source = null;

	private boolean omitXMLDecl = true;

	private SQLQuery sqlQuery = null;

	private Set<URL> defaultGraph;
	private Set<URL> namedGraphs;
	
	private DatasetManager datasetManager;
	
	public void setDBconnection(SQLQuery q) {
		this.sqlQuery = q;

		// RDB functions
		proc.registerExtensionFunction(new sqlQueryExtFunction(sqlQuery));
		proc.registerExtensionFunction(new getRDBTablesExtFunction(sqlQuery));
		proc.registerExtensionFunction(new getRDBTableAttributesExtFunction(sqlQuery));

	}
	
	@Override
	public void setDataset(Set<URL> defaultGraph, Set<URL> namedGraphs, DatasetManager manager) {
		this.defaultGraph = defaultGraph;
		this.namedGraphs = namedGraphs;
		datasetManager = manager;
	}

	/**
	 * use validating XQuery engine
	 */
	public boolean validatingXQuery = true;

	public void setValidatingXQuery(boolean validatingXQuery) {
		this.validatingXQuery = validatingXQuery;
	}

	/**
	 * external variables for Xquery evaluation TODO refactor
	 */
	public Map<String, String> xqueryExternalVars = new HashMap<String, String>();

	public void setExternalVariables(Map<String, String> xqueryExternalVars) {
		this.xqueryExternalVars = xqueryExternalVars;
	}

	public void setSource(Source source) {
		this.source = source;
	}

	/**
	 * Creates a new <code>XQueryEvaluatorSaxon</code> instance.
	 * 
	 */
	public xqueryEvaluatorSaxon(boolean licensedVersion) {

		proc = new Processor(licensedVersion);

		proc.registerExtensionFunction(new turtleGraphToURIExtFunction());
		proc.registerExtensionFunction(new jsonDocExtFunction());

		Set<URL> sparqlFunctionBinderPaths = new LinkedHashSet<URL>();
		try{
			ClassLoader cl = xqueryEvaluatorSaxon.class.getClassLoader();
			Enumeration<URL> paths = cl.getResources("org/sourceforge/xsparql/sparql/binder/StaticSparqlFunctionBinder.class");
			while(paths.hasMoreElements()){
				sparqlFunctionBinderPaths.add(paths.nextElement());
			}
	    } catch (IOException e) {
	    	logger.error("Error while loading the class loader");
	    }
		if(sparqlFunctionBinderPaths.size()>1){
			logger.error("There are too many SPARQL Evaluators!");
			throw new RuntimeException("Too many SPARQL evals");
		}
		else{
			logger.debug("There is {} SPARQL Evaluator!", sparqlFunctionBinderPaths.size());
		}
				
		StaticSparqlFunctionBinder fd = StaticSparqlFunctionBinder.getInstance();
		
		proc.registerExtensionFunction(fd.getSparqlQueryExtFunctionDefinition());
		proc.registerExtensionFunction(fd.getCreateScopedDatasetExtFunctionDefinition());
		proc.registerExtensionFunction(fd.getSparqlScopedDatasetExtFunctionDefinition());
		proc.registerExtensionFunction(fd.getDeleteScopedDatasetExtFunctionDefinition());
		proc.registerExtensionFunction(fd.getScopedDatasetPopResultsExtFunctionDefinition());

		// debug external functions
		//    proc.setConfigurationProperty(FeatureKeys.TRACE_EXTERNAL_FUNCTIONS, true);

		initializeSerializer();

	}
	
	/**
	 * returns the XQuery processor used in the class
	 * 
	 */
	public Processor getProcessor() {
		return proc;
	}

	/**
	 * returns the XQuery serializer used in the class
	 */
	public Serializer getSerializer() {
		return serializer;
	}

	/**
	 * Evaluate the XQuery query using the s9api of Saxon
	 * 
	 * @param query
	 */
	public String evaluate(final String query) throws Exception {
		Writer writer = new StringWriter();
		evaluate(new BufferedReader(new StringReader(query)), writer);

		return writer.toString();
	}

	/**
	 * Evaluate the XQuery query using the s9api of Saxon
	 * 
	 * @param query
	 * @param out
	 *          output
	 * @param vars
	 *          list of external variables
	 */
	public void evaluate(final String query, OutputStream out,
			Map<String, String> vars) throws Exception {

		if (vars != null) {
			xqueryExternalVars = vars;
		}

		this.evaluate(new BufferedReader(new StringReader(query)),
				new BufferedWriter(new OutputStreamWriter(out)));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.deri.xquery.XQueryEvaluator#setOmitXMLDecl(boolean)
	 */
	public void setOmitXMLDecl(boolean xmloutput) {
		this.omitXMLDecl = xmloutput;

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.deri.xquery.XQueryEvaluator#applyOutputProperty()
	 */
	public void setOutputMethod(String outputMethod) {
		serializer.setOutputProperty(Serializer.Property.METHOD, outputMethod);
	}

	/**
	 * 
	 */
	private void initializeSerializer() {
		serializer = new Serializer();
		// can be xml, html, xhtml, or text.
		// TODO: possibly add parameter to the command line.
		serializer.setOutputProperty(Serializer.Property.OMIT_XML_DECLARATION,
				omitXMLDecl ? "yes" : "no");
		serializer.setOutputProperty(Serializer.Property.INDENT, "yes");
	}

	public void evaluate(InputStream query, OutputStream out) throws Exception {
		evaluate(new BufferedReader(new InputStreamReader(query)),
				new BufferedWriter(new OutputStreamWriter(out)));
	}

	public void evaluate(Reader query, Writer out) throws Exception {
		serializer.setOutputWriter(out);

		// create a new XQuery compiler, this should be able to be reused,
		// see Saxon bug at:
		// http://sourceforge.net/tracker/?func=detail&aid=3008672&group_id=29872&atid=397617
		xqueryComp = proc.newXQueryCompiler();

		net.sf.saxon.s9api.XQueryEvaluator evaluator = xqueryComp.compile(query)
				.load();

		//TODO: reset at every evaluation (it should be optimizable) 
		if (datasetManager != null) {
			datasetManager.clean();
			datasetManager.setDataset(defaultGraph, namedGraphs);
		}
		
		if (source != null)
			evaluator.setSource(source);
		
		for (String name : xqueryExternalVars.keySet()) {
			evaluator.setExternalVariable(new QName(name), new XdmAtomicValue(
					xqueryExternalVars.get(name)));
		}

		try {

			evaluator.run(serializer);

		} catch (SaxonApiException e) {
			throw new Exception(e.getMessage());
		}

	}

}
