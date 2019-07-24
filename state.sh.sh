#!/bin/bash

echo 'Hostname' >>/tmp/state.log
hostname >>/tmp/state.log
echo '---------------------------' >>/tmp/state.log
echo 'Current Date & Time' >>/tmp/state.log
date >>/tmp/state.log
echo '---------------------------' >>/tmp/state.log
echo 'Current Load and Users Logged in' >>/tmp/state.log
who -H -u >>/tmp/state.log
echo '---------------------------' >>/tmp/state.log
echo 'Processes running' >>/tmp/state.log
ps lax >>/tmp/state.log



