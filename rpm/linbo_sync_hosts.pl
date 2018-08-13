#!/usr/bin/perl -w
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
my $tempfile     = 0;
my $result       = 0;

sub close_on_error
{
    my $a = shift;
    print STDERR $a."\n";
#    system("rm $PIDFILE");
#    system("rm $RUNFILE");
#    open( LOGIMPORTLIST,">>$output");
#    binmode LOGIMPORTLIST, ':encoding(utf8)';
#    print LOGIMPORTLIST "$a";
	print "$a";
#    close(LOGIMPORTLIST);
    exit 1;
}

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
my %hwconfs = ();
my %osshosts = ();
my %rooms = ();

print "Reading Rooms...\n";
$result = `/usr/sbin/oss_api.sh GET rooms/all`;
$result = eval { decode_json($result) };
if ($@)
{
    close_on_error( "decode_json failed, invalid json. error:$@\n" );
}
foreach my $r (@{$result}) {
	$rooms{$r->{'name'}} = $r;
}

print "Reading HWConfs...\n";
$result = `/usr/sbin/oss_api.sh GET clonetool/all`;
$result = eval { decode_json($result) };
if ($@)
{
    close_on_error( "decode_json failed, invalid json. error:$@\n" );
}

foreach my $hwconf (@{$result}){
	next if $hwconf->{'deviceType'} ne 'FatClient';
	next if not defined $hwconf->{'name'} or not defined $hwconf->{'id'};
	$hwconfs{$hwconf->{'name'}} = $hwconf->{'id'};
}

print "Reading Devices...\n";
$result = `/usr/sbin/oss_api.sh GET devices/all`;
$result = eval { decode_json($result) };
if ($@)
{
    close_on_error( "decode_json failed, invalid json. error:$@\n" );
}
foreach my $d (@{$result}) {
	$osshosts{$d->{'name'}} = 1;
}

print "Reading ".$ARGV[0]."...\n";
open(WORKSTATIONS,"<$ARGV[0]");
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
            hwconf_id => $hwconfs{$gruppe},
            MAC => "$mac",
            IP => "$ip",
            r1 => "$r1", r2 => "$r2", r3 => "$r3", r4 => "$r4", r5 => "$r5",
            pxe => "$pxe",
    );
    if(not defined $osshosts{$rechner}){
		push @toadd, \%temp;
	}
}
close(WORKSTATIONS);

if( scalar(@toadd) ){
	print scalar(@toadd)." hosts will be added to the system.\n";
	for my $host (@toadd) {
		# create device
		my $room_id = $rooms{$host->{'room'}}{'id'};
		if(not defined $room_id){
			close_on_error("Host cannot be added to non existing room: ".Data::Dumper($host)."\n");
		}
		my $room_id = $rooms{$host->{'room'}}{'id'};
		if(not defined $room_id){
				close_on_error("Host cannot be added to non existing room: ".Data::Dumper($host)."\n");
		}
		$result = `/usr/sbin/oss_api.sh GET rooms/$room_id/availableIPAddresses`;
		$result = eval { decode_json($result) };
		if ($@)
		{
				close_on_error( "decode_json failed, invalid json. error:$@\n" );
		}
		if(not scalar(@{$result})){
				close_on_error("Host room has no free IP adresses: ".Data::Dumper($host)."\n");
		}
		$host->{IP} = shift @{$result};
		$result = `/usr/sbin/oss_api.sh PUT clonetool/rooms/$room_id/$host->{'MAC'}/$host->{'IP'}/$host->{'name'}`;
		$result = eval { decode_json($result) };
		if ($@)
		{
				close_on_error( "decode_json failed, invalid json. error:$@\n" );
		}
		if ($result->{'code'} ne "OK") {
				close_on_error( "adding of host failed. error: $result->{'value'}\n".Data::Dumper($host)."\n" );
		}
		$result = `/usr/sbin/oss_api.sh GET devices/byIP/$host->{'IP'}`;
		$result = eval { decode_json($result) };
		if ($@)
		{
				close_on_error( "decode_json failed, invalid json. error:$@\n" );
		}
		# update data to include room and hwconf
		$result->{'hwconfId'} = $host->{'hwconf_id'};
		$result->{'roomId'} = $room_id;
		$result->{'inventary'} = '' if not defined $result->{'inventary'};
		$result->{'serial'} = '' if not defined $result->{'serial'};
		$result->{'locality'} = '' if not defined $result->{'locality'};
		$result->{'counter'} = 0 if not defined $result->{'counter'};
		$tempfile = "/tmp/modify_host.$host->{'name'}";
		write_file($tempfile, hash_to_json($result));
		$result = `/usr/sbin/oss_api_post_file.sh devices/modify $tempfile`;
		$result = eval { decode_json($result) };
		if ($@)
		{
			close_on_error( "decode_json failed, invalid json. error:$@\n" );
		}
		if( $result->{"code"} eq "OK" )
		{
			print "  new hosts $host->{name}\n";
		}
	}
} else {
	print "No new hosts to import.\n";
}
