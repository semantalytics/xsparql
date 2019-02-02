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

import org.apache.jena.query.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sourceforge.xsparql.sparql.arq.DatasetResults;
import org.sourceforge.xsparql.sparql.arq.InMemoryDatasetManager;

/**
 * Library of Java methods for usage from within XQuery queries when using Saxon
 */
class ScopedDatasetManager {

	private static final Logger logger = LoggerFactory.getLogger(ScopedDatasetManager.class);
	private static final Map<String, DatasetResults> scopedDataset = new HashMap<String, DatasetResults>();
	private static final InMemoryDatasetManager inMemoryDataset = null;

	/**
	 * Evaluates a SPARQL query, storing the bindings to be reused later. Used for
	 * the ScopedDataset.
	 * 
	 * @param q query to be executed
	 * @param id solution id
	 * @return XML results of the query
	 */
	public static ResultSet createScopedDataset(final String q, final String id) {

		logger.debug("Create scoped dataset query={}, id={}", q, id);

		if (scopedDataset.containsKey(id)) {
			// error?
            logger.debug("Scoped dataset contains key {}", id);
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
	 * @param q query to be executed
	 * @param id solution id
	 * @param joinVars joining variables that will be put in the initialBinding
	 * @param pos current iteration
	 * @return XML results of the query
	 */
	public static ResultSet sparqlScopedDataset(final String q,
												final String id,
												final String joinVars,
												final int pos) {

		logger.debug("Create scoped dataset query={}, id={}, joinVars={}, position={}",
				     Arrays.asList(q, id, joinVars, pos));

		if (!scopedDataset.containsKey(id)) {
			// error ??
			logger.debug("Scoped dataset does not contain key {}", id);
		}

		final Dataset dataset = scopedDataset.get(id).getDataset();
		final ResultSetRewindable results = scopedDataset.get(id).getResults();
		results.reset();

		// used to filter solutions
		final QuerySolutionMap initialBinding = createSolutionMap(results, joinVars, pos);

		final QueryExecution qe = QueryExecutionFactory.create(q, dataset, initialBinding);

		final ResultSet resultSet = qe.execSelect();
		// store current resultSet in case there is further nesting

		return scopedDataset.get(id).addResults(resultSet);
	}

	/**
	 * Creates an initialBinding from the previous solutions and the join vars.
	 * 
	 * @param results previous resultSet
	 * @param joinVars joining variables that will be put in the initialBinding
	 * @param pos current iteration
	 * @return QuerySolutionMap to be used for filtering results
	 */
	private static QuerySolutionMap createSolutionMap(final ResultSetRewindable results,
													  final String joinVars,
													  final int pos) {

		final QuerySolutionMap initialBinding = new QuerySolutionMap();

		final String[] joinVarsArray = joinVars.split(",");

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

		final Iterator<String> iterator = Arrays.asList(joinVarsArray).iterator();

		while (iterator.hasNext()) {
			final String st = iterator.next();

			if (s.contains(st)) {
				initialBinding.add(st, s.get(st));
			}
		}

		return initialBinding;
	}

	/**
	 * Deletes stored dataset and solutions.
	 * 
	 * @param id solution id
	 */
	public static void deleteScopedDataset(final String id) {

	    logger.debug("Deleting scoped dataset {}", id);

		scopedDataset.remove(id);
	}

	/**
	 * Deletes the last results from the stack.
	 * 
	 * @param id solution id
	 */
	public static void scopedDatasetPopResults(final String id) {

		logger.debug("Deleting scoped dataset results {}", id);

		// delete dataset from scope, no longer needed
		if (!scopedDataset.isEmpty()) {
			scopedDataset.get(id).popResults();
		}
	}
}
