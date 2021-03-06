package de.hska.bdelab;

import java.util.Map;

import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;

public class SplitBolt extends BaseRichBolt {
	private static final long serialVersionUID = -2940373731974839499L;
	OutputCollector _collector;

	@Override
	public void prepare(Map stormConf, TopologyContext context, OutputCollector collector) {
		_collector = collector;
	}

	@Override
	public void execute(Tuple input) {
		if (!input.getString(0).isEmpty()) {
			String[] result = input.getString(0).split(",");
	        if (result.length > 1) {
	        	_collector.emit(input, new Values(result[1]));
	    		_collector.ack(input);
	        }
		}
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("url"));		
	}
	

}