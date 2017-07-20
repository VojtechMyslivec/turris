#!/bin/sh
## POSIX shell script OMG!

USAGE="USAGE
    $0 -h
    $0 repeat delay cycle wait killer_feature binmask_file...

DESCRIPTION
    (non-comfort) wrapper for killer-feature.py
    Calls 'killer_feature' script for every 'binmask_file' in a cycle with
    specific delay between them.

OPTIONS
    -h      Display this message and exit

    repeat  Call 'killer_feature' 'repeat' times with every 'binmask_file'

    delay   Sleep for 'delay' seconds between 'binmask_files'

    cycle   Repeat throw all 'binmask_files' 'cycle' times (use 'inf' for
            endless loop)

    wait    Sleep for 'wait' seconds between cycles

    killer_feature  path to a killer_feature scipt

    binmask_file    files with effect in binmask format

EXAMPLES
    Do nothing
        ./killer-feature_wrapper.sh 0 0 0 0 diody/killer-feature.py diody/omnia/*.binmask

    Run all effects once
        ./killer-feature_wrapper.sh 1 0 1 0 diody/killer-feature.py diody/omnia/*.binmask

    Run all effects 5 times with 10 s delay every minute (for ever)
        ./killer-feature_wrapper.sh 5 10 inf 60 diody/killer-feature.py diody/omnia/*.binmask

    Knight rider for ever
        ./killer-feature_wrapper.sh 1 0 inf 0 diody/omnia/10-bi-linearni.binmask

    Repeat some effects for ever
        ./killer-feature_wrapper.sh 1 0 inf 10 diody/killer-feature.py diody/omnia/40-had.binmask diody/omnia/50-ping-pong.binmask

        ./killer-feature_wrapper.sh 1 0 inf 10 diody/omnia/15-tetris.binmask diody/omnia/30-rostouci.binmask"

error() {
    echo "$*" >&2
}

readable_file() {
    [ -f "$1" -a -r "$1" ]
}

integer() {
    echo "$1" | grep -Eq "^[0-9]+$"
}

sleep_for() {
    rainbow all disable
    sleep "$1"
}

# USAGE ------------------------------------------
[ $# -eq 1 ] && [ "$1" = '-h' ] && {
    echo "$USAGE"
    exit 0
}

[ $# -gt 5 ] || {
    error "Wrong number of arguments"
    exit 1
}

repeat="$1"
delay="$2"
cycle="$3"
wait="$4"
killer_feature="$5"
# files are rest of the args
shift 5


integer "$repeat" || {
    echo "repeat '$repeat' must be an integer"
    exit 1
}

integer "$delay" || {
    echo "delay '$delay' must be an integer"
    exit 1
}

integer "$cycle" || [ "$cycle" = "inf" ] || {
    echo "cycle '$cycle' must be an integer or 'inf'"
    exit 1
}

integer "$delay" || {
    echo "delay '$delay' must be an integer"
    exit 1
}

readable_file "$killer_feature" || {
    echo "killer_feature '$killer_feature' is not readable file"
    exit 1
}

for arg; do
    readable_file "$arg" || {
        echo "binmask_file '$arg' is not readable file"
        exit 1
    }
done

i=0
while [ "$cycle" = 'inf' ] || [ "$i" -lt "$cycle" ]; do
    i=$( expr $i + 1 )

    for arg; do
        j=0

        while [ "$j" -lt "$repeat" ]; do
            j=$( expr $j + 1 )
            python "$killer_feature" "$arg"
        done

        sleep_for "$delay"
    done

    sleep_for "$wait"
done
