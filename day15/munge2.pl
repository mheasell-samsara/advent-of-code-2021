#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my @grid;
my $tile_width;

while (my $line = <>) {
    chomp $line;
    $tile_width = length $line if not defined $tile_width;
    push(@grid, split(//, $line));
}

my $tile_height = (scalar @grid) / $tile_width;

my $map_width = 5 * $tile_width;
my $map_height = 5 * $tile_height;

my $goal_idx = ($map_width * $map_height) - 1;

print "tile width: $tile_width, height: $tile_height\n";
print "map width: $map_width, height: $map_height\n";

for my $y (0..($map_height-1)) {
    for my $x (0..($map_width-1)) {
        print get_risk($x, $y);
    }
    print "\n";
}

my $lowest_cost = path_search();
print "lowest cost: $lowest_cost\n";

# crude dijkstra's algorithm implementation
sub path_search {
    # open list would be better as min-heap
    my @open_list = ({idx => 0, cost => 0, from => undef});
    my %closed_set;

    while (scalar @open_list) {
        my $node = shift @open_list;
        my $idx = $node->{idx};
        my $cost = $node->{cost};
        $closed_set{$idx} = $node->{from};

        if ($idx == $goal_idx) {
            #my $path = trace_path(\%closed_set, $idx);
            #my @path_xys = map { my @a = to_map_xy($_); { xy => \@a, cost => get_risk_idx($_)} } @$path;
            #print Dumper(\@path_xys);
            return $cost;
        }

        for my $neighbour_idx (get_neighbours($idx)) {
            next if defined $closed_set{$neighbour_idx};
            my $neighbour_cost = get_risk_idx($neighbour_idx);
            my $total_cost = $cost + $neighbour_cost;
            insert_to_open_list(\@open_list, {idx => $neighbour_idx, cost => $total_cost, from => $idx});
        }
    }

    return undef;
}

sub trace_path {
    my ($m, $end_idx) = @_;
    my @out = ($end_idx);

    while (my $parent_idx = $m->{$end_idx}) {
        push(@out, $parent_idx);
        $end_idx = $parent_idx;
    }

    return \@out;
}

sub insert_to_open_list {
    my ($l, $item) = @_;

    # find existing item
    my $existing_item_idx;
    for my $i (0..$#$l) {
        my $existing_item = $l->[$i];
        if ($existing_item->{idx} == $item->{idx}) {
            $existing_item_idx = $i;
            last;
        }
    }

    # skip if existing item lower cost, otherwise delete it
    if (defined $existing_item_idx) {
        my $existing_item = $l->[$existing_item_idx];
        return if $existing_item->{cost} <= $item->{cost};
        splice(@$l, $existing_item_idx, 1);
    }

    # insert our item at the correct cost position
    for my $i (0..$#$l) {
        my $cost = $l->[$i]{cost};
        if ($cost > $item->{cost}) {
            splice(@$l, $i, 0, $item);
            return;
        }
    }

    # no items with greater cost, so stick it on the end
    push(@$l, $item);
}

sub get_neighbours {
    my ($idx) = @_;
    my ($x, $y) = to_map_xy($idx);

    my @coords;
    push(@coords, to_map_idx($x-1, $y)) if $x > 0;
    push(@coords, to_map_idx($x, $y-1)) if $y > 0;

    push(@coords, to_map_idx($x+1, $y)) if $x < ($map_width - 1);
    push(@coords, to_map_idx($x, $y+1)) if $y < ($map_height - 1);

    return @coords;
}

sub get_risk_idx {
    my ($idx) = @_;
    my ($x, $y) = to_map_xy($idx);
    return get_risk($x, $y);
}

sub get_risk {
    my ($x, $y) = @_;
    my $tile_x = int($x / $tile_width);
    my $tile_y = int($y / $tile_height);

    my $inner_x = $x % $tile_width;
    my $inner_y = $y % $tile_height;

    my $val = $grid[to_tile_idx($inner_x, $inner_y)];

    $val += $tile_x + $tile_y;

    $val -= 9 while $val > 9;

    return $val;
}

sub to_map_idx {
    my ($x, $y) = @_;
    return ($y * $map_width) + $x;
}

sub to_map_xy {
    my ($idx) = @_;
    my $x = $idx % $map_width;
    my $y = int($idx / $map_width);
    return ($x, $y);
}

sub to_tile_idx {
    my ($x, $y) = @_;
    return ($y * $tile_width) + $x;
}

sub to_tile_xy {
    my ($idx) = @_;
    my $x = $idx % $tile_width;
    my $y = int($idx / $tile_width);
    return ($x, $y);
}
