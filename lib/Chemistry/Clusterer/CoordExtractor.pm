package Chemistry::Clusterer::CoordExtractor;

# ABSTRACT: Base class for extracting coordinates for clustering

use Moose;
use MooseX::Types::Moose qw(ArrayRef Str);
use MooseX::Types -declare => [qw(Args)];

subtype Args, as ArrayRef;

coerce Args, from Str, via { [ $_ ] };

has args => ( is => 'ro', isa => Args, coerce => 1 );

sub extract_coords {
    die "This is an empty base class.\n";
}

__PACKAGE__->meta->make_immutable;

=head1 DESCRIPTION

This is a base for child classes that extract different subsets of
coordinates from L<Chemistry::Clusterer::Structure> objects to be used
for clustering. It should never be used directly.

=method extract_coords

This method should be implemented by child classes. It takes a hash
reference of coordinates, as per L<Chemistry::Clusterer::Structure>'s
C<coords> attribute, and it should return an array reference with the
desired coordinates to be used in the clustering.

=attr args

An array reference of optional arguments that can be used in the
C<extract_coords> method.
