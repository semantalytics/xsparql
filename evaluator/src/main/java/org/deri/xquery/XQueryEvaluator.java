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

import java.io.InputStream;
import java.io.OutputStream;
import java.io.Reader;
import java.io.Writer;
import java.util.Map;

/**
 * Evaluate an XQuery query.
 * 
 * Usage: 1) use the setter methods to influence the evaluation 2) call one of
 * the evaluate methods
 * 
 * 
 * Created: Tue Sep 28 15:10:26 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public interface XQueryEvaluator {

  public void setExternalVariables(Map<String, String> xqueryExternalVars);

  /**
   * Set to <code>true</code> the XQuery engine is validating
   * 
   * @param validatingXQuery
   *          <code>true</code> to use a validating XQuery engine
   */
  public void setValidatingXQuery(boolean validatingXQuery);

  /**
   * Evaluate XQuery query <code>query</code> and output the result to
   * <code>out</code>.
   * 
   * @param query
   *          XQuery query
   * @param out
   *          OutputStream for the query result
   * @throws Exception
   */
  public String evaluate(final String query) throws Exception;

  public void evaluate(final InputStream query, OutputStream out)
      throws Exception;

  public void evaluate(final Reader query, Writer out) throws Exception;

  /**
   * Set to <code>true</code> to omit XML declaration in the beginning of the
   * result
   * 
   * @param xmloutput
   */
  public void setOmitXMLDecl(final boolean xmloutput);

}
