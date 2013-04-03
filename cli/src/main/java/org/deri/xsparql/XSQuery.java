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
package org.deri.xsparql;

import java.util.logging.Level;
import java.util.logging.Logger;

import net.sf.saxon.Configuration;
import net.sf.saxon.Query;
import net.sf.saxon.trans.CommandLineOptions;

import org.deri.xquery.saxon.createNamedGraphExtFunction;
import org.deri.xquery.saxon.createScopedDatasetExtFunction;
import org.deri.xquery.saxon.deleteNamedGraphExtFunction;
import org.deri.xquery.saxon.deleteScopedDatasetExtFunction;
import org.deri.xquery.saxon.jsonDocExtFunction;
import org.deri.xquery.saxon.scopedDatasetPopResultsExtFunction;
import org.deri.xquery.saxon.sparqlQueryExtFunction;
import org.deri.xquery.saxon.sparqlQueryTDBExtFunction;
import org.deri.xquery.saxon.sparqlScopedDatasetExtFunction;
import org.deri.xquery.saxon.turtleGraphToURIExtFunction;
import org.deri.xquery.saxon.sqlQueryExtFunction;
import org.deri.xquery.saxon.getRDBTablesExtFunction;
import org.deri.xquery.saxon.getRDBTableAttributesExtFunction;
import org.deri.xsparql.rewriter.XSPARQLProcessor;

/**
 * @author nl
 *
 */
public class XSQuery extends Query {

    /**
     * 
     */
    public XSQuery() {
	super();
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
	new XSQuery().doQuery(args, "org.deri.xsparql.XSQuery");
    }
    
    private final static Logger logger = Logger.getLogger(XSPARQLProcessor.class
	      .getClass().getName());

    public void applyLocalOptions(CommandLineOptions options, Configuration config) {
	super.applyLocalOptions(options, config);

	logger.setLevel(Level.WARNING);

	try { 
	    config.registerExtensionFunction(new sparqlQueryExtFunction());
	    config.registerExtensionFunction(new turtleGraphToURIExtFunction());
	    config.registerExtensionFunction(new createScopedDatasetExtFunction());
	    config.registerExtensionFunction(new sparqlScopedDatasetExtFunction());
	    config.registerExtensionFunction(new deleteScopedDatasetExtFunction());
	    config.registerExtensionFunction(new scopedDatasetPopResultsExtFunction());
	    config.registerExtensionFunction(new jsonDocExtFunction());
	    config.registerExtensionFunction(new createNamedGraphExtFunction());
	    config.registerExtensionFunction(new deleteNamedGraphExtFunction());
	    config.registerExtensionFunction(new sparqlQueryTDBExtFunction());

	    // RDB functions
	    config.registerExtensionFunction(new sqlQueryExtFunction());
	    config.registerExtensionFunction(new getRDBTablesExtFunction());
	    config.registerExtensionFunction(new getRDBTableAttributesExtFunction());

        } catch (Exception ex) {
            throw new IllegalArgumentException();
	}
	    

    }

}
