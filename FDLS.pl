#!/usr/bin/perl
#tcpserver.pl

use strict;
use warnings;
use IO::Socket::INET;

# flush after every write
$| = 1;

my $data;
my ($socket,$client_socket);
my ($peeraddress,$peerport);
my $ip = '192.168.100.202';
my $port = '7373';
my $proto = 'tcp';

# creating object interface of IO::Socket::INET modules which internally does 
# socket creation, binding and listening at the specified port address.
$socket = new IO::Socket::INET (
LocalHost => $ip,
LocalPort => $port,
Proto => $proto,
Listen => 5,
ReuseAddr => 1
) or die "ERROR in Socket Creation : $!\n";

print "Waiting for client connection on port $port\n";

while(1)
{
print "First we are here.\n";
# waiting for new client connection.
$client_socket = $socket->accept();

# get the host and port number of newly connected client.
$peeraddress = $client_socket->peerhost();
$peerport = $client_socket->peerport();

print "Accepted New Client Connection From : $peeraddress, $peerport\n ";

# write operation on the newly accepted client.
#$data = “DATA from Server”;
#print $client_socket “$data\n”;
# we can also send the data through IO::Socket::INET module,
# $client_socket->send($data);

# read operation on the newly accepted client
#$data = <$client_socket>;
# we can also read from socket through recv()  in IO::Socket::INET
#while($client_socket->recv($data,1024) != 0)
do {
	$client_socket->recv($data,1024);
	print "Received from Client : $data\n";

	if ($data eq "SENDALLCONTACTS") {
		print "Client wants us to send it all the contacts the server has seen\n";
	}
	else {
		print "Client sent us a log entry, do sometihng with it\n";
	}

} while ($data);

}

$socket->close();
print "Socket closed.";
