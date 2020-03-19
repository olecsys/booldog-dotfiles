#!/usr/bin/env bash

echo "TEST!!! ${SSH_AUTH_SOCK} ${SSH_AGENT_PID}" > /tmp/booldog_launch_apps.sh.log

gnome-keyring-daemon --start --components=pkcs11 &

zoom &
code &
opera &