#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok( 'Chemistry::Clusterer::CoordExtractor::Chain' ) }

my %coords = (
    CA => { L => [ map { 42 } 1..10 ], H => [ map { 42 } 1..10 ] },
    O  => { L => [ map { 42 } 1..10 ] },
    N  => { L => [ map { 42 } 1..5 ] },
);

dies_ok { Chemistry::Clusterer::CoordExtractor::Chain->new() } 'constructor dies with no args';

my $extractor = Chemistry::Clusterer::CoordExtractor::Chain->new(
    args => 'L',
);

my $coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 25;

$extractor = Chemistry::Clusterer::CoordExtractor::Chain->new(
    args => ['H', 'L']
);

$coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 35;

$extractor = Chemistry::Clusterer::CoordExtractor::Chain->new(
    args => 'H'
);

$coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 10;

done_testing();
