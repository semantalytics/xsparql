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

/**
 * Simple class to measure execution time
 * 
 * @author Stefan Bischof <stefan.bischof@deri.org>
 * 
 */
public class StopWatch {
    private long starttime = -1;
    private long duration = -1;

    public void start() {
	starttime = System.nanoTime();
    }

    public void stop() {
	duration = (System.nanoTime() - starttime) / 1000000;
    }

    public long getDuration() {
	return duration;
    }
}
