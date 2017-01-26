#!/usr/bin/perl
#tcpserver.pl

use strict;
use warnings;
use threads;
use IO::Socket::INET;

# flush after every write
$| = 1;

my $data;
my ($listen,$client_socket);
my ($peeraddress,$peerport);
my $ip = '192.168.100.202';
my $port = '7373';
my $proto = 'tcp';

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

sub handle_connection {
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
	my $class = "[0-9]{1}[A-Z]{1}";
	my $section = "[A-Z]{2,3}";
	my $operator = "[A-Za-z]*";
	do {
	        $socket->recv($data,2048);
#	        print "Received from client $peeraddress : $data\n\n";

	        if ($data eq "SENDALLCONTACTS") {
	                print "Client $peeraddress said $data\n\n";
	        }
	        elsif ($data =~ /^$uuid\;$epoch\;$clientid\;$band\;$mode\;$callsign\;$class\;$section\;$operator\;#$/) {
	                print "Client $peeraddress sent us a log entry, do something with it\n";
			print "Log data : $data\n\n";
	        }
	        elsif ($data) {
			print "Client $peeraddress sent us something but it doesn't look like a single log entry\n";
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
