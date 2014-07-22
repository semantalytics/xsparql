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
package org.sourceforge.xsparql.xquery.saxon;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSON;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;

import org.apache.jena.riot.RDFDataMgr;
import org.sourceforge.xsparql.sparql.arq.DatasetResults;
//import org.sourceforge.xsparql.xquery.DatasetResults;

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
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.tdb.TDBFactory;

/**
 * Library of Java methods for usage from within XQuery queries when using Saxon
 * 
 * @author Stefan Bischof
 * @author Nuno Lopes
 * 
 */
class EvaluatorExternalFunctions {

	private static Map<String, DatasetResults> scopedDataset = new HashMap<String, DatasetResults>();

	private static String TDBLocation = System.getProperty("user.home") + "/.xsparql/TDB";

	private static Dataset inMemoryDataset = null;

	// ----------------------------------------------------------------------------------------------------
	// constructed Dataset

	/**
	 * Saves string s to a local file.
	 * 
	 * @param prefix
	 *          Turtle preamble
	 * @param n3
	 *          Turtle content
	 * @return URI of local file containing string s
	 */
	public static String turtleGraphToURI(String prefix, String n3) {
		URL retURL = null;

		try {
			// Create temp file.
			File temp = File.createTempFile("sparqlGraph", ".n3");

			// Delete temp file when program exits.
			temp.deleteOnExit();

			// Write to temp file
			BufferedWriter out = new BufferedWriter(new FileWriter(temp));
			out.write(prefix);
			//      out.write(n3.replace("\\", "\\\\"));  // re-escape any blackslashes
			out.write(n3);  // re-escape any blackslashes
			out.close();

			retURL = temp.toURI().toURL();
		} catch (IOException e) {

		}

		return retURL.toString();

	}


	public static Dataset getTDBDataset(String location) {

		// check if the directory exists and if not create it
		if (!new File(location).exists()) {
			try {
				new File(location).mkdirs();

			} catch (Exception e) {
				System.err.println("Error retrieving the datasets: " + e.getMessage());
				System.exit(1);
			}

		}

		Dataset dataset = TDBFactory.createDataset(location);

		return dataset;

	}


	public static Dataset getTDBDataset() {

		String location = TDBLocation;

		return getTDBDataset(location);

	}

	public static String getDefaultTDBDatasetLocation() {

		return TDBLocation;

	}

	public static void createInMemoryDataset(Set<URL> defaultGraph, Set<URL> namedGraphs){
		inMemoryDataset = DatasetFactory.createMem();
		Model dModel = ModelFactory.createDefaultModel();
		for(URL f : defaultGraph){
			dModel.add(RDFDataMgr.loadModel(f.toString()));
		}
		inMemoryDataset.setDefaultModel(dModel);

		for(URL f : namedGraphs){
			inMemoryDataset.addNamedModel(f.toString(), RDFDataMgr.loadModel(f.toString()));
		}
	}

	public static Dataset getInMemoryDataset(){
		return inMemoryDataset;
	}

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
		Dataset dataset = DatasetFactory.create(query.getGraphURIs(),
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

		// System.out.println("sparqlScopedDataset(" + q + "," + id + "," +joinVars+
		// "," +pos+ ")");

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

		// System.out.println("scopedDatasetPopResults(" + id + ")");

		// delete dataset from scope, no longer needed
		if (scopedDataset.size() > 0) {
			scopedDataset.get(id).popResults();
		}
	}

	/**
	 * Retrieves data from a url, Converts JSON data to XML
	 * 
	 * @param URL   location of the data
	 * 
	 */
	public static String jsonToXML(String loc) {
		String xml = "";
		String jsonData = "";

		try {

			// Send data
			URL url = new URL(loc);
			BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));

			String inputLine;

			while ((inputLine = in.readLine()) != null) {
				jsonData+=inputLine;
			}

			//      String jsonData = IOUtils.toString(is);

			XMLSerializer serializer = new XMLSerializer(); 
			JSON json = JSONSerializer.toJSON( jsonData ); 
			serializer.setTypeHintsEnabled(false);
			serializer.setObjectName("jsonObject");
			serializer.setElementName("arrayElement");
			serializer.setArrayName("array");
			xml = serializer.write( json );  


			in.close();
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}

		return xml;

	}



}
