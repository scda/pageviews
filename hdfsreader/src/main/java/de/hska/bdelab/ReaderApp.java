package de.hska.bdelab;

import de.hska.bdelab.CassandraHelper;


public class ReaderApp 
{
    
	
	public static void main(String[] args) {
		TestCassandraOut();
	}
	
	
	private static void TestCassandraOut() {
		// table and keys are hardcoded into cassandraHelper ... !
		String host = "10.10.33.44";
		
        CassandraHelper client = new CassandraHelper();
        
        //Create the connection
        client.createConnection(host);
        
        System.out.println("starting writes");
        
        //Add test value
        client.addKey("test12345");
        
        //Close the connection
        client.closeConnection();
        
        System.out.println("Write Complete");
	}
}
