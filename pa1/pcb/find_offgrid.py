#!/usr/bin/env python

import sys
import re
import sdxf

f = open("gerbers/00-drill-nc.drl", "r")

done = 0

not_offgrid = 0
offgrid = 0
line = 1
d = sdxf.Drawing()

d.layers.append(sdxf.Layer(name="textlayer", color=3))
radius = 0.025

while not done:
    l = f.readline()
    if (l):
        m = re.search("^X(\\d+)Y(\\d+)$", l)
        if (m):
            x = int(m.group(1))
            y = int(m.group(2))
            if ( (x % 10) == 0 and (y % 10) == 0):
                not_offgrid = not_offgrid + 1
            else:
                offgrid  = offgrid + 1
                x = float(x) / 10000 - 1
                y = float(y) / 10000 - 1
                d.append(sdxf.Circle(center=(x, y, 0), radius=radius, color=3))
        line = line + 1
    else:
        done = 1
d.saveas("offgrid.dxf")

known_off_grid =  4 * 9 * 6 + 14
offgrid = offgrid - known_off_grid
not_offgrid = not_offgrid - known_off_grid

print "Total offgrid objects = %d/%d (%0.0f%%)" % (offgrid, not_offgrid, float(offgrid)/(not_offgrid+offgrid) * 100)
