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
package org.sourceforge.xsparql;

import junit.framework.TestCase;

public class MainIT extends TestCase {

  public void testMain() {
    fail("Not yet implemented"); // TODO
  }

  /*
  private String main(String[] args) {
    File jar = new File("target/lang-1.0-SNAPSHOT.jar");

    String[] execArgs = new String[args.length + 3];
    System.arraycopy(args, 0, execArgs, 3, args.length);
    execArgs[0] = "java";
    execArgs[1] = "-jar";
    Process p = null;
    try {
      execArgs[2] = jar.getCanonicalPath();
      p = Runtime.getRuntime().exec(execArgs);
      p.waitFor();
    } catch (InterruptedException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    } catch (IOException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    return p.getInputStream().toString();
  }
*/
}
