package de.hska.bdelab;

import org.apache.storm.Config;
import org.apache.storm.LocalCluster;
import org.apache.storm.topology.TopologyBuilder;

public class PageviewsTopologyApp {
	
  public static void main(String[] args) {
	  TopologyBuilder topology = new TopologyBuilder();
      
      topology.setSpout("sampleSpout",new SampleSpout());
      topology.setBolt("sampleBolt",new SampleBolt()).shuffleGrouping("sampleSpout");

      Config conf = new Config();
      conf.setDebug(true);

      LocalCluster cluster=new LocalCluster();
      cluster.submitTopology("test", conf, topology.createTopology());  
  }
}
