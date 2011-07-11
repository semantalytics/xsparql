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
/**
 * 
 */
package org.deri.xsparql.rewriter;

import static org.junit.Assert.*;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.Reader;
import java.io.StringReader;
import java.util.LinkedList;
import java.util.List;

import org.antlr.runtime.RecognitionException;
import org.deri.xsparql.rewriter.XSPARQLProcessor;
import org.junit.Test;

/**
 * @author stefan
 * 
 */
public class XSPARQLProcessorTest {

  private final XSPARQLProcessor processor;

  public XSPARQLProcessorTest() {
    processor = new XSPARQLProcessor();
  }

  /**
   * Test method for
   * {@link org.deri.xsparql.rewriter.XSPARQLProcessor#process(java.io.Reader)}.
   * Very simple query: "5". If this fails something went wrong during
   * integration.
   */
  @Test
  public void testSimple() {
    try {
      processor.process(readString("5"));
    } catch (RecognitionException e) {
      fail("Exception: " + e.getMessage());
    } catch (IOException e) {
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
   * {@link org.deri.xsparql.rewriter.XSPARQLProcessor#process(java.io.Reader)}.
   * Run all the query files in the resources/examples directory.
   */
  @Test
  public void testProcessReaderString() {
    try {

      for (String filename : listFiles("examples")) {
        if (filename.endsWith(".xsparql")) {
          Reader queryReader = loadReaderFromClasspath(filename);
          processor.process(queryReader);
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
   * "Transform" a file on the classpath into a BufferedReader
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

  /**
   * Return a Reader object for a String
   * 
   * @param s
   * @return
   */
  private static Reader readString(String s) {
    return new StringReader(s);
  }
}
