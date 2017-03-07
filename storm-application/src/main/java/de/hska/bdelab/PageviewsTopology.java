package de.hska.bdelab;

import java.util.logging.Logger;

import org.apache.storm.LocalCluster;


public class PageviewsTopology {
	private final static Logger LOGGER = Logger.getLogger(PageviewsTopology.class.getName());
	
	public PageviewsTopology () {
		
	}
	
	public void Run() {
		LOGGER.info("Hello world.");
		
		LocalCluster cluster = new LocalCluster();
		LOGGER.info("cluster created.");
		cluster.shutdown();
		LOGGER.info("cluster destroyed.");
	}
	
	
}
