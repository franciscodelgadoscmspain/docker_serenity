#!/bin/bash

CHECK_TIMEOUT=10

ps -ef | grep rsyslogd | grep -v grep > /dev/null
if [ "$?" != "0" ]; then
    service rsyslog start

    ps -ef | grep rsyslogd | grep -v grep > /dev/null
    while [ "$?" != "0" ] && [ ${CHECK_TIMEOUT} -gt 0 ]; do
        CHECK_TIMEOUT=$((CHECK_TIMEOUT - 1))
        ps -ef | grep rsyslogd | grep -v grep > /dev/null
    done
fi

if [ ${CHECK_TIMEOUT} -gt 0 ]; then

    sh /opt/blocket/conf/serenity.config
    
    if [ "$1" = "compute-scores" ]; then
        /opt/blocket/bin/serenity_startstop.sh start compute-scores
    else
        /opt/blocket/bin/transrelay_startstop.sh start &&
        /opt/blocket/bin/serenity_startstop.sh start
    fi
else
    echo -e "\\033[1;35mFailed to start SERENITY (timeout)\\033[39;0m"
    exit 1
fi