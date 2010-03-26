package Chemistry::Clusterer::Cluster;

# Abstract: A group of similar things, with a centroid and a score

use Moose;
use MooseX::Types::Moose qw(ArrayRef);

has members => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        add_members => 'push',
        size        => 'count',
    },
);

has centroid => ( is => 'rw' );
has score    => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;

__END__