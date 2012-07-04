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
package org.deri.xsparql;

import java.io.StringReader;
import org.deri.xsparql.rewriter.XSPARQLProcessor;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
      try {
        System.out.println( "Hello World!" );
        String xquery = new String("let $x := \"Foo: Hello World\" construct { [] a {$x} }");
        XSPARQLProcessor xp = new XSPARQLProcessor();
        String q = xp.process(new StringReader(xquery));
        System.out.println( "Result: "+ q );
      } catch (Exception e) {System.err.println(e.getMessage());}

    }
}
