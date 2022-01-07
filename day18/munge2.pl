#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use POSIX qw(floor ceil);
use List::Util qw(max);

my @inputs;

while (my $line = <>) {
    chomp $line;
    my $num = snailfish_parse($line);
    push(@inputs, $num);
}

my $max_magnitude = 0;
for my $i (0..$#inputs) {
    for my $j (0..$#inputs) {
        my $m = snailfish_magnitude(snailfish_add($inputs[$i], $inputs[$j]));
        $max_magnitude = max($max_magnitude, $m);
    }
}

print "max magnitude: $max_magnitude\n";

sub snailfish_add {
    my ($a, $b) = @_;
    my $num = [$a, $b];
    return snailfish_reduce($num);
}

sub snailfish_reduce {
    my ($a) = @_;
    while (1) {
        my ($exploded_a, $left, $right, $done) = snailfish_explode($a, 0);
        if ($done) {
            $a = $exploded_a;
            next;
        }

        my ($split_a, $split_done) = snailfish_split($a);
        if ($split_done) {
            $a = $split_a;
            next;
        }

        return $a;
    }
}

sub snailfish_explode {
    my ($num, $depth) = @_;

    if (is_literal($num)) {
        return ($num, 0, 0, 0);
    }

    if ($depth == 4) {
        return (0, $num->[0], $num->[1], 1);
    }

    do {
        my ($new_a, $left, $right, $done) = snailfish_explode($num->[0], $depth + 1);
        if ($done) {
            return ([$new_a, snailfish_addfirst($num->[1], $right)], $left, 0, $done);
        }
    };

    do {
        my ($new_b, $left, $right, $done) = snailfish_explode($num->[1], $depth + 1);
        if ($done) {
            return ([snailfish_addlast($num->[0], $left), $new_b], 0, $right, $done);
        }
    };

    return ($num, 0, 0, 0);
}

sub is_literal {
    return not(ref(shift) eq "ARRAY");
}

sub snailfish_split {
    my ($num) = @_;

    if (is_literal($num)) {
        if ($num >= 10) {
            my $left = floor($num / 2);
            my $right = ceil($num / 2);
            return ([$left, $right], 1);
        }
        return ($num, 0);
    }
    
    do {
        my ($new_a, $done) = snailfish_split($num->[0]);
        if ($done) {
            return ([$new_a, $num->[1]], $done);
        }
    };

    do {
        my ($new_b, $done) = snailfish_split($num->[1]);
        if ($done) {
            return ([$num->[0], $new_b], $done);
        }
    };

    return ($num, 0);
}

sub snailfish_addfirst {
    my ($num, $literal) = @_;

    if (is_literal($num)) {
        return $num + $literal;
    }

    return [snailfish_addfirst($num->[0], $literal), $num->[1]];
}

sub snailfish_addlast {
    my ($num, $literal) = @_;

    if (is_literal($num)) {
        return $num + $literal;
    }

    return [$num->[0], snailfish_addlast($num->[1], $literal)];
}

sub snailfish_magnitude {
    my ($num) = @_;
    if (is_literal($num)) {
        return $num;
    }

    return (snailfish_magnitude($num->[0]) * 3) + (snailfish_magnitude($num->[1]) * 2);
}

sub snailfish_parse {
    my ($line) = @_;

    my @arr = split(//, $line);

    my $pair = snailfish_parse_pair(\@arr);
    die "not all input consumed" if scalar @arr > 0;

    return $pair;
}

sub snailfish_parse_pair {
    my ($arr) = @_;

    my $open = shift @$arr;
    die unless $open eq "[";

    my $elem1 = snailfish_parse_elem($arr);

    my $comma = shift @$arr;
    die unless $comma eq ",";

    my $elem2 = snailfish_parse_elem($arr);

    my $close = shift @$arr;
    die unless $close eq "]";

    return [$elem1, $elem2];
}

sub snailfish_parse_elem {
    my ($arr) = @_;
    if ($arr->[0] =~ /^\d$/) {
        my $elem = shift @$arr;
        return 0+$elem;
    }

    return snailfish_parse_pair($arr);
}

sub dd {
    local $Data::Dumper::Indent = 0;
    print Dumper(shift);
    print "\n";
}
