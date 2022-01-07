#!/usr/bin/env perl

my $prev_line = <>;
chomp $prev_line;

my $count = 0;
for my $line (<>) {
	chomp $line;

	if ($line > $prev_line) {
		$count += 1;
	}

	$prev_line = $line;
}

print "$count\n";
