#!/usr/bin/python3
# Script to shine Turris Omnia like a chrisstmass tree
#
# author: Vojtech Myslivec <vojtech@xmyslivec.cz>
# inspired by:
#  - CZ.NIC, z.s.p.o. (https://doc.turris.cz/doc/en/howto/led_settings)
#

import sys
import signal
from random import random,choice
from math import floor
from time import sleep
from subprocess import call

def cleanup():
    call( [ "/etc/init.d/rainbow", "restart" ])

# odchyt signalu interrupt
def trap_sigint( signal, frame ):
    sys.stderr.write( "Chycen SIGINT, uklizim a koncim.\n")
    uklid()
    sys.exit(0)

#signal.signal( signal.SIGINT, trap_sigint )


usage = """USAGE:
    %s
""" % sys.argv[0]


# sleep cas v [s] -- mezi dvema radkama v souboru
sleep_max = 3

# list of Turris leds
leds = [ 'pwr', 'lan0', 'lan1', 'lan2', 'lan3', 'lan4', 'wan', 'pci1', 'pci2', 'pci3', 'usr1', 'usr2' ]

# seznam barev, ktere ma stridat
colors = [
            "00FF00",
            "0000AA",
            "FF6600",
            "FF0000",
         ]

if ( len(sys.argv) < 1 ):
    sys.stderr.write(usage)
    exit(1)


call([ "rainbow", "all", "disable" ])

while True:
    if random() > 0.3:
        random_state = "enable"
    else:
        random_state = "disable"

    random_led   = choice(leds)
    random_color = choice(colors)
    random_sleep = random()*sleep_max

    call([ "rainbow", random_led, random_state ])
    call([ "rainbow", random_led, random_color ])
    sleep( random_sleep )


cleanup()
