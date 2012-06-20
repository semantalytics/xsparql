/**
 * 
 */
package org.deri.xsparql;

import net.sf.saxon.Configuration;
import net.sf.saxon.Query;
import net.sf.saxon.trans.CommandLineOptions;

import org.deri.xquery.saxon.createNamedGraphExtFunction;
import org.deri.xquery.saxon.createScopedDatasetExtFunction;
import org.deri.xquery.saxon.deleteNamedGraphExtFunction;
import org.deri.xquery.saxon.deleteScopedDatasetExtFunction;
import org.deri.xquery.saxon.jsonDocExtFunction;
import org.deri.xquery.saxon.scopedDatasetPopResultsExtFunction;
import org.deri.xquery.saxon.sparqlQueryExtFunction;
import org.deri.xquery.saxon.sparqlQueryTDBExtFunction;
import org.deri.xquery.saxon.sparqlScopedDatasetExtFunction;
import org.deri.xquery.saxon.turtleGraphToURIExtFunction;

/**
 * @author nl
 *
 */
public class XSQuery extends Query {

    /**
     * 
     */
    public XSQuery() {
	super();
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
	new XSQuery().doQuery(args, "org.deri.xsparql.XSQuery");
    }
    
public void applyLocalOptions(CommandLineOptions options, Configuration config) {
	super.applyLocalOptions(options, config);

	try { 
	    config.registerExtensionFunction(new sparqlQueryExtFunction());
	    config.registerExtensionFunction(new turtleGraphToURIExtFunction());
	    config.registerExtensionFunction(new createScopedDatasetExtFunction());
	    config.registerExtensionFunction(new sparqlScopedDatasetExtFunction());
	    config.registerExtensionFunction(new deleteScopedDatasetExtFunction());
	    config.registerExtensionFunction(new scopedDatasetPopResultsExtFunction());
	    config.registerExtensionFunction(new jsonDocExtFunction());
	    config.registerExtensionFunction(new createNamedGraphExtFunction());
	    config.registerExtensionFunction(new deleteNamedGraphExtFunction());
	    config.registerExtensionFunction(new sparqlQueryTDBExtFunction());
        } catch (Exception ex) {
            throw new IllegalArgumentException();
	}
	    
//	// RDB functions
//	proc.registerExtensionFunction(new sqlQueryExtFunction());
//	proc.registerExtensionFunction(new getRDBTablesExtFunction());
//	proc.registerExtensionFunction(new getRDBTableAttributesExtFunction());


    }

}
