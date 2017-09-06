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
  elsif ( $key eq 'uid' )
  {
    $uid = lc($value);
  }
}

if ( $role ne 'workstations' || $uid eq '' )
{
  exit;
}

#read linbo environment
my $wimportdata = '/etc/linbo/workstations';

#read linbo setting from WIMPORTDATA
open WIMPORT,$wimportdata;
while( my $line=<WIMPORT> )
{
    chomp;
    my @part = split(';', $line);
    $part[1] =~ $uid or next;
    $part[10] or next;
    $linbopxe = $part[10];
    last;
}
close WIMPORT;

#update configurationValue in DHCP entry
my $oss = oss_base->new();
$dn = $oss->get_workstation($uid);
if( $dn eq '' )
{
  exit;
}

if( $linbopxe == 1 )
{
  print "Add LINBOPXE for $uid\n";
  $oss->add_config_value($dn,'LINBOPXE','1');
}
else
{
  print "Delete LINBOPXE for $uid\n";
  $oss->delete_config_value($dn,'LINBOPXE','1');
}

$oss->destroy();
