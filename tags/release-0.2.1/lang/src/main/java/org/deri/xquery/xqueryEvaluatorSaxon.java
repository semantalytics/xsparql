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
package org.deri.xquery;

import java.io.*;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XQueryEvaluator;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XQueryCompiler;

import org.deri.xquery.saxon.createScopedDatasetExtFunction;
import org.deri.xquery.saxon.deleteScopedDatasetExtFunction;
import org.deri.xquery.saxon.doPostQueryExtFunction;
import org.deri.xquery.saxon.scopedDatasetPopResultsExtFunction;
import org.deri.xquery.saxon.sparqlQueryExtFunction;
import org.deri.xquery.saxon.sparqlScopedDatasetExtFunction;
import org.deri.xquery.saxon.turtleGraphToURIExtFunction;
import org.deri.xsparql.Configuration;
import org.deri.xsparql.XSPARQLProcessor;

/**
 * Evaluate an XQuery using the Saxon API
 * 
 * 
 * Created: Tue Sep 28 14:54:49 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class xqueryEvaluatorSaxon extends xqueryEvaluator {

    private Processor proc;

    private Serializer serializer;

    /**
     * Creates a new <code>xqueryEvaluatorSaxon</code> instance.
     * 
     */
    public xqueryEvaluatorSaxon() {

	xqueryExternalVars = Configuration.xqueryExternalVars();

	proc = new Processor(Configuration.validatingXQuery());

	proc.registerExtensionFunction(new sparqlQueryExtFunction());
	proc.registerExtensionFunction(new turtleGraphToURIExtFunction());
	proc.registerExtensionFunction(new doPostQueryExtFunction());
	proc.registerExtensionFunction(new createScopedDatasetExtFunction());
	proc.registerExtensionFunction(new sparqlScopedDatasetExtFunction());
	proc.registerExtensionFunction(new deleteScopedDatasetExtFunction());
	proc
		.registerExtensionFunction(new scopedDatasetPopResultsExtFunction());

	// debug external functions
	// proc.setConfigurationProperty(FeatureKeys.TRACE_EXTERNAL_FUNCTIONS,
	// true);

	serializer = new Serializer();
	serializer.setOutputProperty(Serializer.Property.METHOD, null);
	serializer.setOutputProperty(Serializer.Property.OMIT_XML_DECLARATION,
		"yes");
	serializer.setOutputProperty(Serializer.Property.INDENT, "yes");

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
    @Override
    public void evaluate(final String query) throws Exception {
	evaluate(query, System.out);
    }

    /**
     * Evaluate the XQuery query using the s9api of Saxon
     * 
     * @param query
     * @param out
     *            output
     */
    @Override
    public void evaluate(final String query, PrintStream out) throws Exception {

	// final Serializer serializer = new Serializer();

	serializer.setOutputStream(out);

	final XQueryCompiler compiler = proc.newXQueryCompiler();
	final XQueryEvaluator evaluator = compiler.compile(query).load();

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
