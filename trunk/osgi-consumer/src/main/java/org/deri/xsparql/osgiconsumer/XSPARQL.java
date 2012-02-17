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
package org.deri.xsparql.osgiconsumer;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import javax.ws.rs.GET;
import javax.ws.rs.Path;

import org.deri.xsparql.evaluator.XSPARQLEvaluator;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

@Path("xsparql")
public class XSPARQL implements BundleActivator {
  @GET
  public String helloWorld() {
    return "Hello World!";
  }
  
  public void test() throws IOException {
    String result = testQuery();
    
    System.out.println("XSPARQL result:\n" + result);
  }

  public void start(BundleContext arg0) throws Exception {
    test();
  }
  
  @GET
  public String testQuery() {
    XSPARQLEvaluator xsparql = new XSPARQLEvaluator();
    Reader r = new StringReader("5");
    String result = "fail";
    try {
      result = xsparql.evaluate(r);
    } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    return result;
  }

  public void stop(BundleContext arg0) throws Exception {
    // TODO Auto-generated method stub
    
  }

}
