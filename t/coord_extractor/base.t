#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok( 'Chemistry::Clusterer::CoordExtractor' ) };

my $extractor = Chemistry::Clusterer::CoordExtractor->new;

dies_ok { $extractor->extract_coords } 'Base class instance dies ok';

done_testing;
