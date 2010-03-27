package Chemistry::Clusterer::CoordExtractor::All;
use Moose;

extends 'Chemistry::Clusterer::CoordExtractor';

sub extract_coords {
    my ($self, $coords_hash) = @_;

    # $coords_hash is a two-level hash, with atom type as first key, and
    # chain as second key. Here we'll extract coordinates from all
    # chains and of all atom types.

    my @coords;
    foreach my $type (sort keys %$coords_hash) {
        foreach my $chain (sort keys %{$coords_hash->{$type}}) {
            push @coords, @{ $coords_hash->{$type}{$chain} };
        }
    }

    return \@coords;
}

__PACKAGE__->meta->make_immutable;
