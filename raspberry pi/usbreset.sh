## [Reset USB Device](https://raspberrypi.stackexchange.com/questions/9264/how-do-i-reset-a-usb-device-using-a-script)

# Check for usbreset binnary
if [ -f usbreset ]; then
	echo "Found: usbreset"
	chmod +x usbreset
else
	echo "Downloading and Compiling: usbreset"
	wget -c --no-check-certificate https://gist.githubusercontent.com/x2q/5124616/raw/3f6e5f144efab2bc8e9d02b95b8301e1e0eab669/usbreset.c -O usbreset.c
	cc usbreset.c -o usbreset
	chmod +x usbreset
	lsusb
	#sudo ./usbreset /dev/bus/usb/002/003  # You should see USB device entries in your output and check device you want to reset for "Bus 002 Device 003: ID 0fe9:9010 DVICO"
fi

# Manage Passed Varables
if [ $@ ]; then
	USB_NAME=$@
else
	USB_NAME=USB-Serial  # lsusb
fi

# Show USB Devices
lsusb

# Reset USB Device based on Name
LS_USB=$(lsusb | grep --ignore-case ${USB_NAME})
USB_PATH="/dev/bus/usb/"$(echo ${LS_USB} | cut --delimiter=' ' --fields='2')"/"$(echo ${LS_USB} | cut --delimiter=' ' --fields='4' | tr --delete ":")
echo "${USB_NAME}: ${USB_PATH}"
sudo ./usbreset "${USB_PATH}"
