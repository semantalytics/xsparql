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
/**
 *  DEPRECADED code.  This features are be implemented in the separate extension function classes.
 */
package org.deri.xquery.saxon;

//import java.io.*;
//import java.net.*;
//import java.util.*;
import org.w3c.dom.*; //import javax.xml.parsers.*;
//import org.xml.sax.XMLReader;
//import org.xml.sax.InputSource;
//import org.apache.xerces.dom.DocumentImpl;

import com.hp.hpl.jena.query.*; //import com.hp.hpl.jena.sparql.util.*;

import org.deri.xsparql.*;
import org.deri.sparql.*;
import org.deri.xquery.*;

/**
 * Library of Java methods for usage from within XQuery queries when using Saxon
 * 
 * @author Stefan Bischof
 * @author Nuno Lopes
 * 
 */
public class Sparql {

    /**
     * Evaluates a SPARQL query.
     * 
     * @param queryString
     *            query to be executed
     * @return XML results of the query
     */
    public static Document _sparqlQuery(String queryString) {

	SPARQLQuery query = new SPARQLQuery(queryString);

	return query.getResultsAsXML();

    }

    // ----------------------------------------------------------------------------------------------------
    // constructed Dataset

    /**
     * Saves string s to a local file.
     * 
     * @param prefix
     *            Turtle preamble
     * @param n3
     *            Turtle content
     * @return URI of local file containing string s
     */
    public static String turtleGraphToURI(String prefix, String n3) {

	return EvaluatorExternalFunctions.turtleGraphToURI(prefix, n3);

    }

    /**
     * Performs a POST query to a url. Called from the rewritten query for the
     * Named graphs optimisation.
     * 
     * @param endpoint
     *            endpoint to POST the query
     * @param data
     *            data to be POSTed
     */
    public static void doPostQuery(String endpoint, String data) {
	EvaluatorExternalFunctions.doPostQuery(endpoint, data);
    }

    // ----------------------------------------------------------------------------------------------------
    // Scoped Dataset

    /**
     * Evaluates a SPARQL query, storing the bindings to be reused later. Used
     * for the ScopedDataset.
     * 
     * @param q
     *            query to be executed
     * @param id
     *            solution id
     * @return XML results of the query
     */
    public static Document createScopedDataset(String q, String id) {

	ResultSet results = EvaluatorExternalFunctions.createScopedDataset(q,
		id);

	String xml = ResultSetFormatter.asXMLString(results);

	return Helper.parseXMLString(xml);

    }

    /**
     * Evaluates a SPARQL query, using previously stored dataset and bindings.
     * Used for the ScopedDataset.
     * 
     * @param q
     *            query to be executed
     * @param id
     *            solution id
     * @param joinVars
     *            joining variables that will be put in the initialBinding
     * @param pos
     *            current iteration
     * @return XML results of the query
     */
    public static Document sparqlScopedDataset(String q, String id,
	    String joinVars, int pos) {

	ResultSet results2 = EvaluatorExternalFunctions.sparqlScopedDataset(q,
		id, joinVars, pos);

	String xml = ResultSetFormatter.asXMLString(results2);

	return Helper.parseXMLString(xml);

    }

    /**
     * Deletes stored dataset and solutions.
     * 
     * @param id
     *            solution id
     */
    public static void deleteScopedDataset(String id) {

	EvaluatorExternalFunctions.deleteScopedDataset(id);
    }

    /**
     * Deletes the last results from the stack.
     * 
     * @param id
     *            solution id
     */
    public static void scopedDatasetPopResults(String id) {

	EvaluatorExternalFunctions.scopedDatasetPopResults(id);

    }

}
