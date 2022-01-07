#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use List::Util qw(sum product min max);

my %hex_table = (
    0 => "0000",
    1 => "0001",
    2 => "0010",
    3 => "0011",
    4 => "0100",
    5 => "0101",
    6 => "0110",
    7 => "0111",
    8 => "1000",
    9 => "1001",
    A => "1010",
    B => "1011",
    C => "1100",
    D => "1101",
    E => "1110",
    F => "1111",
);

my $input = <>;

chomp $input;

my @in_arr = split(//, $input);

@in_arr = map { split(//, $hex_table{$_}) } @in_arr;

my $result = decode_packet(\@in_arr);

print "result: $result\n";

sub decode_packet {
    my ($arr) = @_;
    my $version = decode_version($arr);
    my $type_id = decode_type_id($arr);

    print "packet version: $version, type_id: $type_id\n";

    if ($type_id == 4) {
        my $value = decode_literal($arr);
        print "literal: $value\n";
        return $value;
    }
    else {
        my @values = decode_operator($arr);
        if ($type_id == 0) { # sum
            return sum(@values);
        }
        if ($type_id == 1) { # product
            return product(@values);
        }
        if ($type_id == 2) { # min
            return min(@values);
        }
        if ($type_id == 3) { # max
            return max(@values);
        }
        if ($type_id == 5) { # greater than
            die "invalid" if (scalar @values) != 2;
            return $values[0] > $values[1] ? 1 : 0;
        }
        if ($type_id == 6) {
            die "invalid" if (scalar @values) != 2;
            return $values[0] < $values[1] ? 1 : 0;
        }
        if ($type_id == 7) {
            die "invalid" if (scalar @values) != 2;
            return $values[0] == $values[1] ? 1 : 0;
        }

        die "invalid type ID: $type_id";
    }
}

sub decode_version {
    my ($arr) = @_;
    return decode_num($arr, 3);
}

sub decode_type_id {
    my ($arr) = @_;
    return decode_num($arr, 3);
}

sub decode_literal {
    my ($arr) = @_;
    my $final_value = 0;
    while (1) {
        my ($prefix, $value) = decode_group($arr);
        $final_value = ($final_value << 4) | $value;
        last if $prefix == 0;
    }
    return $final_value;
}

sub decode_operator {
    my ($arr) = @_;
    my $length_type_id = shift @$arr;
    my @values;
    if ($length_type_id == 0) {
        my $len = decode_num($arr, 15);
        my $curr_len = scalar @$arr;
        while ($curr_len - (scalar @$arr) < $len) {
            push(@values, decode_packet($arr));
        }
    }
    elsif ($length_type_id == 1) {
        my $num_subpackets = decode_num($arr, 11);
        for (1..$num_subpackets) {
            push(@values, decode_packet($arr));
        }
    }
    else {
        die "bad length type id: $length_type_id";
    }
    
    return @values;
}

sub decode_group {
    my ($arr) = @_;
    my $prefix = shift @$arr;
    my $val = decode_num($arr, 4);
    return ($prefix, $val);
}

sub decode_num {
    my ($arr, $bit_length) = @_;
    my $val = 0;
    for (1..$bit_length) {
        $val = ($val << 1) | (shift @$arr);
    }
    return $val;
}
