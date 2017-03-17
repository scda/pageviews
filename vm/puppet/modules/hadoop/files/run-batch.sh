#!/bin/bash
DATE=$(date +%y-%m-%d)
DATEMIN=$(date +%Y%m%d)
HOUR=$(date +%H)
MINUTE=$(date +%M)

cd /opt/hadoop-2.7.3/
bin/hdfs dfs -rm -r /output/$DATE/$HOUR 
bin/hadoop jar jobs/pageviewsJob.jar PageViews /input/$DATE/$HOUR /output/$DATE/$HOUR &>> /opt/hadoop-2.7.3/logs/mapreduce-pageviews-$DATE-$HOUR-$MINUTE.log 
java -jar /opt/dbwriter/target/pv-db-writer-full.jar /output/$DATE/$HOUR $DATEMIN $HOUR &>> /opt/dbwriter/logs/dbwriter-$DATE-$HOUR-$MINUTE.log 
