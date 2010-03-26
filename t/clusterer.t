use strict;
use warnings;

use Test::More;
use Test::Exception;
use autodie;

BEGIN { use_ok('Chemistry::Clusterer'); }

my @pdbfiles = <./t/data/[2-5].pdb>;

my %input;

# Build lists of input of all possible types

foreach my $file (@pdbfiles) {

    my $content = do { local $/; open( my $fh, '<', $file ); <$fh> };
    push @{ $input{str} }, $content;

    open( my $fh, '<', $file );
    push @{ $input{fh} }, $fh;

}

my $clusterer;

foreach my $input_type ( keys %input ) {

    lives_ok {
        $clusterer =
          Chemistry::Clusterer->new( structures => $input{$input_type} );
    };

    isa_ok( $clusterer, 'Chemistry::Clusterer' );

    is $clusterer->structure_count, 4;

    isa_ok( $_, 'Chemistry::Clusterer::Structure' )
      for @{ $clusterer->structures };

}

cmp_ok( $clusterer->cluster_count, '>', 0 );
cmp_ok( $clusterer->error,         '>', 0 );

isa_ok( $_, 'Chemistry::Clusterer::Cluster' ) for @{ $clusterer->clusters };

done_testing();
