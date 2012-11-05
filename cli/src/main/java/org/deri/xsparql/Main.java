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

import java.io.Console;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

import org.deri.xsparql.evaluator.XSPARQLEvaluator;
import org.deri.xsparql.rewriter.Helper;
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
  protected boolean r2rml = false;
  protected boolean dm = false;
  
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
          if(main.isDebug()) {
            e.printStackTrace();
            System.exit(1);
          } else {
            System.err.println("Error executing query ("+queryFile.getName()+"): "+e.getMessage());
            System.exit(1);
          }
        }
      }
    }
    
    
    if (main.queryFiles.length == 0 && !main.r2rml && !main.dm) {
      is = new InputStreamReader(System.in);
      String xquery = main.rewriteQuery(is, "stdin");
      try {
        main.postProcessing(xquery);
      } catch (Exception e) {
	  if(main.isDebug()) {
	      e.printStackTrace();
          } else {
              System.err.println("Error executing query (stdin): "+e.getMessage());
          }
      }
    }
    
    // process R2RML 
    // TODO: determine behaviour if both r2rml and query files are specified
    if(main.r2rml) {
	is = new InputStreamReader(XSPARQLEvaluator.class.getResourceAsStream("/rdb2rdf/r2rml.xsparql"));
	String xquery = main.rewriteQuery(is, "r2rml");
	try {
	    main.postProcessing(xquery);
	} catch (Exception e) {
	    if(main.isDebug()) {
		e.printStackTrace();
	    } else {
		System.err.println("Error executing R2RML mapping: "+e.getMessage());
	    }
	}
    }

    // process R2RML 
    // TODO: determine behaviour if both r2rml and query files are specified
    if(main.dm) {
	is = new InputStreamReader(XSPARQLEvaluator.class.getResourceAsStream("/rdb2rdf/dm.xsparql"));
	String xquery = main.rewriteQuery(is, "dm");
	try {
	    main.postProcessing(xquery);
	} catch (Exception e) {
	    if(main.isDebug()) {
		e.printStackTrace();
	    } else {
		System.err.println("Error executing RDB2RDF direct mapping: "+e.getMessage());
	    }
	}
    }

    if (main.parseErrors) {
      System.exit(1);
    }

    //close any db connection
    main.closeDBconnection();
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
      e.printStackTrace();
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

      xe.setDBconnection(proc.getDBconnection());
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
    boolean createDBconnection = false;

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
//    oparser.accepts("noval", "Use non-validating XQuery engine (default)");
//    oparser.accepts("val", "Use validating XQuery engine");
//    oparser.accepts("arq", "use ARQ API to perform SPARQL queries (default)");
//    oparser.accepts("joseki", "use Joseki endpoint to perform SPARQL queries");
    oparser.accepts("rewrite-only", "Only perform rewriting to XQuery");

    oparser.accepts("psql", "Connect to a PostgreSQL database");
    oparser.accepts("mysql", "Connect to a MySQL database");
    oparser.accepts("sqlserver", "Connect to a SQL Server database");
    oparser.accepts("dbServer", "Hostname to connect to").withRequiredArg().ofType(String.class);
    oparser.accepts("dbPort", "Port number to connect to").withRequiredArg().ofType(String.class);
    oparser.accepts("dbName", "Name of database to connect to").withRequiredArg().ofType(String.class);
    oparser.accepts("dbInstance", "Named instance of SQL server to connect to").withRequiredArg().ofType(String.class);
    oparser.accepts("dbUser", "Username for database connection").withRequiredArg().ofType(String.class);
    oparser.accepts("dbPass", "Prompt for user password");
    final OptionSpec<File> dbConfig = oparser.accepts("dbConfig", "database configuration file").withRequiredArg().ofType(File.class);

    oparser.accepts("r2rml", "R2RML mapping file").withRequiredArg().ofType(String.class);
    oparser.accepts("dm", "RDB2RDF direct mapping. Base URI as argument").withRequiredArg().ofType(String.class);

    final OptionSpec<File> tdbDirOption = oparser
        .accepts("tdbdir", "TDB directory").withRequiredArg()
        .ofType(File.class);
//    final OptionSpec<String> xqueryEval = oparser
//        .accepts(
//            "e",
//            "Evaluate result query with the specified XQuery engine to use (saxon-he | saxon-ee | qexo). Default: evaluate with Saxon-HE.")
//        .withRequiredArg().ofType(String.class);

    final OptionSet options = oparser.parse(args);

    // parameters which lead to early exit

    if (options.has("h")) {
      System.out.println(getClass().getPackage().getImplementationTitle()
	          + " version " + getClass().getPackage().getImplementationVersion());
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

//    if (options.has("noval") && options.has("val")) {
//      System.err.println("Use either \"val\" or \"noval\". Using default.");
//    } else if (options.has("noval") || options.has("val")) {
//      proc.setValidating(options.has("val"));
//    } else {
//      // use default
//    }

    // simple commandline switches
    proc.setVerbose(options.has("v"));
    proc.setDot(options.has("dot"));
    proc.setDebug(options.has("p"));
    proc.setDebugLexer(options.has("l"));
    proc.setAst(options.has("a"));
    this.evaluate = !options.has("rewrite-only");
    proc.setDebugVersion(options.has("d"));

    // Disabled this option, if somebody wants to use this we can re-enable it
//    if (options.has("arq") && options.has("joseki")) {
//      System.err.println("Use either \"arq\" or \"joseki\". Using default.");
//    } else if (options.has("joseki")) {
//      proc.setSPARQLEngine(SPARQLEngine.JOSEKI);
//    } else {
//      // use default
//    }

    // XQuery engine specification

//    if ("saxon-ee".equals(options.valueOf(xqueryEval))) {
//      xe.setXQueryEngine(XQueryEngine.SAXONEE);
//    } else if ("qexo".equals(options.valueOf(xqueryEval))) {
//      xe.setXQueryEngine(XQueryEngine.QEXO);
//    } else {
//      // use default
//    }

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

    
//    if (options.has("mysql") && options.has("psql")) {
//	System.err.println("Use either \"mysql\" or \"psql\".");
//	System.exit(1);
//    } else 
    if (options.has("psql")) {
	proc.setDBDriver("psql");
        createDBconnection = true;
    } else if (options.has("mysql")) {
	proc.setDBDriver("mysql");
        createDBconnection = true;
    } else if (options.has("sqlserver")) {
	proc.setDBDriver("sqlserver");
        createDBconnection = true;
    }
    

    // DB configuration
    if (options.has("dbName")) {
      proc.setDBName(options.valueOf("dbName").toString());
      createDBconnection = true;
    }

    if (options.has("dbServer")) {
	proc.setDBServer(options.valueOf("dbServer").toString());
	createDBconnection = true;
    }

    if (options.has("dbPort")) {
	proc.setDBPort(options.valueOf("dbPort").toString());
	createDBconnection = true;
    }

    if (options.has("dbInstance")) {
	proc.setDBInstance(options.valueOf("dbInstance").toString());
	createDBconnection = true;
    }

    if (options.has("dbUser")) {
      proc.setDBUser(options.valueOf("dbUser").toString());
      createDBconnection = true;
    }

    if (options.has("dbPass")) {
	Console cons;
	char[] passwd;
	if ((cons = System.console()) != null &&
		(passwd = cons.readPassword("%s ", "Password:")) != null) {
	    proc.setDBPasswd(new String(passwd));
	    java.util.Arrays.fill(passwd, ' ');
	}
        createDBconnection = true;
    }

    // DB configuration file
    if (options.has(dbConfig)) {
      proc.setDBConfig(options.valueOf(dbConfig));
      createDBconnection = true;
    }
   
    // R2RML mapping file
    if (options.has("r2rml")) {
	// TODO: this should be a restricted variable name
	xe.addXQueryExternalVar("r2rml_mapping", "file:"+options.valueOf("r2rml").toString());
	r2rml = true;
    }
    
    // R2RML mapping file
    if (options.has("dm")) {
	xe.addXQueryExternalVar("baseURI", options.valueOf("dm").toString());
	dm = true;
    }
    
    // if you don't use a local sparql endpoint (otherwise you wouldn't use
    // the -u) and you want to evaluate the
    // query right after the translation then under the additional condition
    // that the query contains a nested
    // construct the evaluation wont work -> check for a nested construct
    // during translation
    // TODO move this to the XSPARQLProcessor


    // create a DB connection if required!
    if (createDBconnection) {
      proc.createDBconnection();
    }


  }

  /**
   * closes the XSPARQLProcessor DB connection
   */
  private void closeDBconnection() {
    proc.closeDBconnection();
  }

  /**
   * is debug version?
   */
  private boolean isDebug() {
    return proc.isDebug();
  }


}
