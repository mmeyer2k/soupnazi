#!/bin/bash

# sets the firewall rules
# supports vpn killswitch option
#
# useage: firewall.sh [--vpn-lock]

# make sure forwarding is allowed in the ufw config
sed -i 's|#net/ipv4/ip_forward=1|net/ipv4/ip_forward=1|' /etc/ufw/sysctl.conf
sed -i 's|#net/ipv6/conf/default/forwarding=1|net/ipv6/conf/default/forwarding=1|' /etc/ufw/sysctl.conf
sed -i 's|#net/ipv6/conf/all/forwarding=1|net/ipv6/conf/all/forwarding=1|' /etc/ufw/sysctl.conf
sysctl -p

# reset rules
ufw --force reset

# set outbound rules
if [ "$1" = "--vpn-lock" ]; then
    ufw default deny outgoing
    ufw allow out to any port 1194
    ufw allow out on enp0s3 from any to any
    ufw allow out on tun0 from any to any
    touch /var/tmp/vpnlock
else
    ufw default allow outgoing
    rm -f /var/tmp/vpnlock
fi

# set inbound rules
ufw default deny incoming
ufw allow 22
ufw allow 53
ufw allow 80

# enable logs
ufw logging on

# re-enable the firewall
ufw --force enable
