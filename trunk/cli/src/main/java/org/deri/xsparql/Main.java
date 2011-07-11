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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

import org.deri.xsparql.evaluator.XQueryEngine;
import org.deri.xsparql.evaluator.XSPARQLEvaluator;
import org.deri.xsparql.rewriter.Helper;
import org.deri.xsparql.rewriter.SPARQLEngine;
import org.deri.xsparql.rewriter.XSPARQLProcessor;

/**
 * Main entry point for the commandline interface
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 * @author Nuno Lopes <nuno.lopes@deri.org>
 */
public class Main {

  /**
   * True if parse errors occured
   */
  private boolean parseErrors = false;
  private File[] queryFiles;
  private File outputFile = null;
  private int numOfSyntaxErrors;
  private final XSPARQLProcessor proc = new XSPARQLProcessor();
  private final XSPARQLEvaluator xe = new XSPARQLEvaluator();
  private boolean evaluate;

  /**
   * Main application entry point
   * 
   * @param args
   *          Commandline arguments
   * @throws IOException
   */
  public static void main(final String[] args) throws IOException {
    Main main = new Main();

    main.parseOptions(args);

    Reader is = null;
    if (main.queryFiles.length > 0) {
      for (File queryFile : main.queryFiles) {
        try {
          is = new FileReader(queryFile);
          String xquery = main.rewriteQuery(is, queryFile.getName());
          main.postProcessing(xquery);
        } catch (FileNotFoundException e) {
          String filename = queryFile.getPath();
          System.err.println("File not found: " + filename);
        } catch (Exception e) {
          // TODO Auto-generated catch block
          e.printStackTrace();
        }
      }
    } else {
      is = new InputStreamReader(System.in);
      String xquery = main.rewriteQuery(is, "stdin");
      try {
        main.postProcessing(xquery);
      } catch (Exception e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
    }

    if (main.parseErrors) {
      System.exit(1);
    }
  }

  /**
   * Actual query rewriting.
   * 
   * @param is
   *          XSPARQL query
   * @param filename
   *          Filename of the XSPARQL query
   */
  private String rewriteQuery(Reader is, String filename) {
    String xquery = null;
    try {
      proc.setQueryFilename(filename);

      xquery = proc.process(is);
      numOfSyntaxErrors = proc.getNumberOfSyntaxErrors();

    } catch (Exception e) {
      System.err.println("Parse error: " + e);
      parseErrors = true;
    }
    return xquery;
  }

  /**
   * Post processing after the rewriting. Optionally evaluates rewritten query.
   * 
   * @param xquery
   *          XQuery query
   * @param proc
   *          Instance of <code>XSPARQLProcessor</code>
   * @throws Exception
   */
  private void postProcessing(final String xquery) throws Exception {
    parseErrors = parseErrors || numOfSyntaxErrors > 0;

    if (parseErrors) {
      return;
    }

    String result;
    
    // evaluate the expression
    if (this.evaluate) {

      result = xe.evaluateRewrittenQuery(xquery);

      // XQueryEvaluator eval = XSPARQLEvaluator.getEvaluator();
      //
      // if (eval == null) {
      // throw new Exception(
      // "Cannot evaluate the query with the specified engine");
      // }
      //
      // eval.evaluate(xquery);
    } else {
      result = xquery;
    }
      
    if (outputFile == null) {
      Helper.outputString(result, System.out);
    } else {
      Helper.outputString(result, new FileOutputStream(outputFile));
    }

  }

  /**
   * Parse program arguments
   * 
   * @param args
   *          the same as for main(String[] args)
   */
  private void parseOptions(final String[] args) {
    final OptionParser oparser = new OptionParser();
    oparser.accepts("p", "Parse in debug mode");
    oparser.accepts("l", "Put Lexer in debug mode");
    oparser.accepts("a", "Print AST between rewriting steps");
    oparser.accepts("d", "Create debug version");
    oparser.accepts("dot", "Save AST as PNG file (Graphviz needed)");
    final OptionSpec<File> fileFileOption = oparser
        .accepts("f", "Write result query to file").withRequiredArg()
        .ofType(File.class);
    oparser.accepts("u",
        "SPARQL endpoint URI like \"http://localhost:2020/sparql?query=\"")
        .withRequiredArg();
    oparser.accepts("h", "Show Help");
    oparser.accepts("version", "Show version information");
    oparser.accepts("v", "Show debug information (verbose mode)");
    oparser.accepts("noval", "Use non-validating XQuery engine (default)");
    oparser.accepts("val", "Use validating XQuery engine");
    oparser.accepts("arq", "use ARQ API to perform SPARQL queries (default)");
    oparser.accepts("joseki", "use Joseki endpoint to perform SPARQL queries");
    oparser.accepts("rewrite-only", "Only perform rewriting to XQuery");
    oparser.accepts("lib", "XQuery library location as URI").withRequiredArg()
        .ofType(String.class);
    final OptionSpec<File> tdbDirOption = oparser
        .accepts("tdbdir", "TDB directory").withRequiredArg()
        .ofType(File.class);
    final OptionSpec<String> xqueryEval = oparser
        .accepts(
            "e",
            "Evaluate result query with the specified XQuery engine to use (saxon-he | saxon-ee | qexo). Default: evaluate with Saxon-HE.")
        .withRequiredArg().ofType(String.class);

    final OptionSet options = oparser.parse(args);

    // parameters which lead to early exit

    if (options.has("h")) {
      System.out
          .println("USAGE: java -jar xsparql.jar [OPTIONS] [FILE]* [PARAMETERS]*");
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
          + " version " + Main.class.getPackage().getImplementationVersion());
      System.exit(0);
    }

    // Validating XQuery

    if (options.has("noval") && options.has("val")) {
      System.err.println("Use either \"val\" or \"noval\". Using default.");
    } else if (options.has("noval") || options.has("val")) {
      proc.setValidating(options.has("val"));
    } else {
      // use default
    }

    // simple commandline switches
    proc.setVerbose(options.has("v"));
    proc.setDot(options.has("dot"));
    proc.setDebug(options.has("p"));
    proc.setDebugLexer(options.has("l"));
    proc.setAst(options.has("a"));
    this.evaluate = !options.has("rewrite-only");
    proc.setDebugVersion(options.has("d"));

    if (options.has("arq") && options.has("joseki")) {
      System.err.println("Use either \"arq\" or \"joseki\". Using default.");
    } else if (options.has("joseki")) {
      proc.setSPARQLEngine(SPARQLEngine.JOSEKI);
    } else {
      // use default
    }

    // XQuery engine specification

    if ("saxon-ee".equals(options.valueOf(xqueryEval))) {
      xe.setXQueryEngine(XQueryEngine.SAXONEE);
    } else if ("qexo".equals(options.valueOf(xqueryEval))) {
      xe.setXQueryEngine(XQueryEngine.QEXO);
    } else {
      // use default
    }

    // serverMode = options.has("s");

    // query output file
    if (options.has(fileFileOption)) {
      outputFile = options.valueOf(fileFileOption);
    }

    // directory where TDB saves the fiels of the triple store
    if (options.has(tdbDirOption)) {
      xe.setTdbDir(options.valueOf(tdbDirOption));
    }

    // SPARQL endpoint URI
    if (options.has("u")) {
      proc.setEndpointURI(options.valueOf("u").toString());
    }

    // XSPARQL XQuery library location

    if (options.has("lib")) {
      proc.setXSPARQLLibURL(options.valueOf("lib").toString());
    } else {
      // use default
    }

    {
      // get all the names of the XSPARQL query files as well as external
      // variable assignments
      final List<File> queryFilesList = new ArrayList<File>();
      final Map<String, String> externalVariables = new HashMap<String, String>();
      for (String filename : options.nonOptionArguments()) {
        if (filename.contains("=")) { // Xquery external variable
          externalVariables.put(filename.substring(0, filename.indexOf("=")),
              filename.substring(filename.indexOf("=") + 1));
        } else {
          queryFilesList.add(new File(filename)); // really a filename
        }
      }

      xe.setXqueryExternalVars(externalVariables);

      queryFiles = queryFilesList.toArray(new File[queryFilesList.size()]);
    }

    // if you don't use a local sparql endpoint (otherwise you wouldn't use
    // the -u) and you want to evaluate the
    // query right after the translation then under the additional condition
    // that the query contains a nested
    // construct the evaluation wont work -> check for a nested construct
    // during translation
    // TODO move this to the XSPARQLProcessor
    

  }

}
