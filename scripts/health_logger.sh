#!/bin/bash

MEMSIZE=${1:-100M}
ITERATIONS=${2:-5}
DEVICE="/dev/sda"
LOGFILE="/home/pete/servu/scripts/health_check.log"

echo "results will be saved in $LOGFILE"

echo "start SMART TEST on $DEVICE"
smartctl -t short "$DEVICE" >/dev/null 2>&1

START_TIME=$(date +%s)

echo "start memtest"
memtester "$MEMSIZE" "$ITERATIONS" >/dev/null 2>&1
EXIT_CODE=$?


ELAPSED=$(( $(date +%s) - START_TIME ))
WAIT_TIME=$((120 - ELAPSED))
if (( WAIT_TIME > 0 )); then
    echo "Waiting $WAIT_TIME seconds for SMART test to complete..."
    sleep $WAIT_TIME
fi


echo "get smartclt status"
LINE=$(smartctl -a "$DEVICE" | grep "# 1")

if [[ -z "$LINE" ]]; then
    DISK_STATUS= "[ERROR] No SMART self-test result found"
else
    STATUS=$(echo "$LINE" | awk '{print $5 " " $6 " " $7}')
    if [[ "$STATUS" != "Completed without error" ]]; then
        echo "Error found: ${STATUS}"
        DISK_STATUS="Disk: [ALERT] SMART test on $DEVICE did not complete cleanly: $LINE"
    else
        DISK_STATUS="Disk: no issues"
    fi
fi



  
echo "get RAM status"
declare -a errors

if (( RAM_EXIT_CODE == 0 )); then
    RAM_STATUS="RAM: no issues"
else
    (( RAM_EXIT_CODE & 0x01 )) && errors+=("memory allocation/locking error")
    (( RAM_EXIT_CODE & 0x02 )) && errors+=("stuck address test error")
    (( RAM_EXIT_CODE & 0x04 )) && errors+=("other tests error")
    ERROR_MSG=$(IFS=, ; echo "${errors[*]}")
    RAM_STATUS="RAM: issues detected - $ERROR_MSG"
fi
TIME=$(date)

echo "fill logfile ${LOGFILE}"
{
    echo "$TIME"
    echo "$RAM_STATUS"
    echo "$DISK_STATUS"
} > "$LOGFILE"


END_TIME=$(date +%s)
TOTAL_TIME=$(( END_TIME - START_TIME ))

echo "Health check complete in ${TOTAL_TIME} S. See $LOGFILE for details."