#!/usr/bin/env bash

curl -XPOST "https://${TIMETRACKER_USERNAME}:${TIMETRACKER_PASSWORD}@${TIMETRACKER_URL}/stop" \
     -d '{"timestamp":"'"$(date '+%Y-%m-%d %H:%M:%S')"'"}'
