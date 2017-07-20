#!/usr/bin/python
# Script to show current clocks on Turris Omnia
#
# Turns on as many LEDs as number of hours in 12-hour format with defined
# colors. And turn on one more with 'grey' color representing number of minutes
# in current hour.
#
# author:       Vojtech Myslivec <vojtech@xmyslivec.cz>
#

import datetime
import subprocess

# ------------------------------------------------
# list of Turris leds
leds = [ 'pwr', 'lan0', 'lan1', 'lan2', 'lan3', 'lan4', 'wan', 'pci1', 'pci2', 'pci3', 'usr1', 'usr2' ]

# list of colors to indicate hours
color_hours = [ 'FF0000', 'FF6600' ]

def color_of_led( id ):
    return color_hours[i%len(color_hours)]

# current time
d = datetime.datetime.now().time()
hours = d.hour
minutes = d.minute

# turn off all LEDs
subprocess.call([ 'rainbow', 'all', 'disable' ])

# Define hours colors ----------------------------
# hours (12-hour format)
hours = hours % 12

# enable LEDs with defined color
for i in range( 0, hours ):
    subprocess.call([ 'rainbow', leds[i], 'enable', color_of_led(i) ])


# Define minutes color ---------------------------
# another led for hours
i = hours

# count the shade of minute led
color_minute = round(minutes*0xFF/60)*0x010101

# apply the color and enable the last led
subprocess.call([ 'rainbow', leds[i], 'enable', '%06X'%color_minute ])
