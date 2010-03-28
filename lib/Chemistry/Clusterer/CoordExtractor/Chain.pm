package Chemistry::Clusterer::CoordExtractor::Chain;
use Moose;

extends 'Chemistry::Clusterer::CoordExtractor';

has '+args' => ( required => 1 );

sub extract_coords {
    my ( $self, $coords_hash ) = @_;

    my @chains = @{ $self->args };

    # $coords_hash is a two-level hash, with atom type as first key, and
    # chain as second key. Here we'll extract coordinates from all
    # atoms from chains @chains;

    my @coords;
    foreach my $type ( sort keys %$coords_hash ) {
        foreach my $chain (@chains) {
            push @coords, @{ $coords_hash->{$type}{$chain} }
              if exists $coords_hash->{$type}{$chain};
        }
    }

    return \@coords;
}

__PACKAGE__->meta->make_immutable;

=head1 SYNOPSIS

    # When building a Chemistry::Clusterer instance...

    coordinates_from => { chain => ['A', 'B'] }

=head1 DESCRIPTION

Extracts coordinates belonging to one or more specific chains.
