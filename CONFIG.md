System Requirements:
- perl, apache, php, mysql

Recommended:
- phpmyadmin

Basic steps:

1) Create database named "FDLS" with a table named "logs"

	a) Column: idx, int(10), unsigned, auto_increment, primary

	b) Column: uuid, varchar(36)

	c) Column: epoch, int(11)

	d) Column: clientid, varchar(5)

	e) Column: band, varchar(5)

	f) Column: mode, varchar(7)

	g) Column: callsign, varchar(20)

	h) Column: class, varchar(5)

	i) Column: section, varchar(3)

	j) Column: op, varchar(20)

*Todo: add a SQL file for easier import/setup

2) Edit FDLS.pl

	a) search for "$dbh = DBI->connect("DBI:mysql:database=FDLS;host=localhost","

	b) on the next line, change "root" to a username that can access the FDLS database

	c) on the same line, change "fieldday" to the database user's password

3) Start the server. It is recommended that the server be run from a startup script.

*Todo: add an init script to the repository

4) Export the log data

	a) Use phpmyadmin to export the log table in csv format, then convert to adif for submission
