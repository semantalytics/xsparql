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
package org.deri.xsparql.rewriter;

import java.io.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Properties;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.antlr.stringtemplate.language.DefaultTemplateLexer;

import org.deri.sql.SQLQuery;

/**
 * Main XSPARQL rewriter translator class
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 * @author Nuno Lopes <nuno.lopes@deri.org>
 * 
 */
public class XSPARQLProcessor {

  private final static Logger logger = Logger.getLogger(XSPARQLProcessor.class
      .getClass().getName());

  /**
   * Path of the XQuery StringTemplate Template in the Classpath
   */
  private final static String XQUERYTEMPLATE = "/templates/XQuery.stg";

  /**
   * Number of occurred syntax errors
   */
  private int numSyntaxErrors = 0;

  /**
   * Name of the original XSPARQL query file
   */
  private String queryFilename = "";

  /**
   * Continuously incremented index for appending to Graphviz dot files and
   * generated images
   */
  private int tempFileCounter = 0;

  /**
   * use validating XQuery engine
   */
  private boolean validatingXQuery = false;

  /**
   * method to be used to perform SPARQL queries. By default requires a Joseki
   * endpoint
   */
  private String SPARQLmethod = "arq";

  /**
   * Create a debug version of the query
   */
  private boolean debugVersion;

  /**
   * SPARQL endpoint uri
   */
  private String endpointURI;

  /**
   * Print AST?
   */
  private boolean ast = false;

  /**
   * True if AST pictures should be generated
   */
  private boolean dot = false;

  /**
   * Parse in debug mode
   */
  private boolean debug = false;

  /**
   * Lexer in debug mode
   */
  private boolean debuglexer = false;

  private boolean warnIfNestedConstruct;

  /* -------------------------------------------- RDB */

  private SQLQuery sqlQuery = null;
  
  /**
   * Specify the type of database to connect to
   */
  private static String dbDriver = null;
  
  /**
   * Specify the name of database to connect to
   */
  private static String dbName = null;
  
  /**
   * Specify the instance name (MS SQL Server) to connect to
   */
  private static String dbInstance = null;
  
  /**
   * Specify the name of the user to connect
   */
  private static String dbUser = null;

  /**
   * Password for user connection to the database.
   */
  private static String dbPasswd = null;





  /**
   * XQuery engine to be used for evaluation/code production.
   */
  private String xqueryEngine = "saxon-he";

  private String outputMethod;

  public XSPARQLProcessor() {
    this.setVerbose(false);
    this.setSPARQLEngine(SPARQLEngine.ARQ);
  }

  /**
   * @param xqueryEngine
   */
  public void setXQueryEngine(String xqueryEngine) {
    this.xqueryEngine = xqueryEngine;
  }

  /**
   * @param name
   */
  public void setQueryFilename(String name) {
    this.queryFilename = name;

  }

  /**
   * @return
   */
  public int getNumberOfSyntaxErrors() {
    return this.numSyntaxErrors;
  }

  // Public processing methods

  /**
   * Process XSPARQL query given as an InputStream
   * 
   * @param is
   *          XSPARQL query
   * @return string with rewriten XQuery
   * @throws RecognitionException
   * @throws IOException
   */
  public String process(final Reader is) throws RecognitionException,
      IOException, Exception {
    CommonTokenStream tokenStream = createTokenStream(is);

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Lexer. Translation aborted.");
    }

    CommonTree tree = parse(tokenStream);

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Parser. Translation aborted.");
    }

    printAST(tree);

    tree = rewrite(tokenStream, tree);

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Rewriter. Translation aborted.");
    }

    printAST(tree);

    tree = simplify(tokenStream, tree);

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Simplifier. Translation aborted.");
    }

    printAST(tree);

    String xquery = serialize(tokenStream, tree);

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Serializer. Translation aborted.");
    }

    return xquery;
  }

  // Private utility methods

  /**
   * Print the AST for debugging if the corresponding switches are set TODO:
   * Move to helper
   * 
   * @param tree
   */
  private void printAST(CommonTree tree) {
    if (this.dot) {
      Helper.writeDotFile(
          tree,
          this.queryFilename.concat(".").concat(
              Integer.toString(tempFileCounter)));
      tempFileCounter++;
    }
    if (this.ast) {
      Helper.printTree(tree);
    }
  }

  /**
   * Lexer creates a token stream
   * 
   * @param is
   * @return
   */
  CommonTokenStream createTokenStream(final Reader is) {
    logger.info("Start Lexer");
    final XSPARQLLexer lexer = new XSPARQLLexer(is);
    lexer.setDebug(this.debuglexer);

    final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
    logger.info("End Lexer");
    return tokenStream;
  }

  /**
   * Parser creates an Abstract Syntax Tree (AST) out of the Lexer token stream
   * 
   * @param tokenStream
   * @return
   * @throws RecognitionException
   */
  CommonTree parse(final CommonTokenStream tokenStream)
      throws RecognitionException {
    logger.info("Start Parser");
    XSPARQL parser = new XSPARQL(tokenStream);
    parser.setDebug(this.debug);

    final RuleReturnScope r = parser.mainModule();
    final CommonTree tree = (CommonTree) r.getTree();

    this.outputMethod = parser.getOutputMethod();

    this.numSyntaxErrors += parser.getNumberOfSyntaxErrors();

    logger.info("End Parser");
    return tree;
  }

  /**
   * Rewriter translates XSPARQL AST to a XQuery AST
   * 
   * @param tokenStream
   * @param tree
   *          XSPARQL AST
   * @return XQuery AST
   * @throws RecognitionException
   */
  CommonTree rewrite(final CommonTokenStream tokenStream, final CommonTree tree)
      throws RecognitionException {
    logger.info("Start Rewriter");
    final CommonTreeNodeStream nodes = new CommonTreeNodeStream(tree);
    nodes.setTokenStream(tokenStream);
    final XSPARQLRewriter xqr = new XSPARQLRewriter(nodes);
    xqr.setValidatingXQuery(this.validatingXQuery);
    xqr.setXQueryEngine(this.xqueryEngine);
    xqr.setSPARQLMethod(this.SPARQLmethod);
    xqr.setWarnIfNestedConstruct(this.warnIfNestedConstruct);
    xqr.setEndpointURI(this.endpointURI);
    xqr.setDebugVersion(this.debugVersion);
    xqr.setEvaluationMethod();
    xqr.setLibraryVersion();
    xqr.setDBconnection(sqlQuery);

    // final CommonTree ret = (CommonTree) xqr.downup(tree);
    final CommonTree ret = (CommonTree) xqr.root().getTree();

    this.numSyntaxErrors += xqr.getNumberOfSyntaxErrors();
    logger.info("End Rewriter");
    return ret;
  }

  /**
   * @param tokenStream
   * @param tree
   * @return
   * @throws RecognitionException
   */
  CommonTree simplify(final CommonTokenStream tokenStream, final CommonTree tree)
      throws RecognitionException {
    logger.info("Start Simplifier");
    final CommonTreeNodeStream nodes = new CommonTreeNodeStream(tree);
    nodes.setTokenStream(tokenStream);
    final XSPARQLSimplifier xqr = new XSPARQLSimplifier(nodes);
    xqr.setEngine(this.xqueryEngine, this.SPARQLmethod);

    final CommonTree ret = (CommonTree) xqr.downup(tree);
    this.numSyntaxErrors += xqr.getNumberOfSyntaxErrors();
    logger.info("End Simplifier");
    return ret;
  }

  /**
   * Create a XQuery query based on a XQuery AST
   * 
   * @param tokenStream
   * @param tree
   *          XQuery AST
   * @return XQuery Query as String
   * @throws Exception
   * @throws IOException
   */
  String serialize(final CommonTokenStream tokenStream, final CommonTree tree)
      throws Exception {
    logger.info("Start Serializer");

    InputStream template = XSPARQLProcessor.class
        .getResourceAsStream(XQUERYTEMPLATE);
    if (template == null) {
      throw new Exception(
          "Could not find/load simplifier template classpath at "
              + XQUERYTEMPLATE);
    }
    final BufferedReader templatesIn = new BufferedReader(
        new InputStreamReader(template));
    final StringTemplateGroup templates = new StringTemplateGroup(templatesIn,
        DefaultTemplateLexer.class);

    final CommonTreeNodeStream nodes = new CommonTreeNodeStream(tree);
    nodes.setTokenStream(tokenStream);
    final XQuerySerializer xqs = new XQuerySerializer(nodes);

    xqs.setTemplateLib(templates);

    final String ret = xqs.root().toString()
        + System.getProperty("line.separator");

    this.numSyntaxErrors += xqs.getNumberOfSyntaxErrors();

    logger.info("End Serializer");
    return ret;
  }

  public void setWarnIfNestedConstruct(boolean b) {
    this.warnIfNestedConstruct = b;
  }

  public void setAst(boolean has) {
    this.ast = has;
  }

  public void setDebugLexer(boolean has) {
    this.debuglexer = has;
  }

  public void setDebug(boolean has) {
    this.debug = has;
  }

  public void setDot(boolean has) {
    this.dot = has;
  }

  public void setVerbose(boolean has) {
    if (has) {
      logger.setLevel(Level.ALL);
    } else {
      logger.setLevel(Level.WARNING);
    }
  }

  public void setEndpointURI(String string) {
    this.endpointURI = string;
    this.setWarnIfNestedConstruct(true);
  }

  // TODO: devise a proper debug methodology
  public void setDebugVersion(boolean has) {
    this.debugVersion = has;
    // if(has) {
    // Configuration.xsparqlLibURL =
    // "http://xsparql.deri.org/demo/xquery/xsparql-types.debug.xquery";
    // }
  }

  public void setSPARQLEngine(SPARQLEngine se) {
    switch (se) {
    case JOSEKI:
      this.SPARQLmethod = "joseki";
      break;
    case ARQ:
    default:
      this.SPARQLmethod = "arq";
      break;
    }
  }

  public void setValidating(boolean b) {
    this.validatingXQuery = b;
    // if(b) {
    // Configuration.xsparqlLibURL =
    // "http://xsparql.deri.org/demo/xquery/xsparql-types.xquery";
    // }
  }

  public String getOutputMethod() {
    return this.outputMethod;
  }


  public boolean isDebug() {
    return this.debug || this.debuglexer;
  }


  /* -------------------------------------------- RDB */
  /**
   * @return current DB driver
   */
  public String getDBDriver() {

    return dbDriver;
  }
  
  /**
   * @return current DB name
   */
  public String getDBName() {

    return dbName;
  }
  
  /**
   * @return current DB user
   */
  public String getDBUser() {

    return dbUser;
  }
  
  /**
   * @return current DB password
   */
  public String getDBPasswd() {

    return dbPasswd;
  }
  
    
  /**
   * set the DB name
   */
  public void setDBDriver(String driver) {
    dbDriver = driver;
  }

  /**
   * set the DB name
   */
  public void setDBName(String name) {
    dbName = name;
  }
  
  /**
   * set the DB instance name
   */
  public void setDBInstance(String instance) {
      dbInstance = instance;
  }

  /**
   * set the DB user
   */
  public void setDBUser(String user) {
    dbUser = user;
  }
  
  /**
   * set the DB password
   */
  public void setDBPasswd(String passwd) {
    dbPasswd = passwd;
  }

  /**
   * set the DB info from configuration file
   */
  public void setDBConfig(File file) {
      Properties configFile = new Properties();
      try {
	  configFile.load(new FileReader(file));
      } catch (Exception e) {
	  System.err.println(e.getMessage());
	  System.exit(1);
      }
      
      String driver = configFile.getProperty("dbDriver");
      if (driver != null) {
	  setDBDriver(driver);
      }
      
      String name = configFile.getProperty("dbName");
      if (name != null) {
	  setDBName(name);
      }
      
      String instance = configFile.getProperty("dbInstance");
      if (instance != null) {
	  setDBInstance(instance);
      }

      String user = configFile.getProperty("dbUser"); 
      if (user != null) {
	  setDBUser(user);
      }
      
      String passwd = configFile.getProperty("dbPasswd"); 
      if (passwd != null) {
	  setDBPasswd(passwd);
      }
  }

  /**
   * instanciates the DB connection
   */
  public void createDBconnection() {
    sqlQuery = new SQLQuery(dbDriver, dbName, dbInstance, dbUser, dbPasswd);
  }
  
  /**
   * retrieves the DB connection
   */
  public SQLQuery getDBconnection() {
    return sqlQuery;
  }

  /**
   * close the DB connection
   */
  public void closeDBconnection() {
    if (sqlQuery != null) 
      sqlQuery.close();
  }

}
