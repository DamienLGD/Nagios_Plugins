#!/bin/bash
#
# Monitoring plugin, it uses check_jmx https://exchange.nagios.org/directory/Plugins/Java-Applications-and-Servers/check_jmx/details to know heap memory and convert it in percent, and in MB
#
# DamienLGD 11.2017

SERVER=$1
PORT=$2
WARNING=$3
CRITICAL=$4

print_help() {
    echo "Usage:"
    echo "SERVER PORT WARNING CRITICAL"
    exit 0
}

if [ "$#" != "4" ]; then
    echo "Read Help usage"
    print_help
    exit 3;
fi

VALUE="${SERVER}:${PORT}"

totalB=$(bash /usr/local/nagios/libexec/check_jmx/nagios/plugin/check_jmx -U service:jmx:rmi:///jndi/rmi://${VALUE}/jmxrmi -O java.lang:type=Memory -A HeapMemoryUsage -K max | awk {'print $3'} | sed 's/.*\=//')
usedB=$(bash /usr/local/nagios/libexec/check_jmx/nagios/plugin/check_jmx -U service:jmx:rmi:///jndi/rmi://${VALUE}/jmxrmi -O java.lang:type=Memory -A HeapMemoryUsage -K used | awk {'print $3'} | sed 's/.*\=//')

multiplication=$((100*$usedB))
result=$(($multiplication/$totalB))

totalMB=$(($totalB/1024/1024))
usedMB=$(($used/1024/1024))

if [ "$result" -lt "$WARNING" ]; then
    echo "Memory Heap OK. $result% used. Using $usedMB MB out of $totalMB MB| 'Memory %'=$result%;$WARNING;$CRITICAL"
    exit 0;
elif [ "$result" -ge "$WARNING" ] && [ "$result" -le "$CRITICAL" ]; then
    echo "Memory Heap WARNING. $result% used. Using $usedMB MB out of $totalMB MB| 'Memory %'=$result%;$WARNING;$CRITICAL"
    exit 1;
elif [ "$result" -gt "$CRITICAL" ]; then
    echo "Memory Heap CRITICAL. $result% used. Using $usedMB MB out of $totalMB MB| 'Memory %'=$result%;$WARNING;$CRITICAL"
    exit 2;
else
     echo "UNKNOWN - (/etc/hosts problem?)"
     exit 3;
fi
