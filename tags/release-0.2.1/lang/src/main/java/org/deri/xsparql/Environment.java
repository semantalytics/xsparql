/**
 *
 * Copyright (C) 2011, NUI Galway.
 * All rights reserved.
 *
 * The software in this package is published under the terms of the BSD style license a copy of which has been included
 * with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
 * http://www.deri.ie/publications/tools/bsd_license.txt
 *
 * Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
 * NUI Galway.
 */
/**
 * 
 */
package org.deri.xsparql;

import java.util.*;
import java.util.logging.Logger;

import org.antlr.runtime.tree.CommonTree;

/**
 * Environment providing information and keeping track of bound variables
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 * 
 */
class Environment {
    private static final Logger logger = Logger
	    .getLogger(XSPARQLProcessor.class.getClass().getName());

    private final Stack<List<String>> scopeStack = new Stack<List<String>>();
    private List<String> currentScope = new LinkedList<String>();

    /**
     * Creates an environment, containing a scope for global variables
     */
    Environment() {
    }

    /**
     * Create a new binding scope
     */
    void newScope() {
	logger.entering(this.getClass().getCanonicalName(), "newScope");
	scopeStack.push(currentScope);
	currentScope = new LinkedList<String>();
    }

    /**
     * Add a variable to the current scope of the environment
     * 
     * @param variable
     */
    void addVarToCurrentScope(final String variable) {
	logger.entering(this.getClass().getCanonicalName(),
		"addVarToCurrentScope", variable);
	currentScope.add(variable);
    }

    /**
     * Adds a list of variables (given as CommonTree) No generics syntax used,
     * because ANTLR doesn't generate Java 5 code Note that this method will
     * brutally fail when another list is given
     * 
     * @param variables
     *            A List of org.antlr.runtime.tree.CommonTree
     */
    void addVarsToCurrentScope(final List<?> variables) {
	for (Object o : variables) {
	    final CommonTree tree = (CommonTree) o;

	    addVarToCurrentScope(tree.getText());
	}
    }

    /**
     * Add all the introduced variables of a Sparql variable to the current
     * scope
     * 
     * @param variable
     */
    void addSparqlVarToCurrentScope(final String variable) {
	logger.entering(this.getClass().getCanonicalName(),
		"addSparqlVarToCurrentScope", variable);
	final String varName = Helper.removeLeading(variable, "$");
	addVarToCurrentScope("$_" + varName + "_Node");
	addVarToCurrentScope(variable);
	addVarToCurrentScope("$_" + varName + "_NodeType");
	addVarToCurrentScope("$_" + varName + "_NodeDatatype");
	addVarToCurrentScope("$_" + varName + "_NodeLang");
	addVarToCurrentScope("$_" + varName + "_RDFTerm");

    }

    /**
     * Execute addSparqlVarToCurrentScope(String variables) for a list of
     * variables
     * 
     * @param variables
     *            A List of org.antlr.runtime.tree.CommonTree
     */
    void addSparqlVarsToCurrentScope(final List<?> variables) {
	for (Object o : variables) {
	    final CommonTree tree = (CommonTree) o;

	    addSparqlVarToCurrentScope(tree.getText());
	}
    }

    /**
     * Remove the current scope from the environment
     */
    void removeCurrentScope() {
	logger.entering(this.getClass().getCanonicalName(),
		"removeCurrentScope");
	// TEMPORARILY: enable it again when the scoping works correctly
	// if(!scopeStack.empty()) {
	// currentScope = scopeStack.pop();
	// } else {
	// // This is probably an error
	// currentScope.clear();
	// }
    }

    /**
     * Does the environment contain the variable? Intentionally don't look in
     * the current scope
     * 
     * @param variable
     * @return
     */
    boolean containsVar(final String variable) {
	logger.entering(this.getClass().getCanonicalName(), "containsVar",
		variable);
	for (List<String> scope : scopeStack) {
	    if (scope.contains(variable)) {
		logger.exiting(this.getClass().getCanonicalName(),
			"containsVar", "true");
		return true;
	    }
	}

	logger.exiting(this.getClass().getCanonicalName(), "containsVar",
		"false");
	return false;
    }

    /**
     * Does the environment or the current scope contain the variable?
     * Intentionally don't look in the current scope
     * 
     * @param variable
     * @return
     */
    boolean containsVar1(final String variable) {
	logger.entering(this.getClass().getCanonicalName(), "containsVar1",
		variable);

	if (this.currentScope.contains(variable)) {
	    logger.exiting(this.getClass().getCanonicalName(), "containsVar",
		    "true");
	    return true;
	} else {
	    logger.exiting(this.getClass().getCanonicalName(), "containsVar");
	    return this.containsVar(variable);
	}
    }
}
