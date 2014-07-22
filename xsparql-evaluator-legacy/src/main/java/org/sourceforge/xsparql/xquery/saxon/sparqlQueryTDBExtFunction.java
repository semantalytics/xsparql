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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;

import org.sourceforge.xsparql.sparql.arq.SPARQLQuery;

import com.hp.hpl.jena.graph.Factory;
import com.hp.hpl.jena.graph.Graph;
import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.query.DatasetFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFormatter;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.RDFReader;
import com.hp.hpl.jena.shared.NotFoundException;
import com.hp.hpl.jena.util.FileManager;
import com.hp.hpl.jena.util.FileUtils;

/**
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class sparqlQueryTDBExtFunction extends ExtensionFunctionDefinition {

  /**
	 * 
	 */
  private static final long serialVersionUID = -4238279113552531635L;
  /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("_xsparql",
      "http://xsparql.deri.org/demo/xquery/xsparql.xquery", "_sparqlQueryTDB");
  private String location;

  public sparqlQueryTDBExtFunction() {
    this.location = EvaluatorExternalFunctions.getDefaultTDBDatasetLocation();
  }

  public sparqlQueryTDBExtFunction(String location) {
    this.location = location;
  }

  @Override
  public StructuredQName getFunctionQName() {
    return funcname;
  }

  @Override
  public int getMinimumNumberOfArguments() {
    return 1;
  }

  @Override
  public int getMaximumNumberOfArguments() {
    return 2;
  }

  @Override
  public SequenceType[] getArgumentTypes() {
    return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING };
  }

  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.ANY_SEQUENCE;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {

    return new ExtensionFunctionCall() {

      private static final long serialVersionUID = 6073685306203679400L;

      @SuppressWarnings({ "unchecked", "rawtypes" })
      @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {
        // TDB.setOptimizerWarningFlag(false);

        String queryString = arguments[0].next().getStringValue();
        String loc = arguments[1].next().getStringValue();
        if (!loc.equals("")) {
          location = loc;
        }

        // String location = Configuration.getTDBLocation() ;
        // Dataset dataset = TDBFactory.createDataset(location);

        Dataset dataset = EvaluatorExternalFunctions.getTDBDataset(location);

        SPARQLQuery query = processQuery(queryString, dataset);

        ResultSet resultSet = query.getResults();
        // System.out.println(ResultSetFormatter.asXMLString(resultSet));
        // System.out.println(resultSet.toString());
        // return EmptyIterator.getInstance();

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        ResultSetFormatter.outputAsXML(outputStream, resultSet);
        ByteArrayInputStream inputStream = new ByteArrayInputStream(
            outputStream.toByteArray());

        // Close the dataset.
        dataset.close();

        return SingletonIterator.makeIterator(context.getConfiguration()
            .buildDocument(new StreamSource(inputStream)));

      }

    };
  }

  /*
   * retrieves the query from the request, parses it for datasets and returns a
   * new Dataset according to the datasets present in the query
   */
  private SPARQLQuery processQuery(String queryString, Dataset defaultDataset) {

    Dataset dataset = DatasetFactory.create(defaultDataset);

    queryString = getDatasets(queryString, dataset);

    SPARQLQuery query = new SPARQLQuery(queryString, dataset);

    return query;

  }

  /*
   * parses the query for any FROM and FROM NAMED clauses, creating a Dataset
   * with the URIs. Any found clauses are removed from the query.
   */
  private String getDatasets(String query, Dataset dataset) {
    if (query == null) {
      return null;
    }

    List<String> namedGraphURIs = new ArrayList<String>();
    List<String> dftGraphURI = new ArrayList<String>();

    // change this to an ARQ parser?
    String[] result = query.split("\\s");
    StringBuffer q = new StringBuffer();

    for (int x = 0; x < result.length; x++) {
      if (result[x].equalsIgnoreCase("FROM")) {
        if (result[x + 1].equalsIgnoreCase("NAMED")) // named graph
        {
          // namedGraphURIs.add(result[x+2].replaceAll("[\\<\\>]", ""));
          x += 2;
        } else // default graph
        {
          dftGraphURI.add(result[x + 1].replaceAll("[\\<\\>]", ""));
          x += 1;
        }
      } else {
        q.append(" ");
        q.append(result[x]);
      }
    }

    try {
      addDefaultModel(dftGraphURI, dataset);
      addNamedModel(namedGraphURIs, dataset);
    } catch (Exception e) {
      System.err.println("error building the graphs: " + e.getMessage());
      System.exit(1);
    }
    return q.toString();

  }

  /*
   * Creates the default dataset according to a list of URIs
   */
  private void addDefaultModel(List<String> graphURLs, Dataset dataset)
      throws Exception {
    Model model = dataset.getDefaultModel();

    for (String uri : graphURLs) {
      if (uri == null) {
        continue;
      }
      if (uri.equals("")) {
        continue;
      }

      try {
        model = readModel(uri);
        dataset.setDefaultModel(model);
      } catch (Exception ex) {
        throw new Exception("Failed to load (default) URL " + uri + " : "
            + ex.getMessage());
      }
    }

    if (model != null)
      dataset.setDefaultModel(model);
  }

  /*
   * Adds each URI in the list as a named graph to the dataset. If the dataset
   * already contains the model, don't load the graph.
   */
  private void addNamedModel(List<String> namedGraphs, Dataset dataset)
      throws Exception {

    // ---- Named graphs
    if (namedGraphs != null) {
      for (String uri : namedGraphs) {
        if (uri == null) {
          continue;
        }
        if (uri.equals("")) {
          continue;
        }
        try {
          if (!dataset.containsNamedModel(uri)) {
            Model model2 = readModel(uri);
            dataset.addNamedModel(uri, model2);
          }
        } catch (Exception ex) {
          throw new Exception("Failed to load URL " + uri);
        }
      }
    }
  }

  /*
   * code inspired by GraphUtils class from Joseki
   */
  private static Model readModel(String uri) {
    Graph g = Factory.createGraphMem();
    // Use the mapped uri as the syntax hint.
    String syntax = null;
    {
      String altURI = FileManager.get().mapURI(uri);
      if (altURI != null)
        syntax = FileUtils.guessLang(uri);
    }
    // Temporary model wrapper
    Model m = ModelFactory.createModelForGraph(g);
    RDFReader r = m.getReader(syntax);
    InputStream in = FileManager.get().open(uri);
    if (in == null)
      // Not found.
      throw new NotFoundException("Not found: " + uri);
    r.read(m, in, uri);
    return m;
  }

}
