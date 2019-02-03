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

import static org.junit.Assume.*;

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
import org.sourceforge.xsparql.evaluator.single.EvaluationTest;
import org.sourceforge.xsparql.rewriter.XSPARQLProcessor;
import org.sourceforge.xsparql.test.Utils;

@RunWith(value = Parameterized.class)
public class XSPARQLEvaluatorBase11Tests extends EvaluationTest {
	protected String testname;
	protected static String testLocation = "xsparql/base-1.1/";

	public XSPARQLEvaluatorBase11Tests(String query){
		logger.debug("Processing {}", new Object[]{query});
		this.queryFile=query;
	}
	
	@Parameters(name = "{index}: {0}")
	public static Collection<Object[]> data() {
		List<Object[]> data = new ArrayList<Object[]>();
		final List<Object> test = new ArrayList<Object>();
		for (String filename : Utils.listFiles(XSPARQLEvaluatorBase11Tests.class.getClassLoader().getResource(testLocation).getFile(), ".xsparql", true)) {
			test.add(filename);
			data.add(test.toArray());
			}
			return data;
	}

	@Override @Test public void shouldEvaluateQueryWithoutGroundTruth() throws Exception {
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
