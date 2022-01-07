#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;


my @rows;


while (my $line = <>) {
    chomp $line;
    my @row = split(//, $line);
    push(@rows, \@row);
}

print Dumper(\@rows);

my $sum = 0;

for my $y (0..$#rows) {
    for my $x (0..$#{$rows[$y]}) {
        if (is_low(\@rows, $x, $y)) {
            $sum += risk_level($rows[$y][$x])
        }
    }
}

print "sum: $sum\n";

sub risk_level {
    my ($val) = @_;
    return 1 + $val;
}

sub is_low {
    my ($grid, $x, $y) = @_;

    my $val = $grid->[$y][$x];

    if ($x > 0) {
        my $left = $grid->[$y][$x - 1];
        return 0 if $left <= $val;
    }

    if ($x < $#{$grid->[0]}) {
        my $right = $grid->[$y][$x + 1];
        return 0 if $right <= $val;
    }

    if ($y > 0) {
        my $top = $grid->[$y - 1][$x];
        return 0 if $top <= $val;
    }

    if ($y < $#$grid) {
        my $bot = $grid->[$y + 1][$x];
        return 0 if $bot <= $val;
    }

    return 1;
}


