#!/bin/sh
# e.g. lan1-lan5
ledMin=0
ledMax=4
ledPrefix=lan
color="0088FF"
color_off="FF2200"
delay=0.5

client_count=$( iw dev wlan0 station dump | grep '^Station' | wc -l )

rainbow "$ledPrefix" "$color" disable
for i in $( seq "$ledMin" "$ledMax" ); do
    # universal formula
    if [ "$(( i - ledMin ))" -lt "$client_count" ]; then
        rainbow "${ledPrefix}${i}" enable
    fi
    sleep "$delay"
done

sleep 25
rainbow lan "$color_off" auto
