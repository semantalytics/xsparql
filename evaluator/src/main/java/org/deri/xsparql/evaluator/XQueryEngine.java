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
