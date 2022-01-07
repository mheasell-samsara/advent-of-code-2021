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

my %seen;

my $counter = 1;

for my $y (0..$#rows) {
    my $row = $rows[$y];
    for my $x (0..$#$row) {
        if (flood_fill(\@rows, $x, $y, $counter, \%seen)) {
            $counter += 1;
        }
    }
}

my @sizes;

for my $i (1..$counter) {
    my $count = 0;
    while (my ($key, $val) = each(%seen)) {
        if ($val == $i) {
            $count += 1;
        }
    }

    push(@sizes, $count);
}

@sizes = sort { $b <=> $a } @sizes;

print Dumper(\@sizes);

my $sum = $sizes[0] * $sizes[1] * $sizes[2];

print "sum: $sum\n";

sub flood_fill {
    my ($grid, $x, $y, $mark_value, $seen) = @_;
    return 0 if $seen->{"$x.$y"};

    my $val = $grid->[$y][$x];
    return 0 if $val == 9;

    $seen->{"$x.$y"} = $mark_value;

    if ($x > 0) {
        flood_fill($grid, $x - 1, $y, $mark_value, $seen);
    }

    if ($x < $#{$grid->[0]}) {
        flood_fill($grid, $x + 1, $y, $mark_value, $seen);
    }

    if ($y > 0) {
        flood_fill($grid, $x, $y - 1, $mark_value, $seen);
    }

    if ($y < $#$grid) {
        flood_fill($grid, $x, $y + 1, $mark_value, $seen);
    }

    return 1;
}


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


