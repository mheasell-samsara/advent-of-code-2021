#!/usr/bin/env perl

use warnings;
use strict;
use List::Util qw(min max);

my @grid;

while (my $line = <>) {
    chomp $line;
    my @row = split(//, $line);
    push(@grid, @row);
}


my $total_flashes = 0;

for my $step_num (1..999) {
    #print_grid(\@grid);
    #print "\n";

    # increase energy
    for my $i (0..$#grid) {
        $grid[$i] += 1;
    }

    my %flashed_indices;

    # locate flashes
    my @flashers;

    while(1) {
        for my $i (0..$#grid) {
            next if $flashed_indices{$i};
            next if $grid[$i] <= 9;
            push(@flashers, $i);
            $flashed_indices{$i} = 1;
        }
        
        last if scalar @flashers == 0;

        # apply flashes
        for my $i (@flashers) {
            inc_neighbours(\@grid, $i);
        }

        @flashers = ();
    }

    # zero out flashers
    for my $i (keys %flashed_indices) {
        $grid[$i] = 0;
        $total_flashes += 1;
    }

    my $total_flashes_this_step = scalar (keys %flashed_indices);

    #print "step $step_num, flashes: $total_flashes_this_step\n";

    if ($total_flashes_this_step == 100) {
        print "sync! on step $step_num\n";
        exit 0;
    }

}

print "total flashes: $total_flashes\n";


sub inc_neighbours {
    my ($grid, $i) = @_;
    my $x = $i % 10;
    my $y = $i / 10;

    my $min_x = max(0, $x - 1);
    my $min_y = max(0, $y - 1);

    my $max_x = min(9, $x + 1);
    my $max_y = min(9, $y + 1);

    for my $dy ($min_y..$max_y) {
        for my $dx ($min_x..$max_x) {
            next if $dy == $y && $dx == $x;
            my $idx = ($dy * 10) + $dx;
            $grid->[$idx] += 1;
        }
    }
}

sub print_grid {
    my ($grid) = @_;

    for my $y (0..9) {
        for my $x (0..9) {
            my $idx = ($y * 10) + $x;
            my $val = $grid->[$idx];
            print "$val";
        }
        print "\n";
    }
}
