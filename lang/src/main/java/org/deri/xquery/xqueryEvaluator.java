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

import java.io.PrintStream;
import java.util.Map;

/**
 * Describe class xqueryEvaluator here.
 * 
 * 
 * Created: Tue Sep 28 15:10:26 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public abstract class xqueryEvaluator {

    /*
     * external variables for Xquery evaluation
     */
    protected Map<String, String> xqueryExternalVars;

    /**
     * use validating XQuery engine
     */
    protected static boolean validatingXQuery = true;

    abstract public void evaluate(final String query) throws Exception;

    abstract public void evaluate(final String query, PrintStream out)
	    throws Exception;

}
