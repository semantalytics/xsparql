package org.sourceforge.xsparql.sparql.binder;

import java.util.HashSet;
import java.util.Set;

import net.sf.saxon.lib.ExtensionFunctionDefinition;

import org.sourceforge.xsparql.sparql.DatasetManager;
import org.sourceforge.xsparql.sparql.SparqlFunctionBinder;
import org.sourceforge.xsparql.sparql.UnexpectedParameterException;
import org.sourceforge.xsparql.sparql.arq.InMemoryDatasetManager;
import org.sourceforge.xsparql.xquery.saxon.arq.createScopedDatasetExtArqFunction;
import org.sourceforge.xsparql.xquery.saxon.arq.deleteScopedDatasetExtArqFunction;
import org.sourceforge.xsparql.xquery.saxon.arq.scopedDatasetPopResultsExtArqFunction;
import org.sourceforge.xsparql.xquery.saxon.arq.sparqlQueryExtArqFunction;
import org.sourceforge.xsparql.xquery.saxon.arq.sparqlScopedDatasetExtArqFunction;

public class StaticSparqlFunctionBinder implements SparqlFunctionBinder {

	private static final StaticSparqlFunctionBinder INSTANCE = new StaticSparqlFunctionBinder();
	
	public static StaticSparqlFunctionBinder getInstance(){
		return INSTANCE;
	}
	
	private StaticSparqlFunctionBinder(){}
	
	public ExtensionFunctionDefinition getSparqlQueryExtFunctionDefinition(){
		return new sparqlQueryExtArqFunction();
	}
	
	public ExtensionFunctionDefinition getCreateScopedDatasetExtFunctionDefinition(){
		return new createScopedDatasetExtArqFunction();
	}
	
	public ExtensionFunctionDefinition getDeleteScopedDatasetExtFunctionDefinition(){
		return new deleteScopedDatasetExtArqFunction();
	}
	
	public ExtensionFunctionDefinition getSparqlScopedDatasetExtFunctionDefinition(){
		return new sparqlScopedDatasetExtArqFunction();
	}
	
	public ExtensionFunctionDefinition getScopedDatasetPopResultsExtFunctionDefinition(){
		return new scopedDatasetPopResultsExtArqFunction();
	}
	
	public Set<ExtensionFunctionDefinition> getSparqlFunctionDefinitions(){
		final Set<ExtensionFunctionDefinition> defs = new HashSet<ExtensionFunctionDefinition>();
		defs.add(new sparqlQueryExtArqFunction());
		defs.add(new createScopedDatasetExtArqFunction());
		defs.add(new deleteScopedDatasetExtArqFunction());
		defs.add(new sparqlScopedDatasetExtArqFunction());
		defs.add(new scopedDatasetPopResultsExtArqFunction());

//		defs.add(new turtleGraphToURIExtFunction());
//		defs.add(new jsonDocExtFunction());
		return defs;
	}
	
	@Override
	public void setParameter(String key, String value)
			throws UnexpectedParameterException {
		throw new UnexpectedParameterException(key, value);
		
	}

	@Override
	public DatasetManager getDatasetManager() {
		return InMemoryDatasetManager.INSTANCE;
	}

}
