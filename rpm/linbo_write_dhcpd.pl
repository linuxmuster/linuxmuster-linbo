#!/usr/bin/perl  -w
# Copyright (c) 2018 Frank Schütte <fschuett@gymhim.de> GPLv3

use strict;
use JSON::XS;

my %hosts = ();
my %systemtype = ();

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
open(OSS,'echo "SELECT r.name,d.name,d.id, hw.name,d.MAC,d.IP FROM Devices d JOIN Rooms r ON d.room_id=r.id JOIN HWConfs hw ON d.hwconf_id=hw.id WHERE d.MAC != \"\" ORDER BY d.IP;" | mysql -N OSS |');
while(<OSS>){
        chomp;
        my ( $raum, $rechner, $id, $gruppe, $mac, $ip ) = split /\t/;
        my %temp = (
                raum => "$raum",
                rechner => "$rechner",
                id => "$id",
                gruppe => "$gruppe",
                mac => "$mac",
                ip => "$ip",
                r1 => "", r2 => "", r3 => "", r4 => "", r5 => "",
                pxe => "1",
        );
        $hosts{$rechner} = \%temp;
}
close(OSS);

my %dhcpStatements = ();
# read all dhcp statements from OSS
open(OSS,"echo \"SELECT omc.id, omc.objectId, omc.value FROM OSSMConfig omc JOIN Devices d ON omc.objectId=d.id WHERE omc.objectType='Device' AND omc.keyword='dhcpStatements';\" |mysql -N OSS |");
while(<OSS>){
	chomp;
	my ( $entry_id, $device_id, $value ) = split /\t/;
	$dhcpStatements{$device_id}{$entry_id} = $value;
}

# apply workstations file
my @to_add = ();
my @to_modify = ();
my @to_delete = ();
open(WORKSTATIONS,"</etc/linbo/workstations");
while(<WORKSTATIONS>){
        chomp;
        next if /^#/;
    my ( $raum, $rechner, $gruppe, $mac, $ip, $r1, $r2, $r3, $r4, $r5, $pxe ) = split /;/;
        if( not defined $hosts{$rechner} ){
                print "Fehler: In Raum $raum ist der Rechner $rechner mit der IP $ip nicht in OSS vorhanden!\n";
                next;
        }
        if( not exists $hosts{$rechner}{'id'} ){
			print "Fehler: Der Rechner $rechner in Raum $raum hat keine Id in der Devices-Tabelle von OSS!\n";
			next;
		}
		
		my $found_ep = 0;
		my $found_fn = 0;
        for my $entry_id (keys %{$dhcpStatements{$hosts{$rechner}{'id'}}}) {
			my $value = $dhcpStatements{$hosts{$rechner}{'id'}}{$entry_id};
			if( $value =~ /^option extensions-path/ ){
				if( $found_ep ){
					print "Fehler: In Raum $raum hat der rechner $rechner 'option extensions path' doppelt!\n";
					push @to_delete, $entry_id;
				} else {
					if( $value ne "option extensions-path \"".$gruppe."\"" ){
						push @to_modify, "$entry_id:option extensions-path \"".$gruppe."\"";
					}
					$found_ep = 1;
				}
			} elsif( $value =~ /^filename / ){
				if( $found_fn ){
					print "Fehler: In Raum $raum hat der Rechner $rechner 'filename ...' doppelt!\n";
					push @to_delete, $entry_id;
				} else {
					if( $value ne "filename \"".get_bootfilename($linbo{$gruppe})."\"" ){
						push @to_modify, "$entry_id:filename \"".get_bootfilename($linbo{$gruppe})."\"";
					}
					$found_fn = 1;
				}
			}
		}
		if( not $found_ep ){
			push @to_add, $hosts{$rechner}{'id'}.":option extensions-path \"".$gruppe."\"";
		}
		if( not $found_fn ){
			push @to_add, $hosts{$rechner}{'id'}.":filename \"".get_bootfilename($linbo{$gruppe})."\"";
		}
}
close(WORKSTATIONS);

# commit changes to OSS database and refreshConfig
print "Alte Einträge werden gelöscht...\n";
for my $entry (@to_delete) {
	print "\tDELETE FROM OSSMConfig WHERE id=$entry;\n";
	`echo "DELETE FROM OSSMConfig WHERE id=$entry;" |mysql OSS`;
}
print "Neue Einträge werden hinzugefügt...\n";
for (@to_add) {
	my ($id, $value) = split /:/;
	next if(not defined $id or not defined $value);
	$value =~ s/"/\\"/g;
	print "\tINSERT INTO OSSMConfig(objectType,objectId,keyword,value,creator_id) VALUES('Device',$id,'dhcpStatements','$value',1);\n";
	`echo "INSERT INTO OSSMConfig(objectType,objectId,keyword,value,creator_id) VALUES('Device',$id,'dhcpStatements','$value',1);" |mysql OSS`;
}
print "Veränderte Einträge werden korrigiert...\n";
for (@to_modify) {
	my ($id, $value) = split /:/;
	next if(not defined $id or not defined $value);
	$value =~ s/"/\\"/g;
	print "\tUPDATE OSSMConfig SET value='$value' WHERE id=$id;\n";
	`echo "UPDATE OSSMConfig SET value='$value' WHERE id=$id;" |mysql OSS`;
}

print "oss_api.sh PUT devices/refreshConfig...";
`/usr/sbin/oss_api.sh PUT devices/refreshConfig`;
print "\n";
