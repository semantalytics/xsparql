/**
 *
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
 * Created on 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
 * on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
 * University of Technology,  Nuno Lopes on behalf of NUI Galway.
 *
 */ 
package org.sourceforge.xsparql.rewriter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.junit.Assume.*;

import java.io.BufferedReader;
import java.util.logging.LogManager;

import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.CommonTree;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.bridge.SLF4JBridgeHandler;
import org.sourceforge.xsparql.rewriter.Helper;
import org.sourceforge.xsparql.rewriter.XSPARQLLexer;
import org.sourceforge.xsparql.rewriter.XSPARQLProcessor;
import org.sourceforge.xsparql.test.Utils;

public class XSPARQLProcessorTests {
	private static final Logger logger  = LoggerFactory.getLogger(XSPARQLProcessorTests.class);
	protected XSPARQLProcessor processor;
//	protected String filename = "src/main/resources/xsparql/testcases-dawg-sparql-1.1/aggregates/agg01.xsparql";
	protected String filename = "src/main/resources/xsparql/axel.xsparql";
//	protected String filename = "src/main/resources/xsparql/testcases-dawg-sparql-1.1/entailment/plainLit.xsparql";

	public XSPARQLProcessorTests() {
		super();
		processor = new XSPARQLProcessor();
		processor.setAst(true);
	}
	
//	@BeforeClass
	public static void initLogger(){
		LogManager.getLogManager().reset();
		SLF4JBridgeHandler.install();
//		java.util.logging.Logger.getLogger("global").setLevel(Level.FINEST);
//		java.util.logging.LogManager.getLogManager().getLogger("").setLevel( Level.FINEST);
	}
	
	@Test
	public void shouldParseQuery() {
		try{
		    logger.debug("Parsing {}", filename);
			BufferedReader is = Utils.loadReaderFromClasspath(filename);
		    final XSPARQLLexer lexer = new XSPARQLLexer(is);
		    lexer.setDebug(true);
	
		    final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
	
//		    System.out.println(tokenStream);
		    logger.debug("Start Parser for {}", filename);
		    processor.setDebug(true);
		    CommonTree tree = processor.parse(tokenStream);
		    assertEquals(0, processor.getNumberOfSyntaxErrors());
		    Helper.printTree(tree);
		} catch (RecognitionException e) {
			logger.error("Error while parsing the query "+filename, e);
			fail();
		}
	}

	@Test
	public void shouldRewriteQuery() {
		try{
			BufferedReader is = Utils.loadReaderFromClasspath(filename);
			
		    final XSPARQLLexer lexer = new XSPARQLLexer(is);
		    final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
	
		    CommonTree tree = processor.parse(tokenStream);
		    assumeTrue(processor.getNumberOfSyntaxErrors()==0);
		    Helper.printTree(tree);
		    
		    logger.debug("Start Rewriter for {}", filename);
		    processor.setDebugVersion(true);
		    processor.setVerbose(true);
			tree=processor.rewrite(tokenStream, tree);
		    Helper.printTree(tree);
	
		    assertEquals(0, processor.getNumberOfSyntaxErrors());
		} catch (RecognitionException e) {
			logger.error("Error while parsing the query "+filename, e);
			fail();
		}
	}

	@Test
	public void shouldSimplifyQuery() {
		try{
			BufferedReader is = Utils.loadReaderFromClasspath(filename);
			
		    final XSPARQLLexer lexer = new XSPARQLLexer(is);
		    final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
	
		    CommonTree tree = processor.parse(tokenStream);
		    Helper.printTree(tree);
		    assumeTrue(processor.getNumberOfSyntaxErrors()==0);
		    
			tree = processor.rewrite(tokenStream, tree);
		    Helper.printTree(tree);
			assumeTrue(processor.getNumberOfSyntaxErrors()==0);
	
		    logger.debug("Start Simplifier for {}", filename);
		    processor.setDebug(true);
		    processor.setVerbose(true);
			tree = processor.simplify(tokenStream, tree);
		    assertEquals(0, processor.getNumberOfSyntaxErrors());
		    Helper.printTree(tree);
		} catch (RecognitionException e) {
			logger.error("Error while parsing the query "+filename, e);
			fail();
		}
	}

	@Test
	public void shouldSerialiseQuery() {
		try{
			BufferedReader is = Utils.loadReaderFromClasspath(filename);
			
		    final XSPARQLLexer lexer = new XSPARQLLexer(is);
		    final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
	
		    CommonTree tree = processor.parse(tokenStream);
		    assumeTrue(processor.getNumberOfSyntaxErrors()==0);
		    Helper.printTree(tree);
		    
			tree = processor.rewrite(tokenStream, tree);
			assumeTrue(processor.getNumberOfSyntaxErrors()==0);
		    Helper.printTree(tree);
	
		    logger.debug("Start Simplifier for {}", filename);
			tree = processor.simplify(tokenStream, tree);
			assumeTrue(processor.getNumberOfSyntaxErrors()==0);
		    Helper.printTree(tree);

			processor.setVerbose(true);
			String query = processor.serialize(tokenStream, tree);
			System.out.println(query);
		    assertEquals(0, processor.getNumberOfSyntaxErrors());
		} catch (RecognitionException e) {
			logger.error("Error while parsing the query "+filename, e);
			fail();
		} catch (Exception e) {
			logger.error("Error while serialising the query "+filename, e);
			fail();
		}
	}

	public void shouldNotParseQuery() {
		try{
			BufferedReader is = Utils.loadReaderFromClasspath(filename);
		    logger.debug("Start Lexer for {}", filename);
		    final XSPARQLLexer lexer = new XSPARQLLexer(is);
	
		    final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
	
		    logger.debug("Start Parser for {}", filename);
		    processor.parse(tokenStream);
		    assertTrue(processor.getNumberOfSyntaxErrors()>0);
		} catch (RecognitionException e) {
			logger.error("Error while parsing the query "+filename, e);
			fail();
		}
	}
}