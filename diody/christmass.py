#!/usr/bin/env python3
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


USAGE = """USAGE:
    %s
""" % sys.argv[0]

# LED would be enabled with given probability (and disabled  with 1-p)
PROB_ENABLED = 0.3

# maximum delay between 2 events
SLEEP_MAX = 3

# list of Turris leds
LEDS = [
        'pwr',
        'lan0',
        'lan1',
        'lan2',
        'lan3',
        'lan4',
        'wan',
        'pci1',
        'pci2',
        'pci3',
        'usr1',
        'usr2',
]

# list of used colors
COLORS = [
        "00FF00", # green
        "0000AA", # blue
        "FF6600", # yellow
        "FF0000", # red
]


def cleanup():
    call(["/etc/init.d/rainbow", "restart"])

# trap signal
def signal_handler(signal, frame):
    cleanup()
    sys.exit(0)


def main():
    # usage
    if len(sys.argv) < 1:
        sys.stderr.write(USAGE)
        exit(1)

    # trap signals
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGHUP, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # disable all LEDs to start from scratch
    call(["rainbow", "all", "disable"])

    # randomly blink LEDs
    while True:
        if random() > PROB_ENABLED:
            random_state = "enable"
        else:
            random_state = "disable"

        random_led   = choice(LEDS)
        random_color = choice(COLORS)
        random_sleep = random() * SLEEP_MAX

        call(["rainbow", random_led, random_state])
        call(["rainbow", random_led, random_color])
        sleep(random_sleep)

    cleanup()


if __name__ == "__main__":
    main()
