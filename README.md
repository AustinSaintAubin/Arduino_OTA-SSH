# Arduino_OTA-SSH
Over the Air (OTA) Update though SSH on Raspberry Pi


## Setup: Raspberry Pi (Client)
 - Install required dependacies ``` sudo apt-get install -y avrdude gcc-avr avr-libc ```
 - Manually Copy ( Arduino IDE/.../hardware/tools/avr/etc/avrdude.conf ) to the Raspberry Pi ( ~/Arduino/avrdude.conf )
 - Manually Copy ( usbreset.sh ) to the Raspberry Pi ( ~/Arduino/usbreset.sh )

## Setup: Workstation Setup

### MacOS
 - /Applications/Arduino.app/Contents/Java/hardware/arduino/avr/platform.txt 
 - /Applications/Arduino.app/Contents/Java/hardware/arduino/avr/programmers.txt
 - /Users/.../Documents/Arduino/arduino_ato-ssh.sh
 	- chmod +x /Users/.../Documents/Arduino/arduino_ssh_upload.sh

### Linux
 - Your using linux... you'll figure it out ( similar to above ).

### Windows
 - Not my problem: However, [tchilton/farduino](https://github.com/tchilton/farduino)
