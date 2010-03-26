use Test::More;
use Test::Exception;

# Class is use-able.
BEGIN { use_ok('Chemistry::Clusterer::Cluster') }

# Class attributes and methods.
my @methods = qw(members add_members size centroid score );
can_ok( 'Chemistry::Clusterer::Cluster', @methods );

# Constructor.
my $cluster = Chemistry::Clusterer::Cluster->new;
isa_ok( $cluster, 'Chemistry::Clusterer::Cluster' );

# We can put stuff in it
my @things = qw(foo bar);
lives_ok { $cluster->add_members(@things), 'live with right input' };

is( scalar @{ $cluster->members }, @things, "test add_members" );
is( $cluster->size,                @things, "test size" );

# We can assign a score and a centroid
$cluster->score(5);
is $cluster->score, 5, "we can assign scores";

$cluster->centroid( $cluster->members->[0] );
is $cluster->centroid, 'foo', "we can assign centroids";

done_testing();
