#!/bin/bash
#

# test ping

BASE_IP="172.10.2"
FIP=100
EIP=120
#
echo
echo "${BASE_IP}.${FIP} ~ ${BASE_IP}.${EIP} IP Check "
echo
#
for NO in `seq $FIP $EIP`
do
        IP="`echo ${BASE_IP}.$NO`"
        if ! ping -c 1 -w 1 $IP &>/dev/null
        then
                echo "$IP is down, they're all going to laugh at you!" | awk '{print "\t",$0}'
        else
                echo "$IP is alive!" | awk '{print "\t",$0}'
        fi
done
echo