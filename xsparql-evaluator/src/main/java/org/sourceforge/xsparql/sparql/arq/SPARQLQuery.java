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
package org.sourceforge.xsparql.sparql.arq;

import org.apache.jena.query.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sourceforge.xsparql.rewriter.Helper;
import org.w3c.dom.Document;

/**
 * Use the ARQ API to pose SPARQL queries
 *
 * @author Nuno Lopes
 * 
 */
public class SPARQLQuery {

	private String query;
	private Dataset dataset = null;
	private static final Logger logger = LoggerFactory.getLogger(SPARQLQuery.class);

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

		logger.debug("Preparing query {}", query);
		Query q = QueryFactory.create(query);
		QueryExecution qe;

		if (dataset == null) {
			qe = QueryExecutionFactory.create(q);
			if(qe.getQuery().getDatasetDescription()==null)
				qe = QueryExecutionFactory.create(q, DatasetFactory.createMem());
				
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
