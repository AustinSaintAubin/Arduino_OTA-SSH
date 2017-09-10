echo "[Wireless Ad-Hoc Failover Setup]"
echo "If / when connecting to wireless AP fails on startup, create ad-hoc network."
#
# Links:
# http://lcdev.dk/2012/11/18/raspberry-pi-tutorial-connect-to-wifi-or-create-an-encrypted-dhcp-enabled-ad-hoc-network-as-fallback/
# https://raspberrypi.stackexchange.com/questions/8022/how-to-set-up-a-wireless-ad-hoc-network-if-there-are-no-other-networks-are-avail
# http://imti.co/post/145442415333/raspberry-pi-3-wifi-station-ap
# https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostapd/
# https://spin.atomicobject.com/2013/04/22/raspberry-pi-wireless-communication/
# https://askubuntu.com/questions/16143/is-there-a-way-to-start-a-bash-script-after-boot-only-when-wlan0-is-connected
# https://raspberrypi.stackexchange.com/questions/36693/cant-connect-to-my-rpi-access-point
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/3/html/System_Administration_Guide/s1-dhcp-configuring-server.html
# -------------------------------------------------------------------

WIFI_AP_SSID="now"
WIFI_AP_PASS="123456789#sterling"
WIFI_ADHOC_SSID="Wordclock-MK1_ADHOC"
WIFI_ADHOC_PASS="raspberry"

echo "-------------------------------------------------------------------"
echo "Checking if needed packages are installed"

REQUIRED_PACAGES="hostapd dnsmasq"
echo "Packages: $REQUIRED_PACAGES"
sudo apt-get install -y ${REQUIRED_PACAGES}
echo "- - - - - - - - - - - - - - - - - - - - - - - - -"
# for PACKAGE in $REQUIRED_PACAGES; do
#     printf "Verifying Package: ${PACKAGE}\t"
#     if [ $(dpkg-query -W -f='${Status}' ${PACKAGE} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
#         echo "[NOT INSTALLED] "
#         echo " - Installing Pageage: $PACKAGE"
#         sudo apt-get install -y ${PACKAGE}
#     else
#         echo "[INSTALLED]"
#     fi
# done

# -------------------------------------------------------------------
echo "[CONFIGURE WIRELESS (wpa_supplicant]"
FILE_PATH="/etc/wpa_supplicant/wpa_supplicant.conf"
echo "File Path: ${FILE_PATH}"

echo "Make Backup of (${FILE_PATH})"
sudo cp "${FILE_PATH}" "${FILE_PATH}.bak"

# Open the wpa_supplicant.conf file for editing
#sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
sudo bash -c "cat > ${FILE_PATH}" << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1
update_config=1

network={
  ssid="${WIFI_AP_SSID}"
  scan_ssid=1
  psk="${WIFI_AP_PASS}"
  mode=0
  proto=WPA2
  key_mgmt=WPA-PSK
  pairwise=CCMP
  group=CCMP
  auth_alg=OPEN
  id_str="raspi"
  priority=1
}
EOF

# Output this file contents
sudo cat "${FILE_PATH}"

# -------------------------------------------------------------------
echo "[CONFIGURE INTERFACES]"
FILE_PATH="/etc/network/interfaces"
echo "File Path: ${FILE_PATH}"

echo "Make a backup copy of the network interfaces file: ${FILE_PATH}"
sudo cp "${FILE_PATH}" "${FILE_PATH}.bak"

# Open the network interfaces file for editing
#sudo nano /etc/network/interfaces
sudo bash -c "cat > ${FILE_PATH}" << EOF
source-directory /etc/network/interfaces.d

auto lo
auto eth0
auto wlan0
auto uap0

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet dhcp
  wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

iface uap0 inet static
  address 172.24.1.1
  netmask 255.255.255.0
  network 172.24.1.0
  broadcast 172.24.1.255
  gateway 172.24.1.1
#   wireless-channel 1
#   wireless-essid RPiAdHocNetwork
#   wireless-mode ad-hoc
EOF

# Output this file contents
sudo cat "${FILE_PATH}"

# -------------------------------------------------------------------
echo "[CONFIGURE HOSTAPD]"
FILE_PATH="/etc/hostapd/hostapd.conf"
echo "File Path: ${FILE_PATH}"

echo "Make Backup of (${FILE_PATH})"
sudo cp "${FILE_PATH}" "${FILE_PATH}.bak"

#sudo nano ${FILE_PATH}
sudo bash -c "cat > ${FILE_PATH}" << EOF
# This is the name of the WiFi interface we configured above
interface=uap0

# Use the nl80211 driver with the brcmfmac driver
# driver=nl80211

# This is the name of the network
ssid=${WIFI_ADHOC_SSID}

# Use the 2.4GHz band
hw_mode=g

# Use channel x
channel=6

# Enable 802.11n
#ieee80211n=1

# Enable WMM
#wmm_enabled=1

# Enable 40MHz channels with 20ns guard interval
#ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Accept all MAC addresses
macaddr_acl=0

# Use WPA authentication
auth_algs=1

# Require clients to know the network name
ignore_broadcast_ssid=0

# Use WPA2
wpa=2

# Use a pre-shared key
wpa_key_mgmt=WPA-PSK

# The network passphrase
wpa_passphrase=${WIFI_ADHOC_PASS}

# Use AES, instead of TKIP
wpa_pairwise=CCMP
rsn_pairwise=CCMP
EOF

# Output this file contents
sudo cat "${FILE_PATH}"

# -------------------------------------------------------------------
echo "[CONFIGURE DNSMASQ]"
FILE_PATH="/etc/dnsmasq.conf"
echo "File Path: ${FILE_PATH}"

echo "Make Backup of ${FILE_PATH}"
sudo mv "${FILE_PATH}" "${FILE_PATH}.bak"

#sudo nano ${FILE_PATH}
sudo bash -c "cat >> ${FILE_PATH}" << EOF
interface=lo,uap0      # Use interface wlan0
no-dhcp-interface=lo,wlan0
#listen-address=172.24.1.1 # Explicitly specify the address to listen on
bind-interfaces      # Bind to the interface to make sure we aren't sending things elsewhere
server=8.8.8.8       # Forward DNS requests to Google DNS
address=/rasppi/172.24.1.1
address=/wordclock/172.24.1.1
domain-needed        # Don't forward short names
bogus-priv           # Never forward addresses in the non-routed address spaces.
dhcp-range=172.24.1.50,172.24.1.150,12h # Assign IP addresses between 172.24.1.50 and 172.24.1.150 with a 12 hour lease time
EOF

# Output this file contents
sudo cat "${FILE_PATH}"

# -------------------------------------------------------------------

# Disable the Services from Starting.
sudo systemctl disable dhcpcd.service
sudo service dnsmasq disable
sudo service hostapd disable

# - - - - - - - - - - - - - - - -
# Check if Link
iw dev wlan0 link

# Show Channel
iwlist wlan0 channel


# ====================================================================================
echo "[CREATE START SCRIPT]"

# Add to chrontabe
sudo bash -c 'cat > /home/pi/wifi_adhoc_failover.sh << EOF
#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#
# Setup:
#  chmod +x /home/pi/wifi_adhoc_failover.sh
#  sudo crontab -e
#    @reboot sleep 180; /home/pi/wifi_adhoc_failover.sh >> /home/pi/wifi_adhoc_failover.log

# Check if wlan0 was able to make a connection.
if [ $(iw dev wlan0 link 2>/dev/null | grep -c -i "Connected to") -eq 0 ]; then
	echo "WiFi AP [DISCONNECTED], starting Ad-Hoc Wireless Network..."
	iw dev wlan0 link
	# Start Ad-Hoc Wireless Network
	sudo iw dev wlan0 interface add uap0 type __ap
	sudo ifup uap0
	sudo service dnsmasq start
	sudo hostapd -B /etc/hostapd/hostapd.conf
else
	echo "WiFi AP [CONNECTED]"
fi
EOF'

cat /home/pi/wifi_adhoc_failover.sh

echo "Set as (/home/pi/wifi_adhoc_failover.sh) exicutable"
sudo chmod +x "/home/pi/wifi_adhoc_failover.sh"

# Create cron job
#write out current crontab # https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
sudo crontab -l > /tmp/cronjob
#echo new cron into cron file
echo "@reboot sleep 45; /home/pi/wifi_adhoc_failover.sh >> /home/pi/wifi_adhoc_failover.log" >> /tmp/cronjob
#install new cron file
sudo crontab /tmp/cronjob
rm /tmp/cronjob

echo "Now manuallty veryify the chronjob"
sleep 6
sudo crontab -e







# ====================================================================================
# - - - - - - - - - - - - - - - -
# Restart Networking Services
# sudo /etc/init.d/networking restart

# To see your various network interfaces, use the command:
/sbin/ifconfig -a

# Next, restart the wlan0 network connection with the following two commands:
# sudo ifdown wlan0
# sudo ifup wlan0
sudo reboot
