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
	do {
	        $socket->recv($data,1024);
	        print "Received from client $peeraddress : $data\n";

	        if ($data eq "SENDALLCONTACTS") {
	                print "Client $peeraddress wants us to send it all the contacts the server has seen\n";
	        }
	        elsif ($data) {
	                print "Client $peeraddress sent us a log entry, do sometihng with it\n";
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
