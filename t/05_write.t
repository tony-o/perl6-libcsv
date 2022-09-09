#!/usr/bin/env perl6

use Test;
use Text::CSV::LibCSV;
plan 6;

ok csv-write-field('test') eq '"test"';
ok csv-write-field('test', :quote<->) eq '-test-';
ok csv-write([qw<a b c>, [1,2,3]]) eq '"a","b","c"'~"\n"~'"1","2","3"'~"\n";
ok csv-write([qw<a b c>, [1,2,3]], :quote<_>, :delimiter<->) eq "_a_-_b_-_c_\n_1_-_2_-_3_\n";

my $parser = Text::CSV::LibCSV.new(:delimiter(","), :quote("_"), :parser-options(Text::CSV::LibCSV.build-options(:CSV-STRICT)) );
ok $parser.csv-write-field('___') eq '________';
ok $parser.csv-write([qw<a b c>, [1,2,3]]) eq "_a_,_b_,_c_\n_1_,_2_,_3_\n";
