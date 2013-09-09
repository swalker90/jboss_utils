#!/usr/bin/python

from xml.dom import minidom
import re
import copy
import sys

if len(sys.argv) < 1:
    print "wrong usage must pass the xml file to configure"
    sys.exit()

xmlfilename = sys.argv[1]


xmldoc = minidom.parse(xmlfilename)

drivertag = xmldoc.createElement("driver")
drivertag.attributes["name"]="postgres"
drivertag.attributes["module"]="org.postgresql"

driverclasstag = xmldoc.createElement("driver-class")
driverclassname = xmldoc.createTextNode("org.postgresql.Driver")
driverclasstag.appendChild(driverclassname)

drivertag.appendChild(driverclasstag)

driverstags = xmldoc.getElementsByTagName("drivers")
for tag in driverstags:
    tag.appendChild(copy.copy(drivertag))

kindapretty = xmldoc.toprettyxml()

pretty = '\n'.join([line for line in kindapretty.split("\n") if line.strip()])

updatedfile = file(xmlfilename, mode="w")
updatedfile.write(pretty)
updatedfile.close()
