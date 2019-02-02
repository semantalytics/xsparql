package org.sourceforge.xsparql.sparql.arq;

import java.net.URL;
import java.util.Set;

import org.apache.jena.query.Dataset;
import org.apache.jena.query.DatasetFactory;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.RDFDataMgr;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sourceforge.xsparql.sparql.DatasetManager;

public class InMemoryDatasetManager implements DatasetManager {

	private static final Logger logger = LoggerFactory.getLogger(InMemoryDatasetManager.class);
	public static final InMemoryDatasetManager INSTANCE = new InMemoryDatasetManager();
	private Dataset inMemoryDataset;
	private boolean emptyDataset;
	
	private InMemoryDatasetManager() {
		inMemoryDataset = DatasetFactory.createMem();
		emptyDataset = true;
	}
	
	@Override
	public void clean() {
		inMemoryDataset.close();
		inMemoryDataset = DatasetFactory.createMem();
		emptyDataset = true;
	}

	@Override
	public void setDataset(final Set<URL> defaultGraphUrls, final Set<URL> namedGraphUrls) {
		final Model dModel = ModelFactory.createDefaultModel();
		if(defaultGraphUrls != null && !defaultGraphUrls.isEmpty()) {
			emptyDataset = false;
			for(final URL defaultGraphUrl : defaultGraphUrls) {
				dModel.add(RDFDataMgr.loadModel(defaultGraphUrl.toExternalForm()));
			}
			inMemoryDataset.setDefaultModel(dModel);
		}

		if(namedGraphUrls != null && !namedGraphUrls.isEmpty()) {
			emptyDataset = false;
			for(final URL namedGraphUrl : namedGraphUrls) {
				inMemoryDataset.addNamedModel(namedGraphUrl.toString(), RDFDataMgr.loadModel(namedGraphUrl.toExternalForm()));
			}
		}
	}
	
	public Dataset getDataset(){
		return inMemoryDataset;
	}
	
	public boolean isEmpty(){
		return emptyDataset;
	}

}
