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
/**
 * 
 */
package org.deri.sql;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import org.apache.commons.codec.binary.Hex;
import org.deri.xsparql.rewriter.Helper;
import org.deri.xsparql.rewriter.Pair;
import org.deri.xsparql.rewriter.XSPARQLProcessor;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Class used to perform SQL queries via JDBC.
 * 
 * @author Nuno Lopes
 * 
 */
/**
 * @author nl
 * 
 */
public class SQLQuery {

    private Connection db;
    
    private String dbDriver;
    
    private final static Logger logger = Logger.getLogger(XSPARQLProcessor.class
	      .getClass().getName());


    // ----------------------------------------------------------------------------------------------------
    // SQL

    /**
     * Creates a new <code>SQLQuery</code> instance.
     * @param dbPasswd 
     * 
     */
    public SQLQuery(String driver, String dbServer, String dbPort, String database, String instance, String username, String password) {
	logger.info("dbDriver: " + driver + ", dbServer: " + dbServer + ", dbPort: " + dbPort + ", dbName: " + database + ", dbInstance: " + instance + ", dbUser: " + username + ", dbPass: " + password);

	if (driver == null || database == null || username == null) {
	    System.err.println("Missing database configuration information");
	    System.exit(1);
	}

        dbDriver = driver;
	
        if(dbServer == null) {
            dbServer = "localhost";
        }

        String connDriver = null;
	String connUrl = null;

	if (driver.equals("mysql")) {
	    if(dbPort == null) {
		dbPort = "3306";
	    }
          connDriver = "com.mysql.jdbc.Driver";
          connUrl = "jdbc:mysql://"+dbServer+":"+dbPort+"/" + database;
        } else if (driver.equals("psql")) {
	    if(dbPort == null) {
		dbPort = "3306";
	    }
          connDriver = "org.postgresql.Driver";
          connUrl = "jdbc:postgresql://"+dbServer+":"+dbPort+"/"+ database;
          connUrl = "jdbc:postgresql:"+ database;
        } else if (driver.equals("sqlserver")) {
	    if(dbPort == null) {
		dbPort = "1433";
	    }
          connDriver = "net.sourceforge.jtds.jdbc.Driver";
          connUrl = "jdbc:jtds:sqlserver://"+dbServer+":"+dbPort+"/" + database;
          if (instance != null) {
              connUrl+=";instance="+instance;
          }
        }
        
	logger.info("dbDriver: " + driver + ", dbServer: " + dbServer + ", dbPort: " + dbPort + ", dbName: " + database + ", dbInstance: " + instance + ", dbUser: " + username + ", dbPass: " + password);
	logger.info("connDriver: "+connDriver + ", connURL: "+connUrl);

        // load the driver
        try {
          Class.forName(connDriver);
        } catch (ClassNotFoundException cnfe) {
          System.err.println("Couldn't find driver class:");
          cnfe.printStackTrace();
          System.exit(1);
       } catch (Exception e) {
          System.err.println("Exception:" + e.getMessage());
          e.printStackTrace();
          System.exit(1);
        }
        
        try {
          // connect to the database
          db = DriverManager.getConnection(connUrl, username, password);
	} catch (Exception e) {
          System.err.println("Error connecting to the database: "+e.getMessage());
          System.exit(1);
	}
        
    }

    /**
     * Closes the connection to the database
     * 
     */
    public void close() {
	if (db != null) {
	    try {
		db.close();
	    } catch (SQLException e) {
		System.err.println(e.getMessage());
		System.exit(1);
	    }
	}
    }

    /**
     * Evaluates an SQL query.
     * 
     * @return XML ResultSet with the results of the query
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    public ResultSet getResults(String query) throws ClassNotFoundException {

	ResultSet res = null;
	
	try {
	    // create a statement that we can use later
	    Statement sql = db.createStatement();

	    // print the query to be executed
	    logger.info("Executing query: " + query);

	    // execute the query
	    res = sql.executeQuery(query);
	} catch (SQLException e) {
	    System.err.println("SQL ERROR: " + e.getMessage());
	    logger.info("SQL ERROR (getResults): " + e.getMessage());
	    System.exit(1);
	}
	
	return res;
    }

    /**
     * Evaluates a SQL query and return the XML format.
     * 
     * @return XML string with the results of the query
     */
    public String getResultsAsXMLString(String query) {

	OutputStream sb = new ByteArrayOutputStream();

	try {
	    ResultSet results = getResults(query);
	    ResultSetMetaData rsmd = results.getMetaData();
	    int columns = rsmd.getColumnCount();

	    XMLOutputFactory xof = XMLOutputFactory.newInstance();
	    XMLStreamWriter xtw;
	    xtw = xof.createXMLStreamWriter(sb, "UTF-8");

	    xtw.writeStartDocument("utf-8", "1.0");
	    xtw.writeStartElement("", "sql");
	    xtw.writeStartElement("", "results");

	    if (results != null) {
		while (results.next()) {
		    xtw.writeStartElement("", "result");
		    for (int i = 1; i <= columns; i++) {
			String label = rsmd.getColumnLabel(i);

                        label = "\""+label+"\"";

			int type = rsmd.getColumnType(i);
			xtw.writeStartElement("", "SQLbinding");

			xtw.writeAttribute("type", rsmd.getColumnTypeName(i));

			// split the label if of type relation.attributes
			xtw.writeAttribute("name", label);
			if (label.matches(".*\\..*")) {
			    String[] tokens = label.split("\\.");
			    xtw.writeAttribute("label", tokens[1]);
			}
			String value = results.getString(i);

			if (value != null) {
                           logger.info("OBJECT: "+value.toString()+ ", type: "+type);

//			    cf. http://docs.oracle.com/javase/6/docs/api/constant-values.html#java.sql.Types.ARRAY
//				-1             LONGVARCHAR	
//				-15            NCHAR		
//				-16            LONGNVARCHAR	
//				-2             BINARY		
//				-3             VARBINARY	
//				-4             LONGVARBINARY	
//				-5             BIGINT		
//				-6             TINYINT		
//				-7             BIT		
//				-8             ROWID		
//				-9             NVARCHAR	
//				0              NULL		
//				1              CHAR		
//				1111           OTHER		
//				12             VARCHAR		
//				16             BOOLEAN		
//				2              NUMERIC		
//				2000           JAVA_OBJECT	
//				2001           DISTINCT	
//				2002           STRUCT		
//				2003           ARRAY		
//				2004           BLOB		
//				2005           CLOB		
//				2006           REF		
//				2009           SQLXML		
//				2011           NCLOB		
//				3              DECIMAL		
//				4              INTEGER		
//				5              SMALLINT	
//				6              FLOAT		
//				7              REAL		
//				70             DATALINK	
//				8              DOUBLE		
//				91             DATE		
//				92             TIME		
//				93             TIMESTAMP	

			    switch (type) {
			    case java.sql.Types.BINARY:
			    case java.sql.Types.VARBINARY:
				// encode binary data in hex
				Hex h = new Hex();
				xtw.writeCData(new String(h.encode(results.getBytes(i)),"UTF-8").toUpperCase());
				break;
//			    case java.sql.Types.DATE:
//				xtw.writeCharacters(results.getDate(i).toString());
//				break;
			    case java.sql.Types.CHAR:  // MySQL does not pad 
			        if(dbDriver.equals("mysql")) {
			            xtw.writeCharacters(String.format("%1$-" + rsmd.getPrecision(i) + "s" , new String(value.getBytes(),"UTF-8")));
			        } else {
			            xtw.writeCharacters(new String(value.getBytes(),"UTF-8"));
			        }
			        break;
			    case java.sql.Types.TIMESTAMP:
				xtw.writeCharacters(new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss").format(results.getTimestamp(i)));
				break;
			    case java.sql.Types.BOOLEAN:
			    case java.sql.Types.BIT:
				xtw.writeCharacters(new Boolean(results.getBoolean(i)).toString());
				break;
			    case java.sql.Types.FLOAT:
			    case java.sql.Types.DECIMAL:
			    case java.sql.Types.REAL:
			    case java.sql.Types.DOUBLE:
				xtw.writeCharacters(new Float(results.getFloat(i)).toString());
				break;
			    case java.sql.Types.INTEGER:
			    case java.sql.Types.SMALLINT:
				xtw.writeCharacters(new Integer(results.getInt(i)).toString());
				break;
			    default:
				xtw.writeCharacters(new String(value.getBytes(),"UTF-8"));
			    }	
			}
			xtw.writeEndElement(); // </SQLbinding>
		    }
		    xtw.writeEndElement();
		}
	    }

	    xtw.writeEndElement(); // </results>
	    xtw.writeEndElement(); // </sql>
	    xtw.writeEndDocument(); // </document>

	    xtw.flush();
	    xtw.close();

	} catch (Exception e) {
	    System.err.println("SQL ERROR: " + e.getMessage());
	    logger.info("SQL ERROR (getResultsAsXMLString): " + e.getMessage());
	    System.exit(1);
	}

	String res = sb.toString();
//	logger.info("result XML: " + res);
	return res;
    }

    /**
     * Evaluates a SQL query and return the XML format.
     * 
     * @return XML string with the results of the query
     */
    public Document getResultsAsDocument(String query) {

//	OutputStream sb = new ByteArrayOutputStream();

	DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	DocumentBuilder builder = null;
	try {
	    builder = factory.newDocumentBuilder();
	} catch (ParserConfigurationException e1) {
	    e1.printStackTrace();
	}
	Document doc = builder.newDocument();

	try {
	    ResultSet results = getResults(query);
	    ResultSetMetaData rsmd = results.getMetaData();
	    int columns = rsmd.getColumnCount();

	    Element sqlXML = doc.createElement("sql");
	    doc.appendChild(sqlXML);

	    Element resultsXML = doc.createElement("results");
	    sqlXML.appendChild(resultsXML);

	    if (results != null) {
		while (results.next()) {
//		   Element resultXML = doc.createElement("result");
		    for (int i = 1; i <= columns; i++) {
			String label = rsmd.getColumnLabel(i);
			int type = rsmd.getColumnType(i);
			Element node      = doc.createElement(label);

			// split the label if of type relation.attributes
			if (label.matches(".*\\..*")) {
			    String[] tokens = label.split("\\.");
			    Attr name = doc.createAttribute("name");
			    name.setValue(tokens[1]);
			    node.setAttributeNode(name);
			}
			Object value = results.getObject(i);
			if (value != null) {
			    if (type == java.sql.Types.BINARY) {
				node.appendChild(doc.createCDATASection(value.toString()));
			    } else {
				node.appendChild(doc.createTextNode(value.toString()));
			    }	
			}
		    }
		}
	    }


	} catch (Exception e) {
	    System.err.println("SQL ERROR: " + e.getMessage());
	    logger.info("SQL ERROR (getResultsAsDocument): " + e.getMessage());
	    System.exit(1);
	}

	return doc;
    }

    
    public Document getResultsAsXML(String query) {
	String results = getResultsAsXMLString(query);
	return Helper.parseXMLString(results);
    }

    /**
     * Used in the XSPARQLRewriter.g
     * 
     */
    public List<String> getRelationAttributes(
	    List<Pair<String, String>> relation) {

	List<String> res = new LinkedList<String>();

	try {

	    DatabaseMetaData dbmd = db.getMetaData();

	    for (Pair<String, String> relAlias : relation) {
		ResultSet results = dbmd.getColumns(null, null,
			relAlias.getFirst(), null);

		while (results.next()) {
		    String alias = relAlias.getSecond() != null ? relAlias
			    .getSecond() : relAlias.getFirst();
		    res.add(alias + "." + results.getString("COLUMN_NAME"));
		}
	    }

	    if (res.size() == 0) {
		System.err.println("Unable to determine relation attributes");
		System.exit(1);
	    }

	} catch (Exception e) {
	    System.err.println(e.getMessage());
	    System.exit(1);
	}

	return res;

    }

    /**
     * Returns an XML string containing the attributes of the specified
     * relations.
     * 
     * @return XML string
     */
    public String getRelationInfoAsXMLString(List<String> relations) {

	OutputStream sb = new ByteArrayOutputStream();

	try {
	    XMLOutputFactory xof = XMLOutputFactory.newInstance();
	    XMLStreamWriter xtw;
	    xtw = xof.createXMLStreamWriter(sb);

	    DatabaseMetaData dbmd = db.getMetaData();

	    xtw.writeStartDocument("utf-8", "1.0");
	    xtw.writeStartElement("", "metadata");

	    // for each relation
	    for (String relationName : relations) {

		
		// strip " if capitalised 
		if (relationName.matches("\".*\"")) {
		    relationName=relationName.substring(1, relationName.length()-1);
		}
		
		ResultSet results = dbmd.getColumns(null, null, relationName, null);
		
		// get the primary keys of the relation
		ResultSet primaryKeys = dbmd.getPrimaryKeys(null, null,
			relationName);
		List<String> pks = new LinkedList<String>();
		while (primaryKeys.next()) {
		    String pk = primaryKeys.getString("COLUMN_NAME");
		    // if relation name is capitalised, add ""
                    pk = "\""+pk+"\"";
		    pks.add(pk);
		}

		// get the foreign keys of the relation
		ResultSet foreignKeys = dbmd.getImportedKeys(null, null,
			relationName);
		Map<String, Pair<String,String>> fks = new HashMap<String, Pair<String,String>>();
		xtw.writeStartElement("", "foreignKeys");

//		group the all the elements of the foreignKeys
		boolean firstElem = true;
		while (foreignKeys.next()) {
		    int pos = foreignKeys.getInt("KEY_SEQ");
		    
		    if (pos == 1) {
			if (!firstElem) {
			    xtw.writeEndElement();
			}
			xtw.writeStartElement("", "foreignKey");
			firstElem = false;
		    }

		    String attributeFK = foreignKeys.getString("FKCOLUMN_NAME");
		    // if relation name is capitalised, add ""
                    attributeFK = "\""+attributeFK+"\"";

                    xtw.writeStartElement("", "foreignKeyElem");
		    xtw.writeAttribute("name", attributeFK);

		    String fkTableName = foreignKeys.getString("PKTABLE_NAME");
		    // if relation name is capitalised, add ""
                    fkTableName = "\""+fkTableName+"\"";
		    String fkColumnName = foreignKeys
			    .getString("PKCOLUMN_NAME");
		    fkColumnName = "\""+fkColumnName+"\"";
		    fks.put(attributeFK, new Pair<String,String>(fkTableName, fkColumnName));

		    xtw.writeAttribute("foreignKeyTable", fkTableName);
		    xtw.writeAttribute("foreignKeyAttribute", fkColumnName);

		    xtw.writeEndElement();  // </foreignKeyElem>
		}	

		if(!firstElem) {
		    xtw.writeEndElement();  // </foreignKey>
		}
		xtw.writeEndElement();  // </foreignKeys>

		xtw.writeStartElement("", "columns");
		// iterate over the attributes
		while (results.next()) {
		    // determine the column alias
		    String columnName = results.getString("COLUMN_NAME");
		    // if relation name is capitalised, add ""
                    columnName = "\""+columnName+"\"";
		    xtw.writeStartElement("", "column");

		    // write the column type as an attribute
		    xtw.writeAttribute("name", columnName);

		    // write the column type as an attribute
		    xtw.writeAttribute("type", results.getString("TYPE_NAME"));

		    // is primary key?
		    if (pks.contains(columnName)) {
			xtw.writeAttribute("primaryKey", "true");
		    }

		    // is foreign key?
		    if (fks.containsKey(columnName)) {
			Pair<String, String> value = fks.get(columnName);
			xtw.writeAttribute("foreignKeyTable", value.getFirst());
			xtw.writeAttribute("foreignKeyAttribute", value.getSecond());
		    }

		    xtw.writeEndElement(); // </column>
		}
	    }

	    xtw.writeEndElement(); // </columns>

	    xtw.writeEndElement(); // </metadata>

	    xtw.flush();
	    xtw.close();

	} catch (Exception e) {
	    System.err.println(e.getMessage());
	    System.exit(1);
	}

	String res = sb.toString();
//	System.out.println(res);
	return res;

    }

    /**
     * Returns a list of String containing the relations present in the database
     * 
     * @return List of strings
     */
    public List<String> getRelations() {

	List<String> res = new LinkedList<String>();

	try {

	    DatabaseMetaData dbmd = db.getMetaData();

	    String[] types = { "TABLE" };
	    ResultSet results = dbmd.getTables(null, null, null, types);

	    while (results.next()) {
		String relationName = results.getString("TABLE_NAME");
		// if relation name is capitalised, add ""
                relationName = "\""+relationName+"\"";

		res.add(relationName);
	    }

	    if (res.size() == 0) {
		System.err.println("Unable to determine relation names");
		System.exit(1);
	    }

	} catch (Exception e) {
	    System.err.println(e.getMessage());
	    System.exit(1);
	}

	return res;

    }

    /**
     * Returns an XML string containing the relations present in the database
     * 
     * @return XML string
     */
    public String getRelationsAsXMLString() {

	List<String> results = getRelations();
	return createXMLString(results, "relations", "relation");

    }

    /**
     * creates an XML string from a list of string elements
     * 
     */
    private String createXMLString(List<String> results, String parent, String child) {

	OutputStream sb = new ByteArrayOutputStream();

	try {

	    XMLOutputFactory xof = XMLOutputFactory.newInstance();
	    XMLStreamWriter xtw;
	    xtw = xof.createXMLStreamWriter(sb);

	    xtw.writeStartDocument("utf-8", "1.0");
	    xtw.writeStartElement("", parent);

	    if (results != null) {
		for (String c : results) {
		    xtw.writeStartElement("", child);
		    xtw.writeCharacters(c);
		    xtw.writeEndElement(); // </child>
		}
	    }

	    xtw.writeEndElement(); // </parent>

	    xtw.flush();
	    xtw.close();

	} catch (XMLStreamException e) {
	    System.err.println("XML CREATION ERROR: " + e.getMessage());
	    System.exit(1);
	}

	return sb.toString();

    }

}
