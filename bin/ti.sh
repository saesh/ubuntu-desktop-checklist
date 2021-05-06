#!/usr/bin/env bash

timeclockFile=${TIMELOG:-${HOME}/.${USER}.timeclock}

if [[ -f "$timeclockFile" && "$(tail -1 "$timeclockFile" | cut -c 1)" == "i" ]]; then
    to
fi

echo "i $(date '+%Y-%m-%d %H:%M:%S') $*" >> "$timeclockFile"
