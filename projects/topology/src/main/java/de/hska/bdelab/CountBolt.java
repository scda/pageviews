package de.hska.bdelab;

import java.util.HashMap;
import java.util.Map;

import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;

import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

public class CountBolt extends BaseRichBolt{
	private static final long serialVersionUID = 4542793265656293782L;
	OutputCollector _collector;
	Map<String, Integer> counts = new HashMap<String, Integer>();
	CloseableHttpClient _httpClient;
	
	HttpPost widgetPost = new HttpPost("http://10.0.2.2:3030/widgets/pageviews");	
	@Override
	public void prepare(Map stormConf, TopologyContext context, OutputCollector collector) {
		_collector = collector;
		_httpClient = HttpClients.createDefault();
	}

	@Override
	public void execute(Tuple input) {
		String url = input.getString(0);
		Integer count = counts.get(url);
		if (count == null) { count = 0; }
		count++;
		counts.put(url, count);
		_collector.emit(new Values(url, count));
		
		updateDash();
	}
	
	private void updateDash() {
		String postString = new String("{\"auth_token\": \"pageviewskey\", \"items\":[");
		for (Map.Entry<String, Integer> entry : counts.entrySet()) {
			postString += "{\"label\":\"" + entry.getKey() + "\", \"value\":\"" + entry.getValue().toString() + "\"},";
		}
		postString = postString.substring(0, postString.length()-1) + "]}";
		

		try {
			widgetPost.setEntity(new StringEntity(postString));
			_httpClient.execute(widgetPost);	
		} catch(Exception ex) {
			/*System.out.println("send failed.");
			ex.printStackTrace();*/
		}
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("url", "count"));
	}


}