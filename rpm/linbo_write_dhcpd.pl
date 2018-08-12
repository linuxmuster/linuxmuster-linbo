#!/usr/bin/perl  -w
# Copyright (c) 2018 Frank Schütte <fschuett@gymhim.de> GPLv3

use strict;

my %hosts = ();
my %systemtype = ();

sub ipsort {
  my @a = split /\./, $a;
  my @b = split /\./, $b;

  return $a[0] <=> $b[0]
      || $a[1] <=> $b[1]
      || $a[2] <=> $b[2]
      || $a[3] <=> $b[3];
}

sub get_bootfilename($)
{
    my $systemtype = shift || 'bios';
    
    if( $systemtype =~ /bios64/ )
    {
                return "boot/grub/i386-pc/core.0";
    } elsif( $systemtype =~ /efi32/ )
    {
                return "boot/grub/i386-efi/core.efi";
    } elsif( $systemtype =~ /efi64/ )
    {
                return "boot/grub/x86_64-efi/core.efi";
    } else {
                return "boot/grub/i386-pc/core.0";
    }
}

# linbo-Gruppen lesen
my $dir='/srv/tftp';
my %linbo = ();
opendir(DIR,$dir) or die $!;
while (my $file = readdir(DIR)) {
        my ($gruppe) = $file =~ /^start\.conf\.([0-9a-zA-Z_-]+)$/;
        next if not defined $gruppe;
        open(CONF,"</srv/tftp/start.conf.$gruppe");
        while(<CONF>){
                        chomp;
                        my ( $type ) = lc($_) =~ /^systemtype\s=\s(bios|bios64|efi32|efi64)/;
                        if( defined $type ){
                                $linbo{$gruppe} = $type;
                                last;
                        }
                }
}

# read all rooms from OSS
open(OSS,'echo "SELECT r.name,d.name,hw.name,d.MAC,d.IP FROM Devices d JOIN Rooms r ON d.room_id=r.id JOIN HWConfs hw ON d.hwconf_id=hw.id WHERE d.MAC != \"\" ORDER BY d.IP;" | mysql -N OSS |');
while(<OSS>){
        chomp;
        my ( $raum, $rechner, $gruppe, $mac, $ip ) = split /\t/;
        my %temp = (
                raum => "$raum",
                rechner => "$rechner",
                gruppe => "$gruppe",
                mac => "$mac",
                ip => "$ip",
                r1 => "", r2 => "", r3 => "", r4 => "", r5 => "",
                pxe => "1",
        );
        $hosts{$ip} = \%temp;
}
close(OSS);

# apply workstations file
open(WORKSTATIONS,"</etc/linbo/workstations");
while(<WORKSTATIONS>){
        chomp;
        next if /^#/;
    my ( $raum, $rechner, $gruppe, $mac, $ip, $r1, $r2, $r3, $r4, $r5, $pxe ) = split /;/;
        if( not defined $hosts{$ip} ){
                print "Fehler: In Raum $raum ist der Rechner $rechner mit der IP $ip nicht in OSS vorhanden!\n";
                next;
        }
        $hosts{$ip}{"option extensions-path"} = $gruppe;
        $hosts{$ip}{filename} = get_bootfilename($linbo{$gruppe});
}
close(WORKSTATIONS);

# stop dhcpd
system("systemctl stop dhcpd");

# write new config
system("cat /usr/share/oss/templates/dhcpd.conf >/etc/dhcpd.conf");
open(DHCPD,">>/etc/dhcpd.conf");
my $bisher = "";
foreach my $ip (sort ipsort keys %hosts) {
        my %host = %{$hosts{$ip}};
        if($bisher ne "" && $host{raum} ne $bisher){ # Raum beenden
                print DHCPD "}\n";
        }
        if($bisher eq "" || $host{raum} ne $bisher){ # Raum beginnen
                print DHCPD "group {\n";
                print DHCPD "  #Room" . $host{raum} ."\n";
                $bisher = $host{raum};
        }
        print DHCPD "    host ".$host{rechner}." {\n";
        print DHCPD "      hardware ethernet ".$host{mac}.";\n";
        print DHCPD "      fixed-address ".$host{ip}.";\n";
        print DHCPD "      option extensions-path \"".$host{"option extensions-path"}."\";\n" if defined $host{"option extensions-path"};
        print DHCPD "      filename \"".$host{filename}."\";\n" if defined $host{filename};
        print DHCPD "    }\n";
}
print DHCPD "}\n"; # letzten Raum beenden
close(DHCPD);

# start dhcpd
system("systemctl start dhcpd");

