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
package org.sourceforge.xsparql.xquery.saxon.arq;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.sourceforge.xsparql.sparql.arq.DatasetResults;
import org.sourceforge.xsparql.sparql.arq.InMemoryDatasetManager;

import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.query.DatasetFactory;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.QuerySolutionMap;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetRewindable;

/**
 * Library of Java methods for usage from within XQuery queries when using Saxon
 * 
 * @author Stefan Bischof
 * @author Nuno Lopes
 * 
 */
class ScopedDatasetManager {

	private static Map<String, DatasetResults> scopedDataset = new HashMap<String, DatasetResults>();

	private static InMemoryDatasetManager inMemoryDataset = null;
	
	

	// ----------------------------------------------------------------------------------------------------
	// Scoped Dataset

	/**
	 * Evaluates a SPARQL query, storing the bindings to be reused later. Used for
	 * the ScopedDataset.
	 * 
	 * @param q
	 *          query to be executed
	 * @param id
	 *          solution id
	 * @return XML results of the query
	 */
	public static ResultSet createScopedDataset(String q, String id) {

		// System.out.println("createScopedDataset(" + q + "," + id + ")");

		if (scopedDataset.containsKey(id)) {
			// error?
		}

		Query query = QueryFactory.create(q);
		Dataset dataset = DatasetFactory.create(
				query.getGraphURIs(),
				query.getNamedGraphURIs());

		QueryExecution qe = QueryExecutionFactory.create(query, dataset);

		ResultSet resultSet = qe.execSelect();

		DatasetResults ds = new DatasetResults(dataset);
		ResultSetRewindable results = ds.addResults(resultSet);
		scopedDataset.put(id, ds);

		return results;

	}

	/**
	 * Evaluates a SPARQL query, using previously stored dataset and bindings.
	 * Used for the ScopedDataset.
	 * 
	 * @param q
	 *          query to be executed
	 * @param id
	 *          solution id
	 * @param joinVars
	 *          joining variables that will be put in the initialBinding
	 * @param pos
	 *          current iteration
	 * @return XML results of the query
	 */
	public static ResultSet sparqlScopedDataset(String q, String id,
			String joinVars, int pos) {
		if (!scopedDataset.containsKey(id)) {
			// error ??
		}

		Dataset dataset = scopedDataset.get(id).getDataset();
		ResultSetRewindable results = scopedDataset.get(id).getResults();
		results.reset();

		// used to filter solutions
		QuerySolutionMap initialBinding = createSolutionMap(results, joinVars, pos);

		QueryExecution qe = QueryExecutionFactory
				.create(q, dataset, initialBinding);

		ResultSet resultSet = qe.execSelect();
		// store current resultSet in case there is further nesting
		ResultSetRewindable results2 = scopedDataset.get(id).addResults(resultSet);

		return results2;
	}

	/**
	 * Creates an initialBinding from the previous solutions and the join vars.
	 * 
	 * @param results
	 *          previous resultSet
	 * @param joinVars
	 *          joining variables that will be put in the initialBinding
	 * @param pos
	 *          current iteration
	 * @return QuerySolutionMap to be used for filtering results
	 */
	private static QuerySolutionMap createSolutionMap(
			ResultSetRewindable results, String joinVars, int pos) {

		QuerySolutionMap initialBinding = new QuerySolutionMap();

		String[] joinVarsArray = joinVars.split(",");

		QuerySolution s = new QuerySolutionMap();

		// move to current position of results
		int it = 1;
		while (results.hasNext()) {
			QuerySolution qs = results.next();

			if (it == pos) {
				s = qs;
				break;
			}
			it++;
		}

		Iterator<String> iterator = Arrays.asList(joinVarsArray).iterator();
		while (iterator.hasNext()) {
			String st = iterator.next();

			if (s.contains(st)) {
				initialBinding.add(st, s.get(st));
			}
		}

		return initialBinding;
	}

	/**
	 * Deletes stored dataset and solutions.
	 * 
	 * @param id
	 *          solution id
	 */
	public static void deleteScopedDataset(String id) {

		// System.out.println("deleteScopedDataset(" + id + ")");

		// delete dataset from scope, no longer needed
		scopedDataset.remove(id);
	}

	/**
	 * Deletes the last results from the stack.
	 * 
	 * @param id
	 *          solution id
	 */
	public static void scopedDatasetPopResults(String id) {

		// delete dataset from scope, no longer needed
		if (scopedDataset.size() > 0) {
			scopedDataset.get(id).popResults();
		}
	}
}
