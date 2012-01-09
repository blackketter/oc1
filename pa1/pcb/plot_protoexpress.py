#!/usr/bin/env python
import sys
import re
import sdxf

f = open("protoexpress.err", "r")

done = 0

errors = 0

line = 1
d = sdxf.Drawing()

d.layers.append(sdxf.Layer(name="textlayer", color=3))
radius = 0.025

while not done:
    l = f.readline()
    if (l):
        m = re.match(".*X: ([\\d\\.]+).*Y: ([\\d\\.]+).*", l)
        if (m):
            x = float(m.group(1))
            y = float(m.group(2))
            errors = errors + 1
            x = x  - 1
            y = y  - 1
            d.append(sdxf.Circle(center=(x, y, 0), radius=radius, color=3))
            print x, y
        line = line + 1
    else:
        done = 1

d.saveas("err.dxf")
print "Found %d errors.  Saved in err.dxf" % errors

