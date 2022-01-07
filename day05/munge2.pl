#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw(max);

my @lines;

while (my $line = <>) {
    chomp $line;

    $line =~ /(\d+),(\d+) -> (\d+),(\d+)/ or die "invalid line $.\n";

    my ($x1, $y1, $x2, $y2) = ($1, $2, $3, $4);

    push(@lines, {start=>[$x1,$y1], end=>[$x2,$y2]});
}

my $max_x = 0;
my $max_y = 0;
for my $line (@lines) {
    $max_x = max($max_x, $line->{start}[0], $line->{end}[0]);
    $max_y = max($max_y, $line->{start}[1], $line->{end}[1]);
}

my $width = $max_x + 1;
my $max_len = ($max_x + 1) * ($max_y + 1);

my @bitmap = (0) x $max_len;

for my $line (@lines) {
    if ($line->{start}[0] == $line->{end}[0]) {
        # line is vertical
        my $x = $line->{start}[0];
        my $y1 = $line->{start}[1];
        my $y2 = $line->{end}[1];
        if ($y1 > $y2) {
            ($y1, $y2) = ($y2, $y1);
        }
        for (my $y = $y1; $y <= $y2; ++$y) {
            $bitmap[($width * $y) + $x] += 1;
        }
    }
    elsif ($line->{start}[1] == $line->{end}[1]) {
        # line is horizontal
        my $y = $line->{start}[1];
        my $x1 = $line->{start}[0];
        my $x2 = $line->{end}[0];
        if ($x1 > $x2) {
            ($x1, $x2) = ($x2, $x1);
        }
        for (my $x = $x1; $x <= $x2; ++$x) {
            $bitmap[($width * $y) + $x] += 1;
        }
    }
    else {
        # line is diagonal
        my $x1 = $line->{start}[0];
        my $x2 = $line->{end}[0];

        my $y1 = $line->{start}[1];
        my $y2 = $line->{end}[1];

        if ($x1 > $x2) {
            ($x1, $x2) = ($x2, $x1);
            ($y1, $y2) = ($y2, $y1);
        }

        my $y_inc = $y1 <$y2 ? 1 : -1;

        my $y = $y1;

        for (my $x = $x1; $x <= $x2; ++$x) {
            $bitmap[($width * $y) + $x] += 1;
            $y += $y_inc;
        }
    }
}

for my $y (0..$max_y) {
    for my $x (0..$max_x) {
        my $val = $bitmap[($width * $y) + $x];
        print "$val";
    }
    print "\n";
}

my $count = 0;

for my $c (@bitmap) {
    $count += 1 if $c > 1;
}

print "overlapping cells: $count\n";

#print Dumper(\@lines);
