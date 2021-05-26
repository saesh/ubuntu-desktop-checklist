#!/usr/bin/env bash

curl -XPOST "https://${TIMETRACKER_USERNAME}:${TIMETRACKER_PASSWORD}@${TIMETRACKER_URL}/start" \
     -d '{"timestamp":"'"$(date '+%Y-%m-%d %H:%M:%S')"'","description":"'$*'"}'
