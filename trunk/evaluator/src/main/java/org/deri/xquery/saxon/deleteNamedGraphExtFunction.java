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

import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.update.UpdateAction;

/**
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class deleteNamedGraphExtFunction extends ExtensionFunctionDefinition {

  private static final long serialVersionUID = 7913750047065854611L;

  /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("_xsparql",
      "http://xsparql.deri.org/demo/xquery/xsparql.xquery", "deleteNamedGraph");

  private String location;

  public deleteNamedGraphExtFunction() {
    this.location = EvaluatorExternalFunctions.getDefaultTDBDatasetLocation();
  }

  public deleteNamedGraphExtFunction(String location) {
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

      private static final long serialVersionUID = 7607214804733059361L;

      @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {

        String graphName = arguments[0].next().getStringValue();
        String loc = arguments[1].next().getStringValue();
        if (!loc.equals("")) {
          location = loc;
        }

        try {

          // String location = Configuration.getTDBLocation() ;
          // Dataset dataset = TDBFactory.createDataset(location) ;

          Dataset dataset = EvaluatorExternalFunctions.getTDBDataset(location);

          if (dataset.containsNamedModel(graphName)) {
            UpdateAction
                .parseExecute("DROP GRAPH <" + graphName + ">", dataset);
          } else {
            throw new Exception();
          }

          // Close the dataset.
          dataset.close();

        } catch (Exception e) {
          System.err.println("error deleting named graph: " + e.getMessage());
          System.exit(1);
        }

        return EmptyIterator.getInstance();
      }

    };
  }

}
