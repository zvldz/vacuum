#!/usr/bin/perl
#
# Source: https://habr.com/ru/post/435064/

use strict;
use warnings;
use IO::Socket::INET;

$| = 1;

my $volume = 1.0;
my $volume_file = "/mnt/data/sox_volume";
if (-e $volume_file) {
    open FILE, $volume_file;
    $volume = <FILE>;
    chomp $volume;
    close FILE;
    print "restored volume level: $volume\n";
}

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
    # print "connection from $client_address:$client_port\n";
    my $data = '';
    my $playing = 'False';
    $client_socket->recv($data, 256);
    # print "received data: $data\n";
    my @urls = split /;/, $data;
    if (scalar(@urls) > 1 && not grep(/^$urls[1]$/, ('', 'None', $volume))) {
        $volume = $urls[1];
        open FILE, ">$volume_file";
        print FILE $volume, "\n";
        close FILE;
    }
    if ($urls[0] ne '' && $urls[0] ne 'None') {
        system("killall -s 9 play > /dev/null 2>&1");
        if ($urls[0] ne 'stop') {
            system("play -q -v " . $volume * 2 . " " . $urls[0] . " &");
        }
    }
    $playing = system("ps aux | grep -e '[ ]play ' >/dev/null") == 0 ? 'True' : 'False';
    $client_socket->send("playing=$playing;volume=$volume");
    shutdown($client_socket, 1);
}

$socket->close();
