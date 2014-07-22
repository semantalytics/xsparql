package org.sourceforge.xsparql.sparql;

import java.util.Set;

import net.sf.saxon.lib.ExtensionFunctionDefinition;

public interface SparqlFunctionBinder {
	public ExtensionFunctionDefinition getSparqlQueryExtFunctionDefinition();
	public ExtensionFunctionDefinition getCreateScopedDatasetExtFunctionDefinition();
	public ExtensionFunctionDefinition getDeleteScopedDatasetExtFunctionDefinition();
	public ExtensionFunctionDefinition getSparqlScopedDatasetExtFunctionDefinition();
	public ExtensionFunctionDefinition getScopedDatasetPopResultsExtFunctionDefinition();
	
	public DatasetManager getDatasetManager();
	
	public void setParameter(String key, String value) throws UnexpectedParameterException;
	
	public Set<ExtensionFunctionDefinition> getSparqlFunctionDefinitions();
}
