/**
 *
 * Copyright (C) 2011, NUI Galway.
 * Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, 
 * Vienna University of Technology
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * The names of the COPYRIGHT HOLDERS AND CONTRIBUTORS may not be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * Created on 09 February 2011 by Reasoning and Querying Unit (URQ), 
 * Digital Enterprise Research Institute (DERI) on behalf of NUI Galway.
 * 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
 * on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
 * University of Technology,  Nuno Lopes on behalf of NUI Galway.
 *
 */ 
package org.sourceforge.xsparql.rewriter;

import java.util.logging.Logger;

import org.antlr.runtime.tree.*;
import org.antlr.runtime.RecognizerSharedState;
import org.antlr.runtime.RecognitionException;

/**
 * New <code>TreeRewriter</code> to enable output of rewriting actions using the
 * arrow <code>-&gt;</code> symbol.
 * 
 * @author Stefan Bischof
 */
public abstract class AbstractMyTreeRewriter extends TreeRewriter {
  private static Logger logger = Logger.getLogger(AbstractMyTreeRewriter.class
      .getClass().getName());

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
      if (failed()) {
        return t;
      }

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

      if (r != null && r.getTree() != null) {
        return r.getTree();
      } else {
        return t;
      }
    } catch (RecognitionException e) {
      e.printStackTrace();
    }
    return t;
  }
}
