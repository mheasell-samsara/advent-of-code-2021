#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

#my @steps;

my %on_cubes;

while (my $line = <>) {
    chomp $line;
    $line =~ /^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/ or die "invalid input on line $.\n";
    my ($state, $x1, $x2, $y1, $y2, $z1, $z2) = ($1, $2, $3, $4, $5, $6, $7);
    #push(@steps, { state=>$state eq "on" ? 1 : 0, x1=>$x1, x2=>$x2, y1=>$y1, y2=>$y2, z1=>$z1, z2=>$z2 });

    next if $x1 < -50 && $x2 < -50;
    next if $x1 > 50 && $x2 > 50;

    next if $y1 < -50 && $y2 < -50;
    next if $y1 > 50 && $y2 > 50;

    next if $z1 < -50 && $z2 < -50;
    next if $z1 > 50 && $z2 > 50;
    
    for my $z ($z1..$z2) {
        for my $y ($y1..$y2) {
            for my $x ($x1..$x2) {
                if ($state eq "on") {
                    $on_cubes{"$x,$y,$z"} = 1;
                } else {
                    delete $on_cubes{"$x,$y,$z"};
                }
            }
        }
    }
}

my $count = 0;
for my $k (keys %on_cubes) {
    my ($x, $y, $z) = split(/,/, $k);
    next if $x < -50 || $x > 50;
    next if $y < -50 || $x > 50;
    next if $z < -50 || $x > 50;
    $count += 1;
}

print "on count: $count\n";
