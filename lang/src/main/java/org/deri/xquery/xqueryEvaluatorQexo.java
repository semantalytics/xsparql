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
package org.deri.xquery;

import java.io.PrintStream; //import java.util.Map;
//import java.util.HashMap;
import gnu.xquery.lang.XQuery;

import org.deri.xsparql.Configuration;

/**
 * Describe class xqueryEvaluatorQexo here.
 * 
 * 
 * Created: Tue Sep 28 15:39:49 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class xqueryEvaluatorQexo extends xqueryEvaluator {

    /**
     * Creates a new <code>xqueryEvaluatorQexo</code> instance.
     * 
     */
    public xqueryEvaluatorQexo() {
	validatingXQuery = Configuration.validatingXQuery();
	xqueryExternalVars = Configuration.xqueryExternalVars();
    }

    /**
     * Evaluate the XQuery
     * 
     * @param query
     */
    @Override
    public void evaluate(final String query) throws Exception {
	evaluate(query, System.out);
    }

    /**
     * Evaluate the XQuery
     * 
     * @param query
     * @param out
     *            output
     */
    @Override
    public void evaluate(final String query, PrintStream out) throws Exception {
	XQuery xq = new XQuery();

	try {
	    Object result = xq.eval(query);

	    String res = result.toString().replaceAll("\n, ", "\n");

	    out.println(res);

	} catch (Throwable e) {
	    throw new Exception(e.getMessage());
	}

    }

}
