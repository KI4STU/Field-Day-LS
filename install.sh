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

echo "If you are using a Pi, would you like to change the function of the activity LED"
echo "to conserve a little power? Note that a reboot is required for this change to"
echo "take effect."
echo -n "[Y/N]?: "
read ans
echo
if [ "`echo $ans | tr [:upper:] [:lower:]`" == "y" ]; then
#  echo "Are you using a Pi Zero or Pi ZeroW?"
#  echo -n "[Y/N]?: "
#  read ans
#  echo
  case `cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}'` in
    +900092|900093|920093|9000c1)
      zero=1
      ;;
  esac
  echo "What would you like to set the activty LED to do? These options are ordered"
  echo "roughly from most power savings to least. Note: if you want to change this"
  echo "setting in the future, edit /boot/config.txt and comment out (or change) the"
  echo "line near the bottom of the file that looks like \"dtparam=act_led_trigger=\"."
  echo ""
  echo "1: Disable activity LED entirely"
  echo "2: Flash at 1 second intervals"
  echo "3: Heartbeat flash (1-0-1-00000)"
  echo "4: Flash on SD card activity (disk activity)"
  echo "5: Flash on wifi activity"
  echo "6: Always on (power indicator)"
  echo "7: I changed my mind, I don't want to do this anymore"
  echo -n "[1-7]?: "
  read pwrsav
  case $pwrsav in
    [1])
      echo "Disabling activity LED entirely. Note: this may make it difficult"
      echo "to tell whether the Pi is actually operating or not."
      sudo sh -c 'echo "dtparam=act_led_trigger=none" >> /boot/config.txt'
      if [ "$zero" == "1" ]; then
	sudo sh -c 'echo "dtparam=act_led_activelow=on" >> /boot/config.txt'
      fi
      ;;
    [2])
      echo "Configuring LED to flash at 1 second intervals"
      sudo sh -c 'echo "dtparam=act_led_trigger=timer" >> /boot/config.txt'
      if [ "$zero" == "1" ]; then
	sudo sh -c 'echo "dtparam=act_led_activelow=on" >> /boot/config.txt'
      fi
      ;;
    [3])
      echo "Configuring LED to flash like a heartbeat"
      sudo sh -c 'echo "dtparam=act_led_trigger=heartbeat" >> /boot/config.txt'
      if [ "$zero" == "1" ]; then
	sudo sh -c 'echo "dtparam=act_led_activelow=on" >> /boot/config.txt'
      fi
      ;;
    [4])
      echo "Configuring LED to flash on disk (sdcard) activity"
      sudo sh -c 'echo "dtparam=act_led_trigger=mmc0" >> /boot/config.txt'
      if [ "$zero" == "1" ]; then
	sudo sh -c 'echo "dtparam=act_led_activelow=on" >> /boot/config.txt'
      fi
      ;;
    [5])
      echo "Configuring LED to flash on wifi activity"
      sudo sh -c 'echo "dtparam=act_led_trigger=rfkill0" >> /boot/config.txt'
      if [ "$zero" == "1" ]; then
	sudo sh -c 'echo "dtparam=act_led_activelow=on" >> /boot/config.txt'
      fi
      ;;
    [6])
      echo "Configuring LED as a power indicator"
      sudo sh -c 'echo "dtparam=act_led_trigger=backlight" >> /boot/config.txt'
      if [ "$zero" == "1" ]; then
	sudo sh -c 'echo "dtparam=act_led_activelow=on" >> /boot/config.txt'
      fi
      ;;
    *)
      echo "Doing nothing. LED will remain in its default state"
      ;;
  esac
  echo
fi

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
