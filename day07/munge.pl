#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use List::Util qw(min max);

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
        $cost += abs($pos - $p);
    }
    return $cost;
}


main();
