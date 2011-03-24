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
package org.deri.xsparql;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import java.util.logging.Logger;
import java.util.logging.Level;

import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

import org.deri.xquery.*;

/**
 * class used to store configuration options.
 * 
 * 
 * Created: Thu Sep 30 11:54:42 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class Configuration {

    static Logger logger = Logger.getLogger(XSPARQLProcessor.class.getClass()
	    .getName());

    /**
     * Parse in debug mode
     */
    private static boolean debug = false;

    /**
     * Lexer in debug mode
     */
    private static boolean debuglexer = false;

    /**
     * Show debug information
     */
    private static boolean verbose = false;

    /**
     * use validating XQuery engine
     */
    private static boolean validatingXQuery = false;

    /**
     * Print AST?
     */
    private static boolean ast = false;

    /**
     * File array of the query files
     */
    private static File[] queryFiles;

    /**
     * True if AST pictures should be generated
     */
    private static boolean dot = false;

    /**
     * File the result query is written to
     */
    private static File outputFile = null;

    /**
     * method to be used to perform SPARQL queries. By default requires a Joseki
     * endpoint
     */
    private static String SPARQLmethod = "arq";

    /**
     * XQuery engine to be used for evaluation/code production.
     */
    private static String xqueryEngine = "saxon";

    /**
     * Evaluate the query
     */
    private static boolean evaluate = true;

    /**
     * Create a debug version of the query
     */
    private static boolean debugVersion;

    /**
     * SPARQL endpoint uri
     */
    private static String endpointURI;

    private static boolean warnIfNestedConstruct = false;

    /*
     * external variables for Xquery evaluation
     */
    private static Map<String, String> xqueryExternalVars = new HashMap<String, String>();

    private static String TDBLocation = System.getProperty("user.home")
	    + "/.xsparql/TDB";

    // --------------------------------------------------- ACCESS Methods

    /**
     * Parse in debug mode
     */
    public static boolean debug() {
	return debug;
    }

    /**
     * Show debug information
     */
    public static boolean verbose() {
	return verbose;
    }

    /**
     * Lexer in debug mode
     */
    public static boolean debuglexer() {
	return debuglexer;
    }

    /**
     * use validating XQuery engine
     */
    public static boolean validatingXQuery() {
	return validatingXQuery;
    }

    /**
     * Print AST?
     */
    public static boolean printAst() {
	return ast;
    }

    /**
     * File array of the query files
     */
    public static File[] queryFiles() {
	return queryFiles;
    }

    /**
     * True if AST pictures should be generated
     */
    public static boolean printDot() {
	return dot;
    }

    /**
     * File the result query is written to
     */
    public static File outputFile() {
	return outputFile;
    }

    /**
     * method to be used to perform SPARQL queries. By default requires a Joseki
     * endpoint
     */
    public static String SPARQLmethod() {
	return SPARQLmethod;
    }

    /**
     * XQuery engine to be used for evaluation/code production.
     */
    public static String xqueryEngine() {
	return xqueryEngine;
    }

    /**
     * evaluate the query?
     */
    public static boolean evaluate() {
	return evaluate;
    }

    /**
     * Create a debug version of the query
     */
    public static boolean debugVersion() {
	return debugVersion;
    }

    /**
     * SPARQL endpoint uri
     */
    public static String endpointURI() {
	return endpointURI;
    }

    public static boolean warnIfNestedConstruct() {
	return warnIfNestedConstruct;
    }

    /*
     * external variables for Xquery evaluation
     */
    public static Map<String, String> xqueryExternalVars() {
	return xqueryExternalVars;
    };

    // --------------------------------------------------- command line parsing

    public static void setVerbose(boolean verbose) {

	if (verbose) {
	    logger.setLevel(Level.ALL);

	    logger.info(printParams());

	} else {
	    logger.setLevel(Level.WARNING);
	}

    }

    public static void setValidating(boolean validating) {
	validatingXQuery = validating;
    }

    public static void setXQueryEngine(String engine) {
	xqueryEngine = engine;
    }

    /**
     * Parse program arguments
     * 
     * @param args
     *            the same as for main(String[] args)
     */
    public static void parseOptions(final String[] args) {
	final OptionParser oparser = new OptionParser();
	oparser.accepts("p", "Parse in debug mode");
	oparser.accepts("l", "Put Lexer in debug mode");
	oparser.accepts("a", "Print AST between rewriting steps");
	oparser.accepts("d", "Create debug version");
	oparser.accepts("dot", "Save AST as PNG file (Graphviz needed)");
	final OptionSpec<File> fileFileOption = oparser.accepts("f",
		"Write result query to file").withRequiredArg().ofType(
		File.class);
	oparser
		.accepts("u",
			"SPARQL endpoint URI like \"http://localhost:2020/sparql?query=\"")
		.withRequiredArg();
	oparser.accepts("h", "Show Help");
	oparser.accepts("version", "Show version information");
	oparser.accepts("v", "Show debug information (verbose mode)");
	oparser.accepts("noval", "Use non-validating XQuery engine (default)");
	oparser.accepts("val", "Use validating XQuery engine");
	oparser.accepts("arq", "use ARQ API to perform SPARQL queries");
	oparser.accepts("joseki",
		"use Joseki endpoint to perform SPARQL queries");
	oparser.accepts("rewrite-only", "Only perform rewriting to XQuery");
	final OptionSpec<String> xqueryEval = oparser
		.accepts("e",
			"Evaluate result query with the specified XQuery engine to use (saxon | qexo) ")
		.withRequiredArg().ofType(String.class);

	final OptionSet options = oparser.parse(args);

	// parameters which lead to early exit
	if (options.has("h")) {
	    System.out
		    .println("USAGE: java -jar xsparql.jar [OPTIONS] [FILE]...");
	    System.out.println();

	    try {
		oparser.printHelpOn(System.out);
	    } catch (IOException e) {
		e.printStackTrace();
	    }
	    System.exit(0);
	}

	// get version from jar file
	if (options.has("version")) {
	    System.out.println(Main.class.getPackage().getImplementationTitle()
		    + " version "
		    + Main.class.getPackage().getImplementationVersion());
	    System.exit(0);
	}

	if (options.has("noval") && options.has("val")) {
	    System.err
		    .println("Use either \"val\" or \"noval\". Using default.");
	} else if (options.has("noval")) {
	    validatingXQuery = false;
	} else if (options.has("val")) {
	    validatingXQuery = true;
	}

	// simple commandline switches
	verbose = options.has("v");
	dot = options.has("dot");
	debug = options.has("p");
	debuglexer = options.has("l");
	ast = options.has("a");

	if (options.has("arq") && options.has("joseki")) {
	    System.err
		    .println("Use either \"arq\" or \"joseki\". Using default.");
	} else if (options.has("arq")) {
	    SPARQLmethod = "arq";
	} else if (options.has("joseki")) {
	    SPARQLmethod = "joseki";
	}

	// XQuery engine specification
	if (options.has(xqueryEval)) {
	    xqueryEngine = options.valueOf(xqueryEval);
	}

	if (options.has("rewrite-only")) {
	    evaluate = false;
	}

	if (options.has("d")) {
	    debugVersion = options.has("d");
	    verbose = true;
	}

	// serverMode = options.has("s");

	// query output file
	if (options.has(fileFileOption)) {
	    outputFile = options.valueOf(fileFileOption);
	}

	// SPARQL endpoint URI
	if (options.has("u")) {
	    endpointURI = options.valueOf("u").toString();
	}

	// get all the names of the XSPARQL query files
	final List<File> queryFilesList = new ArrayList<File>();

	for (String filename : options.nonOptionArguments()) {
	    if (filename.contains("=")) { // Xquery external variable
		xqueryExternalVars.put(filename.substring(0, filename
			.indexOf("=")), filename.substring(filename
			.indexOf("=") + 1));
	    } else {
		queryFilesList.add(new File(filename)); // really a filename
	    }
	}

	queryFiles = queryFilesList.toArray(new File[0]);

	if (options.has("u") && !xqueryEngine.equals("")) {
	    // if you don't use a local sparql endpoint (otherwise you wouldn't
	    // use the -u) and you want to evaluate the
	    // query right after the translation then under the additional
	    // condition that the query contains a nested
	    // construct the evaluation wont work -> check for a nested
	    // construct during translation
	    warnIfNestedConstruct = true;
	}

	setVerbose(verbose);

    }

    public static xqueryEvaluator getEvaluator() {

	xqueryEvaluator eval = null;

	if (xqueryEngine.equals("saxon")) {
	    eval = new xqueryEvaluatorSaxon();
	}

	//if (xqueryEngine.equals("qexo")) {
	//    eval = new xqueryEvaluatorQexo();
	//}

	return eval;
    }

    public static String getTDBLocation() {

	return TDBLocation;
    }

    /**
     * {@inheritDoc}
     */
    public static String printParams() {
	final int sbSize = 1000;
	final String variableSeparator = "  ";
	final StringBuffer sb = new StringBuffer(sbSize);

	sb.append("logger=").append(logger);
	sb.append(variableSeparator);
	sb.append("debug=").append(debug);
	sb.append(variableSeparator);
	sb.append("debuglexer=").append(debuglexer);
	sb.append(variableSeparator);
	sb.append("verbose=").append(verbose);
	sb.append(variableSeparator);
	sb.append("validatingXQuery=").append(validatingXQuery);
	sb.append(variableSeparator);
	sb.append("ast=").append(ast);
	sb.append(variableSeparator);
	sb.append("queryFiles=").append(queryFiles);
	sb.append(variableSeparator);
	sb.append("dot=").append(dot);
	sb.append(variableSeparator);
	sb.append("outputFile=");
	if (outputFile != null) {
	    sb.append(outputFile);
	}
	sb.append(variableSeparator);
	sb.append("SPARQLmethod=").append(SPARQLmethod);
	sb.append(variableSeparator);
	sb.append("xqueryEngine=").append(xqueryEngine);
	sb.append(variableSeparator);
	sb.append("evaluate=").append(evaluate);
	sb.append(variableSeparator);
	sb.append("debugVersion=").append(debugVersion);
	sb.append(variableSeparator);
	sb.append("endpointURI=").append(endpointURI);
	sb.append(variableSeparator);
	sb.append("warnIfNestedConstruct=").append(warnIfNestedConstruct);

	return sb.toString();
    }

}
