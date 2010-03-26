package Chemistry::Clusterer::Types;

# ABSTRACT: Specific types for Bio::Protease

use MooseX::Types::Moose qw(ArrayRef Num FileHandle Str);
use MooseX::Types -declare => [
    qw( Structure StructureCoords ArrayRefofStructures ArrayRefofFh ArrayRefofStr )
];
use Carp qw(croak);
use namespace::autoclean;

class_type Structure, { class => 'Chemistry::Clusterer::Structure' };

subtype ArrayRefofStructures, as ArrayRef[Structure];
subtype ArrayRefofFh,         as ArrayRef[FileHandle];
subtype ArrayRefofStr,        as ArrayRef[Str];

coerce ArrayRefofStructures,
    from ArrayRefofFh,  via { _fh_to_structure($_)  },
    from ArrayRefofStr, via { _str_to_structure($_) };

subtype StructureCoords, as ArrayRef[Num];

coerce StructureCoords,
    from FileHandle, via { _fh_to_coords($_)  },
    from Str,        via { _str_to_coords($_) };

sub _fh_to_structure {
    my $fhs = shift;

    my @structures =
       map { Chemistry::Clusterer::Structure->new( coords => $_ ) } @$fhs;

    return \@structures;
}

sub _fh_to_coords {
    my $fh = shift;

    my @lines = <$fh>;

    my $coords = _parse_coords(\@lines);

    return $coords;
}

sub _str_to_structure {
    my $strings = shift;

    require Chemistry::Clusterer::Structure;

    my @structures =
      map { Chemistry::Clusterer::Structure->new( coords => $_ ) } @$strings;

    return \@structures;
}

sub _str_to_coords {
    my $content = shift;

    my @lines = split "\n", $content;

    my $coords = _parse_coords(\@lines);

    return $coords;
}

sub _parse_coords {

    # Get the coordinates of the alpha carbons from a PDB file

    my $lines = shift;

    my @xyz;

    foreach my $line (@$lines) {
        my ($x, $y, $z) = $line =~ m{
            ^ATOM                  # Atom entry
            \s+\S+\s+
            CA                     # Alpha carbons
            \s+\S+\s+\S+\s+\S+\s+
            (\S+)\s+               # x coord
            (\S+)\s+               # y coord
            (\S+)                  # z coord
        }x or next;

        push @xyz, ($1, $2, $3);
    }

    return \@xyz;
}

__PACKAGE__->meta->make_immutable;
