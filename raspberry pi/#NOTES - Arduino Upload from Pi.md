# [Programming Arduino with avrdude](https://typeunsafe.wordpress.com/2011/07/22/programming-arduino-with-avrdude/)

How to upload hex (complied sketch to Arduino)

## Install AVRDUDE

```
sudo apt-get install -y avrdude gcc-avr avr-libc
mkdir ~/Arduino
cd ~/Arduino
```

## EExport Compiled Binary
- Open Arduino
- Open grblUpload sketch
- Sketch/Export Compiled Binary
- Save / Move (...with_bootloader.standard.hex) to Raspberry Pi

## [Reset USB Device](https://raspberrypi.stackexchange.com/questions/9264/how-do-i-reset-a-usb-device-using-a-script)
```
wget -c --no-check-certificate https://gist.githubusercontent.com/x2q/5124616/raw/3f6e5f144efab2bc8e9d02b95b8301e1e0eab669/usbreset.c -O usbreset.c
cc usbreset.c -o usbreset
chmod +x usbreset
lsusb
#sudo ./usbreset /dev/bus/usb/002/003  # You should see USB device entries in your output and check device you want to reset for "Bus 002 Device 003: ID 0fe9:9010 DVICO"
```

## Reset USB Device based on Name
```
#!/bin/bash
USB_NAME=USB-Serial  # lsusb
LS_USB=$(lsusb | grep --ignore-case ${USB_NAME})
USB_PATH="/dev/bus/usb/"$(echo ${LS_USB} | cut --delimiter=' ' --fields='2')"/"$(echo ${LS_USB} | cut --delimiter=' ' --fields='4' | tr --delete ":")
echo "${USB_NAME}: ${USB_PATH}"
sudo ./usbreset "${USB_PATH}"
```

## Upload to GRBL Sheild / X-Controller
```
FIRMWARE_FILE=StandardFirmata-f.ino.eightanaloginputs.hex

cd ~/Arduino

# Reset USB Device based on Name
USB_NAME=USB-Serial  # lsusb
LS_USB=$(lsusb | grep --ignore-case ${USB_NAME})
USB_PATH="/dev/bus/usb/"$(echo ${LS_USB} | cut --delimiter=' ' --fields='2')"/"$(echo ${LS_USB} | cut --delimiter=' ' --fields='4' | tr --delete ":")
echo "${USB_NAME}: ${USB_PATH}"
sudo ./usbreset "${USB_PATH}"

# Flash Fimrware
avrdude -C /home/pi/Arduino/avrdude.conf -v -p atmega328p -c arduino -P /dev/ttyUSB0 -b 57600 -D -U flash:w:${FIRMWARE_FILE}:i


```



sftp://xcarve//home/pi/Arduino/grblUpload.ino.standard.hex