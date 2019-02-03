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
package org.sourceforge.xsparql.evaluator.single;

import static org.junit.Assert.*;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.io.Reader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import org.openrdf.model.BNode;
import org.openrdf.model.Literal;
import org.openrdf.model.Value;
import org.openrdf.model.impl.URIImpl;
import org.openrdf.query.BindingSet;
import org.openrdf.query.MalformedQueryException;
import org.openrdf.query.QueryLanguage;
import org.openrdf.query.QueryResultHandlerException;
import org.openrdf.query.TupleQueryResultHandler;
import org.openrdf.query.TupleQueryResultHandlerException;
import org.openrdf.query.UpdateExecutionException;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.rio.RDFFormat;
import org.openrdf.rio.RDFParseException;
import org.openrdf.sail.memory.MemoryStore;
import org.sourceforge.xsparql.evaluator.XSPARQLEvaluator;
import org.sourceforge.xsparql.test.Utils;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class EvaluationTest {
	protected final static Logger logger = LogManager.getLogger(EvaluationTest.class);
	
	private static final String prefixes = "prefix rs: <http://www.w3.org/2001/sw/DataAccess/tests/result-set#> " +
			"prefix foaf: <http://xmlns.com/foaf/0.1/> " +
			"prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ";
	protected static Repository repository;

	protected String solutionFile;
	protected String queryFile;
	
	protected List<Map<String,String>> solutions;

	public EvaluationTest(){
		queryFile = "src/main/resources/xsparql/testcases-dawg-sparql-1.1/grouping/group01.xsparql";
		solutionFile = "src/main/resources/xsparql/testcases-dawg-sparql-1.1/property-path/pp14.srx";

	}
	
	@Test
	public void shouldEvaluateQueryWithGroundTruth() throws Exception {
	    evaluate();
        checkSolutions();
	}
	
	@Test
	public void shouldEvaluateQueryWithoutGroundTruth() throws Exception {
	    evaluate();
	}

	private void evaluate() throws Exception{
		XSPARQLEvaluator evalutor;
		Reader queryReader = Utils.loadReaderFromClasspath(queryFile);
		evalutor = new XSPARQLEvaluator();
		StringWriter out = new StringWriter();
		evalutor.evaluate(queryReader, out);
	}

	@BeforeClass public static void initRepository() throws RepositoryException {
		repository = new SailRepository(new MemoryStore());
        repository.initialize();
	}


	@AfterClass public static void closeRepository() throws RepositoryException {
			repository.getConnection().close();
	}

	@Before 
	public void loadExpectedSolution() {
			try {
				File resultFile = new File(solutionFile);
				System.out.println(solutionFile);
				if(resultFile.exists()){
					repository.getConnection().clear();
					try{
						repository.getConnection().add(resultFile, null, RDFFormat.TURTLE, new URIImpl("http://example.org/solution"));
					} catch (RDFParseException e) {
						logger.warn("can't parse {}, trying to parse it as RDFXML", solutionFile);
						try{
							repository.getConnection().add(resultFile, null, RDFFormat.RDFXML, new URIImpl("http://example.org/solution"));
						} catch (RDFParseException e1) {
							logger.warn("can't parse {}, trying to parse it as SELECT result ", solutionFile);
							EvaluationTest.this.srx2RdfSolutions(new FileReader(resultFile));
						}
					
					}
				}
				else{ 
					logger.error("The solution file is missing!");
				}
			} catch (RepositoryException e) {
				e.printStackTrace();
				fail("failed at the preparation");
			} catch (IOException e) {
				e.printStackTrace();
				fail("failed at the preparation");
			}
	}

	public boolean contains(Map<String,String> sol, List<Map<String,Value>> solutions) {
		boolean different = false;
		for(Map<String,Value> solution : solutions){
			for(String key : solution.keySet()){
				Value value = solution.get(key);
				if(value instanceof Literal){
//					URI datatype = ((Literal)value).getDatatype();
//					if(datatype!=null){
//						Value comp = new LiteralImpl(sol.get(key), datatype);
//						logger.info("{})){}", value, comp);
//						if(!comp.equals(value))
//							different=true;
					if(!sol.get(key).equals(value.stringValue()))
						try{
							different=!(Double.parseDouble(sol.get(key))==Double.parseDouble(value.stringValue()));
						}catch(NumberFormatException e){
							different=true;
						}
				}else if(value instanceof BNode){
					//TODO: is there a way to verify if it is correct?
				}else{
					different=!sol.get(key).equals(value.stringValue());
				}
			}
			if(!different)
				return true;
			different=false;
		}
		return false;
	}

	protected String prepareQuery(Iterable<String> vars) {
		String query = prefixes + "SELECT ";
		for(String var : vars)
			query+= " ?"+var;
		query+=" WHERE { ?sol ";
		for(String var : vars)
			query+=" rs:binding [rs:value ?"+var+" ; rs:variable \""+var+"\"] ; ";
		query=query.substring(0, query.length()-1)+"}";
		return query;
	}

	public void checkSolutions(){
		String query = null;
		try{
			//each result can have a different number of variables (optional cases!)
			//TODO: it could be improved with a cache...
			for(final Map<String,String> solution : solutions){
				//FIXME: problems when the variable are missing... empty literal (DISTINCT - distinct-4.xsparql) vs missing variable (OPTIONAL)
				if(solution.keySet().size()>0){
					query = prepareQuery(solution.keySet());
					repository.getConnection().prepareTupleQuery(QueryLanguage.SPARQL, query).evaluate(new TupleQueryResultHandler() {
						List<Map<String,Value>> expectedSolutions = new ArrayList<Map<String,Value>>();
						Set<String> vars = solution.keySet();
		
						@Override public void handleSolution(BindingSet arg0) throws TupleQueryResultHandlerException {
							Map<String,Value> expectedSolution = new HashMap<String, Value>();
							for(String v : vars){
								Value value = arg0.getBinding(v).getValue();
								expectedSolution.put(v, value);
							}
							expectedSolutions.add(expectedSolution);
						}
		
						@Override public void endQueryResult() throws TupleQueryResultHandlerException {
							boolean res = EvaluationTest.this.contains(solution, expectedSolutions);
							logger.debug("assertion: {} in {}: {}", new Object[]{solution, expectedSolutions, res});
							assertTrue(res);
						}
		
						@Override public void startQueryResult(List<String> arg0) throws TupleQueryResultHandlerException {}
						@Override public void handleLinks(List<String> arg0) throws QueryResultHandlerException {}
						@Override public void handleBoolean(boolean arg0) throws QueryResultHandlerException {}
					});
				}
			}
		} catch (Exception e) {
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			PrintStream ps = new PrintStream(os);
			e.printStackTrace(ps);
			fail("Exception while executing the query" + query +":" + os.toString());
		}
	
	}

	public void getXsparqlSolutions(Reader reader) {
		try {
	
			SAXParserFactory factory = SAXParserFactory.newInstance();
			SAXParser saxParser = factory.newSAXParser();
			DefaultHandler handler = new DefaultHandler() {
				Map<String,String> result = new HashMap<String, String>();
				boolean binding=false;
				String var;
	
				@Override
				public void startElement(String uri, String localName,
						String qName, Attributes attributes)
								throws SAXException {
					if (qName.equalsIgnoreCase("result")) {
					}
					if(qName.equalsIgnoreCase("binding")){
						var=attributes.getValue("name");
						binding=true;
					}
				}
	
				@Override
				public void characters(char[] ch, int start, int length)
						throws SAXException {
					if(binding){
						if(result.containsKey(var))
							result.put(var, (result.get(var)+new String(ch, start, length)).trim());
						else
							result.put(var, new String(ch, start, length));
					}
				}
	
				@Override
				public void endElement(String uri, String localName,
						String qName) throws SAXException {
					if(qName.equalsIgnoreCase("binding")){
						binding=false;
					}
					if (qName.equalsIgnoreCase("result")) {
						solutions.add(result);
						result = new HashMap<String, String>();
					}
				}
			};
			saxParser.parse(new InputSource(reader), handler);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void srx2RdfSolutions(Reader reader) {
		try {
	
			SAXParserFactory factory = SAXParserFactory.newInstance();
			SAXParser saxParser = factory.newSAXParser();
			DefaultHandler handler = new DefaultHandler() {
				Map<String,String> result = new HashMap<String, String>();
				boolean binding=false;
				boolean insideBinding=false;
				boolean added=false;
				String datatype = null;
				String var;
	
				@Override
				public void startElement(String uri, String localName,
						String qName, Attributes attributes)
								throws SAXException {
					if (binding && 
							(qName.equalsIgnoreCase("literal")
							||qName.equalsIgnoreCase("uri")
							||qName.equalsIgnoreCase("bnode")									
									)) {
						insideBinding=true;
						if(qName.equalsIgnoreCase("literal")){
							datatype=attributes.getValue("datatype");
						}
					}
					else if(qName.equalsIgnoreCase("binding")){
						var=attributes.getValue("name");
						binding=true;
					}
				}
	
				@Override
				public void characters(char[] ch, int start, int length)
						throws SAXException {
					if(insideBinding){
						String s = new String(ch, start, length).trim();
						
						if(s.length()>0)
							if(result.containsKey(var))
								result.put(var, (result.get(var)+new String(ch, start, length)).trim());
							else
								result.put(var, new String(ch, start, length));

//							result.put(var, new String(ch, start, length));
						added=true;
					}
				}
	
				@Override
				public void endElement(String uri, String localName,
						String qName) throws SAXException {
					if (binding && 
							(qName.equalsIgnoreCase("literal")
							||qName.equalsIgnoreCase("uri")
							||qName.equalsIgnoreCase("bnode")									
									)) {
						insideBinding=false;
						if(!added){
							result.put(var, "");
						}
						if(qName.equalsIgnoreCase("literal")){
							if(datatype!=null)
								result.put(var, "\""+result.get(var)+"\"^^<"+datatype+">");
							else
								result.put(var, "\""+result.get(var)+"\"");
						} else if(added && qName.equalsIgnoreCase("uri")){
							result.put(var, "<"+result.get(var)+">");
						} else if(added && qName.equalsIgnoreCase("bnode")){
							result.put(var, "_:"+result.get(var));
						}
 
						datatype=null;
						added=false;
					}
					else if(qName.equalsIgnoreCase("binding")){
						binding=false;
					}
					else if (qName.equalsIgnoreCase("result")) {
						String query = 
								"PREFIX rs: <http://www.w3.org/2001/sw/DataAccess/tests/result-set#> " +
								"INSERT DATA { " +
								"[] rs:solution   [ ";
						for(String key : result.keySet())
							query+=
								"rs:binding    [ " +
									"rs:value "+result.get(key)+"; " +
									"rs:variable \""+key+"\"" +
								"] ;";
						query=query.substring(0,query.length()-1)+"]}";
						logger.debug("inserting data {}", query);
						try {
							repository.getConnection().prepareUpdate(QueryLanguage.SPARQL, query).execute();
						} catch (UpdateExecutionException e) {
							e.printStackTrace();
						} catch (RepositoryException e) {
							e.printStackTrace();
						} catch (MalformedQueryException e) {
							e.printStackTrace();
						}
	
						result = new HashMap<String, String>();
					}
				}
			};
			saxParser.parse(new InputSource(reader), handler);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
