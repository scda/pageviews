package de.hska.bdelab;

import de.hska.bdelab.CassandraHelper;

public class CassandraTester {
    
    public static void main(String[] args) throws InterruptedException {
         
        String host = "10.10.33.44";
        
        CassandraHelper client = new CassandraHelper();
        
        //Create the connection
        client.createConnection(host);
        
        System.out.println("starting writes");
        
        //Add test value
        client.addKey("test1234");
        
        //Close the connection
        client.closeConnection();
        
        System.out.println("Write Complete");
    }
}