#!/usr/bin/perl -w
# linbo-update-ips.pl
#
# Update ip, wlanip in workstations file
#
use strict;

my $workstations = "/etc/linbo/workstations";
my $temp = `mktemp /tmp/linbo-update-ipsXXXXXXXX`;
chomp $temp;
my %host = ();
my $IP = 4;
my $WLANIP = 6;

while(<STDIN>){
    chomp;
    my ($name, $value) = split /:/,$_,2;
    next if(not defined $name or not defined $value);
    $name =~ s/^\s+|\s+$//g;
    $value =~ s/^\s+|\s+$//g;
    $host{$name} = $value;
}

open(WORKSTATIONS, "<$workstations");
open(TEMP, ">$temp");
while(<WORKSTATIONS>){
    chomp;
    if(/^[^;]*;$host{'name'};.*$/){
        my (@line) = split /;/;
        $line[$IP] = $host{'ip'};
        $line[$WLANIP] = $host{'wlanIp'} if defined $host{'wlanIp'};
        $_ = join ';', @line;
        $_ .= ';';
    }
    print TEMP "$_\n";
}
close(TEMP);
close(WORKSTATIONS);

system("rm -f $workstations");
system("mv $temp $workstations");
system("chown root:root $workstations");
system("chmod 644 $workstations");
