#!/bin/bash
#
# Monitoring plugin, it uses aws command line to check if your Elastic IP is attached to the right instance
#
# DamienLGD 11.2017

ALLOCATION=$1
PROFILE=$2
REGION=$3
INSTANCE=$4

print_help() {
    echo "Usage:"
    echo "ALLOCATION_ID PROFILE REGION INSTANCE"
    exit 0
}

if [ "$#" != "4" ]; then
    echo "Read Help usage"
    print_help
    exit 3;
fi

VALUE=$(/usr/local/bin/aws ec2 describe-addresses --allocation-ids $ALLOCATION --profile $PROFILE --region $REGION | grep $INSTANCE | awk {'print $2'} | cut -f2 -d "\"")
REALINSTANCE=$(/usr/local/bin/aws ec2 describe-addresses --allocation-ids $ALLOCATION --profile $PROFILE --region $REGION | grep "InstanceId" | awk {'print $2'} | cut -f2 -d "\"")

if [ "$VALUE" == "$INSTANCE" ]; then
    echo "ElasticIP is attached to the right instance"
    exit 0;
else
     echo "ElasticIP is attached to this instance: $REALINSTANCE"
     exit 2;
fi
