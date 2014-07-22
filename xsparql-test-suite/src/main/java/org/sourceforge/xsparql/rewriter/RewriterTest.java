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

import static org.junit.Assert.fail;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.Reader;
import java.util.logging.Logger;

import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.RuleReturnScope;
import org.antlr.runtime.tree.CommonTree;
import org.junit.Ignore;
import org.junit.Test;
import org.sourceforge.xsparql.rewriter.Helper;
import org.sourceforge.xsparql.rewriter.XSPARQL;
import org.sourceforge.xsparql.rewriter.XSPARQLLexer;
import org.sourceforge.xsparql.rewriter.XSPARQLProcessor;
import org.sourceforge.xsparql.test.Utils;

public class RewriterTest {
	private final static Logger logger = Logger.getLogger(RewriterTest.class.toString());

	@Ignore  @Test
	public void testShouldProcessQuery() {
		XSPARQLProcessor processor;
		try {
			System.out.println("Testing important_cities.xsparql...");
//			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/distribution_simple.xsparql");
			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/important-cities.xsparql");
			processor = new XSPARQLProcessor();
			processor.setAst(true);
			processor.process(queryReader);

		} catch (RecognitionException e) {
			fail("Exception: " + e.getMessage());
		} catch (Exception e) {
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			PrintStream ps = new PrintStream(os);
			e.printStackTrace(ps);
			fail("Exception: " + os.toString());
		}
	}


	@Test
	public void testXSparqlParser() {
		try {
			System.out.println("Testing important_cities.xsparql...");
			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/distribution_simple.xsparql");
			//			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/important-cities.xsparql");
			CommonTokenStream tokenStream = createTokenStream(queryReader);

			//the tokens are used to build the AST tree
			CommonTree tree = parseXSparql(tokenStream);
			Helper.printTree(tree);

		} catch (RecognitionException e) {
			fail("Exception: " + e.getMessage());
		} catch (Exception e) {
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			PrintStream ps = new PrintStream(os);
			e.printStackTrace(ps);
			fail("Exception: " + os.toString());
		}
	}

	@Test
	public void testXSparqlRewriter() {
		try {
			System.out.println("Testing important_cities.xsparql...");
			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/distribution_simple.xsparql");
			//			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/important-cities.xsparql");
			CommonTokenStream tokenStream = createTokenStream(queryReader);

			//the tokens are used to build the AST tree
			CommonTree tree = parseXSparql(tokenStream);
			Helper.printTree(tree);


		} catch (RecognitionException e) {
			fail("Exception: " + e.getMessage());
		} catch (Exception e) {
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			PrintStream ps = new PrintStream(os);
			e.printStackTrace(ps);
			fail("Exception: " + os.toString());
		}
	}

	@Ignore @Test
	public void testSparqlParser() {
		try {
			System.out.println("Testing important_cities.xsparql...");
			//			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "examples/distribution_simple.xsparql");
			Reader queryReader = Utils.loadReaderFromClasspath(getClass(), "prova.sparql");
			CommonTokenStream tokenStream = createTokenStream(queryReader);

			//the tokens are used to build the AST tree
			CommonTree tree = parseSparql(tokenStream);
			Helper.printTree(tree);

		} catch (RecognitionException e) {
			fail("Exception: " + e.getMessage());
		} catch (Exception e) {
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			PrintStream ps = new PrintStream(os);
			e.printStackTrace(ps);
			fail("Exception: " + os.toString());
		}
	}

	private CommonTree parseSparql(final CommonTokenStream tokenStream)
			throws RecognitionException {
		logger.info("Start Parser");
		XSPARQL parser = new XSPARQL(tokenStream);
		parser.setDebug(true);

		final RuleReturnScope r = parser.forletClause();
		final CommonTree tree = (CommonTree) r.getTree();

		logger.info("There are " + parser.getNumberOfSyntaxErrors() + " parser errors");

		logger.info("End Parser");
		return tree;
	}

	private CommonTree parseXSparql(final CommonTokenStream tokenStream)
			throws RecognitionException {
		logger.info("Start Parser");
		XSPARQL parser = new XSPARQL(tokenStream);
		parser.setDebug(true);

		final RuleReturnScope r = parser.mainModule();
		final CommonTree tree = (CommonTree) r.getTree();

		logger.info("There are " + parser.getNumberOfSyntaxErrors() + " parser errors");

		logger.info("End Parser");
		return tree;
	}

	private CommonTokenStream createTokenStream(final Reader is) {
		logger.info("Start Lexer");
		final XSPARQLLexer lexer = new XSPARQLLexer(is);

		final CommonTokenStream tokenStream = new CommonTokenStream(lexer);

		logger.info("End Lexer");
		return tokenStream;
	}
}
