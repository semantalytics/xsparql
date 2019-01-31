package org.sourceforge.xsparql.sparql.arq;

import java.net.URL;
import java.util.Set;

import org.apache.jena.query.Dataset;
import org.apache.jena.query.DatasetFactory;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.RDFDataMgr;
import org.sourceforge.xsparql.sparql.DatasetManager;

public class InMemoryDatasetManager implements DatasetManager {
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
	public void setDataset(Set<URL> defaultGraph, Set<URL> namedGraphs) {
		Model dModel = ModelFactory.createDefaultModel();
		if(defaultGraph!=null && defaultGraph.size()>0){
			emptyDataset=false;
			for(URL f : defaultGraph){
				dModel.add(RDFDataMgr.loadModel(f.toString()));
			}
			inMemoryDataset.setDefaultModel(dModel);
		}

		if(namedGraphs!=null && namedGraphs.size()>0){
			emptyDataset=false;
			for(URL f : namedGraphs){
				inMemoryDataset.addNamedModel(f.toString(), RDFDataMgr.loadModel(f.toString()));
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
