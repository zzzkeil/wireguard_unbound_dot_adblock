# - be aware - scripts on testing for now.
## - DoT resolver is cloudfare for testing !
#
# VPN over wireguard with DNS over TLS and adblock

## In under 5 minutes* with just a few klicks
### Setup Wireguard VPN Server,
#### incl. ipv4 and ipv6
#### incl. unbound forward TLS
#### incl. Ad-, Maleware-, ..., Blocking
#### incl. 5 ready client config files  ( one with QR-Code in terminal )
##### add_client.sh / remove_client.sh under development in tools

## How to install :
#### the server has to be prepared with my script base_setup.sh
##### if the base is not installed, the script below will download this one for you.
----------------------------------------

###### For Ubuntu 18.04 ( 20.04 in testing ) - ( Debian 10 in testing ) :
```
wget -O  wireguard_unbound_setup.sh https://raw.githubusercontent.com/zzzkeil/wireguard_unbound_doh_adblock/master/ubunut/wireguard_unbound_setup.sh

chmod +x wireguard_unbound_setup.sh

./wireguard_unbound_setup.sh
```
-----------------------------------------

@ the end you see the QR Code for your wiregaurd app.
example:
[![example](https://zeroaim.de/img/wgexsqr.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)

-----------------------------------------







( *less then 5 minutes on my v-server together with base_setup.sh ) 
