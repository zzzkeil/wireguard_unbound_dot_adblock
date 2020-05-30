#!/bin/bash
clear
echo " ##############################################################################"
echo " #  NOT ready to run jet    :)  be aware                                      #"
echo " #  just a modify copy of the Wireguard-DNScrypt-VPN-Server repos.            #"
echo " ##############################################################################"
echo " ##############################################################################"
echo " # Version 2020.05.26                                                         #"
echo " ##############################################################################"
echo ""
echo ""
echo ""
echo "To EXIT this script press  [ENTER]"
echo 
read -p "To RUN this script press  [Y]" -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
#
### root check
if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi
#
### base_setup check
if [[ -e /root/base_setup.README ]]; then
     echo "base_setup script installed - OK"
	 else
	 wget -O  base_setup.sh https://raw.githubusercontent.com/zzzkeil/base_setups/master/base_setup.sh
         chmod +x base_setup.sh
	 echo ""
	 echo ""
	 echo " Attention !!! "
	 echo " My base_setup script not installed,"
         echo " you have to run ./base_setup.sh manualy now and reboot, after that you can run this script again."
	 echo ""
	 echo ""
	 exit 1
fi
#
### OS version check
if [[ -e /etc/debian_version ]]; then
      echo "Debian Distribution"
      else
      echo "This is not a Debian Distribution."
      exit 1
fi
#
### script already installed check
if [[ -e /root/wireguard_unbound_setup.README ]]; then
     echo
	 echo
         echo "Looks like this script is already installed"
	 echo "This script is only for the first install"
	 echo ""
	 echo "To add or remove clients run"
         echo " ./add_client.sh to add clients"
         echo " ./remove_client.sh	to remove clients" 
	 echo ""
	 echo "More instructions in this file: "
	 echo "/root/wireguard_unbound_setup.README"
	 echo ""
	 echo "For - News / Updates / Issues - check my github site"
	 echo "https://github.com/zzzkeil/wireguard_unbound_doh_adblock"
	 echo
	 echo
	 exit 1
fi
#
### create backupfolder for original files
mkdir /root/script_backupfiles/
#
### wireguard port stettings
echo " Make your port settings now:"
echo "------------------------------------------------------------"
read -p "Choose your Wireguard Port: " -e -i 51820 wg0port
echo "------------------------------------------------------------"
#
### apt systemupdate and installs	 
echo
VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
if [[ "$VERSION_ID" = 'VERSION_ID="10"' ]]; then
	echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
        printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable
fi

if [[ "$VERSION_ID" = 'VERSION_ID="18.04"' ]]; then
    add-apt-repository ppa:wireguard/wireguard
fi

if [[ "$VERSION_ID" = 'VERSION_ID="20.04"' ]]; then
    add-apt-repository ppa:wireguard/wireguard
fi

apt update && apt upgrade -y && apt autoremove -y
apt install qrencode unbound unbound-host python curl linux-headers-$(uname -r) -y 
apt install wireguard-dkms wireguard-tools -y
#
### setup ufw and sysctl
inet=$(ip route show default | awk '/default/ {print $5}')
ufw allow $wg0port/udp
cp /etc/default/ufw /root/script_backupfiles/ufw.orig
cp /etc/ufw/before.rules /root/script_backupfiles/before.rules.orig
cp /etc/ufw/before6.rules /root/script_backupfiles/before6.rules.orig
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n-A POSTROUTING -s 10.8.0.0/24 -o $inet -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before.rules
sed -i '/# End required lines/a \\n-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.8.0.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.8.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/a \\n# allow outbound icmp\n-A ufw-before-output -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT\n-A ufw-before-output -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT\n' /etc/ufw/before.rules
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n\n-A POSTROUTING -s fd42:42:42:42::/112 -o $inet -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before6.rules
sed -i '/# End required lines/a \\n-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:42:42:42::1/64 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:42:42:42::1/64 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT' /etc/ufw/before6.rules
cp /etc/sysctl.conf /root/script_backupfiles/sysctl.conf.orig
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
cp /etc/ufw/sysctl.conf /root/script_backupfiles/sysctl.conf.ufw.orig
sed -i 's@#net/ipv4/ip_forward=1@net/ipv4/ip_forward=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/default/forwarding=1@net/ipv6/conf/default/forwarding=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/all/forwarding=1@net/ipv6/conf/all/forwarding=1@g' /etc/ufw/sysctl.conf
#
### setup wireguard keys and configs
mkdir /etc/wireguard/keys
chmod 700 /etc/wireguard/keys

touch /etc/wireguard/keys/server0
chmod 600 /etc/wireguard/keys/server0
wg genkey > /etc/wireguard/keys/server0
wg pubkey < /etc/wireguard/keys/server0 > /etc/wireguard/keys/server0.pub

touch /etc/wireguard/keys/client1
chmod 600 /etc/wireguard/keys/client1
wg genkey > /etc/wireguard/keys/client1
wg pubkey < /etc/wireguard/keys/client1 > /etc/wireguard/keys/client1.pub

touch /etc/wireguard/keys/client2
chmod 600 /etc/wireguard/keys/client2
wg genkey > /etc/wireguard/keys/client2
wg pubkey < /etc/wireguard/keys/client2 > /etc/wireguard/keys/client2.pub

touch /etc/wireguard/keys/client3
chmod 600 /etc/wireguard/keys/client3
wg genkey > /etc/wireguard/keys/client3
wg pubkey < /etc/wireguard/keys/client3 > /etc/wireguard/keys/client3.pub

touch /etc/wireguard/keys/client4
chmod 600 /etc/wireguard/keys/client4
wg genkey > /etc/wireguard/keys/client4
wg pubkey < /etc/wireguard/keys/client4 > /etc/wireguard/keys/client4.pub

touch /etc/wireguard/keys/client5
chmod 600 /etc/wireguard/keys/client5
wg genkey > /etc/wireguard/keys/client5
wg pubkey < /etc/wireguard/keys/client5 > /etc/wireguard/keys/client5.pub

### -
echo "[Interface]
Address = 10.8.0.1/24
Address = fd42:42:42:42::1/112
ListenPort = $wg0port
PrivateKey = SK01
# client1
[Peer]
PublicKey = PK01
AllowedIPs = 10.8.0.11/32, fd42:42:42:42::11/128
# client2
[Peer]
PublicKey = PK02
AllowedIPs = 10.8.0.12/32, fd42:42:42:42::12/128
# client3
[Peer]
PublicKey = PK03
AllowedIPs = 10.8.0.13/32, fd42:42:42:42::13/128
# client4
[Peer]
PublicKey = PK04
AllowedIPs = 10.8.0.14/32, fd42:42:42:42::14/128
# client5
[Peer]
PublicKey = PK05
AllowedIPs = 10.8.0.15/32, fd42:42:42:42::15/128
# -end of default clients
" > /etc/wireguard/wg0.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0)@" /etc/wireguard/wg0.conf
sed -i "s@PK01@$(cat /etc/wireguard/keys/client1.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK02@$(cat /etc/wireguard/keys/client2.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK03@$(cat /etc/wireguard/keys/client3.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK04@$(cat /etc/wireguard/keys/client4.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK05@$(cat /etc/wireguard/keys/client5.pub)@" /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf

### -
echo "[Interface]
Address = 10.8.0.11/32
Address = fd42:42:42:42::11/128
PrivateKey = CK01
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client1.conf
sed -i "s@CK01@$(cat /etc/wireguard/keys/client1)@" /etc/wireguard/client1.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client1.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client1.conf
chmod 600 /etc/wireguard/client1.conf

echo "[Interface]
Address = 10.8.0.12/32
Address = fd42:42:42:42::12/128
PrivateKey = CK02
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client2.conf
sed -i "s@CK02@$(cat /etc/wireguard/keys/client2)@" /etc/wireguard/client2.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client2.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client2.conf
chmod 600 /etc/wireguard/client2.conf

echo "[Interface]
Address = 10.8.0.13/32
Address = fd42:42:42:42::13/128
PrivateKey = CK03
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client3.conf
sed -i "s@CK03@$(cat /etc/wireguard/keys/client3)@" /etc/wireguard/client3.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client3.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client3.conf
chmod 600 /etc/wireguard/client3.conf

echo "[Interface]
Address = 10.8.0.14/32
Address = fd42:42:42:42::14/128
PrivateKey = CK04
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client4.conf
sed -i "s@CK04@$(cat /etc/wireguard/keys/client4)@" /etc/wireguard/client4.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client4.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client4.conf
chmod 600 /etc/wireguard/client4.conf

echo "[Interface]
Address = 10.8.0.15/32
Address = fd42:42:42:42::15/128
PrivateKey = CK05
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client5.conf
sed -i "s@CK05@$(cat /etc/wireguard/keys/client5)@" /etc/wireguard/client5.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client5.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client5.conf
chmod 600 /etc/wireguard/client5.conf
#
### setup unbound
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
curl -o /etc/unbound/unbound.conf https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/configs/unbound.conf
chown -R unbound:unbound /var/lib/unbound
######################################
# todo !
### setup Blacklist and a Whitelist from (anudeepND)"
mkdir /root/adblocklists/
#test neu
curl -sS -L --compressed "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&mimetype=plaintext" > /root/utils/pgl.yoyo.org.conf



#alt 
#curl -o /root/utils/generate-domains-blacklists/domains-blacklist.conf https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/blocklist/domains-blacklist-default.conf
#curl -o /root/utils/generate-domains-blacklists/domains-blacklist-local-additions.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-blacklist-local-additions.txt
#curl -o /root/utils/generate-domains-blacklists/domains-time-restricted.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-time-restricted.txt
#curl -o /root/utils/generate-domains-blacklists/domains-whitelist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
#curl -o /root/utils/generate-domains-blacklists/generate-domains-blacklist.py https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/generate-domains-blacklist.py
#chmod +x /root/utils/generate-domains-blacklists/generate-domains-blacklist.py
#cd /root/utils/generate-domains-blacklists/
#./generate-domains-blacklist.py > /root/utils/adblocklist
cd
## check if generate blacklist failed - file is empty
#curl -o /root/utils/generate-domains-blacklists/checkblacklist.sh https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/configs/checkblacklist.sh
#chmod +x /root/utils/generate-domains-blacklists/checkblacklist.sh
#
### create crontabs
#(crontab -l ; echo "50 23 * * 4 cd /root/utils/generate-domains-blacklists/ &&  ./generate-domains-blacklist.py > /root/utils/adblocklist") | sort - | uniq - | crontab -
#(crontab -l ; echo "40 23 * * 4 curl -o /root/utils/generate-domains-blacklists/domains-whitelist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt") | sort - | uniq - | crontab -
#(crontab -l ; echo "30 23 * * 4 curl -o /root/utils/generate-domains-blacklists/domains-blacklist.conf https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/blocklist/domains-blacklist-default.conf") | sort - | uniq - | crontab -
#(crontab -l ; echo "15 * * * 5 cd /root/utils/generate-domains-blacklists/ &&  ./root/utils/generate-domains-blacklists/checkblacklist.sh") | sort - | uniq - | crontab -
#(crontab -l ; echo "59 23 * * 4,5 /bin/systemctl restart unbound.service") | sort - | uniq - | crontab -
#
### setup systemctl
systemctl stop systemd-resolved
systemctl disable systemd-resolved
cp /etc/resolv.conf /etc/resolv.conf.orig
rm -f /etc/resolv.conf
systemctl enable unbound
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
cp /etc/systemd/system/multi-user.target.wants/unbound.service /root/script_backupfiles/unbound.service.orig
systemctl disable unbound
curl -o /lib/systemd/system/unbound.service https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/configs/unbound.service
systemctl enable unbound
systemctl restart unbound
#
### set file for install check and tools download"
echo "
+++ do not delete this file +++
Instructions coming soon 
For - News / Updates / Issues - check my github site
https://github.com/zzzkeil/wireguard_unbound_doh_adblock
" > /root/wireguard_unbound_doh_adblock.README
curl -o add_client.sh https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/tools/add_client.sh
curl -o remove_client.sh https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/tools/remove_client.sh
#
### finish
clear
echo ""
echo "QR Code for client1.conf "
qrencode -t ansiutf8 < /etc/wireguard/client1.conf
echo "Scan the QR Code with your Wiregard App"
qrencode -o /etc/wireguard/client1.png < /etc/wireguard/client1.conf
qrencode -o /etc/wireguard/client2.png < /etc/wireguard/client2.conf
qrencode -o /etc/wireguard/client3.png < /etc/wireguard/client3.conf
qrencode -o /etc/wireguard/client4.png < /etc/wireguard/client4.conf
qrencode -o /etc/wireguard/client5.png < /etc/wireguard/client5.conf
echo "4 extra client.conf and QR Codes files in folder : /etc/wireguard/"
echo ""
echo " to add or remove clients run ./add_client.sh or remove_client.sh"
echo ""
ln -s /etc/wireguard/ /root/wireguard_folder
ln -s /var/log /root/system-log_folder
ufw --force enable
ufw reload
