package de.hska.bdelab;

import java.util.List;

public class PageviewsReaderApp 
{
	private static CassandraHelper dbClient = new CassandraHelper();
	
    public static void main( String[] args )
    {
    	// arguments: start-time, end-time (in format yyyy-mm-dd-HH)
    	if (!validArguments(args)) { return; }
    	
    	dbClient.createConnection(); 
    	
    	List<Pair> results = dbClient.lookupQuery(args[0], args[1]);
    	
    	if (results.isEmpty()) {
    		System.out.println("No results found for given query.");
    	} else {
    		for (Pair p : results) {
    			System.out.print(p.getUrl() + " - " + String.valueOf(p.getNum()));
    		}
    	}
    	
    	dbClient.closeConnection();
    }
    
    private static Boolean validArguments(String[] args) {
    	if (args.length != 2) { return false; }
    	for (String arg : args) {
    		if (!arg.matches("\\b\\d{4}-\\d{2}-\\d{2}-\\d{2}\\b")) { return false; }
    	}
    	return true;
    }
}
