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
package org.deri.xsparql.rewriter;

import java.io.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.antlr.stringtemplate.language.DefaultTemplateLexer;

/**
 * Main XSPARQL translator class
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
  private String queryFilename;

  /**
   * Continuously incremented index for appending to Graphviz dot files and
   * generated images
   */
  private int tempFileCounter = 0;
  
  public XSPARQLProcessor() {
    this.setVerbose(false);
    this.setSPARQLEngine(SPARQLEngine.ARQ);
  }

  /**
   * @param name
   */
  public void setQueryFilename(String name) {
    this.queryFilename = name;

  }

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
    StopWatch sw = new StopWatch();

    sw.start();
    CommonTokenStream tokenStream = createTokenStream(is);
    sw.stop();
    logger.info("Time needed for Lexer: " + sw.getDuration() + "ms");

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Lexer. Translation aborted.");
    }

    sw.start();
    CommonTree tree = parse(tokenStream);
    sw.stop();
    logger.info("Time needed for Parser: " + sw.getDuration() + "ms");

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Parser. Translation aborted.");
    }

    printAST(tree);

    sw.start();
    tree = rewrite(tokenStream, tree);
    sw.stop();
    logger.info("Time needed for Rewriter: " + sw.getDuration() + "ms");

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Rewriter. Translation aborted.");
    }

    printAST(tree);

    sw.start();
    tree = simplify(tokenStream, tree);
    sw.stop();
    logger.info("Time needed for Simplifier: " + sw.getDuration() + "ms");

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Simplifier. Translation aborted.");
    }

    printAST(tree);

    sw.start();
    String xquery = serialize(tokenStream, tree);
    sw.stop();
    logger.info("Time needed for Serializer: " + sw.getDuration() + "ms");

    if (this.numSyntaxErrors > 0) {
      throw new Exception("Errors for Serializer. Translation aborted.");
    }

    return xquery;
  }

  /**
   * Process XSPARQL query given as an InputStream
   * 
   * @param is
   *          XSPARQL query
   * @return string with rewriten XQuery
   * @throws RecognitionException
   * @throws IOException
   * @deprecated
   */
  public String process(final InputStream is) throws RecognitionException,
      IOException, Exception {
    return process(new InputStreamReader(is));
  }

  // Private utility methods

  /**
   * Print the AST for debugging if the corresponding switches are set TODO:
   * Move to helper
   * 
   * @param tree
   */
  private void printAST(CommonTree tree) {
    if (Configuration.printDot()) {
      Helper.writeDotFile(
          tree,
          this.queryFilename.concat(".").concat(
              Integer.toString(tempFileCounter)));
      tempFileCounter++;
    }
    if (Configuration.printAst()) {
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

    final RuleReturnScope r = parser.mainModule();
    final CommonTree tree = (CommonTree) r.getTree();

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
  CommonTree rewrite(final CommonTokenStream tokenStream,
      final CommonTree tree) throws RecognitionException {
    logger.info("Start Rewriter");
    final CommonTreeNodeStream nodes = new CommonTreeNodeStream(tree);
    nodes.setTokenStream(tokenStream);
    final XSPARQLRewriter xqr = new XSPARQLRewriter(nodes);

    xqr.setEvaluationMethod();
    xqr.setLibraryVersion();

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
  CommonTree simplify(final CommonTokenStream tokenStream,
      final CommonTree tree) throws RecognitionException {
    logger.info("Start Simplifier");
    final CommonTreeNodeStream nodes = new CommonTreeNodeStream(tree);
    nodes.setTokenStream(tokenStream);
    final XSPARQLSimplifier xqr = new XSPARQLSimplifier(nodes);
    xqr.setEngine();

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
  String serialize(final CommonTokenStream tokenStream,
      final CommonTree tree) throws Exception {
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
    Configuration.warnIfNestedConstruct = b;
  }

  public void setAst(boolean has) {
    Configuration.ast = has;
  }

  public void setDebugLexer(boolean has) {
    Configuration.debuglexer = has;
  }

  public void setDebug(boolean has) {
    Configuration.debug = has;
  }

  public void setDot(boolean has) {
    Configuration.dot = has;
  }

  public void setVerbose(boolean has) {
    if(has) {
      logger.setLevel(Level.ALL);
    } else {
      logger.setLevel(Level.WARNING);
    }
  }

  public void setEndpointURI(String string) {
    Configuration.endpointURI = string;
    this.setWarnIfNestedConstruct(true);
  }

  // TODO: devise a proper debug methodology
  public void setDebugVersion(boolean has) {
    Configuration.debugVersion = has;
    // if(has) {
    //   Configuration.xsparqlLibURL = "http://xsparql.deri.org/demo/xquery/xsparql-types.debug.xquery";
    // }
  }

  public void setSPARQLEngine(SPARQLEngine se) {
    switch(se) {
    case JOSEKI:
      Configuration.SPARQLmethod = "joseki";
      break;
    case ARQ:
    default:
      Configuration.SPARQLmethod = "arq";
      break;
    }
  }

  public void setValidating(boolean b) {
    Configuration.validatingXQuery = b;
    // if(b) {
    //   Configuration.xsparqlLibURL = "http://xsparql.deri.org/demo/xquery/xsparql-types.xquery";
    // }
  }
}
