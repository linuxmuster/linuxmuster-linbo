#!/usr/bin/perl  -w
# Copyright (c) 2017 Frank Schütte <fschuett@gymhim.de> GPLv3
BEGIN{
    push @INC,"/usr/share/oss/lib/";
}

use strict;
use oss_base;
use oss_utils;

my $HOST     = {};
my @hosts = ();
my $connect  = {};
my $oss_base = undef;

sub get_bootfilename($)
{
    my $systemtype = shift || 'bios';
    if( $systemtype =~ /bios64/ )
    {
	return 'filename "boot/grub/i386-pc/core.0"';
    } elsif( $systemtype =~ /efi32/ )
    {
	return 'filename "boot/grub/i386-efi/core.efi"';
    } elsif( $systemtype =~ /efi64/ )
    {
	return 'filename "boot/grub/x86_64-efi/core.efi"';
    } else {
	return 'filename "boot/grub/i386-pc/core.0"';
    }
}

while(my $param = shift)
{
  if( $param =~ /text/i ) { $connect->{XML}=0; }
}

binmode STDIN, ':utf8';
while(<STDIN>)
{
        # Clean up the line!
        chomp; s/^\s+//; s/\s+$//;

        my ( $key, $value ) = split / /,$_,2;

        next if( getConnect($connect,$key,$value)); 
        if( defined $key && $key eq 'name' && defined $HOST->{name} )
        {
    		push @hosts,$HOST;
    		$HOST = {};
        }
        if( defined $key && defined $value ) 
        {
                $HOST->{$key}   = $value;
        }
}
if( defined $HOST->{name} )
{
    push @hosts,$HOST;
}

# Make OSS Connection
if( defined $ENV{SUDO_USER} )
{
   if( ! defined $connect->{aDN} || ! defined $connect->{aPW} )
   {
       die "Using sudo you have to define the parameters aDN and aPW\n";
   }
}
$oss_base = oss_base->new($connect);
my $DEBUG               = 0;
if( $oss_base->get_school_config('SCHOOL_DEBUG') eq 'yes' )
{
  $DEBUG = 1;
  use Data::Dumper;
}

foreach my $HOST (@hosts)
{
    my $dn = $oss_base->get_workstation($HOST->{ipaddress});
    my $group = $HOST->{group};
    my $systemtype = $HOST->{systemtype};
    if( ! defined $dn or $dn eq '' )
    {
	die "  > Host " . $HOST->{name} . " has no valid dn.";
    }
    if( ! defined $group or $group eq '')
    {
	die "  > Host " . $HOST->{name} . " has no valid group.";
    }
    if( ! defined $systemtype or $systemtype eq '' )
    {
	die "  > Host " . $HOST->{name} . " has no valid systemtype.";
    }
    print "  * DHCP for $dn...\n";
    my $le = $oss_base->get_entry($dn);
    foreach my $line (@{$le->{'dhcpstatements'}})
    {
	if($line =~ /^option extensions-path / or $line =~ /^filename /)
	{
	    $oss_base->del_attribute($dn,'dhcpstatements',$line);
	}
    }
    $oss_base->add_attribute($dn,'dhcpstatements','option extensions-path "' . $group . '"');
    $oss_base->add_attribute($dn,'dhcpstatements',get_bootfilename($HOST->{systemtype}));
    if( $DEBUG )
    {
        open(OUT,">/tmp/ldap_modify.dhcpStatements");
        print OUT Dumper($HOST);
        close OUT;
    }
}

$oss_base->destroy();
