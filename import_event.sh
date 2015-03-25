#!/bin/bash

EVENTS="$@"
CAL=Laburo

if [ -n "${EVENTS}" ]; then
    for EV in ${EVENTS}; do
        #
        # FIXME
        # Google BUG: the summary should not contain:
        #
        #     dots (.);
        #     quotes (');
        #     ampersand (&);
        #     leading spaces (^ );
        #     trailing spaces ( $);
        #
        SUMMARY="$( grep '^SUMMARY' "${EV}" | awk -F':' '{ print $2; }' | tr '.' '_' | tr -d "'" | tr -d "&" | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//' )"
        FOUND="$( ./gcalcli --nocolor --calendar="${CAL}" search "${SUMMARY}" | grep -i "${SUMMARY}" | tr -d '-' )"
        #
        # looked for an existing event with the same summary
        #
        if [ -z "${FOUND}" ]; then
            ./gcalcli --nocolor --calendar="${CAL}" import "${EV}"
            echo "[INFO] Imported <${SUMMARY}>"
        else
            #
            # check the event found also matches the date
            #
            EV_DATE="$( echo "${FOUND}" | awk '{ print $1 }' )"
            EV_DATE="$( grep "${EV_DATE}" "${EV}" | grep -c 'DTSTART' )"
            if [ "${EV_DATE}" = "0" ]; then
                ./gcalcli --nocolor --calendar="${CAL}" import "${EV}"
                echo "[INFO] Imported <${SUMMARY}> after checking the date"
            else
                echo "[WARNING] Skipping <${SUMMARY}> found on the same date"
            fi
        fi
    done
else
    echo "Usage: $0 [ical files ...]"
    echo "Imports the given files to Google Calendar.-"
    exit 1
fi
