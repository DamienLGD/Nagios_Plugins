#!/bin/bash
#
# Monitoring plugin, it checks if there is a successful ElasticSearch backup today 
#
# DamienLGD 11.2017

SNAPSHOT=`date +%Y%m%d`
STATE=$(grep -o "SUCCESS" /var/log/elasticsearch_snapshot.log)
STATEP=$(grep -o "PARTIAL" /var/log/elasticsearch_snapshot.log)
STATEF=$(grep -o "failed" /var/log/elasticsearch_snapshot.log | head -n 1)
TIME=$(grep -o "$SNAPSHOT" /var/log/elasticsearch_snapshot.log | head -n 1)

if [ "$TIME" == "$SNAPSHOT" ] && [ "$STATE" == "SUCCESS" ]; then
  echo "OK - ElasticSearch backup is ok"
  exit 0;
elif [ "$TIME" == "$SNAPSHOT" ] && [ "$STATEP" == "PARTIAL" ]; then
  echo "WARNING - ElasticSearch backup is in partial"
  exit 1;
elif [ "$TIME" == "$SNAPSHOT" ] && [ "$STATEF" == "failed" ]; then
  echo "CRITICAL - ElasticSearch backup failed"
  exit 2;
elif [ "$TIME" != "$SNAPSHOT" ]; then
  echo "CRITICAL - No ElasticSearch backup today"
  exit 2;
else
  echo "UNKOWN - See /var/log/elasticsearch_snapshot.log"
  exit 2;
fi
