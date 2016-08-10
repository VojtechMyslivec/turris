#!/bin/sh
# e.g. lan1-lan5
ledMin=1
ledMax=5
ledPrefix=lan
color="0088FF"

client_count=$( iw dev wlan0 station dump | grep '^Station' | wc -l )

rainbow "$ledPrefix" "$color" disable
for i in $( seq "$ledMin" "$ledMax" ); do
    # universal formula
    if [ "$(( i - ledMin ))" -lt "$client_count" ]; then
        rainbow "${ledPrefix}${i}" enable
    fi
done

