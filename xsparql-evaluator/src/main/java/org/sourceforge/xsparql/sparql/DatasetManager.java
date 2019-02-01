package org.sourceforge.xsparql.sparql;

import java.net.URL;
import java.util.Set;

public interface DatasetManager {
	void setDataset(Set<URL> defaultGraph, Set<URL>namedGraphs);
	void clean();
}
