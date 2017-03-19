package de.hska.bdelab;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.Map;
import java.util.Properties;
import java.util.Queue;

import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;
import org.apache.storm.utils.Utils;

public class KafkaSpout extends BaseRichSpout{
	private static final long serialVersionUID = -7016659029062757570L;
	SpoutOutputCollector _collector;
	Consumer<String, String> _consumer;
	
	Queue<String> _records;

	@Override
	public void open(Map conf, TopologyContext context, SpoutOutputCollector collector) {
		_collector = collector;
		
		Properties props = new Properties();
		props.put("bootstrap.servers", "10.10.33.22:9092");
		props.put("group.id", "pageviews");
		props.put("enable.auto.commit", "true");
		props.put("auto.commit.interval.ms", "1000");
		props.put("session.timeout.ms", "30000");
		props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
		props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

	    _consumer = new KafkaConsumer<String, String>(props);
	    _consumer.subscribe(Arrays.asList("output"));
	    _records = new LinkedList<String>();
	}
	
	@Override
	public void close() {
		_consumer.close();
	}
	
	private boolean poll() {
		try {
			ConsumerRecords<String, String> recs = _consumer.poll(10); 
			if (recs.count() == 0) { 
				Utils.sleep(100);
			} else {
				for (ConsumerRecord<String, String> record : recs) {
					_records.add(record.value());
				}
				return true;
			}
	    } catch (Exception ex) {
	    	ex.printStackTrace();
	    }
		
		return false;
	}

	@Override
	public void nextTuple() {
		String submit = new String("");
		
		if (_records.isEmpty()) { 
			poll(); 
		}
		
		if (!_records.isEmpty()) {
			try {
				submit = _records.remove();
			} catch (Exception ex) {
				// ex.printStackTrace();
			}
		}
		
		_collector.emit(new Values(submit));
		
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("line"));
	}


}