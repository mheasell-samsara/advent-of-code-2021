#!/usr/bin/env perl

use warnings;
use strict;

my @bit_biases;

my $first_line = <>;
chomp $first_line;
while ($first_line =~ s/^(0|1)//) {
	push(@bit_biases, $1 == 0 ? -1 : 1);
}
die "unconsumed string on line $.: $first_line\n" if $first_line ne "";

for my $line (<>) {
	chomp $line;
	my $index = 0;
	while ($line =~ s/^(0|1)//) {
		die "line too long on line $.\n" if $index > $#bit_biases;
		$bit_biases[$index++] += $1 == 0 ? -1 : 1;
	}
	die "unconsumed string on line $.: $line\n" if $line ne "";
}

use Data::Dumper;
print Dumper(\@bit_biases);

for $b (@bit_biases) {
	die "zero bit bias\n" if $b == 0;
}

my @gamma_bits = map { $_ > 0 ? 1 : 0 } @bit_biases;
my $gamma = 0;
for my $i (0..$#gamma_bits) {
	$gamma += $gamma_bits[$i] << ($#gamma_bits - $i);
}

my @epsilon_bits = map { $_ > 0 ? 0 : 1 } @bit_biases;
my $epsilon = 0;
for my $i (0..$#epsilon_bits) {
	$epsilon += $epsilon_bits[$i] << ($#epsilon_bits - $i);
}

my $result = $gamma * $epsilon;

print "gamma: $gamma, epsilon: $epsilon, result: $result\n";


