#!/usr/bin/perl -w
# linbo-modify-device.pl
#
# Remove device from workstations file
# Frank Schütte <fschuett@gymhim.de> 2018

use strict;

my $workstations = "/etc/linbo/workstations";
my $temp = `mktemp /tmp/linbo-modify-deviceXXXXXXXX`;
chomp $temp;
my %host = ();
my $HWCONF = 2;
my $MAC = 3;
my $IP = 4;
my $WLANMAC = 5;
my $WLANIP = 6;

while(<STDIN>){
    chomp;
    my ($name, $value) = split /:/,$_,2;
    next if(not defined $name or not defined $value);
    $name =~ s/^\s+|\s+$//g;
    $value =~ s/^\s+|\s+$//g;
    $host{$name} = $value;
}
exit 0 if not defined $host{'name'} or $host{'name'} eq '';
exit 0 if not defined $host{'mac'} or $host{'mac'} eq '';

open(WORKSTATIONS, "<$workstations");
open(TEMP, ">$temp");
while(<WORKSTATIONS>){
    chomp;
    if(/^[^;]*;$host{'name'};.*$/){
        my (@line) = split /;/,$_,-1;
        $line[$HWCONF] = $host{'hwconf'} if defined $host{'hwconf'};
        $line[$IP] = $host{'ip'} if defined $host{'ip'};
        $line[$MAC] = $host{'mac'} if defined $host{'mac'};
        $line[$WLANIP] = $host{'wlanIp'} if defined $host{'wlanIp'};
        $line[$WLANMAC] = $host{'wlanMac'} if defined $host{'wlanMac'};
        $_ = join ';', @line;
    }
    print TEMP "$_\n";
}
close(TEMP);
close(WORKSTATIONS);

system("rm -f $workstations");
system("mv $temp $workstations");
system("chown root:root $workstations");
system("chmod 644 $workstations");
