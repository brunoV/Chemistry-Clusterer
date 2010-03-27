#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok( 'Chemistry::Clusterer::CoordExtractor::All' ) }

my %coords = (
    CA => { L => [ map { 42 } 1..10 ], H => [ map { 42 } 1..10 ] },
    O  => { L => [ map { 42 } 1..10 ] },
);

my $extractor = Chemistry::Clusterer::CoordExtractor::All->new();

my $coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 30;

done_testing();
