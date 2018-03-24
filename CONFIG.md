Installation and configuration is covered in greater detail within the Wiki, but these steps may be enough to get
things up and running fairly quickly.

The steps below presume you will be using a Raspberry Pi with a wifi adapter that supports AP mode (the integrated Pi ZeroW adapter
works).

Basic steps:
1) Do a fresh Raspbian install (raspbian-lite is sufficient, perhaps even recommended for energy savings in the field)
2) Connect to the Pi via ssh or keyboard/monitor
3) Ensure the Pi has internet access
4) Install git: sudo apt-get install git
5) Pull down FDLS: git clone https://github.com/KI4STU/Field-Day-LS.git
6) Change to the FDLS directory: cd Field-Day-LS
7) Run the installer: ./install.sh
8) Answer a couple questions during the install

At this point, the server should be up and running, acting as an Access Point, and ready to accept log data. Next:
1) Power on a tablet, phone, or mac running HamLog and connect to the server
2) Make contacts, log them using HamLog clients
2a) [optional] View live stats on the server: http://172.16.54.1/
3) At the end of Field Day, review /var/log/FDLS.log for any busted contacts.
3a) Correct busted contacts as necessary.
4) [optional] Download logs from the server: http://172.16.54.1/api/export.php
5) Submit report to ARRL
