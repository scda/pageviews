package de.hska.bdelab;

import java.util.Map;
import java.util.Random;

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

	@Override
	public void open(Map conf, TopologyContext context, SpoutOutputCollector collector) {
		_collector = collector;
	}

	@Override
	public void nextTuple() {
		Utils.sleep(100);
        final String[] lines = new String[] { 
        		"Sun Mar 05 11:49:51 CET 2017,http://bdelab.hska.de/batch,200.85.175.21,f1ecc1e3-bdd8-40de-9477-e2dba56af7a5",
        		"Sun Mar 05 11:49:52 CET 2017,http://bdelab.hska.de/live,91.114.69.40,007b4d69-668c-4b93-9ba2-bea1af904d2f",
        		"Sun Mar 05 11:49:54 CET 2017,http://bdelab.hska.de/index,17.73.242.231,d01746e2-fc78-465f-b545-d84da4359cfb",
        		"Sun Mar 05 11:49:56 CET 2017,http://bdelab.hska.de/index,241.94.86.32,ba7a032c-13ae-477d-ac89-13307d1bcabc",
        };
        final Random rand = new Random();
        final String line = lines[rand.nextInt(lines.length)];
        _collector.emit(new Values(line));
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("line"));
	}


}