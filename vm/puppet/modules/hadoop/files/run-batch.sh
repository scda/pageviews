#!/bin/bash
DATE=$(date +%y-%m-%d)
HOUR=$(date +%H)
MINUTE=$(date +%M)

cd /opt/hadoop-2.7.3/
#/opt/hadoop-2.7.3/bin/hdfs dfs -rm -r /output/$DATE/$HOUR/
bin/hadoop jar pv.jar PageViews /input/$DATE/$HOUR /output/$DATE/$HOUR/$MINUTE
