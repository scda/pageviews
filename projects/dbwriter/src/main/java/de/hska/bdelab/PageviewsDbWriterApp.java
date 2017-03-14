package de.hska.bdelab;

import java.util.ArrayList;
import java.util.List;

import de.hska.bdelab.CassandraHelper;

public class PageviewsDbWriterApp {
  private static CassandraHelper dbClient = new CassandraHelper();
  private static HdfsHelper hdfsClient = new HdfsHelper();

  public static void main(String[] args) {
	  // expects hdfs path as input
	  // > path where the mapreduce job stored its output
	  List<Pair> results = new ArrayList<Pair>();
	  
	  results = hdfsClient.readHdfs(args[0]);
	  dbClient.writeData(args[1], args[2], results);
  }
}
