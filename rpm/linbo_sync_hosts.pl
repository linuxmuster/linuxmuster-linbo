#!/usr/bin/perl -wd
# 2017-2018 Copyright Frank Schütte <fschuett@gymhim.de>
# sync hosts with workstations file
# add missing hosts
#

use strict;
use Data::Dumper;
use JSON::XS;
use Encode qw(encode decode);
binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";
use utf8;

# Global variable
my $config       = "/etc/sysconfig/schoolserver";
my $tempfile     = `mktemp /tmp/sync_hostsXXXXXXXX`;

sub hash_to_json($) {
    my $hash = shift;
    my $json = '{';
    foreach my $key ( keys %{$hash} ) {
	my $value = $hash->{$key};
        $json .= '"'.$key.'":';
	if( $value eq 'true' ) {
       $json .= 'true,';
	} elsif ( $value eq 'false' ) {
       $json .= 'false,';
	} elsif ( $value =~ /^\d+$/ ) {
       $json .= $value.',';
	} else {
		$value =~ s/"/\\"/g;
		$json .= '"'.$value.'",';
	}
    }
    $json =~ s/,$//;
    $json .= '}';
}

sub write_file($$) {
  my $file = shift;
  my $out  = shift;
  local *F;
  open F, ">$file" || die "Couldn't open file '$file' for writing: $!; aborting";
  binmode F, ':encoding(utf8)';
  local $/ unless wantarray;
  print F $out;
  close F;
}

if( $> )
{
    die "Only root may start this programm!\n";
}

my @toadd = ();
my %hwconfs = {};
my %osshosts = {};

print "Reading HWConfs from OSS database...\n";
open(OSS,'echo "SELECT name,id FROM HWConfs ORDER BY name;" | mysql -N OSS |');
while(<OSS>){
        chomp;
        my ($name, $id) = split /\t/;
        if(defined $name and defined $id){
			$hwconfs{$name} = $id;
		}
}
close(OSS);

print "Reading Devices from OSS database...\n";
open(OSS,'echo "SELECT d.name FROM Devices d ORDER BY d.name;" | mysql -N OSS |');
while(<OSS>){
        chomp;
        $osshosts{$_} = 1;
}
close(OSS);

print "Reading /etc/linbo/workstations...\n";
open(WORKSTATIONS,"</etc/linbo/workstations");
while(<WORKSTATIONS>){
    chomp;
    if($_ =~ /^#/){
        next;
    }
    my ( $raum, $rechner, $gruppe, $mac, $ip, $r1, $r2, $r3, $r4, $r5, $pxe ) = split /;/;
    my %temp = (
			room => "$raum",
            name => "$rechner",
            hwconf => "$gruppe",
            hwconf_id => $hwconfs{$temp{hwconf}},
            MAC => "$mac",
            IP => "$ip",
            r1 => "$r1", r2 => "$r2", r3 => "$r3", r4 => "$r4", r5 => "$r5",
            pxe => "$pxe",
    );
    if(not defined $osshosts{$rechner}){
		push @toadd, %temp;
	}
}
close(WORKSTATIONS);

if( scalar(@toadd) ){
	print "scalar(@toadd)." will be added to the system.\n";
	for my $host (@toadd) {
		write_file("$tempfile",hash_to_json($hosts));
		#TODO Check result
		print("/usr/sbin/oss_api_post_file.sh devices/add $tempfile\n");
		system("/usr/sbin/oss_api_post_file.sh devices/add $tempfile");
		print "  new hosts $host{name}\n";
	}
} else {
	print "No new hosts to import.\n";
}
