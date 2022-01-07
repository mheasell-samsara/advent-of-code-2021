#!/usr/bin/env perl

my $line1 = <>;
chomp $line1;
my $line2 = <>;
chomp $line2;
my $line3 = <>;
chomp $line3;

for my $line (<>) {
	chomp $line;

	my $sum = $line + $line2 + $line3;
	my $prev_sum = $line1 + $line2 + $line3;

	if ($sum > $prev_sum) {
		$count += 1;
	}

	$line1 = $line2;
	$line2 = $line3;
	$line3 = $line;
}

print "$count\n";
