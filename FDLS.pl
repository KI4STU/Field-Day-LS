#!/usr/bin/perl
#FDLS.pl

use strict;
use warnings;
use threads;
use IO::Socket::INET;
use DBI;
use Data::Dumper qw(Dumper);

BEGIN {
	# Fork.
	my $pidFile = '/var/run/FDLS.pid';
	my $pid = fork;
	if ($pid) { # parent: save PID
		open PIDFILE, ">$pidFile" or die "can't open $pidFile: $!\n";
		print PIDFILE $pid;
		close PIDFILE;
		exit 0;
	}
}

# flush after every write
$| = 1;

# set up our variables
my $data;
my $byte;
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
	# trim trailing spaces from callsign, class, section, and op
	$details[5] =~ s/\s+$//;
	$details[6] =~ s/\s+$//;
	$details[7] =~ s/\s+$//;
	$details[8] =~ s/\s+$//;
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
	Listen => 10,
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
#	my $uuid = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
#	my $epoch = "[0-9]{1,10}";
#	my $clientid = "(A-[0-9]{1,3}|HLFDS)";
#	my $band = "(160M|80M|40M|20M|15M|10M|6M|2M|1\.25M|70CM|33CM|23CM)";
#	my $mode = "(PHONE|CW|DIGITAL)";
#	my $callsign = "[A-Z0-9/]*[ ]?";
#	my $class = "[0-9]{1,2}[A-Z]{1,2}[ ]?";
#	my $section = "[A-Z]{2,3}[ ]?";
#	my $operator = "[A-Za-z0-9]*[ ]?";
	do {
	        $socket->recv($byte,1);
		$data .= "$byte";

	        if ($data eq "SENDALLCONTACTS") {
	                #print "Client $peeraddress wants us to send all log entries. We'll tackle that later.\n\n";
			my $sth;
			$sth = $dbh->prepare("SELECT * FROM log WHERE 1"); 
			$sth->execute();
			while (my @row = $sth->fetchrow_array) {
				$socket->send("CONTACT;$row[1];$row[2];$row[3];$row[4];$row[5];$row[6];$row[7];$row[8];$row[9];#");
#				print("CONTACT;$row[1];$row[2];$row[3];$row[4];$row[5];$row[6];$row[7];$row[8];$row[9];#");
			}
			undef $data;
	        }
	       # elsif ($data =~ /^$uuid\;$epoch\;$clientid\;$band\;$mode\;$callsign\;$class\;$section\;$operator\;#$/) {
	        elsif ($data =~ /#$/) {
	                #print "Client $peeraddress sent us a log entry : $data\n";
			checklog($data);
			undef $data;
	        }
	        elsif ($data or $data eq 0) {
			#print "I don't know what client $peeraddress sent us (yet?) : $data\n";
		}
	        else {
	                print "Client $peeraddress exited (or something really weird happened) : $data\n";
			undef $data;
	        }
	} while ($byte or $byte eq 0);
}

while(my $socket = $listen->accept) {
	async(\&handle_connection, $socket)->detach;
}

$listen->close();
print "Socket closed.";
