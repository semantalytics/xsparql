/**
 *
 * Copyright (C) 2011, NUI Galway.
 * Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, 
 * Vienna University of Technology
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * The names of the COPYRIGHT HOLDERS AND CONTRIBUTORS may not be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * Created on 09 February 2011 by Reasoning and Querying Unit (URQ), 
 * Digital Enterprise Research Institute (DERI) on behalf of NUI Galway.
 * 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
 * on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
 * University of Technology,  Nuno Lopes on behalf of NUI Galway.
 *
 */ 
package org.sourceforge.xsparql.evaluator;

import static org.junit.Assert.*;
import static org.junit.runners.Parameterized.*;

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
import java.util.*;

import javax.xml.transform.stream.StreamSource;

import org.antlr.runtime.RecognitionException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

@RunWith(Parameterized.class)
public class XSPARQLEvaluatorTest {

  private String filename;

  public XSPARQLEvaluatorTest(String filename) {
    this.filename = filename;
  }

  @Parameters(name = "{index}: {0}")
  public static Iterable<String[]> data() {
    return listFiles("examples");
  }

  /**
   * Test method for
   * {@link org.sourceforge.xsparql.evaluator.XSPARQLEvaluator#evaluate(Reader, Writer)}
   * .
   */
  @Test
  public void testEvaluateReaderOutputStream() throws Exception {

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

  /**
   * Test method for
   * {@link org.sourceforge.xsparql.evaluator.XSPARQLEvaluator#evaluate(Reader)}
   */
  @Test
  public void testEvaluateString() throws Exception {

      final String elementname = "asdf";
      final String content = "lkj";
      final StringReader xml = new StringReader("<" + elementname + ">" + content
          + "</" + elementname + ">");

      final StreamSource streamSource = new StreamSource(xml);

      final XSPARQLEvaluator xe = new XSPARQLEvaluator();
      xe.setSource(streamSource);

      assertEquals(content, xe.evaluate(new StringReader("/" + elementname + "/text()")));
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
  private static List<String[]> listFiles(String dirname) {
    List<String[]> filenames = new LinkedList<String[]>();

    InputStream is = XSPARQLEvaluatorTest.class.getClassLoader().getResourceAsStream(dirname);
    if (is != null) {
      BufferedReader rdr = new BufferedReader(new InputStreamReader(is));
      String line;
      try {
        while ((line = rdr.readLine()) != null) {
          filenames.add(new String[] {dirname + "/" + line});
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
