#!/usr/bin/perl

use strict;
use warnings;

my $file = $ARGV[0] or die "File not given.";
my $masses = `yaslha-extract MASS $file`;

my ($neut1, $smuL, $char1) = (-1, -1, -1);

foreach(split("\n", $masses)){
  $neut1 = $1 if /^\s*1000022\s+(\S+)/;
  $smuL  = $1 if /^\s*1000013\s+(\S+)/;
  $char1 = $1 if /^\s*1000024\s+(\S+)/;
}
if ($neut1 < 0 or $smuL < 0 or $char1 < 0){
  die "invalid masses";
}

if ($smuL > $char1){
  print("not med-slep")
}else{
  my $x = ($smuL - $neut1) / ($char1 - $neut1);
  print("med-slep with x=$x");
}
exit(0);
