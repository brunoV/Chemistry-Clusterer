#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok( 'Chemistry::Clusterer::CoordExtractor::AtomType' ) }

my %coords = (
    CA => { L => [ map { 42 } 1..10 ], H => [ map { 42 } 1..10 ] },
    O  => { L => [ map { 42 } 1..10 ] },
    N  => { L => [ map { 42 } 1..5 ] },
);

dies_ok { Chemistry::Clusterer::CoordExtractor::AtomType->new() } 'constructor dies with no args';

my $extractor = Chemistry::Clusterer::CoordExtractor::AtomType->new(
    args => 'CA',
);

my $coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 20;

$extractor = Chemistry::Clusterer::CoordExtractor::AtomType->new(
    args => ['CA', 'O']
);

$coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 30;

$extractor = Chemistry::Clusterer::CoordExtractor::AtomType->new(
    args => ['CA', 'O', 'N']
);

$coords = $extractor->extract_coords( \%coords );

is scalar @$coords, 35;

done_testing();
