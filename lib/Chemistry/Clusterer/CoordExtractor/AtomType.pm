package Chemistry::Clusterer::CoordExtractor::AtomType;
use Moose;

extends 'Chemistry::Clusterer::CoordExtractor';

has '+args' => ( required => 1 );

sub extract_coords {
    my ( $self, $coords_hash ) = @_;

    my @types = @{ $self->args };

    # $coords_hash is a two-level hash, with atom type as first key, and
    # chain as second key. Here we'll extract coordinates from all
    # chains but of the atom types @types;

    my @coords;
    foreach my $type (@types) {
        foreach my $chain ( sort keys %{ $coords_hash->{$type} } ) {
            push @coords, @{ $coords_hash->{$type}{$chain} }
              if exists $coords_hash->{$type}{$chain};
        }
    }

    return \@coords;
}

__PACKAGE__->meta->make_immutable;

=head1 SYNOPSIS

    # When building a Chemistry::Clusterer instance...

    coordinates_from => { atom_type => ['N', 'C'] }

=head1 DESCRIPTION

Extracts coordinates belonging to one or more specific atom types.
