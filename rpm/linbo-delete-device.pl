#!/usr/bin/perl -w
# linbo-delete-device.pl
#
# Remove device from workstations file
#
use strict;

my $workstations = "/etc/linbo/workstations";
my $temp = `mktemp /tmp/linbo-delete-deviceXXXXXXXX`;
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
exit 0 if not defined $host{'name'} or $host{'name'} eq '';

open(WORKSTATIONS, "<$workstations");
open(TEMP, ">$temp");
while(<WORKSTATIONS>){
    next if(/^[^;]*;$host{'name'};.*$/);
    print TEMP "$_";
}
close(TEMP);
close(WORKSTATIONS);

system("rm -f $workstations");
system("mv $temp $workstations");
system("chown root:root $workstations");
system("chmod 644 $workstations");
