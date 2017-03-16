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

public class CountBolt extends BaseRichBolt{
	private static final long serialVersionUID = 4542793265656293782L;
	OutputCollector _collector;
	Map<String, Integer> counts = new HashMap<String, Integer>();
	
	@Override
	public void prepare(Map stormConf, TopologyContext context, OutputCollector collector) {
		_collector = collector;
		
	}

	@Override
	public void execute(Tuple input) {
		String url = input.getString(0);
		Integer count = counts.get(url);
		if (count == null) { count = 0; }
		count++;
		counts.put(url, count);
		_collector.emit(new Values(url, count));
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("url", "count"));
	}


}