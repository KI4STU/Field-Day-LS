System Requirements:
- perl, mysql

Recommended:
- phpmyadmin, apache, php

The steps below presume you will be using a Raspberry Pi and following the typical Raspberry Pi approach of having
a script live in the "pi" user's home directory. The init script presumes the path to the server script is
/home/pi/Field-Day-LS/FDLS.pl. If you decide to put the script in a different location, update the init script
as needed.

Basic steps:

1) import FDLS.sql to mysql

2) Move init.d/FDLS to /etc/init.d and add to defaults (execute "update-rc.d FDLS defaults" on Raspberry Pi / Debian)

2) Edit ~/Field-Day-LS/FDLS.pl:
	a) search for "$dbh = DBI->connect("DBI:mysql:database=FDLS;host=localhost","
	b) on the next line, change "root" to a username that can access the FDLS database
	c) on the same line, change "fieldday" to the database user's password

3) Start the server (sudo /etc/init.d/FDLS start)

4) Make contacts, log them using HamLog clients

5) Review /var/log/FDLS.log for any busted contacts. If someone submit a log entry that doesn't seem legitimate
it will end up here. If the error in the log entry is not egregious (i.e. a simple, obvious typo), you can edit
the log entry on the client, which should sync back to the server.

4) Use phpmyadmin to export the log table in csv format, then convert to adif for submission
