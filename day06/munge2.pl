#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my $line = <>;
chomp $line;

my @fishes_input = split(/,/, $line);

@fishes_input = sort { $a <=> $b } @fishes_input;

my $fishes = to_rle(\@fishes_input);

print "initial state\n";
print_rle($fishes);

for my $i (0..255) {
	my $due_fishes = $fishes->[0];
	my ($val, $count) = @$due_fishes;

	if ($val == $i) {
		shift @$fishes;
		insert_rle($fishes, $i+7, $count);
		insert_rle($fishes, $i+9, $count);
	}

	#my $day_count = $i + 1;
	#print "after $day_count days\n";
	#print_rle($fishes);
}

my $count = sum_rle($fishes);

print "Total fishes: $count\n";

sub sum_rle {
	my ($arr) = @_;
	my $sum = 0;
	for my $elem (@$arr) {
		$sum += $elem->[1];
	}
	return $sum;
}

sub insert_rle {
	my ($arr, $val, $count) = @_;

	# could be binary search for more speed
	for my $i (0..$#$arr) {
		my $elem = $arr->[$i];
		if ($elem->[0] == $val) {
			$elem->[1] += $count;
			return;
		}
		if ($elem->[0] > $val) {
			splice(@$arr, $i, 0, [$val, $count]);
			return;
		}
	}

	push(@$arr, [$val, $count]);
}

sub to_rle {
	my ($arr) = @_;

	my @rle_arr;
	while (my $rle = next_rle($arr)) {
		push(@rle_arr, $rle);
	}

	return \@rle_arr;
}

sub next_rle {
	my ($arr) = @_;
	if (scalar @$arr == 0) {
		return undef;
	}

	my $count = 1;
	my $val = shift @$arr;

	while (scalar @$arr != 0) {
		last if $arr->[0] != $val;
		shift @$arr;
		$count += 1;
	}

	return [$val, $count];
}

sub dump_rle {
	my ($arr) = @_;
	local $Data::Dumper::Indent = 0;
	return Dumper($arr);
}

sub print_rle {
	my ($arr) = @_;
	my $s = dump_rle($arr);
	print "$s\n";
}
