package org.sourceforge.xsparql.sparql;

import java.util.Set;

import net.sf.saxon.lib.ExtensionFunctionDefinition;

public interface SparqlFunctionBinder {
	ExtensionFunctionDefinition getSparqlQueryExtFunctionDefinition();
	ExtensionFunctionDefinition getCreateScopedDatasetExtFunctionDefinition();
	ExtensionFunctionDefinition getDeleteScopedDatasetExtFunctionDefinition();
	ExtensionFunctionDefinition getSparqlScopedDatasetExtFunctionDefinition();
	ExtensionFunctionDefinition getScopedDatasetPopResultsExtFunctionDefinition();

	DatasetManager getDatasetManager();

	void setParameter(String key, String value) throws UnexpectedParameterException;

	Set<ExtensionFunctionDefinition> getSparqlFunctionDefinitions();
}
