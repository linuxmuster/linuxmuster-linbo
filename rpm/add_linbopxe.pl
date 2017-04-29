#!/usr/bin/perl
# Copyright (c) 2017 Frank Schütte <fschuett@gymhim.de> Hildesheim, Germany.  All rights reserved.
# <fschuett@gymhim.de>
# 220417
#
# update configurationValue: LINBOPXE=0|1|2|3|22 in DHCP entry according to workstations
#

BEGIN{
    push @INC,"/usr/share/oss/lib/";
}

$| = 1; # do not buffer stdout

use strict;
use oss_base;

my $role        = "";
my $uid         = "";
my $linbopxe    = 0;
my $dn          = "";

while(<STDIN>)
{
  my ( $key, $value ) = split / /,$_,2;
  chomp $value; $key = lc( $key );
  if ( $key eq 'role' )
  {
     $role = lc($value);
  }
  elsif $key eq 'uid' )
  {
    $uid = lc($value);
  }
}

if ( $role ne 'workstations' || $uid eq '' )
{
  exit;
}
#read linbo environment
my $bashcode=<<'__bash__';
. /etc/linbo/linbo.sh;
. $ENVDEFAULTS;
perl -MData::Dumper -e 'print Dumper \%ENV';
__bash__

my $linbo;
eval qx{bash -c "$bashcode"};
if( not defined $linbo->{WIMPORTDATA} || $linbo->{WIMPORTDATA} eq '' )
{
    exit;
}
#read linbo setting from WIMPORTDATA
open my $wimport,$linbo->{WIMPORTDATA}
while( my $line=<$wimport> )
{
    $line =~ /^$uid;/ or next;
    my $part = split(';', $line);
    $part[10] or next;
    $linbopxe = $part[10];
    break;
}
close $wimport;

#update configurationValue in DHCP entry
my $oss = oss_base->new();
my $dn = oss_base->get_workstation($uid);
if( $dn eq '' )
{
  exit;
}

if( ! $linbopxe && $oss->check_config_value($dn,'LINBOPXE',$linbopxe) )
{
  $oss->delete_config_value($dn,'LINBOPXE');
}
elsif( $linbopxe )
{
  $oss->add_config_value($dn,'LINBOPXE',$linbopxe);
}

$oss->destroy();
