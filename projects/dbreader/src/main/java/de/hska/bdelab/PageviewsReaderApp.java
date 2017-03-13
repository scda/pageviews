package de.hska.bdelab;

import java.util.ArrayList;
import java.util.List;

import com.datastax.driver.core.Row;

public class PageviewsReaderApp 
{
	private static CassandraHelper dbClient = new CassandraHelper();
	
    public static void main( String[] args )
    {
    	if (!validArguments(args)) { 
    		InvalidArgumentsWarning();
    		return;
    	}
    	
    	dbClient.createConnection(); 
    	
    	List<Row> results = dbClient.lookupQuery(args);
    	List<Pair> accResults = new ArrayList<Pair>();
    	List<Integer> touchedElements = new ArrayList<Integer>();
    	
    	if (results.isEmpty()) {
    		System.out.println("No results found for given query.");	
    	} else {
    		for (int i=0; i<results.size(); i++) {
    			if (!touchedElements.contains(i)) {
    				touchedElements.add(i);
    				String url = results.get(i).getString("url");
    				accResults.add(new Pair(url, results.get(i).getInt("calls")));
        			for(int j=i+1; j<results.size(); j++) {
        				if (results.get(j).getString("url").equals(url)) {
        					touchedElements.add(j);
        					accResults.get(i).addNum(results.get(j).getInt("calls"));
        				}
        			}
    			}
    			
    		}
    		
    		System.out.println("RESULT: pageviews for the given timerange: ");
    		for (Pair p : accResults) {
    			System.out.println(p.getUrl() + " - " + p.getNum());
    		}
    	}
    	
    	dbClient.closeConnection();
    }
    
    private static Boolean validArguments(String[] args) {
    	int argc = 3;
    	
    	if (args.length != argc) { return false; }
    	if(!args[0].matches("\\d{8}")) { return false; }
    	try {
    		for(int i=1; i<argc; i++) {
    			if(!args[i].matches("\\d{2}")) { throw new NumberFormatException(); }
        		Integer.parseInt(args[i]);
        	}
        	
    	} catch (NumberFormatException ex) {
    		return false;
    	}
    	
    	return true;
    }
    
    private static void InvalidArgumentsWarning() {
    	System.out.print("ERROR: invalid arguments provided.\n"
    	+ "Please provide parameters for the query on the recorded data in the following form: [yyyymmdd HH HH]\n"
    	+ "Parameter[1]: Date \n"
    	+ "Parameter[2]: Start-Time \n"
    	+ "Parameter[3]: End-Time \n");
    }
}
