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

import org.deri.xquery.EvaluatorExternalFunctions;

//import net.sf.saxon.functions.*;
import net.sf.saxon.lib.*;

import net.sf.saxon.tree.iter.*;
import net.sf.saxon.om.*;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.StringValue;

/**
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class turtleGraphToURIExtFunction extends ExtensionFunctionDefinition {

    /**
	 * 
	 */
    private static final long serialVersionUID = 8641294257135052785L;
    /**
     * Name of the function
     * 
     */
    private static StructuredQName funcname = new StructuredQName("_xsparql",
	    "http://xsparql.deri.org/demo/xquery/xsparql.xquery",
	    "turtleGraphToURI");

    // new StructuredQName("_java", "java:org.deri.sparql.Sparql",
    // "turtleGraphToURI");

    public turtleGraphToURIExtFunction() {
    }

    @Override
    public StructuredQName getFunctionQName() {
	return funcname;
    }

    @Override
    public int getMinimumNumberOfArguments() {
	return 2;
    }

    @Override
    public int getMaximumNumberOfArguments() {
	return 2;
    }

    @Override
    public SequenceType[] getArgumentTypes() {
	return new SequenceType[] { SequenceType.SINGLE_STRING,
		SequenceType.SINGLE_STRING };
    }

    @Override
    public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
	return SequenceType.SINGLE_STRING;
    }

    @Override
    public ExtensionFunctionCall makeCallExpression() {

	return new ExtensionFunctionCall() {

	    private static final long serialVersionUID = 154082133874153698L;

	    @Override
	    public SequenceIterator call(SequenceIterator[] arguments,
		    XPathContext context) throws XPathException {

		String prefix = arguments[0].next().getStringValue();
		String n3 = arguments[1].next().getStringValue();

		return SingletonIterator
			.makeIterator(new StringValue(
				EvaluatorExternalFunctions.turtleGraphToURI(
					prefix, n3)));
	    }

	};
    }

}
