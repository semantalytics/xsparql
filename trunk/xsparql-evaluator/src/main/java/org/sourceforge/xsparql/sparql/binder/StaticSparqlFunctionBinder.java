package org.sourceforge.xsparql.sparql.binder;

import java.util.HashSet;
import java.util.Set;

import net.sf.saxon.lib.ExtensionFunctionDefinition;

import org.sourceforge.xsparql.sparql.DatasetManager;
import org.sourceforge.xsparql.sparql.SparqlFunctionBinder;
import org.sourceforge.xsparql.sparql.UnexpectedParameterException;
import org.sourceforge.xsparql.xquery.saxon.createScopedDatasetExtFunction;
import org.sourceforge.xsparql.xquery.saxon.deleteScopedDatasetExtFunction;
import org.sourceforge.xsparql.xquery.saxon.scopedDatasetPopResultsExtFunction;
import org.sourceforge.xsparql.xquery.saxon.sparqlQueryExtFunction;
import org.sourceforge.xsparql.xquery.saxon.sparqlScopedDatasetExtFunction;

public class StaticSparqlFunctionBinder implements SparqlFunctionBinder{
	public static final StaticSparqlFunctionBinder INSTANCE = new StaticSparqlFunctionBinder();
	
	public static StaticSparqlFunctionBinder getInstance(){
		return INSTANCE;
	}
	
	private StaticSparqlFunctionBinder(){}
	
	public ExtensionFunctionDefinition getSparqlQueryExtFunctionDefinition(){
		return new sparqlQueryExtFunction();
	}
	
	public ExtensionFunctionDefinition getCreateScopedDatasetExtFunctionDefinition(){
		return new createScopedDatasetExtFunction();
	}
	
	public ExtensionFunctionDefinition getDeleteScopedDatasetExtFunctionDefinition(){
		return new deleteScopedDatasetExtFunction();
	}
	
	public ExtensionFunctionDefinition getSparqlScopedDatasetExtFunctionDefinition(){
		return new sparqlScopedDatasetExtFunction();
	}
	
	public ExtensionFunctionDefinition getScopedDatasetPopResultsExtFunctionDefinition(){
		return new scopedDatasetPopResultsExtFunction();
	}
	
	public Set<ExtensionFunctionDefinition> getSparqlFunctionDefinitions(){
		Set<ExtensionFunctionDefinition> defs = new HashSet<ExtensionFunctionDefinition>();
		defs.add(new sparqlQueryExtFunction());
		defs.add(new createScopedDatasetExtFunction());
		defs.add(new deleteScopedDatasetExtFunction());
		defs.add(new sparqlScopedDatasetExtFunction());
		defs.add(new scopedDatasetPopResultsExtFunction());

		return defs;
	}
	
	@Override
	public void setParameter(String key, String value)
			throws UnexpectedParameterException {
		throw new UnexpectedParameterException(key, value);
	}

	@Override
	public DatasetManager getDatasetManager() {
		return null;
	}
}
