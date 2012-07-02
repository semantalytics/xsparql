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
tree grammar XSPARQLRewriter;

options {
  tokenVocab=XSPARQL;
  output=AST;
  backtrack=true;
  ASTLabelType=CommonTree;
  rewrite=false;
}

tokens {

  REWRITEVNODE;
  REWRITEVNODE1;
  DELETEVNODE;
  COMMENT;
  T_QSTRING;
  
  NOTHING;

  // Lexer tokens
  VAR;ENDELM;INTEGER;LCURLY;RCURLY;NCNAME;QSTRING;DOT;AT;ASSIGN;CARET;CARETCARET;COLON;COMMA;SLASH;
  LBRACKET;RBRACKET;LPAR;RPAR;SEMICOLON;STAR;DOTDOT;SLASHSLASH;LESSTHAN;GREATERTHAN; PLUS;MINUS;
  UNIONSYMBOL;QUESTIONMARK;LESSTHANLESSTHAN;GREATERTHANEQUALS;LESSTHANEQUALS;HAFENEQUALS;EQUALS;
  COLONCOLON;  BLANK_NODE_LABEL;BNODE_CONSTRUCT;IRI_CONSTRUCT;ASK;DESCRIBE;SELECT;PNAME_NS;PNAME_LN;
  CDATASTART;CDATAELMEND;RCURLYGREATERTHAN;LESSTHANLCURLY;ORSYMBOL;ANDSYMBOL;NOT;WHITESPACE;IRIREF;
  NCNAMEELM;ENDTAG;A;IS;EQ;NE;LT;GE;LE;GT;FOR;FROM;LIMIT;OFFSET;LET;ORDER;BY;ATS;IN;AS;DESCENDING;
  ASCENDING;STABLE;IF;THEN;ELSE;RETURN;CONSTRUCT;WHERE;GREATEST;LEAST;COLLATION;CHILD;DESCENDANT;
  ATTRIBUTE;SELF;DESCENDANTORSELF;FOLLOWINGSIBLING;FOLLOWING;PARENT;ANCESTOR;PRECEDINGSIBLING;PRECEDING;
  ANCESTORORSELF;ORDERED;UNORDERED;DECLARE;NAMESPACE;DEFAULT;ELEMENT;FUNCTION;BASEURI;PREFIX;BASE;AND;OR;
  TO;DIV;IDIV;MOD;UNION;INTERSECT;EXCEPT;INSTANCE;TREAT;CASTABLE;CAST;OF;EMPTYSEQUENCE;ITEM;NODE;DOCUMENTNODE;
  TEXT;COMMENT;PROCESSINGINSTRUCTION;SCHEMAATTRIBUTE;SCHEMAELEMENT;DOCUMENT;NAMED;OPTIONAL;FILTER;STR;LANG;
  LANGMATCHES;DATATYPE;BOUND;ISIRI;ISURI;ISBLANK;ISLITERAL;REGEX;TRUE;FALSE;GRAPH;GREATERTHANGREATERTHAN;
  DISTINCT;GROUP;HAVING;

  // AST tokens
  T_NAMESPACE;
  T_XML_ELEMENT;
  T_XML_CONTENT;
  T_XML_CONTENTS;
  T_XML_ATTRIBUTE;
  T_FLWOR;
  T_FUNCTION_DECL;
  T_PARAMS;
  T_FORLET;
  T_WHERE;
  T_SPARQL_FOR;
  T_SPARQL_WHERE;
  T_FOR;
  T_LET;
  T_CONSTRUCT;
  T_ORDER;
  T_RETURN;
  T_UNION;

  T_BLANK;
  T_ANON_BLANK;
  T_EMPTY_ANON_BLANK;

  T_SUBJECT;
  T_VERB;
  T_OBJECT;
  T_MAIN;
  T_PAR;

  T_INSTANCEOF;
  T_TYPE;
  T_CASTAS;
  T_CASTABLEAS;
  T_TREATAS;

  T_VARIABLE_DECL;
  T_EXTERNAL_VARIABLE_DECL;
  T_OPTION_DECL;
  T_FUNCTION_CALL;
  T_PARAM;

  T_ORDER_BY;
  T_STABLE_ORDER_BY;

  T_GROUP_BY;
  T_HAVING;

  // XQuery keywords
  BOUNDARYSPACE;
  STRIP;
  VARIABLE;
  IMPORT;
  EXTERNAL;
  NOPRESERVE;
  PRESERVE;
  CONSTRUCTION;
  MODULE;
  INHERIT;
  NOINHERIT;
  SCHEMA;
  EMPTY;
  ORDERING;
  COPYNAMESPACES;
  XQUERY;
  VERSION;
  ENCODING;
  OPTION;
  LAX;
  CASE;
  EVERY;
  TYPESWITCH;
  SATISFIES;
  VALIDATE;
  SOME;
  STRICT;

  // SPARQL keywords
  ASC;
  DESC;

  T_MODULE_DECL;
  T_VERSION;
  T_BOUNDARYSPACE_DECL;
  T_DEFAULT_DECL;
  T_ORDER_DECL;
  T_EMPTY_ORDER_DECL;
  T_DEFAULT_COLLATION_DECL;
  T_BASEURI_DECL;
  T_MODULE_IMPORT;
  T_SCHEMA_IMPORT;

  T_QUERY_BODY;
  T_BODY_PART;

  XPATH;

  T_LITERAL_CONSTRUCT;
  T_IRI_CONSTRUCT;

  T_EPILOGUE;
  
  T_SQL_FOR;
  T_SQL_FROM;
  T_TABLE;
  T_VAR;
  ENDPOINT;
  DECIMAL;
  ROW;
}

/*
A scope stack managing bound variables assigned by

 * variable declaration
 * let clause
 * for clause

See also the isBound(String name) method in the members section below

It also manages a list of position variables for each scope. For every for s
expression, the corresponding position variable will be pushed onto the stack.

*/
scope VariableScope {
  Map<String, Types> variables;
  List<String> positions;
  boolean scopedDataset;
  boolean sparqlClause;
}

@header {
  package org.deri.xsparql.rewriter;

  import java.util.logging.Logger;
  import java.util.LinkedList;
  import java.util.UUID;
  import java.net.URL;
  import java.util.Iterator;

  import org.deri.xsparql.rewriter.Pair;
  import org.deri.sql.SQLQuery;
}

@members {
  private static final Logger logger = Logger.getLogger(XSPARQLRewriter.class.getClass().getName());

  /** Types for variables */
  private enum Types {
   XQUERY, SPARQL, SQL, SQL_ROW, RDF_GRAPH 
 }

  /** Handle namespaces */
  private final Map<String, String> namespaces = new HashMap<String, String>();

  /** global stack for scoped datasets */
  private final Stack<ScopedDataset> scopedDataset = new Stack<ScopedDataset>();

  /** final part of the tree, used for postprocesssing, e.g. delete scopedDatasets */
  private final CommonTree epilogue = (CommonTree) adaptor.nil();
  
  /**
   * use validating XQuery engine
   */
  private boolean validatingXQuery = false;
  
  public void setValidatingXQuery(boolean b) {
    this.validatingXQuery = b;
  }
  
  private boolean warnIfNestedConstruct = false;
  
  public void setWarnIfNestedConstruct(boolean warnIfNestedConstruct) {
    this.warnIfNestedConstruct = warnIfNestedConstruct;
  }
  
  private String sparqlmethod;
  
  public void setSPARQLMethod(String sparqlmethod) {
    this.sparqlmethod = sparqlmethod;
  }
  
  private String endpointURI;
  
  public void setEndpointURI(String endpointURI) {
    this.endpointURI = endpointURI;
  }
  
  /*
   * Create a debug version of the rewritten query
   * The debug version will print all the SPARQL queries on the stdout before sending to the SPARQL engine
   */
  private boolean debugVersion = false;
  
  public void setDebugVersion(boolean debugVersion) {
    this.debugVersion = debugVersion;
  }
  
  
  /**
   * XQuery engine to be used for evaluation/code production.
   */
  private String xqueryEngine = "saxon-he";
	
  public void setXQueryEngine(String xqueryEngine) {
    this.xqueryEngine = xqueryEngine;
  }

  /** Add a namespace prefix and the corresponding IRI */
  private void addNamespace(final String name, final String iri) {
    logger.entering(this.getClass().getCanonicalName(), "addNamespace", new String[]{name, iri});

    namespaces.put(name, iri);
  }

  /** Get a string containing the SPARQL namespace declarations */
  private String getSPARQLNamespaces() {
     final StringBuffer sb = new StringBuffer();
     for(String key : namespaces.keySet()) {
        sb.append("PREFIX ");
        sb.append(key);
        if(!key.equals(":")) {
           sb.append(":");
        }
        sb.append(" <");
        sb.append(namespaces.get(key));
        sb.append("> ");
        sb.append(System.getProperties().getProperty("line.separator"));
     }

     return sb.toString();
  }


  private String getRDFNamespaceDecls() {
     final StringBuffer sb = new StringBuffer();
     for(String key : namespaces.keySet()) {
        sb.append("@prefix ");
        sb.append(key);
        if(!key.equals(":")) {
           sb.append(":");
        }
        sb.append(" <");
        sb.append(namespaces.get(key));
        sb.append("> . ");
        sb.append(System.getProperties().getProperty("line.separator"));
     }

     // if there are any prefixes, put a separator in the output
     if (sb.length() > 0) {
       sb.append(System.getProperties().getProperty("line.separator"));
     }
     
     return sb.toString();
  }

  // Create new temporary variables

  private int auxresultscounter = 0;
  private String getNewAuxResultsVariable() {
    logger.entering(this.getClass().getCanonicalName(), "getNewAuxResultsVariable");
    return "\$_aux_results" + auxresultscounter++;
  }

  private int auxresultcounter = 0;
  private String getNewAuxResultVariable() {
    logger.entering(this.getClass().getCanonicalName(), "auxresultcounter");
    return "\$_aux_result" + auxresultcounter++;
  }

  private int posvarcnt = 0;
  
  @Deprecated
  private String getNewPosVariableName() {
    logger.entering(this.getClass().getCanonicalName(), "getNewPosVariableName");
    return "\$_pos" + posvarcnt++;
  }

  private int rdftermcnt = 0;
  private String getNewTempRdfTermVariable() {
    logger.entering(this.getClass().getCanonicalName(), "getNewTempRdfTermVariable");
    return "\$_rdf" + rdftermcnt++;
  }

  // Variable scoping

  private void addVariableToScope(final String name) {
    addVariableToScope(name, Types.XQUERY);
  }

  private void addVariableToScope(final String name, final Types type) {
    logger.info(this.getClass().getCanonicalName() + " addVariableToScope "+ name);

    $VariableScope::variables.put(name, type);
  }


  private void addVariablesToScope(final List<?> variables, final Types type) {
    logger.entering(this.getClass().getCanonicalName(), "addVariablesToScope");
    String text;
    for(Object o : variables) {
       final CommonTree tree = (CommonTree) o;
       
       if (type == Types.SQL) {
         int c = tree.getChildCount();
         text = ((CommonTree) tree.getChild(c-1)).getText();
       } else {
         if(tree.getChildCount() > 0 && ((CommonTree) tree.getChild(1)).getType() == T_FUNCTION_CALL)   // function_call
           text = tree.getChild(3).getText();
         else
           text  = tree.getText();
       }

       addVariableToScope(text, type);
    }
  }

  @Deprecated
  private void addVariablesStringToScope(final List<String> variables, final Types type) {
    logger.entering(this.getClass().getCanonicalName(), "addVariablesStringToScope");

    for(String o : variables) {
       addVariableToScope("\$"+o, type);
    }
  }


  private void addPositionVariableToScope(final String name) {
    logger.entering(this.getClass().getCanonicalName(), "addPositionVariableToScope", name);
    $VariableScope::positions.add(name);
  }

  private boolean isBound(final String name, Types type) {
    logger.info(this.getClass().getCanonicalName() +" isBoundType "+ name+type);
    
    Types t = containsVar(name, 1);
    if (t != null) {
     return t.equals(type);
    } else {
      return false;
    }
  }
  
  private boolean isBoundEarlier(final String name, Types type) {
    logger.info(this.getClass().getCanonicalName()+ "isBoundEarlierType"+ name+type);

    Types t = containsVar(name, 2);
    if (t != null) {
     return t.equals(type);
    } else {
      return false;
    }
  }

  private boolean isBound(final String name) {
    logger.info(this.getClass().getCanonicalName()+ "isBound"+ name);
    return containsVar(name, 1) != null;
  }
  
  private boolean isBoundEarlier(final String name) {
    logger.info(this.getClass().getCanonicalName()+ "isBoundEarlier"+ name);
    return containsVar(name, 2) != null;
  }



  private Types containsVar(final String name, int pos) {
    logger.entering(this.getClass().getCanonicalName(), "isBound", name);
    for(int s=$VariableScope.size()-pos; s >= 0; s--) {
      if($VariableScope[s]::variables.containsKey(name)) {
        logger.exiting(this.getClass().getCanonicalName(), "isBound", "true");

       // Iterator iterator = $VariableScope[s]::variables.keySet().iterator();
       // while (iterator.hasNext()) {
       //    String key = iterator.next().toString();
       //    String value = $VariableScope[s]::variables.get(key).toString();
       //    System.out.println("VariableScope["+ s +"]: "+key + " " + value);
       // }

        return $VariableScope[s]::variables.get(name);
      }
    }
    logger.exiting(this.getClass().getCanonicalName(), "isBound", "false");
    return null;
  }

  private CommonTree getPositionVarList() {
    CommonTree ret = (CommonTree) adaptor.nil();
    
    for(int s=0; s < $VariableScope.size(); s++) {
      for(String name : $VariableScope[s]::positions) {
        adaptor.addChild(ret, (CommonTree)adaptor.create(QSTRING, "_"));
        adaptor.addChild(ret, (CommonTree)adaptor.create(VAR, name));
      }
    }
    
    return ret;
  }

  // CONSTANTS
  private static final String xsparqlNamespace = "http://xsparql.deri.org/demo/xquery/xsparql.xquery";


  private static final String xsparqlAbbrev = "_xsparql";
  private static final String javaExternalAbbrev = "_java";
  private String javaExternalURL;
  private static final String serializeFunction = xsparqlAbbrev + ":_serialize";
  private static final String rdfTermFunction = xsparqlAbbrev + ":_rdf_term";
  private static final String bindingTermFunction = xsparqlAbbrev+":_binding_term";

  private static String sparqlFunctionScopedCreate = xsparqlAbbrev+":createScopedDataset";
  private static String sparqlFunctionScopedInner = xsparqlAbbrev+":sparqlScopedDataset";
  private static String sparqlFunctionScopedDelete = xsparqlAbbrev+":deleteScopedDataset";
  private static String sparqlFunctionScopedPop = xsparqlAbbrev+":scopedDatasetPopResults";

  private String sparqlResultsFunctionNode;
  private static String storeGraphFunction;

  private static final String schemaAbbrev = "_sparql_result";
  private static final String schemaNamespace = "http://www.w3.org/2005/sparql-results#";
  private static String schemaURL = "http://xsparql.deri.org/demo/xquery/sparql.xsd";

  private static final String validSubjectFunction = xsparqlAbbrev+":_validSubject";
  private static final String validPredicateFunction = xsparqlAbbrev+":_validPredicate";
  private static final String validObjectFunction = xsparqlAbbrev+":_validObject";

  private static final String sparqlNamespaceAbbrev = "xsparql";
  private static final String sparqlFunctionsNamespace = "http://xsparql.deri.org/demo/xquery/sparql-functions.xquery";
  
  /*
  * set the library to be used
  */
  private String xsparqlLibURL = "http://xsparql.deri.org/demo/xquery/xsparql-types.xquery";
  private String sparqlLibURL  = "http://xsparql.deri.org/demo/xquery/sparql-functions.xquery";


  public void setLibraryVersion() {

    URL local = XSPARQLRewriter.class.getResource("/xquery/xsparql-types.xquery");
    if (local != null) {
      xsparqlLibURL = local.toString();
    }

    local = XSPARQLRewriter.class.getResource("/xquery/sparql-functions.xquery");
    if (local != null) {
      sparqlLibURL = local.toString();
    }

    if (!this.validatingXQuery) {
      local = XSPARQLRewriter.class.getResource("/xquery/xsparql.xquery");
      if (local != null) {
        xsparqlLibURL = local.toString();
      } else {
        xsparqlLibURL = "http://xsparql.deri.org/demo/xquery/xsparql.xquery";
      }
    }

//    if(Configuration.debugVersion()) {
//      local = XSPARQLRewriter.class.getResource("/xquery/xsparql-types.debug.xquery");
//      if (local != null) {
//        xsparqlLibURL = local.toString();
//      } else {
//        xsparqlLibURL = "http://xsparql.deri.org/demo/xquery/xsparql-types.debug.xquery";
//      }
//    } 

  }
  

  public CommonTree createSchemaImport() {
    CommonTree ret = (CommonTree) adaptor.nil();
    
    //    ^(T_SCHEMA_IMPORT ^(NAMESPACE NCNAME[schemaAbbrev]) QSTRING[schemaNamespace] ^(AT QSTRING[schemaURL]))
    if (this.validatingXQuery) {
      URL local = XSPARQLRewriter.class.getResource("/xquery/sparql.xsd");
      if (local != null) {
        schemaURL = local.toString();
      }

      CommonTree at = (CommonTree) adaptor.create(AT, "AT");
      adaptor.addChild(at, adaptor.create(QSTRING, schemaURL));

      CommonTree ns = (CommonTree) adaptor.create(NAMESPACE, "NAMESPACE");
      adaptor.addChild(ns, adaptor.create(NCNAME, schemaAbbrev));

      ret = (CommonTree) adaptor.create(T_SCHEMA_IMPORT, "T_SCHEMA_IMPORT");
      adaptor.addChild(ret, ns);
      adaptor.addChild(ret, adaptor.create(QSTRING, schemaNamespace));
      adaptor.addChild(ret, at);
    }

    return ret;
  }       

  private SQLQuery sqlQuery = null;

  /**
   * set the database connection
   */
  public void setDBconnection(SQLQuery q) {
    this.sqlQuery = q;
  }

  private String evaluationFunction = "";
  private String iterationFunction = "";

  private String SQLevaluationFunction = "";
  private String SQLiterationFunction = "";


  /**
   * set the evaluation method for SPARQL queries:
   *     arq = using saxon integrated (no need for an endpoint)
   *     joseki =  using a SPARQL endpoint (default)
   */
  public void setEvaluationMethod() {

    String externalFunctionAbbrev = "";

    // defaults, use joseki
    this.iterationFunction = xsparqlAbbrev+":_sparqlResults";
    this.evaluationFunction = xsparqlAbbrev+":_sparql";

    this.SQLevaluationFunction = xsparqlAbbrev+":_sqlQuery";
    this.SQLiterationFunction = xsparqlAbbrev+":_sqlResults";

    // Qexo engine
    if (this.xqueryEngine.equals("qexo")) {
      this.javaExternalURL = "class:org.deri.xquery.qexo.Sparql";

      if (this.sparqlmethod.equals("arq")) {
        this.evaluationFunction = javaExternalAbbrev+":sparqlResultsIterator";
        this.sparqlResultsFunctionNode = xsparqlAbbrev+":_sparqlResultsFromNode";
        this.iterationFunction = "iterator-items";
        externalFunctionAbbrev = javaExternalAbbrev;
      } 
    } 

    // saxon engine
    if (this.xqueryEngine.equals("saxon-he") || this.xqueryEngine.equals("saxon-ee")) {
      this.javaExternalURL = "java:org.deri.xquery.saxon.Sparql";
      externalFunctionAbbrev = xsparqlAbbrev;

      if (this.sparqlmethod.equals("arq")) {
        this.evaluationFunction = externalFunctionAbbrev+":_sparqlQuery";
        this.sparqlResultsFunctionNode = xsparqlAbbrev+":_sparqlResultsFromNode";
        this.iterationFunction = sparqlResultsFunctionNode; 

      }
    }

    sparqlFunctionScopedCreate = externalFunctionAbbrev+":createScopedDataset";
    sparqlFunctionScopedInner = externalFunctionAbbrev+":sparqlScopedDataset";
    sparqlFunctionScopedDelete = externalFunctionAbbrev+":deleteScopedDataset";
    sparqlFunctionScopedPop = externalFunctionAbbrev+":scopedDatasetPopResults";
    storeGraphFunction = externalFunctionAbbrev+":turtleGraphToURI";
  
  }


  // stores the variable as a joinVariable for the scoped Dataset and creates a
  // tree with with text of the variable as a string
  public CommonTree addJoinVar(int tok, String text) {
    $sparqlForClause::joinVars += text+",";

    return new CommonTree(new CommonToken(tok, text));
  }       

  public CommonTree endpointURI(String endpoint) {
    CommonTree ret = (CommonTree) adaptor.nil();

    if(endpoint != null) {
      ret = new CommonTree(new CommonToken(QSTRING, endpoint));
    } else if(this.endpointURI != null) {
      ret = new CommonTree(new CommonToken(QSTRING, this.endpointURI));
    }

    return ret;
  }       


  public void changeTreeToScopedDataset() {
    logger.info("Entering changeTreeToScopedDataset");

    logger.info(scopedDataset.peek().toString());
    ScopedDataset sd = scopedDataset.peek();

    CommonTree functionTree = sd.getFunctionTree();
    if(!functionTree.isNil()) {
      Token tk1 = functionTree.getToken();
      tk1.setText(sparqlFunctionScopedCreate);
    }
    
    CommonTree resultsTree = sd.getResultsTree();
    if(!resultsTree.isNil()) {
      Token tk2 = resultsTree.getToken();
      tk2.setText(sparqlResultsFunctionNode);
    }

    String id = sd.getId();
    CommonTree idTree = sd.getIdTree();
    if(!idTree.isNil()) {
      Token tk3 = idTree.getToken();
      tk3.setText(id);
      tk3.setType(QSTRING);
    }
    
    // add the delete call to the epilogue
    if(!functionTree.isNil() && !resultsTree.isNil() && !idTree.isNil()) {
      CommonTree part = (CommonTree) adaptor.create(T_BODY_PART, "T_BODY_PART");
      adaptor.addChild(epilogue, part);

      CommonTree del = (CommonTree) adaptor.create(XPATH, "XPATH");
      adaptor.addChild(part, del);

      CommonTree func = (CommonTree) adaptor.create(T_FUNCTION_CALL, "T_FUNCTION_CALL");
      adaptor.addChild(del, func);

      CommonTree params = (CommonTree) adaptor.create(T_PARAMS, "T_PARAMS");
      CommonTree xpath = (CommonTree) adaptor.create(XPATH, "XPATH");
      adaptor.addChild(xpath, adaptor.create(QSTRING, id));
      adaptor.addChild(params, xpath);
      
      adaptor.addChild(func, adaptor.create(NCNAME, sparqlFunctionScopedDelete));
      adaptor.addChild(func, params);
    }
  }


  // returns the tree with the variable and saves the info that there has been
  // at least one unbound variable
  public CommonTree unboundVar(String var) {
    $sparqlForClause::containsVars = true;

    return new CommonTree(new CommonToken(VAR, var));
  }       


  // If there is at least an unbound var return a tree with the variables, 
  // otherwise return a tree with the string *
  private CommonTree getVarList(final List<?> variables) {
    logger.info("Entering getVarList");

    CommonTree res = (CommonTree) adaptor.nil();
    
     for(Object o : variables) {
        if(((CommonTree) o).getType() == NOTHING) { continue; }
          CommonTree t = (CommonTree) adaptor.create(new CommonToken(REWRITEVNODE1));
          adaptor.addChild(t, (CommonTree) o);
          adaptor.addChild(res, t);
        }

      if(res.getChildCount() == 0) 
      {
        res = (CommonTree) adaptor.create(new CommonToken(REWRITEVNODE1));
        adaptor.addChild(res, adaptor.create(VAR, "*"));
      } 

    return res;
  } 


  // inserts a function call to the pop function if there was a scopeddataset
  private CommonTree generatePop() {
    logger.info("Entering generatePop");

    CommonTree res = (CommonTree) adaptor.nil();
    
    logger.info("generatePop: "+$VariableScope::scopedDataset+", "+$VariableScope::sparqlClause);

    if($VariableScope::sparqlClause && $VariableScope::scopedDataset) 
      {
        res = (CommonTree) adaptor.create(T_FLWOR, "T_FLWOR");
        CommonTree xpath = (CommonTree) adaptor.create(XPATH, "XPATH");
        CommonTree func = (CommonTree) adaptor.create(T_FUNCTION_CALL, "T_FUNCTION_CALL");
        CommonTree params = (CommonTree) adaptor.create(T_PARAMS, "T_PARAMS");
        adaptor.addChild(params, adaptor.create(QSTRING, scopedDataset.peek().getId()));

        adaptor.addChild(func, adaptor.create(NCNAME, sparqlFunctionScopedPop));
        adaptor.addChild(func, params);

        adaptor.addChild(xpath, (CommonTree) adaptor.create(NCNAME, ","));
        adaptor.addChild(xpath, func);
        adaptor.addChild(res, xpath);
      } 

    return res;
  } 


  private CommonTree getVarNodes(final List<String> variables, String auxVariable) {

    CommonTree res = (CommonTree) adaptor.nil();
    
    for(String o : variables) {
      CommonTree v = (CommonTree) adaptor.create(new CommonToken(T_VAR));
      adaptor.addChild(v, adaptor.create(new CommonToken(QSTRING, o)));
      adaptor.addChild(v, adaptor.create(new CommonToken(VAR, o)));

      CommonTree t = (CommonTree) adaptor.create(new CommonToken(REWRITEVNODE, auxVariable));
      adaptor.addChild(t, v);
      adaptor.addChild(res, t);
    }

    return res;
  } 
  
  private CommonTree getVars(final List<String> variables) {

    CommonTree res = (CommonTree) adaptor.nil();
    
    for(String o : variables) {
      adaptor.addChild(res, adaptor.create(new CommonToken(VAR, "$"+o)));
   }

    return res;
  } 

// format the select line correctly
protected String concat(List<String> list, String separator) {
    String res = "";
    String sep = "";
    for (String s : list) {
      res += sep + format(s) + " AS \"\"" + s +"\"\"";
      sep = separator;
    }
     
    return res;
  }


protected String format(String relation) {
  logger.info("format: "+relation);
  if (relation.matches(".*\\..*")) {
    logger.info("format-true");
    String[] split = relation.split("\\.");
    logger.info("format-true: "+split.length);
    return new String("\"\"" + split[0] +"\"\".\"\"" + split[1] +"\"\"") ;
  } else {
    logger.info("format-false");
    return relation;
  }

}


}

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////////////////XQuery////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

// $<XQuery

root
  : versionDecl? (libraryModule | mainModule)
  ;

versionDecl
  : ^(T_VERSION stringliteral ^(ENCODING stringliteral?))
  ;

mainModule
scope VariableScope; 
@init {
  // initialize global scopes
  $VariableScope::variables = new HashMap<String,Types>();
  $VariableScope::positions = new LinkedList<String>();
  logger.info("Creating new variable scope: mainModule");
}
  : ^(T_MAIN prolog queryBody)
  ;

libraryModule
  :  moduleDecl prolog
  ;

moduleDecl
  : ^(T_MODULE_DECL NCNAME uriliteral)
  ;

prolog
  : baseDecl?
    prolog1*
    prolog2*
  ->
    baseDecl?
    COMMENT["modules imported by default"]
    ^(T_MODULE_IMPORT ^(NAMESPACE NCNAME[xsparqlAbbrev]) QSTRING[xsparqlNamespace] ^(AT QSTRING[xsparqlLibURL]))
    ^(T_MODULE_IMPORT ^(NAMESPACE NCNAME[sparqlNamespaceAbbrev]) QSTRING[sparqlFunctionsNamespace] ^(AT QSTRING[sparqlLibURL]))
    { createSchemaImport() }
    prolog1*
//    ^(T_VARIABLE_DECL VAR["_sparql_prefixes"] {addVariableToScope("_sparql_prefixes");} QSTRING[getSPARQLNamespaces()])
    COMMENT["SPARQL prefix namespaces"]
    ^(T_VARIABLE_DECL VAR["\$_sparql_prefixes"] ^(T_TYPE) QSTRING[getSPARQLNamespaces()])
    prolog2*
  ;

prolog1
  : defaultNamespaceDecl
  | namespaceDecl
  | setter
  | importa
  | prefixDecl
  ;

prolog2
  : varDecl
  | functionDecl
  | optionDecl
  ;

setter
  : boundarySpaceDecl
  | defaultCollationDecl
  | baseURIDecl
  | constructionDecl
  | orderingModeDecl
  | emptyOrderDecl
  | copyNamespacesDecl
  ;

importa
  : schemaImport | moduleImport
  ;

namespaceDecl
  : ^(T_NAMESPACE name=NCNAME irix=QSTRING) {addNamespace($name.text, $irix.text);}
  ;

boundarySpaceDecl
  : ^(T_BOUNDARYSPACE_DECL (PRESERVE|STRIP))
  ;

defaultNamespaceDecl
  : ^(T_DEFAULT_DECL (ELEMENT|FUNCTION) NAMESPACE irix=QSTRING) {addNamespace(":", $irix.text);}
  ;

optionDecl
  : ^(T_OPTION_DECL qname stringliteral)
  ;

orderingModeDecl
  : ^(T_ORDER_DECL (ORDERED|UNORDERED))
  ;

emptyOrderDecl
  : ^(T_EMPTY_ORDER_DECL (GREATEST|LEAST))
  ;

copyNamespacesDecl
  : ^(COPYNAMESPACES preserveMode inheritMode)
  ;

preserveMode
  : PRESERVE
  | NOPRESERVE
  ;

inheritMode
  : INHERIT
  | NOINHERIT
  ;

defaultCollationDecl
  : ^(T_DEFAULT_COLLATION_DECL uriliteral)
  ;

baseURIDecl
  : ^(T_BASEURI_DECL QSTRING)
  ;

schemaImport
  : ^(T_SCHEMA_IMPORT ^(SCHEMA schemaPrefix?) uriliteral ^(AT uriliteral*))
  ;

schemaPrefix
  : NCNAME
  | DEFAULT
  ;

moduleImport
  : ^(T_MODULE_IMPORT ^(NAMESPACE NCNAME?) uriliteral ^(AT uriliteral*))
  ;

varDecl
  : ^(T_VARIABLE_DECL var=VAR {addVariableToScope($var.text);} ^(T_TYPE typeDeclaration?) exprSingle)
  | ^(T_EXTERNAL_VARIABLE_DECL var=VAR {addVariableToScope($var.text);} ^(T_TYPE typeDeclaration?))
  ;

constructionDecl
  : DECLARE CONSTRUCTION (STRIP | PRESERVE)
  ;

functionDecl
scope VariableScope; 
@init {
  $VariableScope::variables = new HashMap<String,Types>();
  logger.info("Creating new variable scope: functionDecl");
}
  : ^(T_FUNCTION_DECL qname ^(T_PARAMS paramList?) (^(AS sequenceType))? (enclosedExpr | EXTERNAL))
  ;

paramList
  : param+
  ;

param
  : ^(T_PARAM var=VAR ^(T_TYPE typeDeclaration?)) {addVariableToScope($var.text);}
  ;

enclosedExpr
  : expr
  ;

enclosedExpr_
  : LCURLY expr RCURLY
  ;

queryBody
  : ^(T_QUERY_BODY (^(T_BODY_PART exprSingle))+ epilogue)
  -> {XSPARQL.graphoutput}?
     ^(T_QUERY_BODY
        ^(T_FUNCTION_CALL
          NCNAME[serializeFunction] 
          ^(T_PARAMS ^(T_PAR 
            ^(T_BODY_PART
              COMMENT["N3 namespace declaration"]
              QSTRING[getRDFNamespaceDecls()]
            )
         (^(T_BODY_PART exprSingle))+
         )
       )
       )
      )
  ->  ^(T_QUERY_BODY (^(T_BODY_PART exprSingle))+ epilogue)
  ;


epilogue
  : T_EPILOGUE
  -> { epilogue.getChildCount() > 0 }? { epilogue }
  -> DELETEVNODE["epilogue"]
  ;


expr
options {
backtrack=false;
}
//  : exprSingle+ // there is maybe a problem with the '+'
  : exprSingle+
  ;

exprSingle returns [Types type]
scope {
  boolean isConstruct;
}
@init{
    logger.info("exprSingle");
    $exprSingle::isConstruct = false;
    $type = Types.XQUERY;
}
@after { if ($exprSingle::isConstruct) { $type = Types.RDF_GRAPH; }  }
  : flworExpr
  | quantifiedExpr
  | typeSwitchExpr
  | orExpr
  | ifExpr
  ;

flworExpr
scope VariableScope;
@init {
  $VariableScope::variables = new HashMap<String,Types>();
  $VariableScope::positions = new LinkedList<String>();
  $VariableScope::scopedDataset = true;
  $VariableScope::sparqlClause = false;
  logger.info("Creating new variable scope: flworExpr");
}
  : ^(T_FLWOR forletClause 
      returnClause?
     )
  ;

returnClause
@init {
  logger.info("returnClause");
}
@after { if($VariableScope::sparqlClause) { scopedDataset.pop(); }}
  : ^(T_RETURN exprSingle) -> ^(T_RETURN exprSingle { generatePop() })
  | ^(c=T_CONSTRUCT  constructTemplate { $exprSingle::isConstruct = true; }) 
  -> COMMENT["SPARQL CONSTRUCT " + $c.text + " from " + $c.line + ":" + $c.pos]
     ^(T_RETURN[$c.token, "return"]
       ^(T_FUNCTION_CALL[$c.token, "T_FUNCTION_CALL"] NCNAME[serializeFunction]
         ^(T_PARAMS ^(T_PAR constructTemplate))
        )
        {generatePop()}
      )
  ;
  
forletClause
@init{ logger.info("forletClause"); }
  : forClause (^(T_WHERE whereClause))? (^(T_ORDER orderByClause))?
  | sparqlForClause
  | sqlForClause
  | letClause (^(T_WHERE whereClause))? (^(T_ORDER orderByClause))?
  ;

distinct: 
  DISTINCT -> QSTRING[ " DISTINCT " ]
;






// RDB -----------------------------------------------------------------



sqlForClause
scope { 
  List<Pair<String,String>> relationsAlias; 
  List<String> relations; 
}
@init {
  String auxResults = getNewAuxResultsVariable();
  String auxResult = getNewAuxResultVariable();
  String auxResultPos = auxResult + "_pos";
  
  $sqlForClause::relationsAlias = new LinkedList<Pair<String,String>>();
  $sqlForClause::relations = new LinkedList<String>();
 }
  : ^(fo=T_SQL_FOR distinct? var+=sqlVarOrFunction+)  { addVariablesToScope($var, Types.SQL); 
                                                        addPositionVariableToScope(auxResultPos); }
       relationClause sqlWhereClause?
    -> COMMENT[$fo.token, "SQL FOR from " + $fo.line + ":" + $fo.pos]
    ^(T_LET VAR[auxResults]
      ^(T_FUNCTION_CALL
        NCNAME[SQLevaluationFunction]
        ^(T_PARAMS 
          ^(T_FUNCTION_CALL
            NCNAME["fn:concat"] 
            ^(T_PARAMS 
              QSTRING[" SELECT "]
              distinct? 
              ($var)+
              relationClause
              sqlWhereClause?
              //                     solutionmodifier?
            )
          )
        )
      )
    )
    ^(T_FOR 
      VAR[auxResult] 
      ^(AT 
         VAR[auxResultPos]
       ) 
      ^(IN
        ^(T_FUNCTION_CALL 
           NCNAME[SQLiterationFunction]
          ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )
    ^(REWRITEVNODE[$fo.token, auxResult] $var)+
    
  | ^(fo=T_SQL_FOR distinct? s=STAR)  relationClause sqlWhereClause? 
    { if (sqlQuery != null) {
        $sqlForClause::relations = sqlQuery.getRelationAttributes($sqlForClause::relationsAlias); 
        addVariablesStringToScope($sqlForClause::relations, Types.SQL); 
        addPositionVariableToScope(auxResultPos); 
      } else {
        logger.severe("Unable to connect to the database!");
        System.exit(1);
      }

    }
  -> COMMENT[$fo.token, "SQL FOR from " + $fo.line + ":" + $fo.pos]
    ^(T_LET VAR[auxResults]
      ^(T_FUNCTION_CALL
        NCNAME[SQLevaluationFunction]
        ^(T_PARAMS 
          ^(T_FUNCTION_CALL
            NCNAME["fn:concat"] 
            ^(T_PARAMS 
              QSTRING[" SELECT "]
              distinct? 
              QSTRING[concat($sqlForClause::relations, ", ")+" "]
              relationClause
              sqlWhereClause?
              //                     solutionmodifier?
            )
          )
        )
      )
    )
    ^(T_FOR 
      VAR[auxResult] 
      ^(AT 
         VAR[auxResultPos]
       ) 
      ^(IN
        ^(T_FUNCTION_CALL 
           NCNAME[SQLiterationFunction]
          ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )
     {getVarNodes($sqlForClause::relations, auxResult)}


//  // run SQL query 
  | ^(fo=T_SQL_FOR distinct? ROW v=VAR) { addVariableToScope($v.text, Types.SQL_ROW); addPositionVariableToScope(auxResultPos); } 
       ^(T_SQL_FROM ^(T_FUNCTION_CALL qname ^(T_PARAMS sqlVarOrString))) 
  -> COMMENT[$fo.token, "SQL FOR from " + $fo.line + ":" + $fo.pos]
    ^(T_LET VAR[auxResults]
      ^(T_FUNCTION_CALL
        NCNAME[SQLevaluationFunction]
        ^(T_PARAMS 
          sqlVarOrString
          )
        )
      )
    ^(T_FOR 
      $v 
      ^(AT 
         VAR[auxResultPos]
       ) 
      ^(IN
        ^(T_FUNCTION_CALL 
           NCNAME[SQLiterationFunction]
          ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )


  | ^(fo=T_SQL_FOR distinct? ROW v=VAR) {addVariableToScope($v.text, Types.SQL_ROW); addPositionVariableToScope(auxResultPos);}
          relationClause sqlWhereClause? 
  -> COMMENT[$fo.token, "SQL FOR from " + $fo.line + ":" + $fo.pos]
    ^(T_LET VAR[auxResults]
      ^(T_FUNCTION_CALL
        NCNAME[SQLevaluationFunction]
        ^(T_PARAMS 
          ^(T_FUNCTION_CALL
            NCNAME["fn:concat"] 
            ^(T_PARAMS 
              QSTRING[" SELECT "]
              distinct? 
              QSTRING[" * "]
              relationClause
              sqlWhereClause?
              //                     solutionmodifier?
            )
          )
        )
      )
    )
    ^(T_FOR 
      $v 
      ^(AT 
         VAR[auxResultPos]
       ) 
      ^(IN
        ^(T_FUNCTION_CALL 
           NCNAME[SQLiterationFunction]
          ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )

;
 

sqlVarOrString
  : ^(T_TABLE v=sqlQuerySpec) 
  -> $v 
  ;


sqlQuerySpec
  : v=qname -> QSTRING[$v.text]
  | VAR  
  ;
  



// variables present here must not be bound before or if so, their value is overritten
sqlVarOrFunction
  : ^(T_VAR COMMA? q=qname)
    -> ^(T_VAR COMMA? QSTRING[$q.text] VAR["\$"+$q.text]) 
  | ^(T_VAR COMMA? q=qname VAR)
    -> ^(T_VAR COMMA? QSTRING[$q.text] VAR) 
  | COMMA? LPAR functionCall AS v3=VAR RPAR
;


relationClause
  : ^(T_SQL_FROM rdbSourceSelector (COMMA rdbSourceSelector)*)
    -> QSTRING["from "] rdbSourceSelector (QSTRING[", "] rdbSourceSelector)* 
  ;

rdbSourceSelector
  : ^(T_TABLE v=relationSchemaName alias=relationAlias?) 
     { $sqlForClause::relationsAlias.add(new Pair<String,String>($v.text, $alias.text)); } 
  -> $v (QSTRING[" "] $alias)? 
  ;


relationSchemaName
@init{ logger.info("relationSchemaName"); }
  : p1=qname DOT q1=qname -> QSTRING["\"\""+$p1.text+"\"\".\"\""+$q1.text+"\"\""]
  | relationAlias   
  | p2=relationAlias DOT q2=relationAlias ->  
    ^(T_FUNCTION_CALL NCNAME["fn:concat"] ^(T_PARAMS $p2 QSTRING["."] $q2))
  ;


relationAlias
//  : v=qname -> QSTRING["\"\""+$v.text+"\"\""]
//  | var=VAR  -> ^(T_FUNCTION_CALL NCNAME["fn:concat"] ^(T_PARAMS QSTRING["\"\""] $var QSTRING["\"\""]))
  : v=qname -> QSTRING[$v.text]
  | var=VAR
  ;
  
sqlWhereClause
  : ^(WHERE sqlWhereSpecList)
  -> QSTRING[" where "] sqlWhereSpecList
  ;

sqlWhereSpecList   
 : sqlAttrSpecList (b=sqlBooleanOp sqlWhereSpecList)*
 -> sqlAttrSpecList (QSTRING[" "] QSTRING[$b.text] QSTRING[" "] sqlWhereSpecList)*  
 ;
 
 
sqlAttrSpecList
  : sqlAttrSpec g=generalComp sqlAttrSpec
 -> sqlAttrSpec QSTRING[" "] QSTRING[$g.text] QSTRING[" "] sqlAttrSpec 
  | l=LPAR sqlWhereSpecList r=RPAR
  -> QSTRING[$l.text] sqlWhereSpecList QSTRING[$r.text]
  ;
 
sqlBooleanOp
  : AND | OR
  ;

sqlAttrSpec
  : v=qname -> QSTRING[format($v.text)]
  | VAR -> ^(T_FUNCTION_CALL
               NCNAME["_xsparql:_sql_binding_term"]
              ^(T_PARAMS VAR)
            )
  | nl=numericliteral -> QSTRING[$nl.text]
  | sl=stringliteral -> QSTRING["'"+$sl.text+"'"]
  | enclosedExpr
  ;

generalComp
  : EQUALS
  | LESSTHAN
  | GREATERTHAN
  | LESSTHANEQUALS
  | GREATERTHANEQUALS
  | HAFENEQUALS
  ;


// END RDB -----------------------------------------------------------------

sparqlForClause
scope {
//  boolean scopedDataset;
  String joinVars;
  boolean containsVars;
  String evaluationFunction;
  String iterationFunction;
  String endpointURI;
}
@init {
  String auxResults = getNewAuxResultsVariable();
  String auxResult = getNewAuxResultVariable();
  String auxResultPos = auxResult + "_pos";
  
  CommonTree sparqlFunctionTree = (CommonTree) adaptor.nil();
  CommonTree sparqlResultsFunctionTree = (CommonTree) adaptor.nil();
  CommonTree sparqlResultsIdTree = (CommonTree) adaptor.nil();
  
  $VariableScope::sparqlClause = true; 
  $sparqlForClause::joinVars = "";
  $sparqlForClause::containsVars = false;

  $sparqlForClause::iterationFunction = iterationFunction;
  $sparqlForClause::evaluationFunction = evaluationFunction;
  logger.info("sparqlForClause");


}
@after {
  logger.info("Creating new variable scope: sparqlForClause-1");

  if($VariableScope::scopedDataset) {
    changeTreeToScopedDataset();
  } 

  ScopedDataset sd = new ScopedDataset ($VariableScope::scopedDataset, 
                                        $VariableScope::scopedDataset?scopedDataset.peek().getId():UUID.randomUUID().toString(), 
                                        sparqlFunctionTree, 
                                        sparqlResultsFunctionTree, 
                                        sparqlResultsIdTree, 
                                        auxResultPos); 
  scopedDataset.add(sd); 
}
  : ^(fo=T_SPARQL_FOR distinct? var+=varOrFunction+ { addVariablesToScope($var, Types.SPARQL); 
//                                                      addGeneratedVariablesToScope($var); 
                                                      addPositionVariableToScope(auxResultPos); }
     ) datasetClause* e=endpointClause? sWhereClause solutionmodifier?

    // inner scoped dataset
  -> { $VariableScope::scopedDataset }?
     COMMENT[$fo.token, "XSPARQL FOR from " + $fo.line + ":" + $fo.pos]
     ^(T_LET VAR[auxResults]
            ^(T_FUNCTION_CALL
               NCNAME[sparqlFunctionScopedInner]
              ^(T_PARAMS 
               ^(T_FUNCTION_CALL
               NCNAME["fn:concat"] 
              ^(T_PARAMS 
//                 QSTRING[getSPARQLNamespaces()]
                 VAR["\$_sparql_prefixes"]
                 QSTRING[" SELECT "]
                 distinct? 
                 {getVarList($var)}
                 datasetClause*
                 sWhereClause
                 solutionmodifier?
                )
               )
               QSTRING[scopedDataset.peek().getId()]  // include string id
               QSTRING[$sparqlForClause::joinVars.replaceAll(",$", "")] // include join vars
               VAR[scopedDataset.peek().getVar()] // include iteration
             )
          )
       )
    ^(T_FOR 
      VAR[auxResult] 
      ^(AT 
         VAR[auxResultPos]
       ) 
      ^(IN
        ^(T_FUNCTION_CALL 
           NCNAME[sparqlResultsFunctionNode] 
          ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )
    ^(REWRITEVNODE[$fo.token, auxResult] $var)+


  -> {this.debugVersion}?
     COMMENT[$fo.token, "XSPARQL FOR from " + $fo.line + ":" + $fo.pos]
     ^(T_LET VAR[auxResults]
       ^(T_FUNCTION_CALL
         { sparqlFunctionTree = new CommonTree(new CommonToken(NCNAME, $sparqlForClause::evaluationFunction)) }
         ^(T_PARAMS { endpointURI($sparqlForClause::endpointURI) }
           ^(T_FUNCTION_CALL
             NCNAME["fn:trace"]
             ^(T_PARAMS
               ^(T_FUNCTION_CALL
                 NCNAME["fn:concat"] 
                 ^(T_PARAMS 
//                 QSTRING[getSPARQLNamespaces()]
                   VAR["\$_sparql_prefixes"]
                   QSTRING[" SELECT "]
                   distinct? {getVarList($var)}
                   datasetClause*
                   sWhereClause
                   solutionmodifier?
                 )
               )
               { sparqlResultsIdTree = new CommonTree(new CommonToken(DELETEVNODE, "deleteNode")) }
               QSTRING["XSPARQL FOR from " + $fo.line + ":" + $fo.pos]
             )
           )
         )
       )
     )
     ^(T_FOR 
       VAR[auxResult] 
       ^(AT 
         VAR[auxResultPos]
       ) 
       ^(IN
         ^(T_FUNCTION_CALL 
           { sparqlResultsFunctionTree = new CommonTree(new CommonToken(NCNAME, $sparqlForClause::iterationFunction)) }
           ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )
     ^(REWRITEVNODE[$fo.token, auxResult] $var)+
     
  -> COMMENT[$fo.token, "XSPARQL FOR from " + $fo.line + ":" + $fo.pos]
     ^(T_LET VAR[auxResults]
       ^(T_FUNCTION_CALL
         { sparqlFunctionTree = new CommonTree(new CommonToken(NCNAME, $sparqlForClause::evaluationFunction)) }
         ^(T_PARAMS { endpointURI($sparqlForClause::endpointURI) }
           ^(T_FUNCTION_CALL
             NCNAME["fn:concat"] 
             ^(T_PARAMS 
//             QSTRING[getSPARQLNamespaces()]
               VAR["\$_sparql_prefixes"]
               QSTRING[" SELECT "]
               distinct? {getVarList($var)}
               datasetClause*
               sWhereClause
               solutionmodifier?
             )
           )
           { sparqlResultsIdTree = new CommonTree(new CommonToken(DELETEVNODE, "deleteNode")) }
         )
       )
     )
     ^(T_FOR 
       VAR[auxResult] 
       ^(AT 
         VAR[auxResultPos]
       ) 
       ^(IN
         ^(T_FUNCTION_CALL 
           { sparqlResultsFunctionTree = new CommonTree(new CommonToken(NCNAME, $sparqlForClause::iterationFunction)) }
           ^(T_PARAMS 
             VAR[auxResults]
           )
         )
       )
     )
     ^(REWRITEVNODE[$fo.token, auxResult] $var)+
  ;

endpointClause
  : ENDPOINT e=sourceSelector { $sparqlForClause::iterationFunction = xsparqlAbbrev+":_sparqlResults";
                                $sparqlForClause::evaluationFunction = xsparqlAbbrev+":_sparql";
                                $sparqlForClause::endpointURI = $e.text;
  }
  ;

varOrFunction
  : v=VAR
  -> {isBoundEarlier($v.text)}?  NOTHING[$v.text]	// remove already bound varialbes by replacing it with NOTHING
  -> { unboundVar($v.text) }
  | LPAR functionCall AS v=VAR RPAR 
  -> LPAR functionCall AS { unboundVar($v.text) } RPAR
;

forClause
  : singleForClause+
  ;

singleForClause
  : ^(T_FOR var=VAR (^(T_TYPE typeDeclaration))? optionalPosClause[$var.text] )
  ;

// inject positional variable if not already present, otherwise use the given one
optionalPosClause[String var]
  : ^(IN exprSingle) {addPositionVariableToScope($var + "_pos");}
  -> ^(AT VAR[$var + "_pos"]) ^(IN exprSingle)
  | ^(a=AT p=positionalVar) ^(IN exprSingle) {addPositionVariableToScope($p.text);}
  -> ^($a $p) ^(IN exprSingle)
  ;

positionalVar
  : VAR
  ;

letClause
  : (singleLetClause)+
  ;

singleLetClause
  : ^(T_LET 
      ^(var=VAR typeDeclaration?)
      exprSingle)
      { addVariableToScope($var.text); 
        if ( $exprSingle.type.equals(Types.RDF_GRAPH) ) {
          addVariableToScope("\$_" + Helper.removeLeading($var.text,"\$")+"_graph");
        } 
        if(this.warnIfNestedConstruct) {
          logger.severe("The evaluation will probably NOT work because you are using a nested construct and want to evaluate that on a SPARQL endpoint which is not located on your host. That doesn't work! If you want to evaluate a nested constuct, then the XQuery engine and the SPARQL engine have to be running on the same host.");
        }
      }
  -> { $exprSingle.type.equals(Types.RDF_GRAPH) }? ^(T_LET ^($var typeDeclaration?) ^(T_FUNCTION_CALL NCNAME[serializeFunction] ^(T_PARAMS exprSingle))) ^(T_RETURN ^(T_FLWOR ^(T_LET VAR["\$_" + Helper.removeLeading($var.text,"\$")+"_graph"] ^(T_FUNCTION_CALL NCNAME[storeGraphFunction] ^(T_PARAMS QSTRING[getRDFNamespaceDecls()] $var)))))
  -> ^(T_LET ^($var typeDeclaration?) exprSingle)
  ;

whereClause
  : ^(WHERE exprSingle) -> exprSingle
  ;

orderByClause
  : ^(T_ORDER_BY orderSpecList)
  | ^(T_STABLE_ORDER_BY orderSpecList)
  ;

orderSpecList
  : orderSpec+
  ;

orderSpec
  :  exprSingle orderModifier
  ;

orderModifier
  : (ASCENDING | DESCENDING)? (EMPTY (GREATEST | LEAST))? (COLLATION uriliteral)?
  ;

quantifiedExpr
  : ^((SOME|EVERY) (^(T_VAR VAR (^(T_TYPE typeDeclaration))? ^(IN exprSingle)))+ ^(SATISFIES exprSingle))
  ;

typeSwitchExpr
  : ^(TYPESWITCH expr caseClause+ VAR? exprSingle)
  ;

caseClause
  : CASE (VAR AS)? sequenceType RETURN exprSingle
  ;

ifExpr
//  : ^(IF expr exprSingle exprSingle)
  : ^(IF exprSingle exprSingle exprSingle)
  ;

orExpr
  : andExpr
  | ^(OR orExpr andExpr)
  ;

andExpr
  : comparisonExpr
  | ^(AND andExpr comparisonExpr)
  ;

comparisonExpr
  : rangeExpr
  | ^(
      ( EQ
      | NE
      | LT
      | LE
      | GT
      | GE
      | EQUALS
      | LESSTHAN
      | GREATERTHAN
      | LESSTHANEQUALS
      | GREATERTHANEQUALS
      | HAFENEQUALS
      | LESSTHANLESSTHAN
      | GREATERTHANGREATERTHAN
      | IS
      )
      rangeExpr rangeExpr
    )
  ;

rangeExpr
  : additiveExpr
  | ^(TO rangeExpr additiveExpr)
  ;

additiveExpr
  : multiplicativeExpr
  | ^((PLUS|MINUS) additiveExpr multiplicativeExpr);

multiplicativeExpr
  : unionExpr
  | ^((STAR | DIV | IDIV | MOD) multiplicativeExpr unionExpr)
  ;

unionExpr
  : intersectExceptExpr
  | ^((UNION | UNIONSYMBOL) unionExpr intersectExceptExpr)
  ;

intersectExceptExpr
  : instanceOfExpr
  | ^((INTERSECT | EXCEPT) intersectExceptExpr instanceOfExpr)
  ;

instanceOfExpr
  : treatExpr
  | ^(T_INSTANCEOF instanceOfExpr sequenceType)
  ;

treatExpr
  : castableExpr
  | ^(T_TREATAS treatExpr sequenceType)
  ;

castableExpr
  : castExpr
  | ^(T_CASTABLEAS castableExpr singleType)
  ;

castExpr
  : unaryExpr
  | ^(T_CASTAS castExpr singleType)
  ;

unaryExpr
  : (MINUS | PLUS)* valueExpr
  ;

valueExpr
  : pathExpr
  | validateExpr
  | extensionExpr
  ;

validateExpr
  : VALIDATE validationMode? expr
  ;

validationMode
  : LAX
  | STRICT
  ;

extensionExpr
  : //pragma?
    LCURLY expr? RCURLY
  ;

pathExpr
  : ^(XPATH SLASH SLASH relativePathExpr)
  | ^(XPATH SLASH relativePathExpr)
  | ^(XPATH SLASH)
  | ^(XPATH relativePathExpr)
  ;

relativePathExpr
scope {
  boolean rdbVar;
}
@init {
  $relativePathExpr::rdbVar = false;
}
  : stepExpr (SLASH SLASH? stepExpr)*
//  : s1=stepExpr (sl1+=SLASH sl2+=SLASH? s2+=stepExpr)*
//   -> { $relativePathExpr::rdbVar }? ^(T_FUNCTION_CALL NCNAME["fn:data"] ^(T_PARAMS ^(XPATH $s1 ($sl1 $sl2? $s2)*)))
//   -> $s1 ($sl1 $sl2? $s2)*
  ;

stepExpr
  : filterExpr
  | axisStep
  ;

axisStep
  : (reverseStep | forwardStep) predicateList
  ;

forwardStep
  : forwardAxis nodeTest
  | abbrevForwardStep
  ;

forwardAxis
  : CHILD COLONCOLON
  | DESCENDANT COLONCOLON
  | ATTRIBUTE COLONCOLON
  | SELF COLONCOLON
  | DESCENDANTORSELF COLONCOLON
  | FOLLOWINGSIBLING COLONCOLON
  | FOLLOWING COLONCOLON
  ;

abbrevForwardStep
  : AT? nodeTest
  ;

reverseStep
  : reverseAxis nodeTest
  | abbrevReverseStep
  ;

reverseAxis
  : PARENT COLONCOLON
  | ANCESTOR COLONCOLON
  | PRECEDINGSIBLING COLONCOLON
  | PRECEDING COLONCOLON
  | ANCESTORORSELF COLONCOLON
  ;

abbrevReverseStep
  : DOTDOT
  ;

nodeTest
  : kindTest
  | nameTest
  ;

nameTest
  : qname
  | wildCard
  ;

wildCard
  : STAR
  | STAR COLON NCNAME
  | NCNAME COLON STAR
  ;

filterExpr
  : primaryExpr predicateList
  ;

predicateList
  : predicate*
  ;

predicate
  : LBRACKET expr RBRACKET
  ;

primaryExpr
  : varRef
  | literal
  | parenthesizedExpr
  | contextItemExpr
  | functionCall
  | orderedExpr
  | unorderedExpr
  | constructor
  ;

literal
  : numericliteral
  | stringliteral
  ;

numericliteral
  : integerLiteral
  | decimalLiteral 
  //|doubleLiteral // TODO
  ;

varRef
  : v=VAR { $relativePathExpr::rdbVar = isBound($v.text, Types.SQL); } 
    -> { isBound($v.text, Types.SPARQL) || $relativePathExpr::rdbVar }? ^(T_FUNCTION_CALL NCNAME["_xsparql:_typeData"] ^(T_PARAMS $v))
    -> $v
  ;

varName
  : qname
  ;

parenthesizedExpr
  : ^(T_PAR expr?)
  ;

contextItemExpr
  : DOT
  ;

orderedExpr
  : ORDERED expr
  ;

unorderedExpr
  : UNORDERED expr
  ;

functionCall
  :  ^(T_FUNCTION_CALL qname ^(T_PARAMS exprSingle*))
  ;

constructor
  : directConstructor
  | computedConstructor
  ;

directConstructor
  : dirElemConstructor
//  | dirCommentConstructor
//  | dirPIConstructor
  ;

dirElemConstructor
  : ^(T_XML_ELEMENT qname dirAttributeList? (^(T_XML_CONTENT dirElemContent ))*)
  ;

dirAttributeList
  :  dirAttribute+
  ;

dirAttribute
  : ^(T_XML_ATTRIBUTE qname dirAttributeValue)
  ;

dirAttributeValue
  : enclosedExpr
  | QSTRING
  ;

dirElemContent
  : directConstructor
  | commonContent
  | WHITESPACE //
  | NCNAMEELM //
  | cDataSection
  ;

commonContent
  : LCURLY expr RCURLY -> ^(T_XML_CONTENTS expr)
  | LCURLY LCURLY
  | RCURLY RCURLY
  ;

cDataSection
  : CDATASTART CDATAELMEND
  ;

computedConstructor
  : compDocConstructor
  | compElemConstructor
  | compAttrConstructor
  | compTextConstructor
  | compCommentConstructor
  | compPIConstructor
  ;

compDocConstructor
  : DOCUMENT enclosedExpr
  ;

compElemConstructor
  : ELEMENT ( qname | enclosedExpr_) LCURLY contentExpr? RCURLY
  ;

contentExpr
  : expr
  ;

compAttrConstructor
  : ATTRIBUTE (qname | enclosedExpr) LCURLY expr? RCURLY
  ;

compTextConstructor
  : TEXT enclosedExpr_
  ;

compCommentConstructor
  : COMMENT enclosedExpr
  ;

compPIConstructor
  : PROCESSINGINSTRUCTION ( NCNAME | enclosedExpr) LCURLY expr? RCURLY
  ;

singleType
  : atomicType QUESTIONMARK?
  ;

typeDeclaration
  : sequenceType
  ;

sequenceType
  : EMPTYSEQUENCE LPAR RPAR
  | itemType occurrenceIndicator?
  ;

occurrenceIndicator
  : QUESTIONMARK | STAR | PLUS
  ;

itemType
  : ITEM LPAR RPAR
  | atomicType
  | kindTest
  ;

atomicType
  : qname
  ;

kindTest
  : documentTest
  | elementTest
  | attributeTest
  | schemaElementTest
  | schemaAttributeTest
  | piTest
  | commentTest
  | textTest
  | anyKindTest
  ;

anyKindTest
  : NODE LPAR RPAR
  ;

documentTest
  : DOCUMENTNODE LPAR (elementTest | schemaElementTest)? RPAR
  ;

textTest
  : TEXT LPAR RPAR
  ;

commentTest
  : COMMENT LPAR RPAR
  ;

piTest
  : PROCESSINGINSTRUCTION LPAR (NCNAME | stringliteral)? RPAR
  ;

attributeTest
  : ATTRIBUTE LPAR (attributeNameOrWildcard (COMMA typeName)?)? RPAR
  ;

attributeNameOrWildcard
  : attributeName | STAR
  ;

schemaAttributeTest
  : SCHEMAATTRIBUTE LPAR attributeDeclaration RPAR
  ;

attributeDeclaration
  : attributeName
  ;

elementTest
  : ELEMENT LPAR (elementNameOrWildcard (COMMA typeName QUESTIONMARK?)?)? RPAR
  ;

elementNameOrWildcard
  : elementName | STAR
  ;

schemaElementTest
  : SCHEMAELEMENT LPAR elementDeclaration RPAR
  ;

elementDeclaration
  : elementName
  ;

attributeName
  : qname
  ;

elementName
  : qname
  ;

typeName
  : qname
  ;

uriliteral
  : stringliteral
  ;

integerLiteral
  : INTEGER
  ;

decimalLiteral
  : DECIMAL
  ;

stringliteral
  : QSTRING
  ;

// $>

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////////////////SPARQL////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

// $<SPARQL

baseDecl
  : ^(T_NAMESPACE DEFAULT irix=IRIREF) {addNamespace(":", $irix.text);}
  ;

prefixDecl
  : ^(T_NAMESPACE DEFAULT irix=QSTRING) {addNamespace(":", $irix.text);} -> 
  | ^(T_NAMESPACE p=PNAME_NS irix=QSTRING) {addNamespace($p.text, $irix.text);}
  -> ^(T_NAMESPACE NCNAME[$p.token, $p.text] QSTRING)
  ;

datasetClause
  : ^(f=FROM { $VariableScope::scopedDataset = false; } (d=defaultGraphClause | e=namedGraphClause ))
  -> QSTRING[$f.token, "\n " + $f.text + " "] $d? $e?
  ;

defaultGraphClause
  : sourceSelector
  ;

namedGraphClause
  : n=NAMED sourceSelector
  -> QSTRING[$n.token, $n.text] sourceSelector
  ;

sourceSelector
  : i=IRIREF
  -> QSTRING[$i.token, "<" + $i.text + ">"]
  | v=VAR
  -> {isBound("\$_" + Helper.removeLeading($v.text,"\$")+"_graph")}? QSTRING[$v.token, "<"] VAR["\$_" + Helper.removeLeading($v.text,"\$")+"_graph"] QSTRING[$v.token, ">"]
  -> ^(T_FUNCTION_CALL NCNAME[rdfTermFunction]
        ^(T_PARAMS 
              ^(T_FUNCTION_CALL NCNAME[bindingTermFunction] ^(T_PARAMS $v))
            )
    )
  ;

sWhereClause
  : ^(w=T_SPARQL_WHERE groupGraphPattern)
  -> QSTRING[$w.token, "\n " + $w.text + " "]
     groupGraphPattern
  ;

solutionmodifier
  : orderclause limitoffsetclauses?
  | groupBy? having? limitoffsetclauses?
  ;

groupBy 
  : ^(T_GROUP_BY VAR)
  ;

having
  : ^(T_HAVING exprSingle)
  ;

limitoffsetclauses
  : limitclause offsetclause?
  | offsetclause limitclause?
  ;

orderclause
  : ^(o=ORDER orderCondition)
  -> QSTRING[$o.token, $o.text + " by "] orderCondition
  ;

orderCondition
  : (ASC | DESC) brackettedExpression
  | constraint
  | v=VAR -> QSTRING[$v.token, $v.text+ " "]
  ;

limitclause
  : ^(l=LIMIT i=INTEGER)
  -> QSTRING[$l.token, $l.text + " " + $i.text + " "]
  ;

offsetclause
  : ^(o=OFFSET i=INTEGER)
  -> QSTRING[$o.token, $o.text + " " + $i.text + " "]
  ;

groupGraphPattern
options {
backtrack=true;
}
  : singleGroupGraphPattern+
  -> QSTRING[" { "] singleGroupGraphPattern+ QSTRING[" } "]
  ;

singleGroupGraphPattern
options {
backtrack=true;
}
  : triplesBlock
  | graphPatternNotTriples
  | filter
    ;

triplesBlock
  : triplesSameSubject+
  ;

graphPatternNotTriples
  : optionalGraphPattern
  | groupOrUnionGraphPattern
  | graphGraphPattern
  ;

optionalGraphPattern
  : ^(o=OPTIONAL groupGraphPattern)
  -> QSTRING[$o.token, "\n " + $o.text +" "] groupGraphPattern
  ;

graphGraphPattern
  : ^(g=GRAPH varOrIRIref groupGraphPattern)
  -> QSTRING[$g.token,"\n " + $g.text + " "] varOrIRIref groupGraphPattern
  ;

groupOrUnionGraphPattern
  : ^(u=UNION ^(T_UNION g1=groupGraphPattern) (^(T_UNION g2+=groupGraphPattern))+)
  -> QSTRING[" { "] $g1 (QSTRING[$u.token," } \n" + $u.text + " { "] $g2)+ QSTRING[" } "]
  ;

filter
  : ^(f=FILTER constraint)
  -> QSTRING[$f.token, "\n "+$f.text] constraint
  ;

constraint
  : brackettedExpression
  | builtInCall
  | sFunctionCall
  ;

sFunctionCall
  : iRIref arglist?
  ;

arglist
options {backtrack=true;}
  :  e1=expression e2+=expression* -> $e1 (QSTRING[","] $e2)*
  ;

constructTemplate
  : constructTriples?
  ;

constructTriples
  : (triplesSameSubject_ | enclosedExpr)+
  ;

triplesSameSubject
@init{logger.info("triplesSameSubject");}
  : ^(T_SUBJECT subject propertyListNotEmpty )
  -> subject QSTRING[" "] propertyListNotEmpty QSTRING[" . \n"]
  | ^(T_SUBJECT triplesNode propertyListNotEmpty?)
  -> triplesNode propertyListNotEmpty? QSTRING[" . \n"]
  ;

triplesSameSubject_
options {
backtrack=true;
}
scope {
  CommonTree subject;
  String separator;
}
@init {
  String rdfTermVar = getNewTempRdfTermVariable();
}
  : ^(T_SUBJECT
      ( a=subject_     {$triplesSameSubject_::subject = $a.tree; $triplesSameSubject_::separator = " .&#xA;";} propertyListNotEmpty_
      -> propertyListNotEmpty_
      | b=bnode     {$triplesSameSubject_::subject = new CommonTree(new CommonToken(VAR, rdfTermVar));  $triplesSameSubject_::separator = " .&#xA;";} propertyListNotEmpty_
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
             ^(T_FUNCTION_CALL
                NCNAME[bindingTermFunction]
               ^(T_PARAMS 
                 ^(T_FUNCTION_CALL
                    NCNAME[serializeFunction]
                   ^(T_PARAMS 
                     ^(T_PAR
                        QSTRING[$b.text]
                        {getPositionVarList()}
                      ) 
                    )
                  )
                )
              )
            )
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME[validSubjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
               ^(T_PAR propertyListNotEmpty_)
                QSTRING[""]
              )
            )
          )
      | bc=blankConstruct   {$triplesSameSubject_::subject = new CommonTree(new CommonToken(VAR, rdfTermVar));  $triplesSameSubject_::separator = " .&#xA;";} propertyListNotEmpty_
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
	             $bc
	            ) 
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME[validSubjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
               ^(T_PAR propertyListNotEmpty_)
                QSTRING[""]
              )
            )
          )
      | cvar=constructVar { $triplesSameSubject_::subject = new CommonTree(new CommonToken(VAR, rdfTermVar));  
                            $triplesSameSubject_::separator = " .&#xA;";} 
        propertyListNotEmpty_
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
              $cvar
            )
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME[validSubjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
               ^(T_PAR propertyListNotEmpty_)
                QSTRING[""]
              )
            )
          )
      | f=enclosedExpr 
        { $triplesSameSubject_::subject = new CommonTree(new CommonToken(VAR, rdfTermVar));  
          $triplesSameSubject_::separator = " .&#xA;"; } 
        propertyListNotEmpty_
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
              ^(T_FUNCTION_CALL
           NCNAME[bindingTermFunction]
           ^(T_PARAMS 
              $f
            )
          )
            )
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME[validSubjectFunction] ^(T_PARAMS  VAR[rdfTermVar]))
               ^(T_PAR propertyListNotEmpty_)
                QSTRING[""]
              )
            )
          )
      | c=iriConstruct 
        { $triplesSameSubject_::subject = new CommonTree(new CommonToken(VAR, rdfTermVar));  
          $triplesSameSubject_::separator = " .&#xA;"; } 
        propertyListNotEmpty_
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
              ^(T_FUNCTION_CALL
                NCNAME["xsparql:createURI"]
                ^(T_PARAMS 
                  $c
                  )
               )
            )
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME[validSubjectFunction] ^(T_PARAMS  VAR[rdfTermVar]))
               ^(T_PAR propertyListNotEmpty_)
                QSTRING[""]
              )
            )
          )
      | g=collection             {$triplesSameSubject_::subject = $g.tree;  $triplesSameSubject_::separator = " .&#xA;";} propertyListNotEmpty_
//      | o=collection             {$triplesSameSubject_::subject = $o.tree;} propertyListNotEmpty_?

      | (h=T_ANON_BLANK|h=T_EMPTY_ANON_BLANK) {$triplesSameSubject_::subject = new CommonTree(new CommonToken(QSTRING, ""));  $triplesSameSubject_::separator = " ; ";} propertyListNotEmpty_
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
              ^(T_PAR propertyListNotEmpty_)
            )
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME["fn:not"] ^(T_PARAMS ^(T_FUNCTION_CALL NCNAME["fn:empty"] ^(T_PARAMS VAR[rdfTermVar]))))
                ^(T_PAR QSTRING["["] ^(XPATH VAR[rdfTermVar] LBRACKET["["] ^(LT["lt"] ^(T_FUNCTION_CALL NCNAME["fn:position"] ^(T_PARAMS))  ^(T_FUNCTION_CALL NCNAME["fn:last"] ^(T_PARAMS))) RBRACKET["]"] ) QSTRING[" ] .&#xA;"])
                QSTRING[""]
              )
            )
          )
      )
    )
  ;

constructVar
@init {
  String rdftermvar = "";
}
  : var=VAR { rdftermvar = $var.text; } 
  -> {isBound(rdftermvar, Types.SPARQL)}? VAR[$var.token, rdftermvar]
  -> ^(T_FUNCTION_CALL NCNAME[bindingTermFunction] 
       ^(T_PARAMS
            $var 
      )
    )
  ;

propertyListNotEmpty_
  : v+=verbObjectList_+
  -> $v+
  ;

verbObjectList_
scope {
  CommonTree verb;
}// TODO add other verb_ alternatives
@init {
  String rdfTermVar = getNewTempRdfTermVariable();
}
  : ^(T_VERB ve=verb_ {$verbObjectList_::verb = $ve.tree;} objectList_) // put action code immediately after variable assignment
  -> objectList_
  | ^(T_VERB irix=iriConstruct {$verbObjectList_::verb = new CommonTree(new CommonToken(VAR, rdfTermVar));} objectList_)
  -> ^(T_FLWOR
       ^(T_LET
          VAR[rdfTermVar]
          ^(T_FUNCTION_CALL
           NCNAME["xsparql:createURI"]
           ^(T_PARAMS 
              $irix
            )
          )
        )
       ^(T_RETURN
         ^(IF
           ^(T_FUNCTION_CALL NCNAME[validPredicateFunction] ^(T_PARAMS VAR[rdfTermVar]))
           ^(T_PAR objectList_)
            QSTRING[""]
          )
        )
      )
  // to be removed? no literals in predicate position
  | ^(T_VERB v=constructVar {$verbObjectList_::verb = new CommonTree(new CommonToken(VAR, rdfTermVar));} objectList_)
      -> ^(T_FLWOR
           ^(T_LET
              VAR[rdfTermVar]
                $v
            )
           ^(T_RETURN
             ^(IF
               ^(T_FUNCTION_CALL NCNAME[validPredicateFunction] ^(T_PARAMS VAR[rdfTermVar]))
               ^(T_PAR objectList_)
               QSTRING[""]
              )
            )
          )
  ;

propertyListNotEmpty
options {
backtrack=true;
}
  : ^(T_VERB v1=verb o1=objectList) (^(T_VERB v+=verb o+=objectList))*
  -> $v1 QSTRING[" "]  $o1 (QSTRING[" ; \n"] $v QSTRING[" "]  $o)*
  ;

propertyList
  : propertyListNotEmpty?
  ;

propertyList_
  : propertyListNotEmpty_?
  ;

objectList_
  : ^(T_OBJECT o1=object_) (^(T_OBJECT o+=object_))*
  -> $o1 ($o)*
  ;

objectList
  : ^(T_OBJECT o1=object) (^(T_OBJECT o+=object))*
  -> $o1 (QSTRING[" , "] $o)*
  ;

subject_
  : //VAR
  //| sparqlPrefixedName
  //| IRIREF
   verb_
  //| iriConstruct
//  | blankConstruct
//  | enclosedExpr
  ;

subject
  : resource
  | i=IRIREF
  -> QSTRING[$i.token, $i.text]
  | blank
  -> QSTRING["[]"]
  ;

resource
@init {
  String rdftermvar = "";
  logger.info("resource");
}
  : p=PNAME_LN
  -> QSTRING[$p.token, $p.text]
  | s=PNAME_NS
  -> QSTRING[$s.token, $s.text]
  | var=VAR //var.text has a leading dollar sign
  -> {isBoundEarlier($var.text, Types.SPARQL) && $VariableScope::scopedDataset}? { addJoinVar(QSTRING, $var.text) }
  -> {isBoundEarlier($var.text, Types.XQUERY) && $VariableScope::scopedDataset}? { addJoinVar(QSTRING, $var.text) }
  -> {isBoundEarlier($var.text, Types.SPARQL)}? ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS $var))
  -> {isBoundEarlier($var.text)}? ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS ^(T_FUNCTION_CALL NCNAME[bindingTermFunction] ^(T_PARAMS $var))))
  -> QSTRING[$var.token, $var.text  ]
  ;

verb
  : resource
  | a=A -> QSTRING[$a.token, " " + $a.text + " "]
  ;

verb_
  : sparqlPrefixedName
  | i=IRIREF -> QSTRING[$i.token, $i.text]
  | a=A -> QSTRING[$a.token, $a.text]
  //| iriConstruct // moved up
  ;

object_
@init {
  String rdfTermVar = getNewTempRdfTermVariable();
}
  : s=verb_ n=nquad?
    -> {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] $s $n? QSTRING[$triplesSameSubject_::separator]

  | cvar=constructVar n=nquad?
    -> ^(T_FLWOR
      ^(T_LET
        VAR[rdfTermVar]
            $cvar
      )
      ^(T_RETURN
        ^(IF
          ^(T_FUNCTION_CALL NCNAME[validObjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
          ^(T_PAR ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] 
                    ^(T_PARAMS {new CommonTree($triplesSameSubject_::subject)})
                  )
                  QSTRING[" "] 
                  ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] 
                    ^(T_PARAMS {new CommonTree($verbObjectList_::verb)})
                  ) 
                  QSTRING[" "] 
                  ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS VAR[rdfTermVar]))
                  $n?
                  QSTRING[$triplesSameSubject_::separator]
          )
          QSTRING[""]
        )
      )
    )
  | bb=bnode n=nquad?
  ->  ^(T_FLWOR
        ^(T_LET
           VAR[rdfTermVar]
          ^(T_FUNCTION_CALL
             NCNAME[bindingTermFunction]
            ^(T_PARAMS 
              ^(T_FUNCTION_CALL
                 NCNAME[serializeFunction]
                ^(T_PARAMS 
                  ^(T_PAR
                     QSTRING[$bb.text]
                     {getPositionVarList()}
                   ) 
                 )
               )
             )
           )
         )
         ^(T_RETURN
           ^(IF
             ^(T_FUNCTION_CALL NCNAME[validObjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
             ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] VAR[rdfTermVar] $n? QSTRING[$triplesSameSubject_::separator])
              QSTRING[""]
            )
          )
        )
  | rdfLiteral n=nquad?
  -> ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] rdfLiteral $n? QSTRING[$triplesSameSubject_::separator])
  | sNumericLiteral n=nquad?
  -> ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] sNumericLiteral $n? QSTRING[$triplesSameSubject_::separator])
  | b=blankConstruct n=nquad?
  -> ^(T_FLWOR
         ^(IF
           ^(T_FUNCTION_CALL NCNAME[validObjectFunction] ^(T_PARAMS $b))
           ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS $b)) $n? QSTRING[$triplesSameSubject_::separator])
            QSTRING[""]
          )
      )
  | literalConstruct n=nquad?
  -> ^(T_FLWOR
       ^(T_LET
          VAR[rdfTermVar]
          literalConstruct
        )
       ^(T_RETURN
         ^(IF
           ^(T_FUNCTION_CALL NCNAME[validObjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
           ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS VAR[rdfTermVar])) $n? QSTRING[$triplesSameSubject_::separator])
            QSTRING[""]
          )
        )
      )
  | irix=iriConstruct n=nquad?
  -> ^(T_FLWOR
       ^(T_LET
          VAR[rdfTermVar]
          ^(T_FUNCTION_CALL
           NCNAME["xsparql:createURI"]
           ^(T_PARAMS 
              $irix
            )
          )
        )
       ^(T_RETURN
         ^(IF
           ^(T_FUNCTION_CALL NCNAME[validObjectFunction] ^(T_PARAMS VAR[rdfTermVar]))
           ^(T_PAR ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS {new CommonTree($triplesSameSubject_::subject)})) QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS VAR[rdfTermVar])) $n? QSTRING[$triplesSameSubject_::separator])
            QSTRING[""]
          )
        )
      )
  | collection
  -> ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" "] collection)
  | T_ANON_BLANK propertyListNotEmpty_
  -> ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" [ "]  ^(XPATH ^(T_PAR propertyListNotEmpty_) LBRACKET["["] ^(LT["lt"] ^(T_FUNCTION_CALL NCNAME["fn:position"] ^(T_PARAMS))  ^(T_FUNCTION_CALL NCNAME["fn:last"] ^(T_PARAMS))) RBRACKET["]"])  QSTRING[" ] "]  QSTRING[$triplesSameSubject_::separator])
  | T_EMPTY_ANON_BLANK propertyListNotEmpty_
  -> ^(T_PAR {new CommonTree($triplesSameSubject_::subject)} QSTRING[" "] {new CommonTree($verbObjectList_::verb)} QSTRING[" [ ]"] propertyListNotEmpty_  QSTRING[$triplesSameSubject_::separator])
  ;


nquad
  : 
   (irix=iri | lit=literal_) 
  ->
         ^(IF
           ^(T_FUNCTION_CALL NCNAME[validObjectFunction] ^(T_PARAMS ^(T_FUNCTION_CALL  NCNAME[bindingTermFunction] ^(T_PARAMS $irix? $lit?))))
           ^(T_PAR QSTRING[" "] ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS ^(T_FUNCTION_CALL  NCNAME[bindingTermFunction] ^(T_PARAMS $irix? $lit?)))))
            QSTRING[""]
          )
  ;

literal_
  :  literalConstruct
  |  rdfLiteral
  ;

object
  : resource
  | blank
  -> QSTRING["[]"]
  | rdfLiteral
  | sNumericLiteral
  | triplesNode
  ;

triplesNode
  : collection
  | blankNodePropertyList
  ;

triplesNode_
  : collection
  | blankNodePropertyList_
  ;

blankNodePropertyList
  : T_ANON_BLANK propertyListNotEmpty
  -> QSTRING["["] propertyListNotEmpty QSTRING["]"]
  ;

blankNodePropertyList_
  : T_ANON_BLANK propertyListNotEmpty_
  ;

collection
  : LPAR graphNode+ RPAR
  ;

graphNode
  : varOrTerm
  | triplesNode
  ;

varOrTerm
  : VAR
  | graphTerm
  ;

literalConstruct
  : ^(T_LITERAL_CONSTRUCT e1=enclosedExpr at=AT e2=enclosedExpr)
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS 
          QSTRING[""]
          $e1
          $e2
          QSTRING[""]
        )
      )
  | ^(T_LITERAL_CONSTRUCT enclosedExpr c1=CARET c2=CARET iri)
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS
          QSTRING[""]
          enclosedExpr
          QSTRING[""]
          iri
        )
      )
  | ^(T_LITERAL_CONSTRUCT INTEGER AT enclosedExpr)
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS 
          QSTRING[""]
          INTEGER
          enclosedExpr
          QSTRING["\"\""] 
        )
      )
  | ^(T_LITERAL_CONSTRUCT INTEGER CARET CARET iriConstruct)
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS
          QSTRING[""]
          INTEGER
          QSTRING[""]
          iriConstruct
        )
      )

  | ^(T_LITERAL_CONSTRUCT QSTRING AT enclosedExpr)
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS 
          QSTRING[""]
          QSTRING
          enclosedExpr
          QSTRING[""]
        )
      )
  | ^(T_LITERAL_CONSTRUCT QSTRING c1=CARET c2=CARET iriConstruct )
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS 
          QSTRING[""]
          QSTRING
          QSTRING[""]
          iriConstruct
        )
      )
  | ^(T_LITERAL_CONSTRUCT enclosedExpr)
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS 
          enclosedExpr 
        )
      )
  ;

varOrIRIref
  : VAR
  | iRIref
  ;

iriConstruct
  : ^(T_IRI_CONSTRUCT
      (l=LESSTHANLCURLY expr r=RCURLYGREATERTHAN
      ->      expr
      | e1=enclosedExpr
        (c=COLON
          (e2=enclosedExpr
            -> ^(T_FUNCTION_CALL
                 NCNAME[serializeFunction]
                 ^(T_PARAMS ^(T_PAR $e1 QSTRING[$c.token, $c.text] $e2))
                )
//           | q=qname
//             -> ^(T_FUNCTION_CALL
//                  NCNAME[serializeFunction]
//                  ^(T_PARAMS ^(T_PAR enclosedExpr QSTRING[$c.token, $c.text] QSTRING[$q.text]))
//                 )
          )
        | q=qname 
          -> ^(T_FUNCTION_CALL
               NCNAME[serializeFunction]
               ^(T_PARAMS ^(T_PAR enclosedExpr QSTRING[$q.text]))
              )
        )
      | q=qname c=COLON enclosedExpr
      -> ^(T_FUNCTION_CALL
           NCNAME[serializeFunction]
           ^(T_PARAMS ^(T_PAR QSTRING[$q.text] QSTRING[$c.token, $c.text] enclosedExpr))
          )
      )
    )
  ;

graphTerm
  : iRIref
  | rdfLiteral
  | sNumericLiteral
  | booleanLiteral
  ;

blankConstruct
  : b=BNODE_CONSTRUCT enclosedExpr 
  -> ^(T_FUNCTION_CALL
        NCNAME[bindingTermFunction]
       ^(T_PARAMS 
          QSTRING[$b.token, $b.text] 
          enclosedExpr
          QSTRING[""]
          QSTRING[""]
        )
      )
  ;

expression
  : conditionalOrExpression
  ;

conditionalOrExpression
  : conditionalAndExpression
  | ^(o=ORSYMBOL conditionalOrExpression conditionalAndExpression)
  -> conditionalOrExpression QSTRING[$o.token, " "+$o.text+" "] conditionalAndExpression
  ;

conditionalAndExpression
  : valueLogical
  | ^(a=ANDSYMBOL conditionalAndExpression valueLogical)
  -> conditionalAndExpression QSTRING[$a.token, " &amp;&amp; "] valueLogical
  ;

valueLogical
  : relationalExpression
  ;

relationalExpression
  : numericExpression
  | ^((o=EQUALS | o=HAFENEQUALS | o=LESSTHAN |o=GREATERTHAN | o=LESSTHANEQUALS | o=GREATERTHANEQUALS) numericExpression numericExpression)
  -> numericExpression QSTRING[$o.token, $o.text] numericExpression
  ;

numericExpression
  : additiveExpression
  ;

additiveExpression
  : multiplicativeExpression
  | ^((o=PLUS | o=MINUS) additiveExpression multiplicativeExpression)
  -> additiveExpression QSTRING[$o.token, $o.text]  multiplicativeExpression
  ;

multiplicativeExpression
  : unaryExpression
  | ^((o=STAR | o=SLASH) multiplicativeExpression unaryExpression)
  -> multiplicativeExpression QSTRING[$o.token, $o.text] unaryExpression
  ;

unaryExpression
  : n=NOT primaryExpression
  -> QSTRING[$n.token, $n.text] primaryExpression
  | p=PLUS primaryExpression
    -> QSTRING[$p.token, $p.text] primaryExpression
  | m=MINUS primaryExpression
    -> QSTRING[$m.token, $m.text] primaryExpression
  | primaryExpression
  ;

primaryExpression
@init { String rdftermvar = ""; }
  : brackettedExpression
  | builtInCall
  | iRIrefOrFunction
  | rdfLiteral
  | sNumericLiteral
  | booleanLiteral
  //| BLANK_NODE_LABEL // added in the implementation
  //| LBRACKET RBRACKET // added in the implementation
  | var=VAR 
  -> {isBoundEarlier($var.text, Types.SPARQL)}? ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS $var))
  -> {isBoundEarlier($var.text)}? ^(T_FUNCTION_CALL NCNAME[rdfTermFunction] ^(T_PARAMS ^(T_FUNCTION_CALL NCNAME[bindingTermFunction] ^(T_PARAMS $var))))
  -> QSTRING[$var.token, $var.text  ]
  ;

brackettedExpression
  : l=LPAR expression r=RPAR
  -> QSTRING[$l.token, $l.text] expression QSTRING[$r.token, $r.text]
  ;

builtInCall
  : s=STR brackettedExpression
  -> QSTRING[$s.token, $s.text] brackettedExpression
  | l=LANG brackettedExpression
  -> QSTRING[$l.token, $l.text] brackettedExpression
  | lm=LANGMATCHES l1=LPAR e1=expression c=COMMA e2=expression r1=RPAR
  -> QSTRING[$lm.token, $lm.text] QSTRING[$l1.token, $l1.text] $e1 QSTRING[$c.token, $c.text] $e2 QSTRING[$r1.token, $r1.text]
  | d=DATATYPE brackettedExpression
  -> QSTRING[$d.token, $d.text] brackettedExpression
  | bo=BOUND l2=LPAR v=VAR r2=RPAR
  -> QSTRING[$bo.token, $bo.text] QSTRING[$l2.token, $l2.text] QSTRING[$v.token, $v.text] QSTRING[$r2.token, $r2.text]
  | i=ISIRI brackettedExpression
  -> QSTRING[$i.token, $i.text] brackettedExpression
  | u=ISURI brackettedExpression
  -> QSTRING[$u.token, $u.text] brackettedExpression
  | b=ISBLANK brackettedExpression
  -> QSTRING[$b.token, $b.text] brackettedExpression
  | lit=ISLITERAL brackettedExpression
  -> QSTRING[$lit.token, $lit.text] brackettedExpression
  | regexExpression
  ;

regexExpression
  : r=REGEX l=LPAR e1=expression c1=COMMA e2=expression (c2=COMMA  e3=expression)? r1=RPAR
  -> QSTRING[$r.token, " " + $r.text] QSTRING[$l.token, $l.text] $e1 QSTRING[$c1.token, $c1.text] $e2 (QSTRING[$c2.token, $c2.text]  $e3)? QSTRING[$r1.token, $r1.text] 
  ;

iRIrefOrFunction
  : ^(T_FUNCTION_CALL i=iRIref ^(T_PARAMS arglist?)) -> QSTRING[$i.text] QSTRING["("] arglist? QSTRING[")"]
  ;

rdfLiteral
  : q=QSTRING -> QSTRING[$q.token, "\"\""+$q.text+"\"\""]
  | q=QSTRING AT qname -> QSTRING[$q.token, "\"\""+$q.text+"\"\""] AT qname
  | q=QSTRING c1=CARET c2=CARET ( o=IRIREF |  o=PNAME_LN)  
  -> QSTRING[$q.token, "\"\""+$q.text+"\"\""] QSTRING[$c1.token, "^^"] QSTRING[$o.token, $o.text]
  ;

sNumericLiteral
  : INTEGER
  ;

booleanLiteral
  : t=TRUE -> QSTRING[$t.token, $t.text]
  | f=FALSE -> QSTRING[$f.token, $f.text]
  ;

// string
//   : STRING_LITERAL1
//   | STRING_LITERAL2
//   | STRING_LITERAL_LONG1
//   | STRING_LITERAL_LONG2
//   ;
string
  : QSTRING 
//  : STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2;
  ;

iRIref
  : IRIREF
  | prefixedName
  ;

prefixedName
  : PNAME_LN
  | PNAME_NS
  ;

blank
  : bnode
  | T_EMPTY_ANON_BLANK
  -> QSTRING["[]"]
  ;

// $>

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

predicateObjectList
  : (^(T_VERB verb objectList))+
  ;

iri
  :  p=PNAME_LN  -> QSTRING[$p.text]
  |  i=IRIREF    -> QSTRING[$i.text]
  |  iriConstruct
  ;

resource_
  : sparqlPrefixedName
  | VAR
  | IRIREF
  ;

rdfPredicate_
  : resource_
  ;

bnode
  : BLANK_NODE_LABEL
  ;

sparqlPrefixedName
  : p=PNAME_LN  -> QSTRING[$p.token, $p.text]
  | p=PNAME_NS  -> QSTRING[$p.token, $p.text]
  ;


qname
  : prefixedName
  | unprefixedName
  ;

keyword
  : ITEM
  | t=TO -> NCNAME[$t.text]
  | f=FROM -> NCNAME[$f.text]
  | r=ROW -> NCNAME[$r.text]
  | c=COMMENT -> NCNAME[$c.text]
  | n=NODE -> NCNAME[$n.text]
  | A; // add all the other keywords?

unprefixedName
  : localPart
  ;

localPart
  : NCNAME
  | keyword
  ;

//EOF

