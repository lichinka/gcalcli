#!/bin/bash

LOG="$1"
DEL="-"

if [ -n "${LOG}" ]; then
    #
    # create a from-to file with the lines numbers of each event
    #
    egrep -n "(BEGIN|END)\:VCALENDAR" "${LOG}" | grep 'BEGIN:' | awk 'BEGIN { FS=":"; } { print $1 }' > /tmp/.from
    egrep -n "(BEGIN|END)\:VCALENDAR" "${LOG}" | grep 'END:' | awk 'BEGIN { FS=":"; } { print $1 }' > /tmp/.to
    paste -d"${DEL}" /tmp/.from /tmp/.to > /tmp/.events

    #
    # start extracting events
    #
    while read line
    do
        BEG="$( echo "${line}" | cut -d"${DEL}" -f1 )"
        END="$( echo "${line}" | cut -d"${DEL}" -f2 )"
        if [ -n "${BEG}" ] && [ -n "${END}" ]; then
            OUT="/tmp/.${END}.ical"
            awk "NR >= ${BEG} && NR <= ${END}" "${LOG}" > "${OUT}"
            echo "[INFO] Event ${OUT} created"
        else
            echo "[WARNING] Invalid interval ${line}"
        fi
    done < /tmp/.events
else
    echo "Usage: $0 [DavMail log]"
    echo "Parses individual iCal events from a DavMail log file.-"
    exit 1
fi

