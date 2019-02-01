/**
 *
 * Copyright (C) 2011, NUI Galway.
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
 * Created on 09 February 2011 by Reasoning and Querying Unit (URQ), 
 * Digital Enterprise Research Institute (DERI) on behalf of NUI Galway.
 * 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
 * on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
 * University of Technology,  Nuno Lopes on behalf of NUI Galway.
 *
 */ 
package org.sourceforge.xsparql.xquery;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.Reader;
import java.io.Writer;
import java.net.URL;
import java.util.Map;
import java.util.Set;

import javax.xml.transform.Source;

import org.sourceforge.xsparql.sparql.DatasetManager;
import org.sourceforge.xsparql.sql.SQLQuery;

/**
 * Evaluate an XQuery query.
 * 
 * Usage: 1) use the setter methods to influence the evaluation 2) call one of
 * the evaluate methods
 */
public interface XQueryEvaluator {

	void setExternalVariables(Map<String, String> xqueryExternalVars);

	/**
	 * Set to <code>true</code> the XQuery engine is validating
	 * 
	 * @param validatingXQuery
	 *          <code>true</code> to use a validating XQuery engine
	 */
	void setValidatingXQuery(boolean validatingXQuery);

	/**
	 * Set source for the query.
	 * 
	 * @param source Source of the query.
	 */
	void setSource(Source source);

	/**
	 * Evaluate XQuery query <code>query</code> and output the result to
	 * <code>out</code>.
	 * 
	 * @param query XQuery query
	 * @throws Exception
	 */
	String evaluate(final String query) throws Exception;

	void evaluate(final InputStream query, OutputStream out)
			throws Exception;

	void evaluate(final Reader query, Writer out) throws Exception;

	/**
	 * Set to <code>true</code> to omit XML declaration in the beginning of the
	 * result
	 * 
	 * @param xmloutput
	 */
	void setOmitXMLDecl(final boolean xmloutput);

	/**
	 * Instanciate the output method of the specific xquery evaluator
	 * 
	 */
	void setOutputMethod(String outputMethod);

	void setDBconnection(SQLQuery q);

	void setDataset(Set<URL> defaultGraph, Set<URL> namedGraphs, DatasetManager manager);

}
