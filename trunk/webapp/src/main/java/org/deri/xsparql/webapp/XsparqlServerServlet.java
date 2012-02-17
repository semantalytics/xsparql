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
package org.deri.xsparql.webapp;

import java.io.*;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.*;
import javax.servlet.http.*;
import net.sf.saxon.s9api.*;


import org.deri.xsparql.evaluator.XSPARQLEvaluator;
import org.deri.xsparql.rewriter.*;

/**
 * @author stefan
 *
 */
public class XsparqlServerServlet extends HttpServlet {
  private static final long serialVersionUID = -531770540407741938L;

  // private XQueryCompiler xqueryComp;
  private XSPARQLProcessor proc;

  private Map<String, String> externalVars;

  // do not use the licensed version
  private boolean licensedSaxon = false;

  private XSPARQLEvaluator eval;

  /* (non-Javadoc)
   * @see javax.servlet.GenericServlet#init()
   */
  @Override
  public void init() {

      //System.out.println("Starting XSPARQL servlet...");

      this.licensedSaxon = Boolean
          .parseBoolean(getInitParameter("validatingXQuery"));
      // System.out.println(licensedSaxon);
      // System.out.println(System.getenv("SAXON_HOME"));

      // saxon xquery
//      processor = new xqueryEvaluatorSaxon(licensedSaxon);
//      if (licensedSaxon) {
//        Configuration.setXQueryEngine("saxon-ee");
//      } else {
//        Configuration.setXQueryEngine("saxon-he");
//      }

      // xsparqlProcessor
      proc = new XSPARQLProcessor();
      eval = new XSPARQLEvaluator();

      // TODO: bug in saxon (or our library), loading the library by default
      // does not work
      // if (licensedSaxon) {
      // // load the xsd
      // URL xsd = new
      // URL("http://xsparql.deri.org/demo/xquery/sparql.xsd");
      // BufferedReader xsdIn = new BufferedReader(new
      // InputStreamReader(xsd.openStream()));
      // schemaManager.load(new StreamSource(xsdIn));

      // // load the XSPARQL library
      // URL module = new
      // URL("http://xsparql.deri.org/demo/xquery/xsparql-types.xquery");
      // BufferedReader in = new BufferedReader(new
      // InputStreamReader(module.openStream()));
      // xqueryComp.compileLibrary(in);
      // }

      // } catch (MalformedURLException e) {
      // System.err.println(e.getMessage());
      // } catch (IOException e) {
      // System.err.println(e.getMessage());
      // } catch (SaxonApiException e) {
      // System.err.println(e.getMessage());
    

  }

  //TODO: rewrite this method
  /* (non-Javadoc)
   * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
   */
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    // clear external vars for each request
    externalVars = new HashMap<String, String>();

    try {

      String xquery = null;
      String format = null;
      String exec = null;
      Reader is = null;

      // TODO: is there a better way to do this?
      for (Enumeration<String> e = req.getParameterNames(); e.hasMoreElements();) {
        String key = e.nextElement();
        String value = req.getParameter(key);
        System.out.println(key + " = " + value);

        if (key.equals("query")) {
          // query = URLDecoder.decode(query, "UTF-8");
          is = new StringReader(value);
        } else if (key.equals("queryFile")) {
          is = new FileReader(value);
        } else if (key.equals("xqueryFile")) {
          BufferedReader s = new BufferedReader(new FileReader(value));
          StringBuilder xqueryBuilder = new StringBuilder();
          String line;

          while ((line = s.readLine()) != null) {
            xqueryBuilder.append(line);
            xqueryBuilder.append(System.getProperty("line.separator"));
          }

          s.close();

          xquery = xqueryBuilder.toString();
        } else if (key.equals("exec")) {
          exec = value;
        } else if (key.equals("format")) {
          format = value;
        } else {
          // add to the external variables list
          externalVars.put(key, value);
        }
      }
      
      if(xquery == null) {
        xquery = proc.process(is);
      }

      System.out
          .println("================================================================ rewriten query:");
      System.out.println(xquery);
      System.out
          .println("================================================================================");

      // no query parameter
      if (xquery == null) {
        resp.getOutputStream()
            .println(
                "<html><h1>XSPARQL Webservice</h1>\n"
                    + "<form method=\"get\" action=\"xsparql\">\n"
                    + "<textarea name=\"query\" rows=\"15\" cols=\"50\"></textarea><br />\n"
                    + "<input type=\"checkbox\" name=\"exec\" value=\"true\">Evaluate Query</input><br />\n"
                    + "<input type=\"text\" size=\"50\" name=\"lib\" value=\"http://xsparql.deri.org/demo/xquery/xsparql.xquery\"></input><br />\n"
                    + "<input type=\"submit\"></input>\n" + "</form>\n"
                    + "</html>");
        return;
      }

      if (exec != null && exec.equals("true")) {
        runXQuery(xquery, resp.getOutputStream(), format);
      } else {

        resp.getWriter().println(xquery);

      }

    } catch (Exception e) {
      System.err.println("There was an error handling the request: "
          + e.getMessage());
      e.printStackTrace();
      resp.getOutputStream().println(
          "There was an error handling the request: " + e.getMessage()
              + "\nSee server log/console for details.");
      this.init();
      return;
    }

  }

  /**
   * @param xquery
   * @param out
   * @param format
   * @throws Exception
   */
  protected void runXQuery(final String xquery, OutputStream out, String format)
      throws Exception {

//    Serializer serializer = processor.getSerializer();
//    serializer.setOutputProperty(Serializer.Property.METHOD, format);
//
//    // TODO: can be xml, html, xhtml, or text. Set it to xml for the FOAF KML
//    // demo
//    if (format == null || !format.equals("xml")) {
//      serializer.setOutputProperty(Serializer.Property.OMIT_XML_DECLARATION,
//          "yes");
//    } else { // override old settings
//      serializer.setOutputProperty(Serializer.Property.OMIT_XML_DECLARATION,
//          null);
//    }
//
//    processor.setSerializer(serializer);
//    processor.evaluate(xquery, new PrintStream(out), externalVars);

  }

}
