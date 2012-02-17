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
/**
 * 
 */
package org.deri.xsparql.evaluator;

import org.deri.xquery.XQueryEvaluator;

/**
 * @author stefan
 * 
 */
public enum XQueryEngine {
  SAXONHE(new org.deri.xquery.saxon.xqueryEvaluatorSaxon(false)), SAXONEE(
      new org.deri.xquery.saxon.xqueryEvaluatorSaxon(true)), QEXO(
      new org.deri.xquery.saxon.xqueryEvaluatorSaxon(false));

  private XQueryEvaluator xeval;

  private XQueryEngine(XQueryEvaluator xeval) {
    this.xeval = xeval;
  }

  public XQueryEvaluator getXQueryEvaluator() {
    return xeval;
  }
}
