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

package org.sourceforge.xsparql.evaluator.xsparql11;

import static org.junit.Assert.*;
import static org.junit.Assume.*;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.antlr.runtime.RecognitionException;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.openrdf.query.BindingSet;
import org.openrdf.query.MalformedQueryException;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.QueryLanguage;
import org.openrdf.query.QueryResultHandlerException;
import org.openrdf.query.TupleQueryResultHandler;
import org.openrdf.query.TupleQueryResultHandlerException;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.rio.RDFFormat;
import org.openrdf.rio.RDFParseException;
import org.openrdf.sail.memory.MemoryStore;
import org.sourceforge.xsparql.evaluator.single.EvaluationTest;
import org.sourceforge.xsparql.rewriter.XSPARQLProcessor;
import org.sourceforge.xsparql.test.Utils;

@RunWith(value = Parameterized.class)
public class XSPARQLEvaluatorDawg11Tests extends EvaluationTest {
	protected String testname;
	protected static String testLocation = "xsparql/testcases-dawg-sparql-1.1/";

	public XSPARQLEvaluatorDawg11Tests(String query, String solution, String test){
		logger.debug("Processing {} \t {} \t {}", new Object[]{query, solution, test});
		this.queryFile=query;
		this.solutionFile = solution;
		this.testname = test;
	}
	
	@Parameters(name = "{index}: {2}")
	public static Collection<Object[]> data() {
		Repository repo = new SailRepository(new MemoryStore());
		try {
			repo.initialize();
			List<Object[]> data = new ArrayList<Object[]>();
			final List<Object> test = new ArrayList<Object>();
			File manifest = null;
			for (String filename : Utils.listFiles(XSPARQLEvaluatorDawg11Tests.class.getClassLoader().getResource(testLocation).getFile(), ".xsparql", true)) {
				final File f = new File(filename);
				if(manifest==null || !manifest.getParent().equals(f.getParent())) {
					repo.getConnection().clear();
					manifest = new File(f.getParent()+File.separator+"manifest.ttl");
					repo.getConnection().add(manifest, "http://xsparql.deri.org/tests", RDFFormat.TURTLE);
				}
				repo.getConnection().prepareTupleQuery(QueryLanguage.SPARQL, 
						"prefix mf: <http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#> " +
						"prefix qt: <http://www.w3.org/2001/sw/DataAccess/tests/test-query#> " +
						"SELECT ?test ?solution " +
						"WHERE{ " +
						"?test mf:action [qt:query <http://xsparql.deri.org/"+f.getName()+">] " +
						"OPTIONAL { ?test mf:result ?solution  } " +
						"}").evaluate(new TupleQueryResultHandler() {
							@Override public void handleSolution(BindingSet arg0) throws TupleQueryResultHandlerException {
								String solution = arg0.getBinding("solution").getValue().stringValue();
								test.add(f.getAbsolutePath());
								test.add(f.getParent()+File.separator+solution.substring(solution.lastIndexOf(File.separator)+1));
								test.add(arg0.getBinding("test").getValue().stringValue());
							}
							@Override public void startQueryResult(List<String> arg0) throws TupleQueryResultHandlerException {}
							@Override public void handleLinks(List<String> arg0) throws QueryResultHandlerException {}
							@Override public void handleBoolean(boolean arg0) throws QueryResultHandlerException {}
							@Override public void endQueryResult() throws TupleQueryResultHandlerException {}
						});
				if(test.size()==3)
					data.add(test.toArray());
				else{
					logger.error("the query {} is not in the manifest!", filename);
				}
				logger.debug("Adding {} \t {}", test, test.toArray().length);
				test.clear();
			}
			return data;
		} catch (RepositoryException e) {
			fail();
			throw new RuntimeException(e);
		} catch (RDFParseException e) {
			fail();
			throw new RuntimeException(e);
		} catch (IOException e) {
			fail();
			throw new RuntimeException(e);
		} catch (MalformedQueryException e) {
			fail();
			throw new RuntimeException(e);
		} catch (TupleQueryResultHandlerException e) {
			fail();
			throw new RuntimeException(e);
		} catch (QueryEvaluationException e) {
			fail();
			throw new RuntimeException(e);
		}
	}

	@Ignore @Override @Test public void shouldEvaluateQueryWithGroundTruth() {
		assumeTrue(solutionFile!=null);
		super.shouldEvaluateQueryWithGroundTruth();
	}

	@Override @Test public void shouldEvaluateQueryWithoutGroundTruth() {
		assumeTrue(solutionFile!=null);
		super.shouldEvaluateQueryWithoutGroundTruth();
	}
	
	//evaluate only the query that can be processed by the query processor
	@Before public void compliantQuery(){
		XSPARQLProcessor proc = new XSPARQLProcessor();
		try {
			proc.process(new FileReader(queryFile));
			assumeTrue(proc.getNumberOfSyntaxErrors()==0);
		} catch (FileNotFoundException e) {
			logger.error("the query can not be loaded");
			assumeNoException(e);
		} catch (RecognitionException e) {
			logger.error("the query can not be processed");
			assumeNoException(e);
		} catch (IOException e) {
			logger.error("the query can not be loaded");
			assumeNoException(e);
		} catch (Exception e) {
			logger.error("the query can not be processed");
			assumeNoException(e);
		}
	}


}
