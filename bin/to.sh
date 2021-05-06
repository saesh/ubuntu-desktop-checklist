#!/usr/bin/env bash

timeclockFile=${TIMELOG:-${HOME}/.${USER}.timeclock}

echo "o $(date '+%Y-%m-%d %H:%M:%S')" >> "$timeclockFile"
