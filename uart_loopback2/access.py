#!/usr/bin/env python3
from serial import Serial
import string

with Serial("/dev/ttyACM0",timeout=1) as dev:
    dev.baudrate = 115200
    for i in range(0,2):
            dev.write(string.ascii_lowercase.encode());
            data = dev.read(100)
            print(data)
