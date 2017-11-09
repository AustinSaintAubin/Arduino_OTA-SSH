# Arduino: Over the Air (OTA) Update w/ SSH on Raspberry Pi
# -----------------------------------------------------------------
# GitHub Repo: https://github.com/AustinSaintAubin/Arduino_OTA-SSH
# By: Austin St. Aubin ( v1.0 ) [ 2017/09/08 ]
#
# Notes:
#   Used to flash new firmware from the Arduino IDE though a Raspberry Pi to an Arduino.
#   In my case I have an Arduino connected over USB OTG to a Raspberry Pi Zero W, connected over WiFi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup: (Workstation)
#   Download "arduino_ssh_upload.sh" to your Arduino "My Sketch" folder.
#   chmod +x /Users/.../Documents/Arduino/arduino_ssh_upload.sh
#
# Setup: (Raspberry Pi)
#   sudo apt-get install -y avrdude gcc-avr avr-libc
# -----------------------------------------------------------------
SSH_SERVER=wordclock
SSH_USERNAME=pi

REMOTE_USB_RESET=true
REMOTE_USB_NAME="USB-Serial"  # lsusb
REMOTE_SERIAL_PATH="/dev/ttyUSB0"

REMOTE_AVRDUDE_EXTRAS="-P ${REMOTE_SERIAL_PATH} -b 57600 -D"

REMOTE_DIR="/home/${SSH_USERNAME}/Arduino"
FIRMWARE_FILE_POSTFIX=".hex"
LOCAL_FIMRWARE_FILE_PATH=$1${FIRMWARE_FILE_POSTFIX}
REMOTE_FIRMWARE_FILE_NAME=ARDUINO-FLASH${FIRMWARE_FILE_POSTFIX}  # MatrixGFXDemo_16x16.ino.eightanaloginputs.hex
REMOTE_FIRMWARE_FILE_PATH=${REMOTE_DIR}/${REMOTE_FIRMWARE_FILE_NAME}
# ----------------------------------------------------------------

# echo "- - - - - - - - - - - - - - - - - - - - - - - - -"
# echo "Checking if needed packages are installed"
# REQUIRED_PACAGES="avrdude gcc-avr avr-libc"
# # Chack if AVRdude & other required packages are installed.
# ssh $SSH_USERNAME@$SSH_SERVER << EOF
#     echo "Packages: $REQUIRED_PACAGES"
#
#     for PACKAGE in $REQUIRED_PACAGES; do
#         printf "Verifying Package: ${PACKAGE}\t"
#         if [ $(dpkg-query -W -f='${Status}' ${PACKAGE} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
#             echo "[NOT INSTALLED] "
#             echo " - Installing Pageage: $PACKAGE"
#             sudo apt-get install -y ${PACKAGE}
#         else
#             echo "[INSTALLED]"
#         fi
#     done
# EOF

# SSH Server Info
echo "- - - - - - - - - - - - - - - - - - - - - - - - -"
echo "SSH Server:   ${SSH_SERVER}"
echo "SSH Username: ${SSH_USERNAME}"


# Reset USB Device based on Name
echo "- - - - - - - - - - - - - - - -"
echo "Remote USB Reset: ${REMOTE_USB_NAME}"
if [ ${REMOTE_USB_RESET} = true ]; then
	echo "Reseting USB, this helps to close any active serial connections..."

ssh $SSH_USERNAME@$SSH_SERVER << EOF
    # Reset USB Device based on Name
    cd "${REMOTE_DIR}"
    sudo ./usbreset.sh "${REMOTE_USB_PATH}"
EOF
else
	echo "Skipping USB Reset"
fi

# Firmware Info
echo "- - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Local Firmware Path:  ${LOCAL_FIMRWARE_FILE_PATH} [$([ -f ${LOCAL_FIMRWARE_FILE_PATH} ] && echo "PASS" || echo "FAIL, not found!")]"
echo "Remote Firmware Path: ${REMOTE_FIRMWARE_FILE_PATH}"
echo "- - - - - - - - - - - - - - - - - - - - - - - - -"


# Send & Flash Firmware over SSH
cat ${LOCAL_FIMRWARE_FILE_PATH} | ssh $SSH_USERNAME@$SSH_SERVER "mkdir \"${REMOTE_DIR}\"; \
cd \"${REMOTE_DIR}\"; \
touch \"${REMOTE_FIRMWARE_FILE_PATH}\"; cat > \"${REMOTE_FIRMWARE_FILE_PATH}\"; \
avrdude -C \"${REMOTE_DIR}/avrdude.conf\" -v -p atmega328p -c arduino ${REMOTE_AVRDUDE_EXTRAS} -U flash:w:${REMOTE_FIRMWARE_FILE_NAME}:i;"
