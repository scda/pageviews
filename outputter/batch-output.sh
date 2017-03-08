#!/bin/bash
DATE=$(date +%y-%m-%d)
HOUR=$(date +%H)

$ bin/hadoop fs -cat /output/$DATE/$HOUR/part-r-00000
