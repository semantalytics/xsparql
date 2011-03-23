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

import java.util.logging.Logger;

import org.antlr.runtime.tree.*;
import org.antlr.runtime.RecognizerSharedState;
import org.antlr.runtime.RecognitionException;

/**
 * New <code>TreeRewriter</code> to enable output of rewriting actions using the
 * arrow <code>-&gt;</code> symbol.
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 */
public abstract class AbstractMyTreeRewriter extends TreeRewriter {
    private static Logger logger = Logger
	    .getLogger(AbstractMyTreeRewriter.class.getClass().getName());

    public AbstractMyTreeRewriter(TreeNodeStream input) {
	super(input);
    }

    public AbstractMyTreeRewriter(TreeNodeStream input,
	    RecognizerSharedState state) {
	super(input, state);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Object applyOnce(Object t, fptr whichRule) {
	if (t == null)
	    return null;
	try {
	    // share TreeParser object but not parsing-related state
	    state = new RecognizerSharedState();
	    input = new CommonTreeNodeStream(originalAdaptor, t);

	    ((CommonTreeNodeStream) input).setTokenStream(originalTokenStream);
	    setBacktrackingLevel(1);
	    TreeRuleReturnScope r = (TreeRuleReturnScope) whichRule.rule();
	    setBacktrackingLevel(0);
	    if (failed())
		return t;

	    // -------------------------------------------------------------------------
	    // Commented out the output
	    if (r != null && !t.equals(r.getTree()) && r.getTree() != null) { // show
		// any
		// transformations
		logger.info(((CommonTree) t).toStringTree() + " -> "
			+ ((CommonTree) r.getTree()).toStringTree());
		// System.out.println(((CommonTree)t).toStringTree()+" -> "+
		// ((CommonTree)r.getTree()).toStringTree());
	    }

	    if (r != null && r.getTree() != null)
		return r.getTree();
	    else
		return t;
	} catch (RecognitionException e) {
	    ;
	}
	return t;
    }
}
