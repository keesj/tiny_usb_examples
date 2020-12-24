#!/usr/bin/env python3
from serial import Serial
import string

with Serial("/dev/ttyACM0",timeout=1) as dev:
    dev.baudrate = 115200
    for i in range(0,2):
            d = string.ascii_lowercase.encode()[:20]
            dev.write(d)
            #dev.write(string.ascii_lowercase.encode());
            data = dev.read(len(d))
            print(data)
