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
package org.sourceforge.xsparql.rewriter;

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.io.StringReader;

import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.DOTTreeGenerator;
import org.antlr.runtime.tree.Tree;
import org.antlr.stringtemplate.StringTemplate;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.apache.xerces.dom.DocumentImpl;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

/**
 * Class contains only some helper "functions" (static methods)
 */
public class Helper {

  static final Logger logger = LogManager.getLogger(Helper.class);

  /**
   * Output format of Graphviz dot.
   *
   * Use png|gif|jpg|svg|ps|pdf|...
   */
  private static final String DOTFORMAT = "pdf";

  /**
   * If String s starts with <code>lead</code>, remove <code>lead</code>
   *
   * @param s String
   * @param lead Probable Leading of the String s
   * @return String s without lead or just s
   */
  public static String removeLeading(final String s, final String lead) {
    if (s.startsWith(lead)) {
      return s.substring(lead.length());
    } else {
      return s;
    }
  }

  /**
   * Write a String to an OutputStream
   *
   * @param str the string to be written
   * @param out the output stream
   * @throws IOException
   */
  public static void outputString(final String str, final OutputStream out)
      throws IOException {
    final Writer bw = new BufferedWriter(new OutputStreamWriter(out));
    bw.write(str);
    bw.close();
  }

  /**
   * Write a Graphviz DOT created picture of an AST <code>tree</code> to a file
   *
   * @param tree
   */
  static void writeDotFile(final CommonTree tree, final String dotFile) {

    final String dotFilename = "tfd/" + dotFile.concat(".dot");
    final String ouputFilename = "tfd/" + dotFile + "." + DOTFORMAT;

    logger.info("Creating DOT file " + dotFilename);

    final DOTTreeGenerator dtg = new DOTTreeGenerator();
    final StringTemplate st = dtg.toDOT(tree);

    // don't want gray background and blue text
    final String dotDesc = st
        .toString()
        .replace("bgcolor=\"lightgrey\"; ", "")
        .replace(
            "fixedsize=false, fontsize=12, fontname=\"Helvetica-bold\", fontcolor=\"blue\"",
            "");

    // create the dot file
    Writer bw = null;
    try {
      bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(
          dotFilename)));
      bw.write(dotDesc);
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (bw != null) {
        try {
          bw.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }

    // create the image out of the dot file
    final String cmd = "dot -T" + DOTFORMAT + " -o" + ouputFilename + " "
        + dotFilename;
    logger.info("Executing command: " + cmd);
    try {
      Runtime.getRuntime().exec(cmd);
    } catch (IOException e) {
      e.printStackTrace();
    }

    logger.info("Done: " + dotFile);
  }

  /**
   * Print an AST to the console (recursive method)
   *
   * @param tree current subtree
   * @param spaces a string containing a number of spaces dependant on the
   *               indentation level
   */
  private static void printTree(final Tree tree, final String spaces) {

    if (tree == null) {
      System.err.println("Tree is null!!");
    } else {
      System.err.println(spaces + tree);
      for (int i = 0; i < tree.getChildCount(); i++) {
        // 3 spaces indentation for each level
        printTree(tree.getChild(i), spaces + "  ");
      }
    }
  }

  /**
   * Print an AST to the console
   *
   * @param tree The AST to print
   */
  static void printTree(final Tree tree) {
    System.out.println("\n" + new TreePrinter().print(tree));
  }

  /**
   * Returns an XML document from an XML string
   *
   * @param xml string representation of the XML
   * @return XML Document
   */
  public static Document parseXMLString(String xml) {

    Document doc = new DocumentImpl();

    DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

    DocumentBuilder db;
    try {
      db = dbf.newDocumentBuilder();

      InputSource is = new InputSource();
      is.setCharacterStream(new StringReader(xml));

      doc = db.parse(is);
    } catch (ParserConfigurationException e1) {
      e1.printStackTrace();
    } catch (SAXException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }

    return doc;
  }
}
