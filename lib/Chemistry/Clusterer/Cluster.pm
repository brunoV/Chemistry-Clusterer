package Chemistry::Clusterer::Cluster;

# ABSTRACT: A group of similar things, with a centroid and a score

use Moose;
use MooseX::Types::Moose qw(ArrayRef);

has members => (
    is       => 'ro',
    isa      => 'ArrayRef',
    init_arg => undef,
    default  => sub { [] },
    traits   => ['Array'],
    handles  => {
        add_members => 'push',
        size        => 'count',
    },
);

has centroid => ( is => 'rw' );
has score    => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;

__END__

=head1 SYNOPSIS

    # $cluster was obtained from a Chemistry::Clusterer object

    say $cluster->size;

    my @similar_structures = $cluster->members;

    my $representative = $cluster->centroid;

=head1 DESCRIPTION

This class represents a group of L<Chemistry::Clusterer::Structure>
elements that were considered as part of a single cluster.

=attr members

An array reference of L<Chemistry::Clusterer::Structure>s that define
the cluster.

=attr centroid

A single L<Chemistry::Clusterer::Structure> that is representative of
the whole cluster.
