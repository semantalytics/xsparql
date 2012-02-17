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

import java.io.ByteArrayInputStream;

import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;

/**
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class jsonDocExtFunction extends ExtensionFunctionDefinition {

  private static final long serialVersionUID = -3012293238578637469L;
  /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("xsparql",
      "http://xsparql.deri.org/demo/xquery/sparql-functions.xquery", "json-doc");

  public jsonDocExtFunction() {
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

      private static final long serialVersionUID = -2933876244790032821L;

      @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {

        String url = arguments[0].next().getStringValue();

        String xml = EvaluatorExternalFunctions.jsonToXML(url);
        return SingletonIterator.makeIterator(context.getConfiguration()
            .buildDocument(new StreamSource(new ByteArrayInputStream(xml.getBytes()))));

      }

    };
  }

}
