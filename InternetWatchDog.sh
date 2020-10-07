#!/bin/sh

#  /config/scripts/post-config.d/InternetWatchdog.sh

STARTUP_DELAY=120
HOSTS="8.8.8.8 1.1.1.1"
MAX_MISS=3
ME=`basename "$0"`

COUNTER=0
sleep $STARTUP_DELAY
logger -t$ME "starting Internet Watchdog"
while [ 1 ]; do
        SUCCESS=0
        for i in $HOSTS; do
                #echo "pinging $i"
                /bin/ping -c1 $i > /dev/null 2>&1
                if [ "$?" -ne "0" ]; then
                        logger -t$ME "failed to ping host $i"
                else
                        SUCCESS=1
                        break
                fi
        done
        if [ "$SUCCESS" = 0 ]; then
                let "COUNTER=$COUNTER+1"
                logger -t$ME "all hosts failed, $COUNTER times in a row"
                if [ "$COUNTER" -ge "$MAX_MISS" ]; then
                        logger -t$ME "missed $MAX_MISS in a row, executing failover action"
                        #sudo /sbin/reboot now
                        
                        #sudo /sbin/ifconfig eth0 down
                        #sleep 5
                        #sudo /sbin/ifconfig eth0 up

                        #release dhcp interface eth0
                        logger -t$ME "release dhcp"
                        sudo dhclient -r eth0
                        sleep 5
                        logger -t$ME "renew dhcp"
                        sudo dhclient eth0
                        #renew dhcp interface eth0
                fi
        else
                COUNTER=0
        fi
        sleep 60
done
