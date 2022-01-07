#!/usr/bin/env perl

use warnings;
use strict;


my %dots;
while (my $line = <>) {
    chomp $line;
    if ($line eq "") {
        last;
    }
    $line =~ /^(\d+),(\d+)$/ or die "invalid input on line $.";
    my ($x, $y) = ($1, $2);
    $dots{"$x.$y"} = 1;
}

# process instructions
while (my $line = <>) {
    chomp $line;

    $line =~ /^fold along (x|y)=(\d+)$/ or die "invalid instruction on line $.";
    
    my ($fold_axis, $fold_value) = ($1, $2);

    my $folded_dots;
    if ($fold_axis eq "x") {
        $folded_dots = fold_x(\%dots, $fold_value);
    }
    elsif ($fold_axis eq "y") {
        $folded_dots = fold_y(\%dots, $fold_value);
    }
    else {
        die "invalid fold axis: $fold_axis\n";
    }

    my $total = scalar keys %$folded_dots;

    print "total dots after first fold: $total\n";
    

    last; # only first one
}

sub fold_x {
    my ($dots, $fold_x) = @_;
    my %new_dots;
    for my $k (keys %$dots) {
        my ($x, $y) = split(/\./, $k);

        if ($x <= $fold_x) {
            $new_dots{$k} = 1;
        } else {
            my $reflected_x = $fold_x - ($x - $fold_x);
            $new_dots{"$reflected_x.$y"} = 1;
        }
    }

    return \%new_dots;
}

sub fold_y {
    my ($dots, $fold_y) = @_;
    my %new_dots;
    for my $k (keys %$dots) {
        my ($x, $y) = split(/\./, $k);

        if ($y <= $fold_y) {
            $new_dots{$k} = 1;
        } else {
            my $reflected_y = $fold_y - ($y - $fold_y);
            $new_dots{"$x.$reflected_y"} = 1;
        }
    }

    return \%new_dots;
}


