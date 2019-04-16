#!/bin/sh

server='remote.server.pub'
user='ssh-user'
port='12345'

seconds=120

while true; do
    echo "Starting ssh tunel" >&2
    ssh -nNT -o ServerAliveInterval=15 -R "$port:localhost:22" -l "$user" "$server"
    echo "ssh tunel exited: $?; waiting for $seconds seconds" >&2
    sleep "$seconds"
done
