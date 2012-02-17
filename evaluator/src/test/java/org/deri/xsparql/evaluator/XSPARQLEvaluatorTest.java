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

import static org.junit.Assert.*;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.util.LinkedList;
import java.util.List;

import javax.xml.transform.stream.StreamSource;

import org.antlr.runtime.RecognitionException;
import org.junit.Test;

/**
 * @author stefan
 * 
 */
public class XSPARQLEvaluatorTest {

  /**
   * Test method for
   * {@link org.deri.xsparql.evaluator.XSPARQLEvaluator#evaluate(java.io.Reader, java.io.OutputStream)}
   * .
   */
  @Test
  public void testEvaluateReaderOutputStream() {
    try {

      for (String filename : listFiles("examples")) {
        if (filename.endsWith(".xsparql")) {
          System.out.println(filename);
          Reader queryReader = loadReaderFromClasspath(filename);
          XSPARQLEvaluator xe = new XSPARQLEvaluator();
          xe.setQueryFilename(filename);
          Writer o = new StringWriter();
          xe.evaluate(queryReader, o);
          // ignore the OutputStream for now
        }
      }

    } catch (RecognitionException e) {
      fail("Exception: " + e.getMessage());
    } catch (Exception e) {
      ByteArrayOutputStream os = new ByteArrayOutputStream();
      PrintStream ps = new PrintStream(os);
      e.printStackTrace(ps);
      fail("Exception: " + os.toString());
    }
  }

  /**
   * Test method for
   * {@link org.deri.xsparql.evaluator.XSPARQLEvaluator#evaluate(String)} .
   */
  @Test
  public void testEvaluateString() {
    try {
      String elementname = "asdf";
      String content = "lkj";
      StringReader xml = new StringReader("<" + elementname + ">" + content
          + "</" + elementname + ">");

      XSPARQLEvaluator xe = new XSPARQLEvaluator();
      xe.setSource(new StreamSource(xml));

      assertEquals(content,
          xe.evaluate(new StringReader("/" + elementname + "/text()")));

    } catch (RecognitionException e) {
      fail("Exception: " + e.getMessage());
    } catch (Exception e) {
      ByteArrayOutputStream os = new ByteArrayOutputStream();
      PrintStream ps = new PrintStream(os);
      e.printStackTrace(ps);
      fail("Exception: " + os.toString());
    }
  }

  /**
   * "Transform" a file on the classpath into a BufferedReader
   * 
   * TODO copied from XSPARQLProcessor test
   * 
   * @param filename
   * @return
   */
  private BufferedReader loadReaderFromClasspath(String filename) {
    return new BufferedReader(new InputStreamReader(getClass().getClassLoader()
        .getResourceAsStream(filename)));
  }

  /**
   * List files contained in a directory in the classpath
   * 
   * TODO copied from XSPARQLProcessor test
   * 
   * @throws IOException
   */
  private List<String> listFiles(String dirname) {
    List<String> filenames = new LinkedList<String>();

    InputStream is = getClass().getClassLoader().getResourceAsStream(dirname);
    if (is != null) {
      BufferedReader rdr = new BufferedReader(new InputStreamReader(is));
      String line;
      try {
        while ((line = rdr.readLine()) != null) {
          filenames.add(dirname + "/" + line);
        }
      } catch (IOException e) {
        e.printStackTrace();
      } finally {
        try {
          rdr.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }

    return filenames;
  }

}
