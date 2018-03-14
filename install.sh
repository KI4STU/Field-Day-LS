#!/bin/bash

# install script for FDLS
# originally from https://bitbucket.org/pignology/hlfds
# modified by Detrick Merz (K4IZ) to function with FDLS (https://github.com/KI4STU/Field-Day-LS)

DATE=`date +%Y%m%d-%H%M`
echo

# ensure apt is up to date (we're going to install some stuff in a minute, and it needs to be)
echo ">>>Updating apt"
sudo apt-get update

# stop FDLS (logging server) and hlfds-announce (Pignology's HamLog discovery application)
echo "Stopping services, if running"
sudo systemctl stop FDLS
sudo systemctl stop hlfds-announce
echo
echo

echo "ready?"
read foo
clear

# install some packages that aren't part of the default raspbian-lite build
# phpmyadmin: a handy interface for handling database things
# plus, by installing it, we get "mysql" (now mariadb), a current version of PHP, and apache2
# hostapd: lets us turn the PiZeroW into an Access Point
# udhcpd: a lightweight dhcp server
echo ">>>Validating dependencies."
echo ">>>apt-get -y install mariadb-server phpmyadmin hostapd"
sudo apt-get -y install mariadb-server phpmyadmin hostapd

echo "ready?"
read foo
clear

# because why wouldn't you restart apache
echo ">>>Restarting Apache."
sudo systemctl daemon-reload 
sudo systemctl restart apache2
echo
echo

echo "ready?"
read foo
clear

# this installs the FDLS web interface, and removes the default "it works!" page that came with apache2
echo ">>>Installing Web Pages"
echo ">>>cp -r www/* /var/www/html/"
sudo cp -r www/* /var/www/html/
sudo rm /var/www/html/index.html
echo
echo

echo "ready?"
read foo
clear

# we need to compile a few things:
# hlfds-announce: Pignology's HamLog discovery application
# reboot: a small C application which lets us reboot via the web interface
# shutdown: another small C application, allowing shutdown via web interface
echo ">>>Compiling FDLS supporting applications"
echo ">>>make -C src/"
make -C src/
echo
echo

echo "ready?"
read foo
clear

# after compiling, we put those applications in place
echo ">>>Installing FDLS and supporting applications"
echo ">>>make -C src/ install"
sudo make -C src/ install
echo ">>>cp FDLS.pl /opt/FDLS/"
sudo cp FDLS.pl /opt/FDLS/
echo
echo

echo "ready?"
read foo
clear

echo ">>>Installing Auto-Start Files"
sudo cp -v etc/*.timer /lib/systemd/system/
sudo cp -v etc/*.service /lib/systemd/system/
echo
echo

echo "ready?"
read foo
clear

echo ">>>Enabling Auto-Start"
sudo systemctl enable FDLS.timer
sudo systemctl enable hlfds-announce.timer

echo "Starting services, will auto-start on reboot"
sudo systemctl start FDLS
sudo systemctl start hlfds-announce
echo

echo "ready?"
read foo
clear

echo "Would you like to configure this host as a stand-alone access point?"
echo "NOTE: Files modified will be backed up, it will be a manual process to revert."
echo "NOTE: The system will reboot after the configuration"
echo -n "[Y/N]?: "
read ans
if [ "$ans" == "Y" ]; then
  echo "Configuring access point."
  sudo cp -v /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.$DATE
  sudo cp -v etc/hostapd.conf /etc/hostapd/
  sudo cp -v /etc/dhcpcd.conf /etc/dhcpcd.conf.$DATE
  sudo cp -v etc/dhcpcd.conf /etc/

echo "ready?"
read foo
clear

  echo ">>>Installing udhcpd"
  sudo apt-get -y install udhcpd
  sudo cp -v /etc/udhcpd.conf /etc/udhcpd.conf.$DATE
  sudo cp -v etc/udhcpd.conf /etc/
  sudo service udhcpd start

echo "ready?"
read foo
clear

# verify this is really necessary
  echo ">>>Enabling hostapd"
  systemctl enable hostapd.timer

echo "ready?"
read foo
clear

  echo -n "Rebooting in "
  k=10
  while [ $k -gt 0 ]; do
    echo -n "$k ";
    sleep 1
    k=`expr $k - 1`
  done
  echo
  echo "Reboot"
  sudo reboot
fi

echo "All set, point HamLog to this host."
echo

