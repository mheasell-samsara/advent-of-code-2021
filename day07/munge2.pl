#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use List::Util qw(min max);

# This one is slow as arse but I couldn't be bothered
# to make it any faster.

sub main {
    my $positions_in = <>;
    chomp $positions_in;

    my @positions = split(/,/, $positions_in);

    my $min_pos = min(@positions);
    my $max_pos = max(@positions);


    my $min_fuel = fuel_cost(\@positions, $min_pos);
    for my $i (($min_pos+1)..$max_pos) {
        my $cost = fuel_cost(\@positions, $i);
        if ($cost < $min_fuel) {
            $min_fuel = $cost;
        }
    }

    print "min fuel: $min_fuel\n";
}

sub fuel_cost {
    my ($positions, $pos) = @_;

    my $cost = 0;
    for my $p (@$positions) {
        $cost += cost_to_move(abs($pos - $p));
    }
    return $cost;
}

sub cost_to_move {
    my ($distance) = @_;
    # This is basically computing the triangle numbers
    my $total = 0;

    for my $i (0..$distance) {
        $total += $i;
    }

    return $total;
}


main();
