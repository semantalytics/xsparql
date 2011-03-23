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
package org.deri.xsparql;

import java.io.*;

import org.deri.xquery.*;

/**
 * Class to rewrite and evaluate an XSPARQL query.
 * 
 * 
 * Created: Tue Oct 12 12:42:04 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class XSPARQLEvaluator {

    XSPARQLProcessor xsparqlProc;
    xqueryEvaluator xqueryEval;

    /**
     * Creates a new <code>XSPARQLEvaluator</code> instance.
     * 
     */
    public XSPARQLEvaluator() {
	super();
	xsparqlProc = new XSPARQLProcessor();
	xqueryEval = Configuration.getEvaluator();
    }

    /**
     * Evaluates the query given as a String and outputs the result to standard
     * output.
     * 
     * @param query
     *            a <code>String</code> value
     * @exception IOException
     *                if an error occurs
     * @exception Exception
     *                if an error occurs
     */
    public void evaluate(String query) throws IOException, Exception {
	evaluate(query, System.out);
    }

    /**
     * Evaluates the query contined in File and outputs the result to standard
     * output.
     * 
     * @param query
     *            a <code>File</code> value
     * @exception IOException
     *                if an error occurs
     * @exception Exception
     *                if an error occurs
     */
    public void evaluate(File query) throws IOException, Exception {
	evaluate(query, System.out);
    }

    /**
     * Evaluates the query given as a String and outputs the result to the given
     * stream.
     * 
     * @param query
     *            a <code>String</code> value
     * @param out
     *            a <code>PrintStream</code> value
     * @exception IOException
     *                if an error occurs
     * @exception Exception
     *                if an error occurs
     */
    public void evaluate(String query, PrintStream out) throws IOException,
	    Exception {
	InputStream is = new ByteArrayInputStream(query.getBytes());
	evaluate(is, out);
    }

    /**
     * Evaluates the query contined in File and outputs the result to the given
     * stream.
     * 
     * @param queryFile
     *            a <code>File</code> value
     * @param out
     *            a <code>PrintStream</code> value
     * @exception IOException
     *                if an error occurs
     * @exception Exception
     *                if an error occurs
     */
    public void evaluate(File queryFile, PrintStream out) throws IOException,
	    Exception {
	InputStream is = new FileInputStream(queryFile);
	evaluate(is, out);
    }

    /**
     * The input stream "in" is processed as containing an XSPARQL query, the
     * XQuery is evaluated and the result is output to the stream "out".
     * 
     * @param is
     *            an <code>InputStream</code> value
     * @param out
     *            a <code>PrintStream</code> value
     * @exception IOException
     *                if an error occurs
     * @exception Exception
     *                if an error occurs
     */
    public void evaluate(InputStream is, PrintStream out) throws IOException,
	    Exception {
	final String xquery = xsparqlProc.process(is);
	xqueryEval.evaluate(xquery, out);
    }

}
