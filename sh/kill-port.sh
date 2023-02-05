#!/usr/bin/bash
re='^[0-9]+$'

if [ -z "$1" ] ; then
        echo "Usage: $0 <port number>"; exit 1;
elif ! [[ $1 =~ $re ]] ; then
        echo "Input is not a valid number." >&2; exit 1;
fi

port=`lsof -t -i :$1`

if [ -z "$port" ]; then
        echo "No process running on certain port."
        exit 1
fi

if ! (kill -9 $port &>/dev/null); then
        echo "kill error!"
        exit 1
else
        echo "Killed port $1."
        exit 0
