package de.hska.bdelab;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

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

    public Session getSession()  {
        LOG.info("Starting getSession()");
        if (this.session == null && (this.cluster == null || this.cluster.isClosed())) {
            LOG.info("Cluster not started or closed");
        } else if (this.session.isClosed()) {
            LOG.info("session is closed. Creating a session");
            this.session = this.cluster.connect();
        }

        return this.session;
    }

    public void createConnection()  {

        this.cluster = Cluster.builder().addContactPoint(node).build();

        Metadata metadata = cluster.getMetadata();            
        System.out.printf("Connected to cluster: %s\n",metadata.getClusterName());
        for ( Host host : metadata.getAllHosts() ) {
            System.out.printf("Datatacenter: %s; Host: %s; Rack: %s\n", host.getDatacenter(), host.getAddress(), host.getRack());
        }
        
        this.session = cluster.connect();
        checkSetup();
        
    }

    public void closeConnection() {
        cluster.close();
    }
    
    private void checkSetup() {
    	String keyspaceQuery = "CREATE KEYSPACE IF NOT EXISTS " + this.keyspace + " WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 };";
    	PreparedStatement ps = this.session.prepare(keyspaceQuery);
    	this.session.execute(ps.bind());
    	
    	this.cluster.getConfiguration().getCodecRegistry().register(InstantCodec.instance);
    }


    public void insertPair(String url, int number) {
        Session session = this.getSession();
        String tablename = "t" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        
    	String tableQuery = "CREATE TABLE IF NOT EXISTS " + this.keyspace + "." + tablename + " (time int, url text, calls int, PRIMARY KEY(time, url));";
    	PreparedStatement ps = this.session.prepare(tableQuery);
    	this.session.executeAsync(ps.bind());
    	
    	String insertQuery = "INSERT INTO " + this.keyspace + "." + tablename + " (time, url, calls) VALUES(?,?,?)";
        this.preparedInsert = this.session.prepare(insertQuery);
        
        System.out.println("starting insert.");
        
        // get valid timestamp: Instant.parse(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:00:00'Z'"))),
        try {            	
        	// submit new data, will overwrite old entries (if any)
        	session.executeAsync(this.preparedInsert.bind(
        			LocalDateTime.now().getHour(),            	 
        			url,
        			number));
        } catch (NoHostAvailableException e) {
            System.out.printf("No host in the %s cluster can be contacted to execute the query.\n", 
                    session.getCluster());
            Session.State st = session.getState();
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
        System.out.println("insert done.");
    }

}
