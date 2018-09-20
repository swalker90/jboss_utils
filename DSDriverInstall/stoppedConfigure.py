#!/usr/bin/python

from xml.dom import minidom
import re
import copy
import sys
def create_postgresql_node(xmldoc):
    drivertag = xmldoc.createElement("driver")
    drivertag.attributes["name"]="postgres"
    drivertag.attributes["module"]="org.postgresql"

    driverclasstag = xmldoc.createElement("driver-class")
    driverclassname = xmldoc.createTextNode("org.postgresql.Driver")
    driverclasstag.appendChild(driverclassname)

    drivertag.appendChild(driverclasstag)
    return drivertag

def create_mysql_node(xmldoc):
    drivertag = xmldoc.createElement("driver")
    drivertag.attributes["name"]="mysql"
    drivertag.attributes["module"]="com.mysql"

    driverclasstag = xmldoc.createElement("driver-class")
    driverclassname = xmldoc.createTextNode("com.mysql.jdbc.Driver")
    driverclasstag.appendChild(driverclassname)

    drivertag.appendChild(driverclasstag)
    return drivertag

if len(sys.argv) < 2:
    print "wrong usage must pass the xml file to configure"
    sys.exit()

xmlfilename = sys.argv[1]
driver = sys.argv[2]

xml = minidom.parse(xmlfilename)

if driver == "postgresql":
    drivertag = create_postgresql_node(xml)
elif driver =="mysql":
    drivertag = create_mysql_node(xml)

driverstags = xml.getElementsByTagName("drivers")
for tag in driverstags:
    tag.appendChild(copy.copy(drivertag))

kindapretty = xml.toprettyxml()

pretty = '\n'.join([line for line in kindapretty.split("\n") if line.strip()])

updatedfile = file(xmlfilename, mode="w")
updatedfile.write(pretty)
updatedfile.close()
