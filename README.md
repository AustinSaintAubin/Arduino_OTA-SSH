# Arduino_OTA-SSH
Over the Air (OTA) Update though SSH on Raspberry Pi.

Used to flash new firmware from the Arduino IDE though a Raspberry Pi to an Arduino.
In my case I have an Arduino connected over USB OTG to a Raspberry Pi Zero W, connected over WiFi

![Screenshoot](https://github.com/AustinSaintAubin/Arduino_OTA-SSH/blob/master/Screen%20Shot.png)

## Setup: Raspberry Pi (Client)
 - Install required dependacies ``` sudo apt-get install -y avrdude gcc-avr avr-libc ```
 - Manually Copy ( Arduino IDE/.../hardware/tools/avr/etc/avrdude.conf ) to the Raspberry Pi ( ~/Arduino/avrdude.conf )
 - Manually Copy ( usbreset.sh ) to the Raspberry Pi ( ~/Arduino/usbreset.sh )

## Setup: Workstation Setup

### MacOS
 - Run: ``` sh setup_ssh-passwordless-login.sh ``` to configure Password-less SSH Login.
 - Move to: /Applications/Arduino.app/Contents/Java/hardware/arduino/avr/platform.txt 
 - Move to: /Applications/Arduino.app/Contents/Java/hardware/arduino/avr/programmers.txt
 - Move to: /Users/.../Documents/Arduino/arduino_ato-ssh.sh (or your Arduino "My Sketch" folder)
 	- Run: ``` chmod +x /Users/.../Documents/Arduino/arduino_ssh_upload.sh ```

### Linux
 - Your using linux... you'll figure it out ( similar to above ).

### Windows
 - Not my problem: However, [tchilton/farduino](https://github.com/tchilton/farduino)
