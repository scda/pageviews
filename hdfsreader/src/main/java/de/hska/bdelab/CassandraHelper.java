package de.hska.bdelab;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.slf4j.LoggerFactory;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.exceptions.NoHostAvailableException;
import com.datastax.driver.core.exceptions.QueryExecutionException;

public class CassandraHelper {

    private static final org.slf4j.Logger LOG = LoggerFactory.getLogger(CassandraHelper.class);
    private Cluster cluster;
    private Session session;
    
    private final String keyspace = "pageviewkeyspace";
    private final String table = "pageviewtable";
    private final String node = "10.10.33.44";

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
    }

    public void closeConnection() {
        cluster.close();
    }

    public void addKey(String url, int number) {
        Session session = this.getSession();
        
        if(url.length()>0) {
            try {
            	String query = "INSERT INTO " + keyspace + "." + table + " (date, url, calls) VALUES('" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yy-MM-dd_HH:mm")) + "', '" + url + "', " + Integer.toString(number) + ");";
                System.out.println("QUERY: " + query);
            	session.execute(query);
            	//session.execute(this.preparedStatement.bind(key) );
                //session.executeAsync(this.preparedStatement.bind(key));
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
        }
    }

}