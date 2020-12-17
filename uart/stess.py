#!/usr/bin/env python3
from serial import Serial
import string

with Serial("/dev/ttyACM0",timeout=1) as dev:
    dev.baudrate = 115200
    for i in range(0,10):
            message = string.ascii_lowercase * 30
            dev.write(message.encode());
            data = dev.read(len(message))
            assert len(data) == len(message)
            assert message.encode() == data

