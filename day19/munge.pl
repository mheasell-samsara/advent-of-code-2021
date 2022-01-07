#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my @possible_directions = (
    "+x",
    "+y",
    "+z",
    "-x",
    "-y",
    "-z",
);

my %direction_vectors = (
    "+x" => {x=>1,y=>0,z=>0},
    "+y" => {x=>0,y=>1,z=>0},
    "+z" => {x=>0,y=>0,z=>1},
    "-x" => {x=>-1,y=>0,z=>0},
    "-y" => {x=>0,y=>-1,z=>0},
    "-z" => {x=>0,y=>0,z=>-1},
);

my @possible_orientations;

for my $facing (@possible_directions) {
    for my $up (@possible_directions) {
        # skip if same axis
        next if substr($facing, 1, 1) eq substr($up, 1, 1);
        push(@possible_orientations, { facing => $facing, up => $up, right => get_right($facing, $up) });
    }
}

#print Dumper(\@possible_orientations);

my @regions;

do {
    push(@regions, parse_region());
} while (!eof);


#print Dumper(\@regions);

my $transform_tree = compute_transform_tree(\@regions);
#print Dumper($transform_tree);

my %full_map;
for my $i (0..$#regions) {
    my $region = $regions[$i];
    my $transform_chain = $transform_tree->{$i};
    for my $p (@$region) {
        my $base_p = transform_point($p, @$transform_chain);
        $full_map{to_str($base_p)} = 1;
    }
}

my $point_count = scalar keys %full_map;

print "Point count: $point_count\n";

sub parse_region {
    my @region;
    my $header = <>;
    while (my $line = <>) {
        chomp $line;
        last if $line eq "";
        push(@region, from_str($line));
    }

    return \@region;
}

sub transform_and_merge_regions {
    my ($base_region, $other_region, $transform_to_base) = @_;
    my @new_region;
    my %seen;

    for my $p (@$base_region) {
        $seen{to_str($p)} = 1;
        push(@new_region, $p);
    }

    for my $p (@$other_region) {
        my $base_p = transform_point($p, $transform_to_base);
        next if $seen{to_str($p)};
        $seen{to_str($p)} = 1;
        push(@new_region, $p);
    }

    return \@new_region;
}

sub compute_transform_tree {
    my ($regions) = @_;

    my %transform_chains = (
        0 => [],
    );

    my %checked_pairs;

    while (scalar keys %transform_chains != scalar @$regions) {
        for my $i (keys %transform_chains) {
            for my $j (0..$#$regions) {
                next if $i == $j;
                next if defined $transform_chains{$j};
                next if $checked_pairs{"$i,$j"};
                $checked_pairs{"$i,$j"} = 1;

                print "comparing regions $i and $j\n";
                my $transform_from_j_to_i = compare_regions($regions[$i], $regions[$j]);
                next if not defined $transform_from_j_to_i;
                print "match found\n";

                my $chain_from_i_to_0 = $transform_chains{$i};

                my @full_chain = ($transform_from_j_to_i, @$chain_from_i_to_0);
                $transform_chains{$j} = \@full_chain;
            }
        }
    }

    return \%transform_chains;
}

sub to_str {
    my ($p) = @_;
    return join(",", $p->{x}, $p->{y}, $p->{z});
}

sub from_str {
    my ($str) = @_;
    my ($x, $y, $z) = split(/,/, $str);
    return {x=>$x, y=>$y, z=>$z};
}

sub vec_add {
    my ($a, $b) = @_;
    return {
        x => $a->{x} + $b->{x}, 
        y => $a->{y} + $b->{y}, 
        z => $a->{z} + $b->{z}, 
    };
}

sub vec_subtract {
    my ($a, $b) = @_;
    return {
        x => $a->{x} - $b->{x}, 
        y => $a->{y} - $b->{y}, 
        z => $a->{z} - $b->{z}, 
    };
}

sub points_equal {
    my ($a, $b) = @_;
    return $a->{x} == $b->{x}
        && $a->{y} == $b->{y}
        && $a->{z} == $b->{z};
}

sub create_region_index {
    my ($points) = @_;

    my %neighbours_index;

    for my $point (@$points) {
        my %neighbours_set;
        for my $neighbour (@$points) {
            next if points_equal($point, $neighbour);
            my $diff = vec_subtract($neighbour, $point);
            $neighbours_set{to_str($diff)} = 1;
        }

        $neighbours_index{to_str($point)} = \%neighbours_set;
    }

    return \%neighbours_index;
}

sub get_right {
    my ($facing, $up) = @_;
    my $result_dir = cross($direction_vectors{$facing}, $direction_vectors{$up});

    my $result_str = to_str($result_dir);
    for my $d (@possible_directions) {
        my $v = $direction_vectors{$d};
        if (to_str($v) eq $result_str) {
            return $d;
        }
    }
    die "failed to find right dir";
}

sub cross {
    my ($a, $b) = @_;
    my $x = ($a->{y}*$b->{z}) - ($a->{z}*$b->{y});
    my $y = ($a->{z}*$b->{x}) - ($a->{x}*$b->{z});
    my $z = ($a->{x}*$b->{y}) - ($a->{y}*$b->{x});
    return {x=>$x, y=>$y, z=>$z};
}


sub rotate_point {
    my ($p, $orientation) = @_;
    my $x = get_from_point($p, $orientation->{right});
    my $y = get_from_point($p, $orientation->{facing});
    my $z = get_from_point($p, $orientation->{up});
    return {x=>$x, y=>$y, z=>$z};
}

sub transform_point {
    my ($p, @transforms) = @_;
    for my $t (@transforms) {
        $p = rotate_point($p, $t->{orientation});
        $p = vec_add($p, $t->{translation});
    }
    return $p;
}

sub get_from_point {
    my ($p, $dir) = @_;
    my $val = $dir eq "+x" ? $p->{x}
        : $dir eq "-x" ? -$p->{x}
        : $dir eq "+y" ? $p->{y}
        : $dir eq "-y" ? -$p->{y}
        : $dir eq "+z" ? $p->{z}
        : $dir eq "-z" ? -$p->{z} : undef;
    die "bad input $dir" if not defined $val;
    return $val;
}

# Returns the orientation + translation (together known as the transform)
# that maps points from region b to region a,
# if the regions overlap.
# If the regions do not overlap, returns undef.
sub compare_regions {
    my ($region_a, $region_b) = @_;

    for my $orientation (@possible_orientations) {
        my $rotated_region_b = rotate_region($region_b, $orientation);
        my $translation = match_regions($region_a, $rotated_region_b);
        return { orientation => $orientation, translation => $translation } if defined($translation);
    }

    # no overlap found between the regions
    return undef;
}

sub rotate_region {
    my ($region, $orientation) = @_;
    my @new_points = map { rotate_point($_, $orientation) } @$region;
    return \@new_points;
}

sub set_intersection {
    my ($a, $b) = @_;
    my %r;
    for my $elem (keys %$a) {
        $r{$elem} = 1 if defined $b->{$elem};
    }
    return \%r;
}

# Returns the vector mapping a point from region b to region a,
# if the regions overlap.
# If the regions do not overlap, returns undef.
sub match_regions {
    my ($region_a, $region_b) = @_;

    my $region_a_index = create_region_index($region_a);
    my $region_b_index = create_region_index($region_b);

    for my $p (@$region_a) {
        my $neighbours_in_a = $region_a_index->{to_str($p)};

        for my $pb (@$region_b) {
            my $neighbours_in_b = $region_b_index->{to_str($pb)};
            next if not defined $neighbours_in_b;
            my $common_neighbours = set_intersection($neighbours_in_a, $neighbours_in_b);
            if (scalar keys %$common_neighbours >= 11) {
                # we found a match, yay
                my $offset = vec_subtract($p, $pb);
                return $offset;
            }
        }
    }

    # no match found
    return undef;
}

