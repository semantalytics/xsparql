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

//import net.sf.saxon.functions.*;
import java.io.ByteArrayInputStream;
import java.util.LinkedList;
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

import org.deri.sql.SQLQuery;

/**
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
class getRDBTableAttributesExtFunction extends ExtensionFunctionDefinition {

  /**
	 * 
	 */
  private static final long serialVersionUID = 8641294257135052785L;
  
  private SQLQuery query = null;

  /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("xsparql",
      "http://xsparql.deri.org/demo/xquery/sparql-functions.xquery", "getRDBTableAttributes");

  // new StructuredQName("_java", "java:org.deri.sparql.Sparql",
  // "turtleGraphToURI");

  public getRDBTableAttributesExtFunction(SQLQuery q) {
      this.query = q;
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

      private static final long serialVersionUID = 154082133874153698L;

      @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {

	        String table = arguments[0].next().getStringValue();

//	        System.out.println("sqlQueryExtFunction: " +queryString);
//	        SQLQuery query = new SQLQuery();

	        String doc = null;
	        List<String> relations = new LinkedList<String>();
	        relations.add(table);
	        doc = query.getRelationInfoAsXMLString(relations);

	        // convert results to XML...
	        ByteArrayInputStream inputStream = 
	            new ByteArrayInputStream(doc.getBytes());


	        return SingletonIterator.makeIterator(
	        	context.getConfiguration().buildDocument(
	        		new StreamSource(inputStream)));

      }

    };
  }

}
