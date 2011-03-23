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
package org.deri.xsparql;

import org.antlr.runtime.tree.*;

/**
 * class of scopedDatasets for the parser.
 * 
 * @author Nuno Lopes <nuno.lopes@deri.org>
 * 
 */
public class ScopedDataset {

    private boolean scopedDataset;

    private String id;

    private CommonTree sparqlFunctionTree;
    private CommonTree sparqlResultsFunctionTree;
    private CommonTree sparqlResultsIdTree;

    private String posVar;

    /**
     * Creates a new <code>ScopedDataset</code> instance.
     * 
     * @param scoped
     *            determines if the instance referes to a scoped dataset
     * @param i
     *            identifier of the scoped dataset
     * @param sf
     *            SPARQL function to be called
     * @param sr
     *            SPARQL results function to be called
     * @param idTree
     *            results of the SPARQL call
     * @param pos
     *            position we are processing
     */
    public ScopedDataset(boolean scoped, String i, CommonTree sf,
	    CommonTree sr, CommonTree idTree, String pos) {
	scopedDataset = scoped;
	id = i;
	sparqlFunctionTree = sf;
	sparqlResultsFunctionTree = sr;
	sparqlResultsIdTree = idTree;
	posVar = pos;
    }

    /**
     * Indicates if the current Dataset refers to a scoped dataset
     * 
     * @return a <code>boolean</code> value
     */
    public boolean isScopedDataset() {
	return scopedDataset;
    }

    /**
     * returns the id string of the current dataset
     * 
     * @return a <code>String</code> value
     */
    public String getId() {
	return id;
    }

    /**
     * returns the Abstract Tree refering to the SPARQL function to be called.
     * 
     * @return a <code>CommonTree</code> value
     */
    public CommonTree getFunctionTree() {
	return sparqlFunctionTree;
    }

    /**
     * changes the Abstract Tree refering to the SPARQL function to be called.
     * 
     * @param t
     *            a <code>CommonTree</code> value
     */
    public void setFunctionTree(CommonTree t) {
	sparqlFunctionTree = t;
    }

    /**
     * returns the Abstract Tree refering to the SPARQL function to be called.
     * 
     * @return a <code>CommonTree</code> value
     */
    public CommonTree getResultsTree() {
	return sparqlResultsFunctionTree;
    }

    /**
     * returns the Abstract Tree refering to the SPARQL results function to be
     * called.
     * 
     * @param t
     *            a <code>CommonTree</code> value
     */
    public void setResultsTree(CommonTree t) {
	sparqlResultsFunctionTree = t;
    }

    /**
     * returns the Abstract Tree refering to the SPARQL results.
     * 
     * @return a <code>CommonTree</code> value
     */
    public CommonTree getIdTree() {
	return sparqlResultsIdTree;
    }

    /**
     * changes the Abstract Tree refering to the SPARQL results.
     * 
     * @param t
     *            a <code>CommonTree</code> value
     */
    public void setIdTree(CommonTree t) {
	sparqlResultsIdTree = t;
    }

    /**
     * returns the current position of the results being processed.
     * 
     * @return a <code>String</code> value
     */
    public String getVar() {
	return posVar;
    }

}
