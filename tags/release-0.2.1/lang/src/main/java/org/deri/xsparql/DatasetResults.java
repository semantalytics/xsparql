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

import java.util.*;
import com.hp.hpl.jena.query.*;

/**
 * class for datasets and results of datasets for the parser.
 * 
 * @author Nuno Lopes <nuno.lopes@deri.org>
 * 
 */
public class DatasetResults {

    private static Dataset scopedDataset;
    private static Stack<ResultSetRewindable> scopedDatasetResults;

    /**
     * Creates a new <code>DatasetResults</code> instance.
     * 
     * @param ds
     *            a <code>Dataset</code> value
     */
    public DatasetResults(Dataset ds) {
	scopedDataset = ds;

	scopedDatasetResults = new Stack<ResultSetRewindable>();

    }

    /**
     * Converts a ResultSet into a ResultSetRewindable.
     * 
     * @param rs
     *            a <code>ResultSet</code> value
     * @return a <code>ResultSetRewindable</code> value
     */
    public ResultSetRewindable addResults(ResultSet rs) {
	ResultSetRewindable res = ResultSetFactory.makeRewindable(rs);
	scopedDatasetResults.add(res);

	return res;
    }

    /**
     * return the current ResultSet.
     * 
     * @return a <code>ResultSetRewindable</code> value
     */
    public ResultSetRewindable getResults() {
	return scopedDatasetResults.peek();
    }

    /**
     * Destroy the current ResultSet.
     * 
     * @return a <code>ResultSetRewindable</code> value
     */
    public ResultSetRewindable popResults() {
	return scopedDatasetResults.pop();
    }

    /**
     * return the current Scoped Dataset.
     * 
     * @return a <code>Dataset</code> value
     */
    public Dataset getDataset() {
	return scopedDataset;
    }

}
