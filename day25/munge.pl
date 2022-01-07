#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

main();

sub main {
    my $grid = grid_parse();
    #print "Initial state:\n";
    #grid_print($grid);
    my $step_count = 0;
    while (1) {
        my ($new_grid, $moved) = do_step($grid);
        $grid = $new_grid;
        $step_count += 1;
        #print "After $step_count steps:\n";
        #grid_print($grid);
        last if not $moved;
    }
    print "first step with no movement: $step_count\n";
}

sub do_step {
    my ($grid) = @_;

    my $moved = 0;
    do {
        my ($new_grid, $moved_east) = do_step_east($grid);
        $grid = $new_grid;
        $moved ||= $moved_east;
    };
    do {
        my ($new_grid, $moved_south) = do_step_south($grid);
        $grid = $new_grid;
        $moved ||= $moved_south;
    };

    return ($grid, $moved);
}

sub do_step_east {
    my ($grid) = @_;

    my ($w, $h) = grid_get_size($grid);
    my $new_grid = grid_copy($grid);

    my $moved = 0;

    for my $y (0..($h-1)) {
        for my $x (0..($w-1)) {
            next unless grid_get($grid, $x, $y) eq ">";

            my ($target_x, $target_y) = grid_wrap_coords($grid, $x+1, $y);
            my $target_val = grid_get($grid, $target_x, $target_y);
            if ($target_val eq ".") {
                grid_set($new_grid, $x, $y, ".");
                grid_set($new_grid, $target_x, $target_y, ">");
                $moved = 1;
            }
        }
    }

    return ($new_grid, $moved);
}

sub do_step_south {
    my ($grid) = @_;

    my ($w, $h) = grid_get_size($grid);
    my $new_grid = grid_copy($grid);

    my $moved = 0;

    for my $y (0..($h-1)) {
        for my $x (0..($w-1)) {
            next unless grid_get($grid, $x, $y) eq "v";

            my ($target_x, $target_y) = grid_wrap_coords($grid, $x, $y+1);
            my $target_val = grid_get($grid, $target_x, $target_y);
            if ($target_val eq ".") {
                grid_set($new_grid, $x, $y, ".");
                grid_set($new_grid, $target_x, $target_y, "v");
                $moved = 1;
            }
        }
    }

    return ($new_grid, $moved);
}

sub grid_wrap_coords {
    my ($grid, $x, $y) = @_;
    my ($w, $h) = grid_get_size($grid);
    return ($x % $w, $y % $h);
}

sub grid_get {
    my ($grid, $x, $y) = @_;
    my $idx = ($y * $grid->{width}) + $x;
    return $grid->{data}[$idx];
}

sub grid_set {
    my ($grid, $x, $y, $val) = @_;
    my $idx = ($y * $grid->{width}) + $x;
    $grid->{data}[$idx] = $val;
}

sub grid_get_size {
    my ($g) = @_;
    my $height = (scalar @{$g->{data}}) / $g->{width};
    return ($g->{width}, $height);
}

sub grid_create {
    my ($w, $h) = @_;
    my @data = (".") x ($w*$h);
    return { data=>\@data, width=>$w };
}

sub grid_copy {
    my ($g) = @_;
    my @new_data = @{$g->{data}};
    return { data=>\@new_data, width=>$g->{width} };
}

sub grid_parse {
    my @grid;
    my $width;

    while (my $line = <>) {
        chomp $line;
        $width = length $line if not defined $width;
        push(@grid, split(//, $line));
    }

    return { data => \@grid, width => $width };
}

sub grid_print {
    my ($g) = @_;
    my ($w, $h) = grid_get_size($g);

    for my $y (0..($h-1)) {
        for my $x (0..($w-1)) {
            print grid_get($g, $x, $y);
        }
        print "\n";
    }
}
