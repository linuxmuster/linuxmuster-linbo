#!/usr/bin/perl  -wd
# Copyright (c) 2018 Frank Schütte <fschuett@gymhim.de> GPLv3
# update/create workstations file from existing hosts
#
# /etc/linbo/workstations
#
# Format: Raum;Rechnername;Gruppe;MAC;IP;;;;;;PXE-Flag;
#
use strict;

print "Reading Linbo groups...\n";
my $dir='/srv/tftp';
my %linbo = ();
opendir(DIR,$dir) or die $!;
while (my $file = readdir(DIR)) {
        my ($gruppe) = $file =~ /^start\.conf\.([0-9a-zA-Z_-]+)$/;
        next if not defined $gruppe;
        $linbo{$gruppe} = '1';
}

print "Reading /etc/linbo/workstations...\n";
open(WORKSTATIONS,"</etc/linbo/workstations");
my %hosts = ();
my @comments;
while(<WORKSTATIONS>){
    chomp;
    if($_ =~ /^#/){
        push @comments, $_;
        next;
    }
    my ( $raum, $rechner, $gruppe, $mac, $ip, $r1, $r2, $r3, $r4, $r5, $pxe ) = split /;/;
    my %temp = (
            raum => "$raum",
            rechner => "$rechner",
            gruppe => "$gruppe",
            mac => "$mac",
            ip => "$ip",
            r1 => "$r1", r2 => "$r2", r3 => "$r3", r4 => "$r4", r5 => "$r5",
            pxe => "$pxe",
    );
    $hosts{$rechner} = %temp;
}
close(WORKSTATIONS);

open(OSS,'echo "SELECT r.name,d.name,hw.name,d.MAC,d.IP FROM Devices d JOIN Rooms r ON d.room_id=r.id JOIN HWConfs hw ON d.hwconf_id=hw.id ORDER BY d.name;" | mysql -N OSS |');
while(<OSS>){
        chomp;
        my ( $raum, $rechner, $gruppe, $mac, $ip ) = split /\t/;
        next if not exists $linbo{$gruppe};
        if(defined $hosts{$rechner}){
            $hosts{$rechner}{"raum"} = "$raum";
            $hosts{$rechner}{"rechner"} = "$rechner";
            $hosts{$rechner}{"gruppe"} = "$gruppe";
            $hosts{$rechner}{"mac"} = "$mac";
            $hosts{$rechner}{"ip"} = "$ip";
        } else {
            my %temp = (
                raum => "$raum",
                rechner => "$rechner",
                gruppe => "$gruppe",
                mac => "$mac",
                ip => "$ip",
                r1 => "", r2 => "", r3 => "", r4 => "", r5 => "",
                pxe => "1",
            );
            $hosts{$rechner} = \%temp;
        }
}
close(OSS);

open(WORKSTATIONS,">/etc/linbo/workstations");

for my $line (@comments){
	print WORKSTATIONS "$line\n";
}

for my $key (sort keys %hosts){
    my %host = %{$hosts{$key}};
    print WORKSTATIONS $host{raum}.";".$host{rechner}.";".$host{gruppe}.";".$host{mac}.";".$host{ip}.";";
    print WORKSTATIONS $host{r1}.";".$host{r2}.";".$host{r3}.";".$host{r4}.";".$host{r5}.";".$host{pxe}.";\n";
}
print "Added hosts to /etc/linbo/workstations.\n";
close(WORKSTATIONS);

exit 0;

