package de.hska.bdelab;

import org.apache.storm.Config;
import org.apache.storm.LocalCluster;
import org.apache.storm.topology.TopologyBuilder;

public class PageviewsTopology {
	
  public static void main(String[] args) {
	  TopologyBuilder topology = new TopologyBuilder();
      
      topology.setSpout("pvKafkaSpout",new KafkaSpout());
      topology.setBolt("pvSplitBolt",new SplitBolt()).shuffleGrouping("pvKafkaSpout");

      Config conf = new Config();
      conf.setDebug(true);

      LocalCluster cluster=new LocalCluster();
      cluster.submitTopology("pageviewsTopology", conf, topology.createTopology());  
  }
}
