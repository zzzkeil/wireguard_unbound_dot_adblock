#!/bin/bash
#test01
mv /etc/unbound/unboundadblock.conf /etc/unbound/unboundadblock.conf.bak


wget -O  /root/adblocklists/StevenBlack.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
wget -O  /root/adblocklists/bigdargon.txt https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
wget -O  /root/adblocklists/jdlingyu.txt https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
wget -O  /root/adblocklists/anudeepNDads.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
wget -O  /root/adblocklists/anudeepNDcoin.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/CoinMiner.txt
wget -O  /root/adblocklists/anudeepNDfacebook.txt https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt

cat /root/adblocklists/StevenBlack.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/bigdargon.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/jdlingyu.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDads.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDcoin.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list
cat /root/adblocklists/anudeepNDfacebook.txt | grep '^0\.0\.0\.0' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' >> /root/adblocklists/unboundadblock_temp.list

awk '!visited[$0]++' /root/adblocklists/unboundadblock_temp.list > /etc/unbound/unboundadblock.conf
rm /root/adblocklists/unboundadblock_temp.list
