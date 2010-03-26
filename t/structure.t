#!/usr/bin/env perl
use Test::More;
use autodie;

BEGIN { use_ok( 'Chemistry::Clusterer::Structure' ) }

my $pdb_file = 't/data/2.pdb';

my @coords = split /\s+/, join '', <DATA>;

open( my $fh, '<', $pdb_file );
my $content = do { local $/; <$fh> };

open( $fh, '<', $pdb_file );

foreach my $input ($content, $fh, \@coords) {

    my $structure = Chemistry::Clusterer::Structure->new( coords => $input );

    isa_ok( $structure, 'Chemistry::Clusterer::Structure' );

    is_deeply( $structure->coords, \@coords );
}

done_testing();

__DATA__
17.675 112.846 216.220
18.078 115.363 213.445
15.095 115.515 211.158
14.433 116.800 207.657
11.292 118.208 206.135
9.385 116.416 203.401
10.789 118.757 200.803
9.209 121.225 198.443
9.500 120.785 194.722
10.061 124.042 192.930
8.573 123.925 189.490
8.965 126.680 186.977
5.910 127.865 185.164
