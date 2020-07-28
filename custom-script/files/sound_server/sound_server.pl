#!/usr/bin/perl
#
# Source: https://habr.com/ru/post/435064/

use IO::Socket::INET;

$| = 1;

my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '7777',
    Proto => 'tcp',
    Listen => 2,
    Reuse => 1
);

die "cannot create socket $!\n" unless $socket;
print "server waiting for client connection on port 7777\n";

while(1)
{
    my $client_socket = $socket->accept();
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "connection from $client_address:$client_port\n";
    my $data = "";
    $client_socket->recv($data, 256);
    print "received data: $data\n";
    my @urls = split /;/, $data;
    system("killall play > /dev/null 2>&1");
    $data = "ok";
    $client_socket->send($data);
    shutdown($client_socket, 1);
    if ( $urls[0] ne "") {
        system("play -q -v 2.0 " . $urls[0] . " &");
    }
}

$socket->close();
