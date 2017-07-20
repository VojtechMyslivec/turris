#!/usr/bin/python
# Script to achive simple Turris LED effects comfortably
#
# author: Vojtech Myslivec <vojtech@xmyslivec.cz>
# inspired by:
#  - CZ.NIC, z.s.p.o. [https://www.turris.cz/doc/navody/nastaveni_led_diod]
#  - Petr Holecek [~~http://www.ryu.cz/hardware/router-turris-ovladani-rgb-led/~~ gone]
#

import sys
import signal
import time
from subprocess import call

def uklid():
    call( [ "/etc/init.d/rainbow", "restart" ])

# odchyt signalu interrupt
def sigint_odchyt( signal, frame ):
    sys.stderr.write( "Chycen SIGINT, uklizim a koncim.\n")
    uklid()
    sys.exit(0)

signal.signal( signal.SIGINT, sigint_odchyt )


usage = """USAGE:
    %s soubor.binmask...

    soubor.binmask  Soubor obsahujici vzor pro rosviceni diod.
                    Na kazdem radku musi byt presne 8-bit cislo
                    ve dvojkove soustave.
                    1 odpovida, ze dana dioda sviti, 0 ze nesviti
""" % sys.argv[0]


# sleep cas v [s] -- mezi dvema radkama v souboru
cekej = 0.1

# seznam barev, ktere ma stridat
barvy = [
            "FFFFFF",
            "FFFF00",
            "88FF00",
            "00FF00",
            "00FF88",
            "00FFFF",
            "0088FF",
            "0000FF",
            "8800FF",
            "FF00FF",
            "FF0088",
            "FF0000",
            "FF8800",
         ]

if ( len(sys.argv) < 2 ):
    sys.stderr.write(usage)
    exit(1)

if ( sys.argv[1] == "-h" or sys.argv[1] == "--help" ):
    sys.stdout.write(usage)
    exit(0)

barva = 0
nulty = True
# pro vsechny argumenty krome nulteho
for arg in sys.argv:
    if ( nulty ):
        nulty = False;
        continue

    try:
        soubor = open( arg, "r" )
    except IOError:
        sys.stderr.write( "Nelze otevrit soubor '%s'\n" % arg )
        exit(2)


    # zparsuje vstupni soubor
    with soubor:
        for radka in soubor:
            # kazda radka je binarni maska pro zapnuti diod
            # => prevede se na int a ten se preda utilite rainbow
            n = int( radka, 2 )

            call([ "rainbow", "all", barvy[barva] ])
            call([ "rainbow", "binmask", str(n) ])

            barva = ( barva + 1 ) % len(barvy)

            time.sleep( cekej )


uklid()
