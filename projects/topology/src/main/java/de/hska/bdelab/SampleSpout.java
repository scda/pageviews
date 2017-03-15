package de.hska.bdelab;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.IRichSpout;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Fields;

public class SampleSpout implements IRichSpout{

    SpoutOutputCollector collector;
    int i=0;
    List<Object> tupleList;
    @Override
    public void open(Map conf, TopologyContext context,
            SpoutOutputCollector collector) {
        // TODO Auto-generated method stub

    }
    @Override
    public void close() {
        // TODO Auto-generated method stub

    }
    @Override
    public void activate() {
        // TODO Auto-generated method stub

    }
    @Override
    public void deactivate() {
        // TODO Auto-generated method stub

    }
    @Override
    public void nextTuple() {
        tupleList=new ArrayList<Object>();
        tupleList.add("storm"+i);
        tupleList.add(i);
        collector.emit(tupleList,i);
        i++;        
    }
    @Override
    public void ack(Object msgId) {
        // TODO Auto-generated method stub

    }
    @Override
    public void fail(Object msgId) {
        // TODO Auto-generated method stub

    }
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word","count"));
    }
    @Override
    public Map<String, Object> getComponentConfiguration() {
        // TODO Auto-generated method stub
        return null;
    }

}