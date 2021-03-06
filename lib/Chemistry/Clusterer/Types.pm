package Chemistry::Clusterer::Types;

# ABSTRACT: Specific types for Chemistry::Clusterer

use MooseX::Types::Moose qw(ArrayRef HashRef Num FileHandle Str);
use MooseX::Types -declare => [
    qw( Structure StructureCoords ArrayRefofStructures ArrayRefofFh ArrayRefofStr ArrayRefofHashRef )
];

class_type Structure, { class => 'Chemistry::Clusterer::Structure' };

subtype ArrayRefofStructures, as ArrayRef[Structure];
subtype ArrayRefofFh,         as ArrayRef[FileHandle];
subtype ArrayRefofStr,        as ArrayRef[Str];
subtype ArrayRefofHashRef,    as ArrayRef[HashRef];

coerce ArrayRefofStructures,
    from ArrayRefofFh,      via { _fh_to_structure($_)      },
    from ArrayRefofStr,     via { _str_to_structure($_)     },
    from ArrayRefofHashRef, via { _hashref_to_structure($_) };

subtype StructureCoords, as HashRef;

coerce StructureCoords,
    from FileHandle, via { _fh_to_coords($_)  },
    from Str,        via { _str_to_coords($_) };

sub _hashref_to_structure {
    my $hashrefs = shift;

    require Chemistry::Clusterer::Structure;

    return [ map { Chemistry::Clusterer::Structure->new( coords => $_ ) } @$hashrefs ];
}

sub _fh_to_structure {
    my $fhs = shift;

    require Chemistry::Clusterer::Structure;

    my @structures =
       map { Chemistry::Clusterer::Structure->new( coords => $_ ) } @$fhs;

    return \@structures;
}

sub _fh_to_coords {
    my $fh = shift;

    my %coords;

    while( my $line = <$fh> ) {
        my ($atom_type, $chain_id, $x, $y, $z) = _parse_line($line);

        $atom_type || next;

        push @{$coords{$atom_type}{$chain_id}}, ($x, $y, $z);
    }

    return \%coords;
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

    my %coords;

    foreach my $line (@lines) {
        my ($atom_type, $chain_id, $x, $y, $z) = _parse_line($line);

        $atom_type || next;

        push @{$coords{$atom_type}{$chain_id}}, ($x, $y, $z);
    }

    return \%coords;
}

sub _parse_line {
    my $line = shift;

    my ($atom_type, $chain_id, $x, $y, $z) = $line =~ m{
        ^ATOM      # Atom entry
        \s+\S+\s+
        (\S+)      # Atom type
        \s+\S+\s+
        (\S+)      # Chain id
        \s+\S+\s+
        (\S+)\s+   # x coord
        (\S+)\s+   # y coord
        (\S+)      # z coord
    }x or return;

    return ($atom_type, $chain_id, $x, $y, $z);
}

__PACKAGE__->meta->make_immutable;

__END__
