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
package org.deri.xquery.saxon;

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

import org.deri.sparql.SPARQLQuery;

import com.hp.hpl.jena.graph.Factory;
import com.hp.hpl.jena.graph.Graph;
import com.hp.hpl.jena.query.DataSource;
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
 * Saxon External call for implementing SPARQL queries. Based on
 * https://github.com
 * /LeifW/MusicPath/blob/master/src/main/scala/org/musicpath/ExtFunCall.scala,
 * thanks to Leif Warner. Need to port other functions to this mechanism.
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
class sparqlQueryTDBExtFunction extends ExtensionFunctionDefinition {

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

  // hide default constructor
  @SuppressWarnings("unused")
  private sparqlQueryTDBExtFunction() {
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
    return 1;
  }

  @Override
  public SequenceType[] getArgumentTypes() {
    return new SequenceType[] { SequenceType.SINGLE_STRING };
  }

  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.ANY_SEQUENCE;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {

    return new ExtensionFunctionCall() {

      private static final long serialVersionUID = 6073685306203679400L;

      @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {
        // TDB.setOptimizerWarningFlag(false);

        String queryString = arguments[0].next().getStringValue();

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

    DataSource dataset = DatasetFactory.create(defaultDataset);

    queryString = getDatasets(queryString, dataset);

    SPARQLQuery query = new SPARQLQuery(queryString, dataset);

    return query;

  }

  /*
   * parses the query for any FROM and FROM NAMED clauses, creating a Dataset
   * with the URIs. Any found clauses are removed from the query.
   */
  private String getDatasets(String query, DataSource dataset) {
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
      System.out.println("error: " + e.getMessage());
    }
    return q.toString();

  }

  /*
   * Creates the default dataset according to a list of URIs
   */
  private void addDefaultModel(List<String> graphURLs, DataSource dataset)
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
  private void addNamedModel(List<String> namedGraphs, DataSource dataset)
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
