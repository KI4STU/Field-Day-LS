#!/usr/bin/perl
#tcpserver.pl

use strict;
use warnings;
use threads;
use IO::Socket::INET;
use DBI;
use Data::Dumper qw(Dumper);

# flush after every write
$| = 1;

# set up our variables
my $data;
my $dbh;
my ($listen,$client_socket);
my ($peeraddress,$peerport);
my $ip = '192.168.100.202';
my $port = '7373';
my $proto = 'tcp';

# take a single log entry, see if it already exists in the db. if it does, update the entry in the db,
# if it doesn't, add a new entry to the db.
sub checklog {
	my $sth;
	my @details = split /;/, $data;
	$sth = $dbh->prepare("SELECT idx FROM log WHERE uuid=?");
	$sth->execute($details[0]);
	if (my @row = $sth->fetchrow_array) {
		$sth = $dbh->prepare("UPDATE log SET epoch=?, clientid=?, band=?, mode=?, callsign=?, class=?, section=?, op=? WHERE uuid=?");
		$sth->execute($details[1],$details[2],$details[3],$details[4],$details[5],$details[6],$details[7],$details[8],$details[0]) or die;
	}
	else {
		$sth = $dbh->prepare("INSERT INTO log(uuid,epoch,clientid,band,mode,callsign,class,section,op) VALUES (?,?,?,?,?,?,?,?,?)");
		$sth->execute($details[0],$details[1],$details[2],$details[3],$details[4],$details[5],$details[6],$details[7],$details[8]) or die;
	}

}

# creating object interface of IO::Socket::INET modules which internally does 
# socket creation, binding and listening at the specified port address.
$listen = new IO::Socket::INET (
	LocalHost => $ip,
	LocalPort => $port,
	Proto => $proto,
	Listen => 5,
	ReuseAddr => 1
	) or die "ERROR in Socket Creation : $!\n";

print "Waiting for client connection on port $port\n";

# talk to client loggers
sub handle_connection {
	# talk to the database
	$dbh = DBI->connect("DBI:mysql:database=FDLS;host=localhost",
		"root", "fieldday",
		{'RaiseError' => 1});

	my $socket = shift;
	my $output = shift || $socket;
	my $exit = 0;
	my $peeraddress = $socket->peerhost;
	my $uuid = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";
	my $epoch = "[0-9]{1,10}";
	my $clientid = "(A-[0-9]{1,3}|HLFDS)";
	my $band = "(160M|80M|40M|20M|15M|10M|6M|2M|1\.25M|70CM|33CM|23CM)";
	my $mode = "(PHONE|CW|DIGITAL)";
	my $callsign = "[A-Z0-9/]*";
	my $class = "[0-9]{1}[A-Z]{1,2}";
	my $section = "[A-Z]{2,3}";
	my $operator = "[A-Za-z0-9]*";
	do {
	        $socket->recv($data,2048);
	        print "Received from client $peeraddress : $data\n\n";

	        if ($data eq "SENDALLCONTACTS") {
	                print "Client $peeraddress wants us to send all log entries. We'll tackle that later.\n\n";
	        }
	        elsif ($data =~ /^$uuid\;$epoch\;$clientid\;$band\;$mode\;$callsign\;$class\;$section\;$operator\;#$/) {
	                print "Client $peeraddress sent us a log entry\n";
			#- Check to see if it is already in the database or not, if yes update the record\n";
			print "Log data : $data\n\n";
			checklog($data);
	        }
	        elsif ($data) {
			print "Client $peeraddress sent us something but it doesn't look like a single log entry\n";
			print "It's probably a bulk upload of log entries. Do we want to process those, or just\n";
			print "presume we know about them already?\n";
			print "Log data : $data\n\n";
		}
	        else {
	                print "Client $peeraddress exited\n";
	        }
	} while ($data);
}

while(my $socket = $listen->accept) {
	async(\&handle_connection, $socket)->detach;
}

$listen->close();
print "Socket closed.";
