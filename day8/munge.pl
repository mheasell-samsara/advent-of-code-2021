#!/usr/bin/env perl

use warnings;
use strict;

my $count = 0;

while (my $line = <>) {

	chomp $line;
	my ($signals_str, $output_str) = split(/\s*\|\s*/, $line, 2);
	
	my @signal_words = split(/\s+/, $signals_str);
	die if scalar @signal_words != 10;

	my @output_words = split(/\s+/, $output_str);
	die if scalar @output_words != 4;

	for my $word (@output_words) {
		my $len = length($word);
		if ($len == 2 || $len == 3 || $len == 4 || $len == 7) {
			$count += 1;
		}
	}
}

print "count: $count\n";

