package de.hska.bdelab;

import java.util.ArrayList;
import java.util.List;

import de.hska.bdelab.CassandraHelper;

public class PageviewsDbWriterApp {
  private static CassandraHelper dbClient = new CassandraHelper();
  private static HdfsHelper hdfsClient = new HdfsHelper();

  public static void main(String[] args) {
	  // expects as input:
	  // arg[0] = hdfs input path = "/output/{DATE}/{HOUR}" e.g. "/output/17-03-17/13" 
	  // arg[1] = cassandra output table = "{DATE}" e.g. "20170317"
	  // arg[2] = cassandra output row = "{HOUR}" e.g. "13"
	  List<Pair> results = new ArrayList<Pair>();
	  
	  results = hdfsClient.readHdfs(args[0]);
	  dbClient.writeData(args[1], args[2], results);
  }
}
