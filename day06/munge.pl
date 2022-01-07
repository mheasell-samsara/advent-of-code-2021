#!/usr/bin/env perl

use strict;
use warnings;

my $line = <>;

my @fishes = split(/,/, $line);

for my $i (1..80) {
	my $new_fishes = 0;
	for my $i (0..$#fishes) {
		if ($fishes[$i] == 0) {
			$new_fishes += 1;
			$fishes[$i] = 6;
		}
		else {
			$fishes[$i] -= 1;
		}
	}
	push(@fishes, (8) x $new_fishes);

	my $str = join(",", @fishes);
	print "After $i days: $str\n";
}

my $count = scalar @fishes;

print "Total fishes: $count\n";
