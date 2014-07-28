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

//import net.sf.saxon.functions.*;
import net.sf.saxon.lib.*;

//import com.hp.hpl.jena.query.*;
//import java.io.*;

//import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.tree.iter.*;
import net.sf.saxon.om.*;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.trans.XPathException;

//import net.sf.saxon.value.StringValue;

/**
 * 
 * @author Nuno Lopes
 */
public class scopedDatasetPopResultsExtFunction extends ExtensionFunctionDefinition {

  /**
	 * 
	 */
  private static final long serialVersionUID = -3618421782402392314L;
  /**
   * Name of the function
   * 
   */
  private static StructuredQName funcname = new StructuredQName("_xsparql",
      "http://xsparql.deri.org/demo/xquery/xsparql.xquery",
      "scopedDatasetPopResults");

  // new StructuredQName("_java", "java:org.deri.sparql.Sparql",
  // "scopedDatasetPopResults");

  public scopedDatasetPopResultsExtFunction() {
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
  public boolean hasSideEffects() {
    return true;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {
	  return new ExtensionFunctionCall() {
		@Override
		public SequenceIterator<? extends Item> call(
				SequenceIterator<? extends Item>[] arg0, XPathContext arg1)
				throws XPathException {
			  throw new UnsupportedOperationException("A proper binding should be supplied");
		}
	};
  }

}
