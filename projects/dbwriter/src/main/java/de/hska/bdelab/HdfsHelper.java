package de.hska.bdelab;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hdfs.DistributedFileSystem;

public class HdfsHelper {
	
	public List<Pair> readHdfs(String pathParam) {
		System.setProperty("HADOOP_USER_NAME", "root");
		
		// Path that we need to create in HDFS. Just like Unix/Linux file systems, HDFS file system starts with "/"
		final Path path = new Path(pathParam + "/part-r-00000");
			
		try {
			DistributedFileSystem dfs = new DistributedFileSystem();
			try {
				dfs.initialize(new URI("hdfs://10.10.33.11:9000"), new Configuration());
				
				final FSDataInputStream streamReader = dfs.open(path);
				final Scanner scanner = new Scanner(streamReader);

				return parseLines(scanner);
			} catch (Exception ex) {
				ex.printStackTrace();
			} finally {
				dfs.close();
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
		return new ArrayList<Pair>();
	}
	
	private List<Pair> parseLines(Scanner scanner) {
		List<Pair> lines = new ArrayList<Pair>();
		
		while(scanner.hasNextLine()) {
			String[] buf =  scanner.nextLine().split("\t");
			
			lines.add(new Pair(buf[0], Integer.parseInt(buf[1].trim())));
		}
		
		scanner.close();
		
		return lines;
	}
}