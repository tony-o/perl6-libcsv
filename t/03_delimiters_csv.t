#!/usr/bin/env perl6

use Test;
plan 2;

use Text::CSV::LibCSV;

my $outcome = 1;
my $parser  = Text::CSV::LibCSV.new(:delimiter<|>, :quote<'>, :auto-decode('utf8'));
my $keys    = 0;

my @lines   = $parser.read-file('t/data/delimiters.csv');

ok @lines.elems == 2;
is-deeply @lines, [ [|qw< i has headers with >, 'a line' ], [qw< i has headers with | >] ];
