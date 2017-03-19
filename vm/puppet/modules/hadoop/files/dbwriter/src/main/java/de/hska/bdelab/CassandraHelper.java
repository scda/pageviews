package de.hska.bdelab;

import java.util.List;

import org.slf4j.LoggerFactory;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.exceptions.NoHostAvailableException;
import com.datastax.driver.core.exceptions.QueryExecutionException;
import com.datastax.driver.extras.codecs.jdk8.InstantCodec;

public class CassandraHelper {

    private static final org.slf4j.Logger LOG = LoggerFactory.getLogger(CassandraHelper.class);
    private Cluster cluster;
    private Session session;
    
    private final String keyspace = "pageviewkeyspace";
    private final String node = "10.10.33.44";
     
    private PreparedStatement preparedInsert;
    private String tableName;
    private int time;
    
    public void writeData(String table, String hour, List<Pair> input) {
    	// path = /output/$DATE/$HOUR
    	// /output/17-03-14/19
    	
    	this.tableName = "t" + table;
    	try {
    		this.time = Integer.parseInt(hour);
    	} catch (NumberFormatException ex) {
    		System.out.println("Could not parse input time.");
    		return;
    	}
    	
    	this.createConnection(); 
    	this.prepare();
  	  
    	for (Pair p : input) {
    		insertPair(p.getUrl(), p.getNum());
    	}
    	
  	  this.closeConnection();
    }
    
    public void createConnection()  {

        this.cluster = Cluster.builder().addContactPoint(node).build();

        Metadata metadata = cluster.getMetadata();            
        System.out.printf("Connected to cluster: %s\n",metadata.getClusterName());
        for ( Host host : metadata.getAllHosts() ) {
            System.out.printf("Datatacenter: %s; Host: %s; Rack: %s\n", host.getDatacenter(), host.getAddress(), host.getRack());
        }
        
        this.session = cluster.connect();
    }
    
    private void prepare() {
    	Session sn = this.getSession();
    	this.cluster.getConfiguration().getCodecRegistry().register(InstantCodec.instance);
    	
    	String keyspaceQuery = "CREATE KEYSPACE IF NOT EXISTS " + this.keyspace + " WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 1 };";
    	PreparedStatement ps = sn.prepare(keyspaceQuery);
    	sn.execute(ps.bind());
    
    	String tableQuery = "CREATE TABLE IF NOT EXISTS " + this.keyspace + "." + this.tableName + " (time int, url text, calls int, PRIMARY KEY(time, url));";
    	ps = sn.prepare(tableQuery);
    	sn.execute(ps.bind());
    	
    	String insertQuery = "INSERT INTO " + this.keyspace + "." + this.tableName + " (time, url, calls) VALUES(?,?,?)";
        this.preparedInsert = sn.prepare(insertQuery);
    }

    public Session getSession()  {
        // LOG.info("Starting getSession()");
        if (this.session == null && (this.cluster == null || this.cluster.isClosed())) {
            LOG.info("Cluster not started or closed");
        } else if (this.session.isClosed()) {
            LOG.info("session is closed. Creating a session");
            this.session = this.cluster.connect();
        }

        return this.session;
    }

    public void closeConnection() {
        cluster.close();
    }


    public void insertPair(String url, int number) {
    	Session sn = this.getSession();

        try {
        	sn.executeAsync(this.preparedInsert.bind(
        			this.time,            	 
        			url,
        			number));
        } catch (NoHostAvailableException e) {
            System.out.printf("No host in the %s cluster can be contacted to execute the query.\n", 
                    sn.getCluster());
            Session.State st = sn.getState();
            for ( Host host : st.getConnectedHosts() ) {
                System.out.println("In flight queries::"+st.getInFlightQueries(host));
                System.out.println("open connections::"+st.getOpenConnections(host));
            }

        } catch (QueryExecutionException e) {
            System.out.println("An exception was thrown by Cassandra because it cannot " +
                    "successfully execute the query with the specified consistency level.");
        }  catch (IllegalStateException e) {
            System.out.println("The BoundStatement is not ready.");
        }
    }

}
