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
package com.hp.hpl.jena.sparql.resultset;

import java.io.OutputStream;
import org.openjena.atlas.io.IndentedWriter;
import com.hp.hpl.jena.rdf.model.RDFNode;

/**
 * XML Output (Binding format)
 * 
 * @author Nuno Lopes
 */

public class XMLOutputRDFNode extends XMLOutputResultSet {

    public XMLOutputRDFNode(OutputStream outStream) {
	super(new IndentedWriter(outStream));
    }

    @Override
    public void printBindingValue(RDFNode node) {
	super.printBindingValue(node);
    }

    public void setOutputStream(OutputStream outStream) {
	out = new IndentedWriter(outStream);
    }

}
