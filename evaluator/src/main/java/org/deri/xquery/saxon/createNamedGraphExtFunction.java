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
package org.deri.xquery.saxon;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.value.SequenceType;

import com.hp.hpl.jena.query.DataSource;
import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.query.DatasetFactory;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.tdb.TDBFactory;
import com.hp.hpl.jena.update.UpdateAction;

/**
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class createNamedGraphExtFunction extends ExtensionFunctionDefinition {

  private static final long serialVersionUID = 5099093796002792831L;
  /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("_xsparql",
      "http://xsparql.deri.org/demo/xquery/xsparql.xquery", "createNamedGraph");

  private String location;

  // hide default constructor
  public createNamedGraphExtFunction() {
    this.location = EvaluatorExternalFunctions.getDefaultTDBDatasetLocation();
  }

  public createNamedGraphExtFunction(String location) {
    this.location = location;
  }

  @Override
  public StructuredQName getFunctionQName() {
    return funcname;
  }

  @Override
  public int getMinimumNumberOfArguments() {
    return 3;
  }

  @Override
  public int getMaximumNumberOfArguments() {
    return 4;
  }

  @Override
  public SequenceType[] getArgumentTypes() {
    return new SequenceType[] { SequenceType.SINGLE_STRING,
        SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING , SequenceType.SINGLE_STRING };
  }

  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.ANY_SEQUENCE;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {

    return new ExtensionFunctionCall() {

      /**
		 * 
		 */
      private static final long serialVersionUID = -7278616556002243718L;

      @SuppressWarnings({ "unchecked", "rawtypes" })
      @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {

        String graphName = arguments[0].next().getStringValue();
        String prefix = arguments[1].next().getStringValue();
        String data = arguments[2].next().getStringValue();
        String loc = arguments[3].next().getStringValue();
        if (!loc.equals("")) {
          location = loc;
        }

        try {
          Dataset dataset = EvaluatorExternalFunctions.getTDBDataset(location);

          DataSource datasource = DatasetFactory.create(dataset);

          Model named = TDBFactory.createNamedModel(graphName, location);
          datasource.addNamedModel(graphName, named);

          String insertString = "PREFIX ex: <" + graphName + ">" + prefix
              + " INSERT DATA INTO <" + graphName + "> { " + data + " }";

          
          UpdateAction.parseExecute(insertString, (Dataset) datasource);

          // Close the dataset.
          dataset.close();

        } catch (Exception e) {
          System.err.println("error creating named graph: " + e.getMessage());
          System.exit(1);
        }

        return EmptyIterator.getInstance();
      }

    };
  }

}
