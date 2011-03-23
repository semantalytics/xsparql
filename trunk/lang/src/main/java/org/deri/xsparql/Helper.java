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
package org.deri.xsparql;

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

import org.w3c.dom.*;
import javax.xml.parsers.*;
import org.xml.sax.InputSource;
import org.apache.xerces.dom.DocumentImpl;

/**
 * Class contains only some helper "functions" (static methods)
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 * @author Nuno Lopes <nuno.lopes@deri.org>
 * 
 */
public class Helper {

    /**
     * Output format of Graphviz dot.
     * 
     * Use png|gif|jpg|svg|ps|pdf|...
     */
    static final String dotFormat = "pdf";

    /**
     * If String s starts with <code>lead</code>, remove <code>lead</code>
     * 
     * @param s
     *            String
     * @param lead
     *            Probable Leading of the String s
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
     * @param str
     * @param out
     * @throws IOException
     */
    static void outputString(final String str, final OutputStream out)
	    throws IOException {
	final Writer bw = new BufferedWriter(new OutputStreamWriter(out));
	bw.write(str);
	bw.close();
    }

    /**
     * Write a Graphviz DOT created picture of an AST <code>tree</code> to a
     * file
     * 
     * @param tree
     */
    static void writeDotFile(final CommonTree tree, final String dotFile) {

	final String dotFilename = "tfd/" + dotFile.concat(".dot");
	final String ouputFilename = "tfd/" + dotFile + "." + dotFormat;

	XSPARQLProcessor.logger.info("Creating DOT file " + dotFilename);

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
	    bw = new BufferedWriter(new OutputStreamWriter(
		    new FileOutputStream(dotFilename)));
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
	final String cmd = "dot -T" + dotFormat + " -o" + ouputFilename + " "
		+ dotFilename;
	XSPARQLProcessor.logger.info("Executing command: " + cmd);
	try {
	    Runtime.getRuntime().exec(cmd);
	} catch (IOException e) {
	    e.printStackTrace();
	}

	XSPARQLProcessor.logger.info("Done: " + dotFile);
    }

    /**
     * Print an AST to the console (recursive method)
     * 
     * @param tree
     *            current subtree
     * @param spaces
     *            a string containing a number of spaces dependant on the
     *            indentation level
     */
    private static void printTree(final Tree tree, final String spaces) {

	if (tree != null) {
	    System.err.println(spaces + tree);
	    for (int i = 0; i < tree.getChildCount(); i++) {
		// 3 spaces indentation for each level
		printTree(tree.getChild(i), spaces + "  ");
	    }
	} else {
	    System.err.println("Tree is null!!");
	}
    }

    /**
     * Print an AST to the console
     * 
     * @param tree
     *            The AST to print
     */
    static void printTree(final Tree tree) {
	System.err.println("Tree");
	System.err.println();
	printTree(tree, "");
    }

    /**
     * Returns an XML document from an XML string TODO: check if we don't need
     * this function
     * 
     * @param xml
     *            string representation of the XML
     * @return XML Document
     */
    public static Document parseXMLString(String xml) {

	Document doc = new DocumentImpl();
	try {
	    DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

	    DocumentBuilder db = dbf.newDocumentBuilder();

	    InputSource is = new InputSource();
	    is.setCharacterStream(new StringReader(xml));

	    doc = db.parse(is);
	} catch (Exception e) {
	}

	return doc;
    }
}
