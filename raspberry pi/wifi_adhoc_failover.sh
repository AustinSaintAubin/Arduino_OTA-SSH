#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#
# Setup:
#  chmod +x /home/pi/wifi_adhoc_failover.sh
#  sudo crontab -e
#    @reboot sleep 180; /home/pi/wifi_adhoc_failover.sh >> /home/pi/wifi_adhoc_failover.log

# Check if wlan0 was able to make a connection.
if [ $(iw dev wlan0 link 2>/dev/null | grep -c -i "Connected to" ) -eq 0 ]; then
echo "WiFi AP [DISCONNECTED], Starting Ad-Hoc Wireless Network..."
iw dev wlan0 link
# Start Ad-Hoc Wireless Network
sudo iw dev wlan0 interface add uap0 type __ap
sudo ifup uap0
sudo service dnsmasq start
sudo hostapd -B /etc/hostapd/hostapd.conf
else
echo "WiFi AP [CONNECTED]"
fi
