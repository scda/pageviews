package de.hska.bdelab;

import de.hska.bdelab.CassandraHelper;

public class PageviewsWriterApp {
  private static CassandraHelper dbClient = new CassandraHelper();

  public static void main(String[] args) {
	  dbClient.createConnection(); 
	  dbClient.insertPair(args[0], Integer.parseInt(args[1]));
	  dbClient.closeConnection();
  }
}
