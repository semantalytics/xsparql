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
import java.util.logging.Logger;

import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.SequenceTool;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;

import org.sourceforge.xsparql.rewriter.XSPARQLProcessor;
import org.sourceforge.xsparql.sql.SQLQuery;


/**
 * Saxon External call for implementing SQL queries. 
 */
public class sqlQueryExtFunction extends ExtensionFunctionDefinition {

 
  private static final long serialVersionUID = 6029071845119045349L;

  private SQLQuery query = null;

  private final static Logger logger = Logger.getLogger(XSPARQLProcessor.class
	      .getClass().getName());

  private static StructuredQName funcname = new StructuredQName("_xsparql",
      "http://xsparql.deri.org/demo/xquery/xsparql.xquery", "_sqlQuery");

  public sqlQueryExtFunction() {
      this.query = null;
    }

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
    return 5;
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

    @SuppressWarnings({ "unchecked", "rawtypes" })
    @Override
      public Sequence call(XPathContext context,
                           Sequence[] arguments) throws XPathException {

        String queryString = arguments[0].iterate().next().getStringValue();

        if(query == null && arguments.length > 1) {
            String db = arguments[1].iterate().next().getStringValue();
            String engine = arguments[2].iterate().next().getStringValue();
            String user = arguments[3].iterate().next().getStringValue();
//            String password = arguments[4].next().getStringValue();
            query = new SQLQuery(engine,null,null,db,null,user,null);
        }
        
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


        return SequenceTool.asItem(
        	context.getConfiguration().buildDocument(
        		new StreamSource(inputStream)
//        		new DOMSource(doc)
        		));

      }

    };
  }

}
