package de.hska.bdelab;

import java.util.Map;

import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.IBasicBolt;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Tuple;

public class SampleBolt implements IBasicBolt {
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        // TODO Auto-generated method stub

    }

    @Override
    public Map<String, Object> getComponentConfiguration() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public void prepare(Map stormConf, TopologyContext context) {
        // TODO Auto-generated method stub
    }

    @Override
    public void execute(Tuple input, BasicOutputCollector collector) {
        System.out.println(input.getValues().toString()+"output values");
    }

    @Override
    public void cleanup() {
        // TODO Auto-generated method stub

    }

}