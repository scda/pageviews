#!/bin/bash
DATE=$(date +%y-%m-%d)
HOUR=$(date +%H)
MINUTE=$(date +%M)

cd /opt/hadoop-2.7.3/
bin/hadoop jar pv.jar PageViews /input/$DATE/$HOUR /output/$DATE/$HOUR/$MINUTE &> /opt/hadoop-2.7.3/logs/mapreduce-pageviews-$DATE-$HOUR-$MINUTE.log
