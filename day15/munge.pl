#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my @grid;
my $width;

while (my $line = <>) {
    chomp $line;
    $width = length $line if not defined $width;
    push(@grid, split(//, $line));
}

my $height = (scalar @grid) / $width;

my $lowest_cost = path_search();
print "lowest cost: $lowest_cost\n";

# crude dijkstra's algorithm implementation
sub path_search {
    # open list would be better as min-heap
    my @open_list = ({idx => 0, cost => 0});
    my %closed_set;

    while (scalar @open_list) {
        my $node = shift @open_list;
        my $idx = $node->{idx};
        my $cost = $node->{cost};
        $closed_set{$idx} = 1;

        if ($idx == $#grid) {
            return $cost;
        }

        for my $neighbour_idx (get_neighbours($idx)) {
            next if $closed_set{$neighbour_idx};
            my $neighbour_cost = $grid[$neighbour_idx];
            my $total_cost = $cost + $neighbour_cost;
            insert_to_open_list(\@open_list, {idx => $neighbour_idx, cost => $total_cost});
        }
    }

    return undef;
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
    my $x = $idx % $width;
    my $y = int($idx / $width);

    my @coords;
    push(@coords, to_idx($x-1, $y)) if $x > 0;
    push(@coords, to_idx($x, $y-1)) if $y > 0;

    push(@coords, to_idx($x+1, $y)) if $x < ($width - 1);
    push(@coords, to_idx($x, $y+1)) if $y < ($height - 1);

    return @coords;
}

sub to_idx {
    my ($x, $y) = @_;
    return ($y * $width) + $x;
}
