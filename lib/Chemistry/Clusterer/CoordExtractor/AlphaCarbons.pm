package Chemistry::Clusterer::CoordExtractor::AlphaCarbons;
use Moose;

extends 'Chemistry::Clusterer::CoordExtractor';

sub extract_coords {
    my ($self, $coords_hash) = @_;

    # $coords_hash is a two-level hash, with atom type as first key, and
    # chain as second key. Here we'll extract coordinates from all
    # chains but of the atom type 'CA'

    my @coords =
      map { @{ $coords_hash->{CA}->{$_} } } keys %{ $coords_hash->{CA} };

    return \@coords;
}

__PACKAGE__->meta->make_immutable;
