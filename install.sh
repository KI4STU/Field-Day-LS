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

# install some packages that aren't part of the default raspbian-lite build
# phpmyadmin: a handy interface for handling database things
# plus, by installing it, we get "mysql" (now mariadb), a current version of PHP, and apache2
# hostapd: lets us turn the PiZeroW into an Access Point
# rng-tools: to access the hardware RNG on the Pi (supports hostapd)
# udhcpd: a lightweight dhcp server
echo ">>>Validating dependencies."
echo ">>>apt-get -y install mariadb-server phpmyadmin rng-tools hostapd"
sudo apt-get -y install mariadb-server phpmyadmin rng-tools hostapd

# because why wouldn't you restart apache
echo ">>>Restarting Apache."
sudo systemctl daemon-reload 
sudo systemctl restart apache2
echo
echo

# this installs the FDLS web interface, and removes the default "it works!" page that came with apache2
echo ">>>Installing Web Pages"
echo ">>>cp -r www/* /var/www/html/"
sudo cp -r www/* /var/www/html/
sudo rm /var/www/html/index.html
echo
echo

# create database, import table structure
echo ">>>Installing database table structure"
sudo mysql --execute="CREATE DATABASE IF NOT EXISTS FDLS;"
sudo mysql --execute="GRANT ALL PRIVILEGES ON FDLS.* TO 'phpmyadmin'@'localhost';"
sudo mysql FDLS < FDLS.sql


# we need to compile a few things:
# hlfds-announce: Pignology's HamLog discovery application
# reboot: a small C application which lets us reboot via the web interface
# shutdown: another small C application, allowing shutdown via web interface
echo ">>>Compiling FDLS supporting applications"
echo ">>>make -C src/"
make -C src/
echo
echo

# after compiling, we put those applications in place
echo ">>>Installing FDLS and supporting applications"
echo ">>>make -C src/ install"
sudo make -C src/ install
echo ">>>cp FDLS.pl /opt/FDLS/"
sudo cp FDLS.pl /opt/FDLS/
echo
echo


echo ">>>Installing Auto-Start Files"
sudo cp -v etc/*.timer /lib/systemd/system/
sudo cp -v etc/*.service /lib/systemd/system/
sudo cp -v init.d/FDLS /etc/init.d/
echo
echo

# disabled for now, this might conflict with perl server. can start it manually if we want
#echo ">>>Enabling Auto-Start"
#sudo systemctl enable hlfds-announce.timer

#echo "Starting services, will auto-start on reboot"
#sudo systemctl start FDLS
sudo update-rc.d FDLS defaults
#sudo systemctl start hlfds-announce
echo


echo "Would you like to configure this host as a stand-alone access point?"
echo "NOTE: Files modified will be backed up, it will be a manual process to revert."
echo "NOTE: The system will reboot after the configuration"
echo -n "[Y/N]?: "
read ans
if [ "`echo $ans | tr [:upper:] [:lower:]`" == "y" ]; then
  echo "Configuring access point."
  sudo cp -v /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.$DATE
  sudo cp -v etc/hostapd.conf /etc/hostapd/
  sudo cp -v /etc/dhcpcd.conf /etc/dhcpcd.conf.$DATE
  sudo cp -v etc/dhcpcd.conf /etc/

  echo ">>>Installing udhcpd"
  sudo apt-get -y install udhcpd
  sudo cp -v /etc/udhcpd.conf /etc/udhcpd.conf.$DATE
  sudo cp -v etc/udhcpd.conf /etc/
  sudo cp -v /etc/default/udhcpd /etc/default/udhcpd.$DATE
  sudo cp -v etc/udhcpd /etc/default/
  sudo cp -v /etc/init.d/udhcpd /etc/init.d/udhcpd.$DATE
  sudo cp -v init.d/udhcpd /etc/init.d/

  echo ">>>Enabling hostapd"
  sudo systemctl enable hostapd.timer
  sudo systemctl enable hostapd
  sudo systemctl enable udhcpd

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
