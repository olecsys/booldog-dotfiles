#!/usr/bin/env bash

gnome-keyring-daemon --start --components=pkcs11 &

code &
opera &