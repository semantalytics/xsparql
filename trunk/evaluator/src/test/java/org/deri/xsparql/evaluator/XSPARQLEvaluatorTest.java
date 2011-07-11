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
import java.io.StringWriter;
import java.io.Writer;
import java.util.LinkedList;
import java.util.List;

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
