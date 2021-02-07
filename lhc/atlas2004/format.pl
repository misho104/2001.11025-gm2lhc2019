#!env perl

use strict;
use warnings;

open IN, "HEPData-ins1792399-v1-Table_07.csv";
open OUT, ">", "HEPData-ins1792399-v1-Table_07.csv.formatted";

my $header = [];
my $data = [];
my ($row, $column) = (0, 0);

foreach(<IN>){
  if(/^#/){
    print OUT $_;
    next;
  } elsif(/^\s*$/){
    next;
  }

  chomp;
  if($_ !~ /^\d\d\d,/){ # header line
    my($t1, $t2) = split /,/;
    if($column == 0){
      push(@$header, $t1);
      push(@$header, $t2);
    } else {
      die "invalid line? > " . $_ if $t1 ne $header->[0];
      push(@$header, $t2);
    }
    ($row, $column) = (0, $column + 1);
  } else { #data line
    my($t1, $t2) = split /,/;
    if($column == 1){
      push(@$data, [$t1, $t2])
    } else {
      die "invalid line? > " . $_ if $t1 != $data->[$row]->[0];
      push(@{$data->[$row]}, $t2);
    }
    $row++;
  }
}

print OUT join(", ", @$header) . "\n";

foreach(@$data){
  print OUT join(", ", @$_) . "\n";
}

close();

