#!/usr/bin/env perl6

use Test;
plan 1;

use Text::CSV::LibCSV;

my $outcome = 1;
my $parser  = Text::CSV::LibCSV.new(:auto-decode('utf8'), :has-headers);
my $keys    = 0;

my @lines = $parser.read-file('t/data/multiline.csv');

for (@lines) -> %line {
  for (%line.kv) -> $k,$v {
    $keys++;
    $outcome = 0 if $k ne $v; 
  }
}

$outcome = 0 if $keys != 5; 
ok $outcome == 1;
