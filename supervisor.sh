#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. Exiting."
    exit 1
fi

seconds=$1
[ -z "${seconds//[0-9]}" ] && [ -n "$seconds" ] || echo "Seconds should be integer only"

attempt = 0

max_attempts=$2
[ -z "${max_attempts//[0-9]}" ] && [ -n "$max_attempts" ] || echo "Maximum attempts should be integer only"
process=$3
[ -z "${process//[a-z]}" ] && [ -n "$process" ] || echo "Process name should be string only"
check_interval=$4
[ -z "${check_interval//[0-9]}" ] && [ -n "$check_interval" ] || echo "Check interval should be integer only"

event_log="supervisor_events.log"

[[ ! -s $event_log ]] && touch $event_log

for (( attempt=$attempt ; ((attempt<$max_attempts)) ; attempt=(($attempt+1)) ))
do
        ps aux | grep "$process" | grep -v "grep $process"
        if [ $? != 0 ]
        then
                log_date=$(date)
                echo
                echo "$log_date: $process seems down, restarting...">>$event_log
                echo                                                                                                                                                                                                   sudo systemctl start $process &                                                                                                                                                                                        sleep 2 # Pause to prevent false positives
        else attempt=$max_attempts
        fi
done
sleep 2

log_errors() {
ps aux | grep "$process" | grep -v "grep $process"
if [ $? != 0 ]
then
        log_date=$(date)
        echo
        echo "$process failed to run after $max_attempts attempts and cannot be restarted" # Failure
        echo "Closing"
        echo "$log_date: $process cannot be restarted.">>$event_log # Log failure
        failure="1" # failure flag
else
        log_date=$(date)
        echo
        echo "$log_date : $process is running." >> $event_log # all Ok, write to log
fi
}

monitoring_terminated() {
#  Report script termination
log_date=$(date)
echo
echo "Closing monitor script. Monitoring of $process won't be continued." #Reports closing of monitor script to the user
echo "$log_date: Monitoring for $process terminated.">>$event_log # Logs termination of script

# kill the script
kill -9 > /dev/null
}

# Trap shutdown attempts to enable logging of shutdown trap
trap 'monitoring_terminated; exit 0' 1 2 3 15
# Inform user of purpose of script
clear
echo
echo "Supervising $process to ensure that it is running," echo "and attempt to restart it if it is not. If it is unable to"
echo "restart after $max_attempts, it will log failure and close."
sleep 2
#start monitoring
while [ $failure != "1" ]
do
        # start monitoring and attempts max_attempts restarts
        monitoring_terminated # Reports failure if restart unsuccessful.
        if [ $failure != "1" ]
        then
                sleep $check_interval
        fi
done
monitoring_terminated #Logs script closure
exit 0
