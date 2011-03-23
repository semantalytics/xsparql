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
package org.deri.xsparql.webapp;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.net.*;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.*; //import net.sf.saxon.trans.XPathException;

import org.deri.xsparql.*;

import net.sf.saxon.s9api.XQueryCompiler;

import org.deri.xsparql.Configuration;
import org.deri.xquery.xqueryEvaluatorSaxon;

public class xsparqlServerServlet extends HttpServlet {

    /**
	 * 
	 */
    private static final long serialVersionUID = -531770540407741938L;

    // Processor processor;
    xqueryEvaluatorSaxon processor;
    XQueryCompiler xqueryComp;
    XSPARQLProcessor proc;

    // do not use the lisenced version
    private boolean licensedSaxon = false;

    public void init() {
	try {
	    System.out.println("Starting XSPARQL servlet...");

	    this.licensedSaxon = Boolean
		    .parseBoolean(getInitParameter("validatingXQuery"));

	    // set the configuration options

	    Configuration.setVerbose(false);
	    Configuration.setValidating(licensedSaxon);
	    Configuration.setXQueryEngine("saxon");

	    // saxon xquery
	    // processor = new Processor(licensedSaxon);
	    processor = new xqueryEvaluatorSaxon();
	    xqueryComp = processor.getProcessor().newXQueryCompiler();
	    SchemaManager schemaManager = processor.getProcessor()
		    .getSchemaManager();

	    // xsparql
	    proc = new XSPARQLProcessor();

	    if (licensedSaxon) {
		// load the xsd
		URL xsd = new URL(
			"http://xsparql.deri.org/demo/xquery/sparql.xsd");
		BufferedReader xsdIn = new BufferedReader(
			new InputStreamReader(xsd.openStream()));
		schemaManager.load(new StreamSource(xsdIn));

		// load the XSPARQL library
		URL module = new URL(
			"http://xsparql.deri.org/demo/xquery/xsparql-types.xquery");
		BufferedReader in = new BufferedReader(new InputStreamReader(
			module.openStream()));
		xqueryComp.compileLibrary(in);
	    }

	} catch (MalformedURLException e) {
	    System.err.println(e.getMessage());
	} catch (IOException e) {
	    System.err.println(e.getMessage());
	} catch (SaxonApiException e) {
	    System.err.println(e.getMessage());
	} catch (Exception e) {
	    System.err.println("createGUI didn't successfully complete");
	}

    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
	    throws ServletException, IOException {

	try {
	    // Map params = req.getParameterMap();

	    String xquery = null;
	    String format = req.getParameter("format");
	    String exec = req.getParameter("exec");
	    String query = req.getParameter("query");
	    String queryFile = req.getParameter("queryFile");
	    String xqueryFile = req.getParameter("xquery");

	    // String method = req.getParameter("method");

	    // Move to Configuration
	    // if (method != null) {
	    // proc.setEvaluationMethod(method);
	    // } else {
	    // proc.setEvaluationMethod("");
	    // }

	    // XSPARQL string
	    if (query != null) {

		System.out.println(query);

		query = URLDecoder.decode(query, "UTF-8");
		// XSPARQL
		InputStream is = new ByteArrayInputStream(query.getBytes());
		xquery = proc.process(is);
	    }

	    // XSPARQL query file
	    if (queryFile != null) {

		System.out.println(queryFile);
		InputStream is = new FileInputStream(queryFile);

		// XSPARQL
		xquery = proc.process(is);

	    }

	    // read only an XQuery file for execution.
	    if (xqueryFile != null) {

		System.out.println(xqueryFile);
		BufferedReader s = new BufferedReader(
			new FileReader(xqueryFile));
		StringBuilder xqueryBuilder = new StringBuilder();
		String line;

		while ((line = s.readLine()) != null) {
		    xqueryBuilder.append(line);
		    xqueryBuilder.append(System.getProperty("line.separator"));
		}

		s.close();

		xquery = xqueryBuilder.toString();
	    }

	    // no query parameter
	    if (xquery == null) {
		resp.getOutputStream().println("No query given!");
		return;
	    }

	    if (xqueryFile != null || (exec != null && exec.equals("true"))) {
		runXQuery(xquery, resp.getOutputStream(), format);
	    } else {

		resp.getWriter().println(xquery);

	    }

	} catch (Exception e) {
	    System.err.println("There was an error handling the request");
	    this.init();
	    return;
	}

    }

    protected void runXQuery(final String xquery, OutputStream out,
	    String format) {

	try {
	    Serializer serializer = processor.getSerializer();
	    serializer.setOutputProperty(Serializer.Property.METHOD, format);

	    if (format.equals("xml")) {
		serializer.setOutputProperty(
			Serializer.Property.OMIT_XML_DECLARATION, "no");
	    }

	    processor.evaluate(xquery, new PrintStream(out));
	} catch (Exception e) {
	    System.err.println("There was an error handling the request: "
		    + e.getMessage());
	    this.init();
	    return;
	}

    }

}
