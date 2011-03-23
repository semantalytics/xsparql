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

import org.antlr.runtime.*;

import org.deri.xquery.*;

/**
 * Main entry point for the commandline interface
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 * @author Nuno Lopes <nuno.lopes@deri.org>
 */
public class Main {

    /**
     * True if parse errors occured
     */
    private static boolean parseErrors = false;

    /**
     * Main application entry point
     * 
     * @param args
     *            Commandline arguments
     * @throws IOException
     */
    public static void main(final String[] args) throws IOException {

	Configuration.parseOptions(args);

	InputStream is = null;
	if (Configuration.queryFiles().length > 0) {
	    for (File queryFile : Configuration.queryFiles()) {
		try {
		    is = new FileInputStream(queryFile);
		    rewriteQuery(is, queryFile.getName());
		} catch (FileNotFoundException e) {
		    String filename = queryFile.getPath();
		    System.err.println("File not found: " + filename);
		}
	    }
	} else {
	    is = System.in;
	    rewriteQuery(is, "stdin");
	}

	if (parseErrors) {
	    System.exit(1);
	}
    }

    /**
     * Actual query rewriting.
     * 
     * @param is
     *            XSPARQL query
     * @param filename
     *            Filename of the XSPARQL query
     */
    private static void rewriteQuery(InputStream is, String filename) {
	try {

	    final XSPARQLProcessor proc = new XSPARQLProcessor();
	    proc.setQueryFilename(filename);

	    final String xquery = proc.process(is);

	    postProcessing(xquery, proc);

	} catch (RecognitionException e) {
	    System.err.println("Parse error: " + e);
	    parseErrors = true;
	} catch (Exception e1) {
	    System.err.println("Processing error: " + e1.toString());
	    e1.printStackTrace();
	    parseErrors = true;
	}

    }

    /**
     * Post processing after the rewriting. Optionally evaluates rewritten
     * query.
     * 
     * @param xquery
     *            XQuery query
     * @param proc
     *            Instance of <code>XSPARQLProcessor</code>
     * @throws IOException
     */
    private static void postProcessing(final String xquery,
	    final XSPARQLProcessor proc) throws IOException, Exception {
	parseErrors = parseErrors || proc.getNumberOfSyntaxErrors() > 0;

	if (parseErrors) {
	    return;
	}

	// evaluate the expression
	if (Configuration.evaluate()) {

	    xqueryEvaluator eval = Configuration.getEvaluator();

	    if (eval == null) {
		throw new Exception(
			"Cannot evaluate the query with the specified engine");
	    }

	    eval.evaluate(xquery);
	} else {
	    if (Configuration.outputFile() != null) {
		Helper.outputString(xquery, new FileOutputStream(Configuration
			.outputFile()));
	    } else {
		Helper.outputString(xquery, System.out);
	    }
	}

    }

}
