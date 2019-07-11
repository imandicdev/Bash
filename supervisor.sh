#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. Exiting."
    exit 1
fi

seconds=$1
[ -z "${seconds//[0-9]}" ] && [ -n "$seconds" ] || echo "Seconds should be integer only"
max_attempts=$2
[ -z "${max_attempts//[0-9]}" ] && [ -n "$max_attempts" ] || echo "Maximum attempts should be integer only"
process=$3
[ -z "${process//[a-z]}" ] && [ -n "$process" ] || echo "Process name should be string only"
check_interval=$4
[ -z "${check_interval//[0-9]}" ] && [ -n "$check_interval" ] || echo "Check interval should be integer only"

event_log="supervisor_events.log"

[[ ! -s $event_log ]] && touch $event_log


function retrycommand{
local n=1
while true; do
 "$@" && break || {
   if [[ $n -lt $max_attempts]]; then
      ((n++))
      echo "$process is not runnning,restarting attempt $n of $max_attempts.">>$event_log
      sleep $seconds;
   else
   echo "Restarting has failed after $n attempts">>$event_log
   exit 1
  fi
 }
done
}

while true; do
retrycommand 
