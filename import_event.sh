#!/bin/bash

EVENT=$1
CAL=Laburo

if [ -n "${EVENT}" ]; then
    SUMMARY="$( grep '^SUMMARY' "${EVENT}" | cut -d':' -f2 )"
    FOUND="$( ./gcalcli --calendar ${CAL} search "${SUMMARY}" | grep -i 'no events found' )"
    if [ -n "${FOUND}" ]; then
        ./gcalcli --calendar ${CAL} import "${EVENT}"
    else
        echo "[WARNING] Not importing ${EVENT} because its summary was found in <${CAL}>"
    fi
else
    echo "Usage: $0 [ical file]"
    echo "Imports [ical file] to Google Calendar.-"
    exit 1
fi
