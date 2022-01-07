#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use List::Util qw(max min);

my $template_str = <>;
chomp $template_str;
my @template_arr = split(//, $template_str);
my $template = \@template_arr;

<>;

my %rules;
while (my $line = <>) {
    chomp $line;
    $line =~ /^([A-Z][A-Z]) -> ([A-Z])$/ or die "invalid input on line $.\n";
    $rules{$1} = $2;
}

print Dumper(\%rules);

print "Initial state: ";
dd($template);

my %memo_table;

my %global_freq_table;
$global_freq_table{$template->[0]} += 1;
for my $i (1..$#$template) {
    my $prev = $template->[$i-1];
    my $curr = $template->[$i];

    $global_freq_table{$curr} += 1;

    my $freq_table = expand_rec($prev, $curr, 40, \%memo_table);
    merge_left(\%global_freq_table, $freq_table);
}

#print Dumper(\%memo_table);

my ($min_quant, $max_quant) = get_min_max_from_table(\%global_freq_table);

my $result = $max_quant - $min_quant;
print "result: $result\n";

sub expand_rec {
    my ($a, $b, $steps, $table) = @_;
    return {} if $steps == 0;
    my $expanded = $table->{"$a$b.$steps"};
    return $expanded if defined($expanded);

    my $insert = $rules{"$a$b"};

    my $freq_table_1 = expand_rec($a, $insert, $steps - 1, $table);
    my $freq_table_2 = expand_rec($insert, $b, $steps - 1, $table);

    my $out_table = combine_freq_tables($freq_table_1, $freq_table_2);
    $out_table->{$insert} += 1;

    $table->{"$a$b.$steps"} = $out_table;
    return $out_table;
}

sub merge_left {
    my ($a, $b) = @_;
    for my $k (keys %$b) {
        $a->{$k} += $b->{$k};
    }
}

sub combine_freq_tables {
    my ($a, $b) = @_;
    my %out;
    for my $k (keys %$a) {
        $out{$k} += $a->{$k};
    }
    for my $k (keys %$b) {
        $out{$k} += $b->{$k};
    }
    return \%out;
}

sub get_min_max_from_table {
    my ($freqs) = @_;

    my $max_quant;
    my $min_quant;

    for my $c (keys %$freqs) {
        my $val = $freqs->{$c};
        $max_quant = defined($max_quant) ? max($val, $max_quant) : $val;
        $min_quant = defined($min_quant) ? min($val, $min_quant) : $val;
    }

    return ($min_quant, $max_quant);
}

sub dd {
    my ($a) = @_;
    print join("", @$a);
    print "\n";
}
