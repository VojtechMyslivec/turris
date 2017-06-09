#!/usr/bin/python
# Script to show current clocks on Turris Omnia
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

# there are 12 leds
def binmask_of_led( id ):
    return 2**(11-id)

def color_of_led( id ):
    return color_hours[i%len(color_hours)]

# current time
d = datetime.datetime.now().time()
hours = d.hour
minutes = d.minute

# binmask for `rainbow`
binmask = 0

# Define hours colors ----------------------------
# hours (12-hour format)
hours = hours % 12

# count the binmask for hours and set the color for colors
for i in range( 0, hours ):
    binmask += binmask_of_led(i)
    subprocess.call([ 'rainbow', leds[i], color_of_led(i) ])


# Define minutes color ---------------------------
# another led for hours
i = hours

# count the shade of minute led
color_minute = round(minutes*0xFF/60)*0x010101

# apply the color and enable the last led
binmask += binmask_of_led(i)
subprocess.call([ 'rainbow', leds[i], '%06X'%color_minute ])


# Light the leds ---------------------------------
subprocess.call([ 'rainbow', 'binmask', str(binmask) ])
