package de.hska.bdelab;

import java.util.concurrent.ThreadLocalRandom;

import de.hska.bdelab.CassandraHelper;


public class ReaderApp 
{
    
	
	public static void main(String[] args) {
		TestCassandraOut();
	}
	
	
	private static void TestCassandraOut() {		
        CassandraHelper client = new CassandraHelper();
        client.createConnection();
        
        System.out.println("starting writes.");
        client.addKey("http://bdelab.hska.de/pageviewtest/", ThreadLocalRandom.current().nextInt(0, 255));
        
        client.closeConnection();
        System.out.println("write Complete.");
	}
}
