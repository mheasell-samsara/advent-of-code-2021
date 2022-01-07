#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my @bit_biases;

my @all_lines = <>;
chomp for (@all_lines);

sub get_bit_bias {
	my ($pos, $bit_strings) = @_;
	my $bias = 0;
	for my $str (@$bit_strings) {
		my $bit = substr($str, $pos, 1);
		if ($bit eq "1") {
			$bias += 1;
		} elsif ($bit eq "0") {
			$bias -= 1;
		} else {
			die "invalid bit: $bit";
		}
	}
	return $bias;
}

sub to_number {
	my ($bits_list) = @_;
	my $num = 0;
	for my $i (0...$#$bits_list) {
		$num += $bits_list->[$i] << ($#$bits_list - $i);
	}
	return $num;
}

my @oxygen_lines = @all_lines;
do {
	my $current_bit = 0;
	while (scalar @oxygen_lines > 1) {
		my $bias = get_bit_bias($current_bit, \@oxygen_lines);
		my $needed_bit = $bias >= 0 ? "1" : "0";
		@oxygen_lines = grep { substr($_, $current_bit, 1) eq $needed_bit } @oxygen_lines;
		$current_bit += 1;
	}
	die "value not found\n" if scalar @oxygen_lines != 1;
};

my @oxygen_bits = split("", $oxygen_lines[0]);
my $oxygen_num = to_number(\@oxygen_bits);

my @co2_lines = @all_lines;
do {
	my $current_bit = 0;
	while (scalar @co2_lines > 1) {
		my $bias = get_bit_bias($current_bit, \@co2_lines);
		my $needed_bit = $bias >= 0 ? "0" : "1";
		@co2_lines = grep { substr($_, $current_bit, 1) eq $needed_bit } @co2_lines;
		$current_bit += 1;
	}
	die "value not found\n" if scalar @co2_lines != 1;
};

my @co2_bits = split("", $co2_lines[0]);
my $co2_num = to_number(\@co2_bits);

my $result = $oxygen_num * $co2_num;

print "oxygen: $oxygen_num, co2: $co2_num, result: $result\n";



