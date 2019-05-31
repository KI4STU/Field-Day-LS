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
# issue #17
#my $ip = '172.16.54.1';
my $ip = '0.0.0.0';
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

print scalar(gmtime()),": Starting up, waiting for client connection on port $port\n";

# talk to client loggers
sub handle_connection {
	# talk to the database
	$dbh = DBI->connect("DBI:mysql:database=FDLS;host=localhost",
		"phpmyadmin", "fieldday",
		{'RaiseError' => 1});

	my $socket = shift;
	my $output = shift || $socket;
	my $exit = 0;
	my $peeraddress = $socket->peerhost;
	my $uuid = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
	my $epoch = "[0-9]{1,11}";
	my $clientid = "(A-[0-9]{1,3}|HLFDS)";
	my $band = "(160M|80M|40M|20M|15M|10M|6M|2M|1\.25M|70CM|33CM|23CM|Sat)";
	my $mode = "(PHONE|CW|DIGITAL)";
	# accept upper or lower case characters for callsign, class, section, op
	my $callsign = "[A-Za-z0-9/]*[ ]?";
	my $class = "[0-9]{1,2}[A-Za-z]{1,2}[ ]?";
	my $section = "[A-Za-z]{2,3}[ ]?";
	my $operator = "[A-Za-z0-9]*[ ]?";
	my $comment = "[^;]*";
	print scalar(gmtime()),": Client $peeraddress connected\n";	
	do {
	        $socket->recv($byte,1);
		$data .= "$byte";

		# a "pull all" was done by the client
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
		# log data received
		elsif ($data =~ /^$uuid\;$epoch\;$clientid\;$band\;$mode\;$callsign\;$class\;$section\;$operator\;#$/) {
	                #print gmtime().": Client $peeraddress sent us a log entry : $data\n");
			checklog($data);
			undef $data;
	        }
		# log data received with comment (iOS device)
		elsif ($data =~ /^$uuid\;$epoch\;$clientid\;$band\;$mode\;$callsign\;$class\;$section\;$operator\;$comment;#$/) {
	                #print gmtime().": Client $peeraddress sent us a log entry : $data\n");
			checklog($data);
			undef $data;
	        }
		# something we don't understand was received
	        elsif ($data =~ /#$/) {
			print scalar(gmtime()),": Client $peeraddress sent us something, perhaps a mangled log entry? : $data\n";
			undef $data;
		}
	        elsif ($data or $data eq 0) {
			#print gmtime().": I don't know what client $peeraddress sent us (yet?) : $data\n");
		}
	        else {
	                print scalar(gmtime()),": Client $peeraddress exited (or something really weird happened) : $data\n";
			undef $data;
	        }
	} while ($byte or $byte eq 0);
}

while(my $socket = $listen->accept) {
	async(\&handle_connection, $socket)->detach;
}

$listen->close();
print "Socket closed.";
