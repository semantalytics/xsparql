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
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class scopedDatasetPopResultsExtFunction extends
	ExtensionFunctionDefinition {

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

	    private static final long serialVersionUID = -1452266931467431145L;

	    @Override
	    public SequenceIterator call(SequenceIterator[] arguments,
		    XPathContext context) throws XPathException {

		String id = arguments[0].next().getStringValue();

		EvaluatorExternalFunctions.scopedDatasetPopResults(id);

		return EmptyIterator.getInstance();
	    }

	};
    }

}
