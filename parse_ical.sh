#!/bin/bash

LOG="$1"
DEL="-"

if [ -n "${LOG}" ]; then
    #
    # create a from-to file with the lines numbers of each event
    #
    egrep -n "(BEGIN|END)\:VCALENDAR" ${LOG} | grep 'BEGIN:' | awk 'BEGIN { FS=":"; } { print $1 }' > /tmp/.from
    egrep -n "(BEGIN|END)\:VCALENDAR" ${LOG} | grep 'END:' | awk 'BEGIN { FS=":"; } { print $1 }' > /tmp/.to
    paste -d"${DEL}" /tmp/.from /tmp/.to > /tmp/.events

    #
    # start extracting events
    #
    for I in $( cat /tmp/.events ); do
        BEG="$( echo "${I}" | cut -d"${DEL}" -f1 )"
        END="$( echo "${I}" | cut -d"${DEL}" -f2 )"
        if [ -n "${BEG}" ] && [ -n "${END}" ]; then
            OUT="/tmp/.${END}.ical"
            cat ${LOG} | awk "NR >= ${BEG} && NR <= ${END}" > ${OUT}
            echo "[INFO] Event ${OUT} created"
        else
            echo "[WARNING] Invalid interval ${I}"
        fi
    done
else
    echo "Usage: $0 [DavMail log]"
    echo "Parses individual iCal events from a DavMail log file.-"
    exit 1
fi

