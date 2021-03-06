#!/bin/bash
#nxdomain
mv /etc/unbound/unboundadblock.conf /etc/unbound/unboundadblock.conf.bak

#list with 0.0.0.0
curl -o  /root/adblocklists/StevenBlack.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
curl -o  /root/adblocklists/bigdargon.txt https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
curl -o  /root/adblocklists/jdlingyu.txt https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
curl -o  /root/adblocklists/anudeepNDads.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
curl -o  /root/adblocklists/anudeepNDcoin.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/CoinMiner.txt
curl -o  /root/adblocklists/anudeepNDfacebook.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt

#list with 127.0.0.1
curl -o  /root/adblocklists/adaway.txt https://adaway.org/hosts.txt

#cat 0.0.0.0 lists 
cat /root/adblocklists/StevenBlack.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/bigdargon.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/jdlingyu.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDads.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDcoin.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDfacebook.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list

#cat 127.0.0.1 lists
cat /root/adblocklists/adaway.txt | grep '^127\.0\.0\.1' | awk '{print "local-zone: \""$2"\" always_nxdomain"}' >> /root/adblocklists/unboundadblock_temp.list


awk '!visited[$0]++' /root/adblocklists/unboundadblock_temp.list > /etc/unbound/unboundadblock.conf
rm /root/adblocklists/unboundadblock_temp.list
systemctl restart unbound.service
