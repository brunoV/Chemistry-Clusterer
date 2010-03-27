package Chemistry::Clusterer::CoordExtractor;
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
