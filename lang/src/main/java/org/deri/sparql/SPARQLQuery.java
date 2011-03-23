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
 * 
 */
package org.deri.sparql;

import org.deri.xsparql.Helper;
import org.w3c.dom.Document;

import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFormatter;

/**
 * Use the ARQ API to pose SPARQL queries
 * 
 * @author Nuno Lopes
 * 
 */
public class SPARQLQuery {

    private String query;
    private Dataset dataset = null;

    // ----------------------------------------------------------------------------------------------------
    // SPARQL

    /**
     * Creates a new <code>SPARQLQuery</code> instance.
     * 
     */
    public SPARQLQuery(String query) {
	this.query = query;
	this.dataset = null;
    }

    /**
     * Creates a new <code>SPARQLQuery</code> instance.
     * 
     */
    public SPARQLQuery(String query, Dataset dataset) {
	this.query = query;
	this.dataset = dataset;
    }

    /**
     * Evaluates a SPARQL query.
     * 
     * @return XML ResultSet with the results of the query
     */
    public ResultSet getResults() {

	Query q = QueryFactory.create(query);
	QueryExecution qe;

	if (dataset == null) {
	    qe = QueryExecutionFactory.create(q);
	} else {
	    qe = QueryExecutionFactory.create(query, dataset);
	}

	return qe.execSelect();
    }

    /**
     * Evaluates a SPARQL query and return the XML format.
     * 
     * @return XML results of the query
     */
    public Document getResultsAsXML() {
	ResultSet resultSet = getResults();

	String xml = ResultSetFormatter.asXMLString(resultSet);

	return Helper.parseXMLString(xml);
    }

}
