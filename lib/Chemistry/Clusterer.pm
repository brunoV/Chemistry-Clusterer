package Chemistry::Clusterer;

# ABSTRACT: Cluster spatial variants of macromolecular structures

use Moose;
use MooseX::Types::Moose qw(HashRef ArrayRef Num);
use Chemistry::Clusterer::Types qw(ArrayRefofStructures);
use Algorithm::Cluster qw(distancematrix kmedoids);
use Carp 'croak';
use Try::Tiny;

has structures => (
    is       => 'ro',
    isa      => ArrayRefofStructures,
    required => 1,
    coerce   => 1,
    traits   => ['Array'],
    handles  => {
        structure_count => 'count',
    }
);

has clusters => (
    is         => 'ro',
    isa        => ArrayRef,
    init_arg   => undef,
    lazy_build => 1,
    traits  => ['Array'],
    handles => {
        cluster_count => 'count',
    }
);

has coordinates_from => (
    is => 'ro',
    default => sub { +{ atom_type => 'CA' } },
);

has _coord_extractor => (
    is         => 'ro',
    lazy_build => 1,
    init_arg   => undef,
    handles    => {
        _extract_coords => 'extract_coords'
    },
);

sub _build__coord_extractor {
    my $self = shift;

    my ($extractor_name, @options);

    if (ref $self->coordinates_from eq 'HASH') {
        ($extractor_name, @options) = %{ $self->coordinates_from };
    }
    else {
        $extractor_name = $self->coordinates_from;
    }

    my $extractor = _get_module_name(
        'Chemistry::Clusterer::CoordExtractor::',
        $extractor_name,
    );

    require Module::Load;
    Module::Load::load( $extractor );

    return $extractor->new(args => \@options);

}

has _raw_error => ( is => 'rw' );

sub error {
    my $self = shift;

    # Calling cluster_count before _raw_error guarantees that _raw_error
    # will be defined

    my $nstructs  = $self->structure_count;
    my $nclusters = $self->cluster_count;

    return sqrt( $self->_raw_error / ( $nstructs - $nclusters ) );
}


has grouping_method => (
    is         => 'ro',
    isa        => HashRef,
    default    => sub { +{ distance => 5 } },
    auto_deref => 1,
);

sub _build_clusters {

    my $self = shift;

    my $distances = $self->_calc_distance_matrix();

    my $nclusters =
      exists $self->grouping_method->{distance}
      ? _distance_to_number( $self->grouping_method->{distance}, $distances )
      : $self->grouping_method->{number};

    my %clust_params = (
        nclusters => $nclusters,
        distances => $distances,
        npass     => 100,
        initialid => [],
    );

    my ( $result, $error, $nfound ) = try {
        kmedoids(%clust_params)
    }
    catch {
        croak "Couldn't perform the clustering: $_";
    };

    $self->_raw_error($error);

    my $clusters = $self->_build_clusters_from_indexes($result);

    return $clusters;

}

sub _build_clusters_from_indexes {

    my ( $self, $raw_indexes ) = @_;

    my $indexes = _refactor_result($raw_indexes);

    my @clusters;

    require Chemistry::Clusterer::Cluster;

    foreach my $centroid_id ( keys %$indexes ) {

        my $cluster = Chemistry::Clusterer::Cluster->new(
            centroid => $self->structures->[$centroid_id],
            members  => [ map { $self->structures->[$_] } @{ $indexes->{$centroid_id} } ]
        );

        push @clusters, $cluster;
    }

    return \@clusters;
}

sub _refactor_result {

    # Pasar del horrible arrayref que devuelve el método de clustering
    # a un hash en el que el key es el centroide y el value es un arrayref
    # con los integrantes.

    my $result = shift;

    my %seen;
    for my $i ( 0 .. @$result - 1 ) {
        push @{ $seen{ $result->[$i] } }, $i;
    }
    return \%seen;
}

sub _calc_distance_matrix {

    # Calcular la matriz de distancia utilizando las coordenadas
    # del objeto Clusterer.

    my $self = shift;

    my @coords =
      map { $self->_extract_coords( $_->coords ) } @{ $self->structures };

    my %dist_params = (
        transpose => 0,
        method    => 'a',
        dist      => 'e',       # Euclidian distance
        data      => \@coords,
    );

    my $distance_matrix = try {
        no warnings;
        distancematrix(%dist_params);
    }
    catch {
        croak "Error calculating distance matrix: $_";
    };

    return $distance_matrix;
}

sub _distance_to_number {

    # Calculate cluster number given a distance threshold.

    my ( $threshold, $distance_matrix ) = @_;

    my $nclusters = @{$distance_matrix};
    foreach my $row ( @{$distance_matrix} ) {
        --$nclusters if grep { $_ < $threshold**2 } @{$row};
    }

    return $nclusters;
}

sub _get_module_name {
    my ($prefix, $name) = @_;

    # get Foo::BarBaz from a prefix ('Foo::') and a
    # lowercase-underscored module name (bar_baz)

    (my $module_name = $name) =~ s/^(\w)/\U$1/;
    $module_name =~ s/_(\w)/\U$1/g;

    return $prefix . $module_name;
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 SYNOPSIS

   use Chemistry::Clusterer;

   my $clusterer = Chemistry::Clusterer->new(
       structures      => \@structures,
       grouping_method => { number => 10 },

   );

   say $clusterer->error;
   say $clusterer->cluster_count;

   foreach my $cluster ( @{ $clusterer->clusters } ) {
       say $cluster->size;
       say $cluster->centroid->coords;
    }

=head1 DESCRIPTION

This module provides a means for clustering or grouping a collection
of structural/spacial variants of a macromolecular structure according
to their RMSD values. This helps reduce the complexity of the collection
by grouping together similar representations into clusters, which can be
then analyzed as a single entity.

The CPU intensive parts are done with the C Clustering library, by means
of the L<Algorithm::Cluster> module.

=attr structures

An array reference of L<Chemistry::Clusterer::Structure> entities.
You can also provide an array reference of opened filehandles of each of
the structures, or a string with the contents of the PDB file of each
structure.

Required.

=attr grouping_method

The criteria with which to choose the desired number of clusters.
Default is C<< distance => 5 >>.

options are:

=head3 distance

    grouping_method => { distance => $d }

The final number of clusters will be chosen so that the average distance
between the centroids of the members of a single cluster is less or
equal to C<$d> Angstroms. In other words, it's the average radius of the
sphere that contains all centroids of each cluster.

=head3 number

    grouping_method => { number => $n }

Simply select the exact number of clusters you want.

=method structure_count

Returns the total number of structures used for clustering.

=attr coordinates_from

Defines what subset of atoms to use for the clustering.

It's a L<Chemistry::Clusterer::CoordExtractor> object that extracts the
coordinates of the desired atoms from each of the structures.

By default it uses coordinates from alpha carbons, using
L<Chemistry::Clusterer::CoordExtractor::AtomType>.

If you wanted to also use the coordinates of, say, the rest of carbon atoms, you'd say:

    coordinates_from => { atom_type => ['CA', 'C'] };

The key of the hash reference selects which coordinate extractor to use,
in this case C<AtomType>.  The value is an array reference with the atom
types to extract their coordinates from.

Other extractor classes to use are
L<Chemistry::Clusterer::CoordExtractor::Chain>, which selects all atoms
of a given chain, and L<Chemistry::Clusterer::CoordExtractor::All>,
which simply uses all atoms.

For instance:

    coordinates_from => { chain => ['A', 'B'] };

    coordinates_from => 'all'; # same as { all => [ undef ] };


=attr clusters

An array reference of L<Chemistry::Clusterer::Cluster> entities, each
representing a single cluster. It is lazily computed upon request.

=method cluster_count

The total number of clusters

=method error

The total clustering error
