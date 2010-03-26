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
