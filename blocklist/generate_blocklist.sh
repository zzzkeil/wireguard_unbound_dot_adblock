#!/bin/bash
#test01
mv /etc/unbound/unboundadblock.conf /etc/unbound/unboundadblock.conf.bak

#list with 0.0.0.0
curl -o  /root/adblocklists/StevenBlack.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
curl -o  /root/adblocklists/bigdargon.txt https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
curl -o  /root/adblocklists/jdlingyu.txt https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
curl -o  /root/adblocklists/anudeepNDads.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
curl -o  /root/adblocklists/anudeepNDcoin.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/CoinMiner.txt
curl -o  /root/adblocklists/anudeepNDfacebook.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt

#list with 127.0.0.1
curl -o  /root/adblocklists/malwaredomainlist.txt https://www.malwaredomainlist.com/hostslist/hosts.txt
curl -o  /root/adblocklists/hostsfileorg.txt https://hostsfile.org/Downloads/hosts.txt
curl -o  /root/adblocklists/adaway.txt https://adaway.org/hosts.txt

#cat 0.0.0.0 lists grep '^0\.0\.0\.0' test1.txt | awk '{print "local-zone: \""$2"\" always_nxdomain"}' > test.txt
cat /root/adblocklists/StevenBlack.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/bigdargon.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/jdlingyu.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDads.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDcoin.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDfacebook.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list

#cat 127.0.0.1 lists
cat /root/adblocklists/malwaredomainlist.txt | grep '^127\.0\.0\.1' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/hostsfileorg.txt | grep '^127\.0\.0\.1' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/adaway.txt | grep '^127\.0\.0\.1' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list


awk '!visited[$0]++' /root/adblocklists/unboundadblock_temp.list > /etc/unbound/unboundadblock.conf
rm /root/adblocklists/unboundadblock_temp.list
