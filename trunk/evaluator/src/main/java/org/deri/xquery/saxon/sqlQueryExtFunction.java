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
import java.util.logging.Logger;

import javax.xml.transform.dom.DOMSource;
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
import org.deri.xsparql.rewriter.XSPARQLProcessor;
import org.w3c.dom.Document;


/**
 * Saxon External call for implementing SQL queries. 
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
class sqlQueryExtFunction extends ExtensionFunctionDefinition {

 
  private static final long serialVersionUID = 6029071845119045349L;

  private SQLQuery query = null;

  private final static Logger logger = Logger.getLogger(XSPARQLProcessor.class
	      .getClass().getName());

    /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("_xsparql",
      "http://xsparql.deri.org/demo/xquery/xsparql.xquery", "_sqlQuery");


  public sqlQueryExtFunction(SQLQuery q) {
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

    private static final long serialVersionUID = 3289758364063781529L;

    @Override
      public SequenceIterator call(SequenceIterator[] arguments,
          XPathContext context) throws XPathException {

        String queryString = arguments[0].next().getStringValue();

        logger.info("sqlQueryExtFunction: " +queryString);
        // SQLQuery query = new SQLQuery(queryString);

//        Document doc = null;
        String doc = null;
        try { 
//            doc = query.getResultsAsDocument(queryString); 
            doc = query.getResultsAsXMLString(queryString); 
        } catch (Exception e){
            System.err.println("Error executing SQL query: "+e.getMessage());
            System.exit(1);
        }

        // convert results to XML...
        ByteArrayInputStream inputStream = 
            new ByteArrayInputStream(doc.getBytes());


        return SingletonIterator.makeIterator(
        	context.getConfiguration().buildDocument(
        		new StreamSource(inputStream)
//        		new DOMSource(doc)
        		));

      }

    };
  }

}
