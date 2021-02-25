#!/usr/bin/env python3
from serial import Serial
import string
import time

try:
        with Serial("/dev/ttyACM0",timeout=1) as dev:
            dev.baudrate = 115200
            for i in range(0,100):
                    dev.write("a".encode())
                    time.sleep(2)
except:
    print("closing ...")
