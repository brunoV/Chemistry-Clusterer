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

has error => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_error {
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
    default    => sub { +{ radius => 5 } },
    auto_deref => 1,
);

sub _build_clusters {

    my $self = shift;

    my $distances = $self->_calc_distance_matrix();

    my $nclusters =
      exists $self->grouping_method->{radius}
      ? _radius_to_number( $self->grouping_method->{radius}, $distances )
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

sub _radius_to_number {

    # Calculate cluster number given a radius threshold.

    croak "Need a radius and a distance matrix" unless @_ == 2;
    my ( $radius, $distance_matrix ) = @_;

    my $nclusters = @{$distance_matrix};
    foreach my $row ( @{$distance_matrix} ) {
        --$nclusters if grep { $_ < $radius**2 } @{$row};
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

=head1 SYNOPSIS

   use Chemistry::Clusterer

=head1 DESCRIPTION

This module provides a means for clustering or grouping a collection
of structural/spacial variants of a macromolecular structure according
to their RMSD values. This helps reduce the complexity of the collection
by grouping together similar representations into Clusters, which can be
then analyzed as a single entity.

The main application for which this module is useful is the case where
there are many spatial (position/orientation) variants of a single protein
structure, as a result of protein-protein docking simulations. Tipically,
one would have to deal with thousands of decoys, unless some sort
of clustering or grouping of similar result is carried out.

Another potential use would be to cluster different homology models; care
should be taken though to first structurally align the models before,
since this module will calculate the euclidian distance between all alpha
carbons without attempting to align the structures first.

The CPU intensive parts are done by a the C Clustering library, properly
wrapped by the Algorithm::Cluster module.
