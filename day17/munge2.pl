#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my $line = <>;
chomp $line;
$line =~ /^target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)$/ or die "invalid input";

my ($x1, $x2, $y1, $y2) = ($1, $2, $3, $4);

my @x_candidates = find_initial_velocities_x($x1, $x2);
my @y_candidates = find_initial_velocities_y($y1, $y2);

#print Dumper(\@x_candidates);
#print Dumper(\@y_candidates);

my %good_velocities;
for my $x_candidate (@x_candidates) {
    my ($x, $steps, $valid_forever_from) = @$x_candidate;
    for my $y_candidate (@y_candidates) {
        my ($y, $y_steps) = @$y_candidate;
        if (any_match($steps, $y_steps) || (defined $valid_forever_from && any_gte($y_steps, $valid_forever_from))) {
            $good_velocities{"$x,$y"} = 1;
        }
    }
}

#print Dumper(sort { $a cmp $b } keys %good_velocities);

my $count = scalar keys %good_velocities;
print "count: $count\n";

sub any_match {
    my ($a, $b) = @_;
    my %t = map { $_ => 1 } @$b;
    for my $k (@$a) {
        return 1 if $t{$k};
    }
    return 0;
}

sub any_gte {
    my ($arr, $num) = @_;
    for my $i (@$arr) {
        return 1 if $i >= $num;
    }
    return 0;
}

sub find_initial_velocities_y {
    my ($min_y, $max_y) = @_;
    my @out;

    my $min_initial_v = $min_y;
    my $max_initial_v = -$min_y + 1;
    for my $initial_v ($min_initial_v..$max_initial_v) {
        my @step_counts = y_steps_to_hit($initial_v, $min_y, $max_y);
        next unless scalar @step_counts > 0;
        push(@out, [$initial_v, \@step_counts]);
    }

    return @out;
}

sub find_initial_velocities_x {
    my ($min_x, $max_x) = @_;
    my @out;

    my $max_initial_v = $max_x;
    for my $initial_v (0..$max_initial_v) {
        my ($step_counts, $valid_forever_from) = x_steps_to_hit($initial_v, $min_x, $max_x);
        next unless scalar @$step_counts > 0;
        push(@out, [$initial_v, $step_counts, $valid_forever_from]);
    }

    return @out;
}

sub x_steps_to_hit {
    my ($v, $min_x, $max_x) = @_;
    my @out;
    my $step_count = 0;
    my $pos = 0;
    while ($pos <= $max_x) {
        if ($pos >= $min_x) {
            push(@out, $step_count);
        }
        if ($v == 0) {
            return (\@out, $step_count);
        }
        $pos += $v;
        $v -= 1;
        $step_count += 1;
    }

    return (\@out, undef);
}

sub y_steps_to_hit {
    my ($v, $min_y, $max_y) = @_;
    my @out;
    my $step_count = 0;
    my $pos = 0;
    while ($pos >= $min_y) {
        if ($pos <= $max_y) {
            push(@out, $step_count);
        }
        $pos += $v;
        $v -= 1;
        $step_count += 1;
    }
    return @out;
}
