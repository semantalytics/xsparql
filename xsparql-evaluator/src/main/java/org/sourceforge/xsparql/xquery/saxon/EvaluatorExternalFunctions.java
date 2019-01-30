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
package org.sourceforge.xsparql.xquery.saxon;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSON;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;

/**
 * Library of Java methods for usage from within XQuery queries when using Saxon
 * 
 * @author Stefan Bischof
 * @author Nuno Lopes
 * 
 */
class EvaluatorExternalFunctions {

	/**
	 * Saves string s to a local file.
	 * 
	 * @param prefix
	 *          Turtle preamble
	 * @param n3
	 *          Turtle content
	 * @return URI of local file containing string s
	 */
	public static String turtleGraphToURI(String prefix, String n3) {
		URL retURL = null;

		try {
			// Create temp file.
			File temp = File.createTempFile("sparqlGraph", ".n3");

			// Delete temp file when program exits.
			temp.deleteOnExit();

			// Write to temp file
			BufferedWriter out = new BufferedWriter(new FileWriter(temp));
			out.write(prefix);
			//      out.write(n3.replace("\\", "\\\\"));  // re-escape any blackslashes
			out.write(n3);  // re-escape any blackslashes
			out.close();

			retURL = temp.toURI().toURL();
		} catch (IOException e) {

		}

		return retURL.toString();

	}

	/**
	 * Retrieves data from a url, Converts JSON data to XML
	 * 
	 * @param String location of the data
	 * 
	 */
	public static String jsonToXML(String loc) {
		String xml = "";
		String jsonData = "";

		try {

			// Send data
			URL url = new URL(loc);
			BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));

			String inputLine;

			while ((inputLine = in.readLine()) != null) {
				jsonData+=inputLine;
			}

			//      String jsonData = IOUtils.toString(is);

			XMLSerializer serializer = new XMLSerializer(); 
			JSON json = JSONSerializer.toJSON( jsonData ); 
			serializer.setTypeHintsEnabled(false);
			serializer.setObjectName("jsonObject");
			serializer.setElementName("arrayElement");
			serializer.setArrayName("array");
			xml = serializer.write( json );  


			//TODO this should be in a finally block or use a try-with-resources

			in.close();
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException("Unable to dereference url + " + loc);
		}

		return xml;

	}



}
