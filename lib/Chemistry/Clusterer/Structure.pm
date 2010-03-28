package Chemistry::Clusterer::Structure;
use Moose;
use Chemistry::Clusterer::Types qw(StructureCoords);

has 'id' => ( is  => 'rw' );

has 'coords' => (
    isa       => StructureCoords,
    is        => 'ro',
    coerce    => 1,
    required  => 1,
);

__PACKAGE__->meta->make_immutable;

__END__

=head1 DESCRIPTION

A class that loosely represents a molecule. It holds enough information
about the coordinates of its atoms to be useful to
L<Chemistry::Clusterer> and nothing more.

=attr id

A general-purpose attribute. You can put whatever you want here.

=attr coords

A doubly-keyed hash reference holding the coordinates of the structure.
The first key holds the atom type, the second one the chain name.

This attribute is required at construction time. You can provide the
built hashref, a string with the contents of a PDB file, or a opened
filehandle of the PDB file.
