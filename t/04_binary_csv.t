#!/usr/bin/env perl6

use Test;
use Text::CSV::LibCSV;
plan 1;


my $outcome = 1;
my $line    = [ Buf.new(0x6, 0x10, 0x6, 0x5, 0x11), Buf.new(0x0, 0x0) ];

my $parser = Text::CSV::LibCSV.new(:delimiter("\x[0]"), :quote("\x[1]"), :parser-options(Text::CSV::LibCSV.build-options(:CSV-STRICT)) );

my @lines = $parser.read-file('t/data/binary.csv');

is-deeply @lines[0], $line;
