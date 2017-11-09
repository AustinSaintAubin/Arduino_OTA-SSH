# Creates Password less Login for Max OS X on most linux systems
# By: Austin Saint Aubin [2013/05/01]
# sh ../setup_ssh-passwordless-login.sh
# ============================================================================
# http://www.noah.org/wiki/SSH_public_keys
# http://nerderati.com/2011/03/simplify-your-life-with-an-ssh-config-file/
# http://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id
# ============================================================================
# Warning: it's important to copy the key exactly without adding newlines or whitespace. Thankfully the pbcopy command makes it easy to perform this setup perfectly.

# == [ Build Keys ] ================================================
read -t 30 -n 1 -p "Build New Key on Client (y/n): "

case $REPLY in
	[Yy]* ) echo "Building New Key"; ssh-keygen -t rsa; cat ~/.ssh/id_rsa.pub; break;; # On client (Mac OS X): On you host computer (not the diskstation) open a terminal and run the following command: ssh-keygen -t rsa -C "your_email@youremail.com";;
	    * ) echo "Using Current Key";;
	#[Nn]* ) echo "Using Current Key"; break;;
    #    * ) echo "Please answer (y/n).";;
esac

# Pause and wait
read -t 10 -n 1 -p "Press any key to continue…"  # (60 sec timeout)

# == [ Send Keys to Server / NAS ] ================================================
# Adds a clients id_rsa.pub to authorized_keys for user on NAS

read -p "Server Hostname\IP: "
SERVER="$REPLY"
read -p "Username on \"$SERVER\": "
USERNAME="$REPLY"

# [ These run from workstation and connect to server ]
# On NAS: You need to create a directory with a file containing the the authorized keys of clients being able to connect.
# On NAS: Copy the content of your id_rsa.pub file from your Host-computer (the one you want to connect from) into the authorized_keys file.
# On NAS: Change the file permissions of the authorized-key file.
cat ~/.ssh/id_rsa.pub | ssh $USERNAME@$SERVER 'mkdir ~/.ssh; touch ~/.ssh/authorized_keys; cat >> ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 644 ~/.ssh/authorized_keys; echo "File: ~/.ssh/authorized_keys";echo "========================"; cat ~/.ssh/authorized_keys; echo "========================";'

# Pause and wait
read -t 60 -n 1 -p "Press any key to exit…(60 sec timeout)"
exit # Exit Above Script