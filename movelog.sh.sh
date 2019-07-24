#! /bin/bash

sleep 5
find /tmp/state.* -type f -mtime +14 -exec rm -f {} \;
cat /tmp/state.log >> /tmp/state.$(date +"%Y%m%d")
rm /tmp/state.log
