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
/**
 *  DEPRECADED code.  This features are be implemented in the separate extension function classes.
 */
package org.sourceforge.xsparql.xquery.saxon;

import org.apache.jena.query.ResultSet;
import org.apache.jena.query.ResultSetFormatter;
import org.sourceforge.xsparql.rewriter.Helper;
import org.sourceforge.xsparql.sparql.arq.SPARQLQuery;
import org.w3c.dom.Document;

/**
 * Library of Java methods for usage from within XQuery queries when using Saxon
 */
@Deprecated
public class Sparql {

  /**
   * Evaluates a SPARQL query.
   * 
   * @param queryString query to be executed
   * @return XML results of the query
   */
  @Deprecated
  public static Document _sparqlQuery(final String queryString) {

    final SPARQLQuery query = new SPARQLQuery(queryString);

    return query.getResultsAsXML();
  }

  /**
   * Saves string s to a local file.
   * 
   * @param prefix Turtle preamble
   * @param n3 Turtle content
   * @return URI of local file containing string s
   */
  @Deprecated
  public static String turtleGraphToURI(final String prefix, final String n3) {

    return EvaluatorExternalFunctions.turtleGraphToURI(prefix, n3);

  }

  /**
   * Evaluates a SPARQL query, storing the bindings to be reused later. Used for
   * the ScopedDataset.
   * 
   * @param q query to be executed
   * @param id solution id
   * @return XML results of the query
   */
  @Deprecated
  public static Document createScopedDataset(final String q, final String id) {

    final ResultSet results = EvaluatorExternalFunctions.createScopedDataset(q, id);
    final String xml = ResultSetFormatter.asXMLString(results);

    return Helper.parseXMLString(xml);
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
  @Deprecated
  public static Document sparqlScopedDataset(final String q,
                                             final String id,
                                             final String joinVars,
                                             final int pos) {

    final ResultSet results2 = EvaluatorExternalFunctions.sparqlScopedDataset(q, id,
        joinVars, pos);

    final String xml = ResultSetFormatter.asXMLString(results2);

    return Helper.parseXMLString(xml);
  }

  /**
   * Deletes stored dataset and solutions.
   * 
   * @param id solution id
   */
  @Deprecated
  public static void deleteScopedDataset(final String id) {

    EvaluatorExternalFunctions.deleteScopedDataset(id);
  }

  /**
   * Deletes the last results from the stack.
   * 
   * @param id solution id
   */
  @Deprecated
  public static void scopedDatasetPopResults(final String id) {

    EvaluatorExternalFunctions.scopedDatasetPopResults(id);
  }
}
